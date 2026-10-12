"""
kyc_bypass_db — Robot Framework keyword library (module-level functions).
Provides Bypass KYC Via Database keyword for UAT KYC step bypass.
"""

import json
import os
import sys

# Ensure the libraries/ directory is on sys.path so db_config is importable.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import pymysql
import pymysql.cursors
from robot.api.deco import keyword
from robot.api import logger

from db_config import get_db_config

ROBOT_LIBRARY_SCOPE = "GLOBAL"

# kyc_provider must match the lender that was selected in the journey.
# Resolved from the lender name via _resolve_kyc_provider(); anything unmapped → gq-credentials.
_DEFAULT_KYC_PROVIDER = "gq-credentials"
# vendor_id fallback when a lender has no kyc_lender_vendor_mapping row (vendor 1 = common default).
_DEFAULT_VENDOR_ID = 1
_PROVIDER_KEYWORDS = (
    ("csb", "csb"),          # CSB Bank
    ("tata", "tcl"),         # Tata Capital Limited
    ("tcl", "tcl"),
    ("mirae", "mirae"),      # Mirae
    ("western", "westcap"),  # Western Capital
    ("westcap", "westcap"),
)

# Maps lender display names (as passed by tests) to the exact name stored in gq_internal_lender_master.
# Add an entry whenever the UI name differs from the DB name.
_DB_LENDER_NAME_MAP = {
    "ratnaafin capital": "RCPL",
    "ratnaafin": "RCPL",
    "rcpl": "RCPL",
    "mirae asset": "Mirae",
    "mirae": "Mirae",
}


def _resolve_kyc_provider(lender_name):
    """Maps a lender display name to its kyc_provider code. Unmapped → gq-credentials."""
    if not lender_name:
        return _DEFAULT_KYC_PROVIDER
    name = str(lender_name).strip().lower()
    for keyword_text, provider in _PROVIDER_KEYWORDS:
        if keyword_text in name:
            return provider
    return _DEFAULT_KYC_PROVIDER


_OKYC_REFERENCE_ID = "CSB231173846"
_OKYC_TRANSACTION_ID = "003969"
_OKYC_AADHAAR = "269922040700"
_OKYC_MASKED_AADHAAR = "XXXX-XXXX-0700"
_OKYC_NAME = "Mahalakshmi Kumaresan Thevar"
_OKYC_GENDER = "FEMALE"
_OKYC_DOB = "03-09-1996"
_OKYC_ADDRESS = json.dumps({
    "house": "Tower A-605, Ritz Life",
    "street": "Panhalgad Chs Ltd, Shree Complex",
    "landmark": "Kalyan West",
    "loc": "Adharwadi Jail Road, Above Oasis Hospital",
    "po": "Kalyan D.c.",
    "dist": "Thane",
    "subdist": "",
    "vtc": "Kalyan",
    "pc": "421301",
    "state": "Maharashtra",
    "country": "India",
})
_OKYC_PHOTO_URL = (
    "https://gq-uat-media.s3.ap-south-1.amazonaws.com/customer_documents/"
    "cef2ef3b-da95-4cb4-b766-bc83a4bf8ae3/okyc/de46f239-2650-4b61-bf48-140204c318a7_csb.jpg"
)
_OKYC_XML_URL = (
    "https://gq-uat-media.s3.ap-south-1.amazonaws.com/customer_documents/"
    "cef2ef3b-da95-4cb4-b766-bc83a4bf8ae3/okyc/de46f239-2650-4b61-bf48-140204c318a7_csb.xml"
)
_OKYC_PASS_CODE = ""
_OKYC_XML_VALID = ""
_OKYC_STATUS = "SUCCESS"
_OKYC_RAW_ADDRESS = ""


def _connect():
    config = get_db_config()
    return pymysql.connect(
        host=config["host"],
        user=config["user"],
        password=config["password"],
        db=config["db"],
        charset="utf8mb4",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False,
    )


@keyword("Bypass KYC Via Database")
def bypass_kyc_via_database(mobile: str, app_id=None, lender_name=None):
    """
    Inserts mock KYC data into DB to skip Digilocker step on UAT.
    kyc_provider is derived from lender_name (csb/tcl/mirae/westcap, else gq-credentials).

    Steps (single transaction):
      1. mobile → customer_id  (gq_customer_auth)
      2. mobile → app_id       (basic_info, latest row) — used only if app_id arg is None
      3. Soft-delete existing  (gq_okyc_details for this customer)
      4. Insert gq_okyc_details → capture okyc_id
      5. Insert customer_tracker × 2  (okyc-completed, kyc-completed)
      6. Insert gq_application_compliance_mapping

    Args:
        mobile:  mobile number used to create the application
        app_id:  application id extracted from /okyc/{app_id} URL; resolved from basic_info if None
    """
    kyc_provider = _resolve_kyc_provider(lender_name)
    logger.info(f"KYC bypass: lender_name={lender_name!r} -> kyc_provider={kyc_provider}")

    conn = _connect()
    try:
        with conn.cursor() as cur:
            # 1. customer_id from gq_customer_auth
            cur.execute(
                "SELECT id FROM gq_migrate.gq_customer_auth WHERE mobile = %s",
                (mobile,),
            )
            auth_row = cur.fetchone()
            if not auth_row:
                raise RuntimeError(
                    f"Bypass KYC failed: no customer in gq_customer_auth for mobile={mobile}"
                )
            customer_id = auth_row["id"]
            logger.info(f"KYC bypass: customer_id={customer_id} for mobile={mobile}")

            # 2. app_id from basic_info (latest) — use URL-extracted value if provided
            if not app_id:
                cur.execute(
                    "SELECT id FROM gq_migrate.basic_info WHERE mobile = %s ORDER BY id DESC LIMIT 1",
                    (mobile,),
                )
                bi_row = cur.fetchone()
                if not bi_row:
                    raise RuntimeError(
                        f"Bypass KYC failed: no application in basic_info for mobile={mobile}"
                    )
                app_id = bi_row["id"]
            logger.info(f"KYC bypass: app_id={app_id}")

            # 3. Soft-delete existing okyc_details for this customer
            cur.execute(
                "UPDATE gq_migrate.gq_okyc_details "
                "SET deleted_on = NOW() "
                "WHERE customer_id = %s AND deleted_on IS NULL",
                (customer_id,),
            )
            logger.info(f"KYC bypass: soft-deleted {cur.rowcount} existing okyc_details row(s)")

            # 4. Insert gq_okyc_details
            cur.execute(
                """
                INSERT INTO gq_migrate.gq_okyc_details (
                    code, customer_id, kyc_provider, reference_id, transaction_id,
                    aadhaar, masked_aadhaar, name, gender, dob,
                    address, photo_url, xml_url, pass_code, xml_valid,
                    status, is_active, deleted_on, raw_address
                ) VALUES (
                    UUID(), %s, %s, %s, %s,
                    %s, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s,
                    %s, 1, NULL, %s
                )
                """,
                (
                    customer_id,
                    kyc_provider,
                    _OKYC_REFERENCE_ID,
                    _OKYC_TRANSACTION_ID,
                    _OKYC_AADHAAR,
                    _OKYC_MASKED_AADHAAR,
                    _OKYC_NAME,
                    _OKYC_GENDER,
                    _OKYC_DOB,
                    _OKYC_ADDRESS,
                    _OKYC_PHOTO_URL,
                    _OKYC_XML_URL,
                    _OKYC_PASS_CODE,
                    _OKYC_XML_VALID,
                    _OKYC_STATUS,
                    _OKYC_RAW_ADDRESS,
                ),
            )
            okyc_id = cur.lastrowid
            logger.info(f"KYC bypass: inserted gq_okyc_details id={okyc_id}")

            # 5. Insert customer_tracker (both slugs in one multi-row INSERT)
            cur.execute(
                """
                INSERT INTO gq_migrate.customer_tracker
                    (application_id, cfd_id, cfd_part_id, slug, deleted_on)
                VALUES
                    (%s, NULL, NULL, 'okyc-completed', NULL),
                    (%s, NULL, NULL, 'kyc-completed', NULL)
                """,
                (app_id, app_id),
            )
            logger.info(f"KYC bypass: inserted customer_tracker slugs for app_id={app_id}")

            # 6. Resolve lender_id from the lender master by name (must match selected lender)
            if not lender_name:
                raise RuntimeError(
                    "Bypass KYC failed: lender_name is required to resolve lender_id "
                    "for gq_application_compliance_mapping."
                )
            db_lender_name = _DB_LENDER_NAME_MAP.get(str(lender_name).strip().lower(), lender_name)
            cur.execute(
                "SELECT id FROM gq_migrate.gq_internal_lender_master "
                "WHERE name = %s AND deleted_on IS NULL ORDER BY id DESC LIMIT 1",
                (db_lender_name,),
            )
            lender_row = cur.fetchone()
            if not lender_row:
                raise RuntimeError(
                    f"Bypass KYC failed: no lender in gq_internal_lender_master "
                    f"for name={db_lender_name!r} (original: {lender_name!r})"
                )
            lender_id = lender_row["id"]
            logger.info(f"KYC bypass: lender_id={lender_id} for lender_name={lender_name!r}")

            # 7. Resolve vendor_id from the lender↔vendor mapping (varies per lender, e.g. CSB=2)
            cur.execute(
                "SELECT vendor_id FROM gq_migrate.kyc_lender_vendor_mapping "
                "WHERE lender_id = %s AND is_active = 1 AND deleted_on IS NULL "
                "ORDER BY id DESC LIMIT 1",
                (lender_id,),
            )
            vendor_row = cur.fetchone()
            if vendor_row:
                vendor_id = vendor_row["vendor_id"]
                logger.info(f"KYC bypass: vendor_id={vendor_id} for lender_id={lender_id}")
            else:
                # Some lenders (e.g. Ratnaafin Lite=186) have no kyc_lender_vendor_mapping row.
                # Fall back to vendor 1 — the default used by the rest of that lender family.
                vendor_id = _DEFAULT_VENDOR_ID
                logger.warn(
                    f"KYC bypass: no vendor mapping for lender_id={lender_id} "
                    f"({lender_name!r}); defaulting vendor_id={vendor_id}"
                )

            # 8. Insert gq_application_compliance_mapping
            cur.execute(
                """
                INSERT INTO gq_migrate.gq_application_compliance_mapping (
                    code, application_id, customer_id, lender_id, vendor_id,
                    kyc_type, kyc_detail_id, is_active, deleted_on
                ) VALUES (UUID(), %s, %s, %s, %s, 'OKYC', %s, 1, NULL)
                """,
                (app_id, customer_id, lender_id, vendor_id, okyc_id),
            )
            logger.info(f"KYC bypass: inserted compliance_mapping for app_id={app_id}")

        conn.commit()
        logger.info("KYC bypass: DB transaction committed successfully")

    except Exception as exc:
        conn.rollback()
        raise RuntimeError(f"KYC DB bypass transaction rolled back: {exc}") from exc
    finally:
        conn.close()


# Reusable UAT document images (from app 901433 — existing accepted records).
_DOC_BUCKET = "gq-customer-loan-doc"
_SELFIE_URL = (
    "https://gq-customer-loan-documents-sandbox.s3.ap-south-1.amazonaws.com/"
    "media/application_documents/901433/ApplicantSelfie_1778152867.jpeg"
)
_SELFIE_PATH = "media/application_documents/901433/ApplicantSelfie_1778152867.jpeg"
_SELFIE_MIME = "image/jpeg"
_SELFIE_DOC_MASTER_ID = 26  # "Applicant Selfie" (postloan, salaried)

_ADDRESS_PROOF_URL = (
    "https://gq-customer-loan-documents-sandbox.s3.ap-south-1.amazonaws.com/"
    "media/application_documents/901433/ElectricityBill_1778152914.pdf"
)
_ADDRESS_PROOF_PATH = "media/application_documents/901433/ElectricityBill_1778152914.pdf"
_ADDRESS_PROOF_MIME = "application/pdf"
_ADDRESS_PROOF_DOC_MASTER_ID = 234  # Address proof / Electricity Bill

# All customer_tracker slugs to insert after eNACH (father-name-added handled via UI).
_POST_ENACH_SLUGS = [
    "faceid-completed",
    "selfie-completed",
    "insurance-not-interested",
    "insurance-step-completed",
    "address-proof-uploaded",
]


def _insert_doc_if_missing(cur, app_id, doc_master_id, url, path, mime):
    cur.execute(
        "SELECT id FROM gq_migrate.application_document_mapping "
        "WHERE application_id = %s AND document_master_id = %s AND deleted_on IS NULL LIMIT 1",
        (app_id, doc_master_id),
    )
    if cur.fetchone():
        logger.info(f"Selfie bypass: doc {doc_master_id} already present for app_id={app_id}")
        return
    cur.execute(
        """
        INSERT INTO gq_migrate.application_document_mapping
            (code, application_id, document_master_id, document_url,
             bucket_name, file_path, mime_type, status, is_active, deleted_on)
        VALUES (UUID(), %s, %s, %s, %s, %s, %s, 'ACCEPTED', 1, NULL)
        """,
        (app_id, doc_master_id, url, _DOC_BUCKET, path, mime),
    )
    logger.info(f"Selfie bypass: inserted doc {doc_master_id} for app_id={app_id}")


def _insert_slug_if_missing(cur, app_id, slug):
    cur.execute(
        "SELECT id FROM gq_migrate.customer_tracker "
        "WHERE application_id = %s AND slug = %s AND deleted_on IS NULL LIMIT 1",
        (app_id, slug),
    )
    if cur.fetchone():
        logger.info(f"Selfie bypass: slug '{slug}' already present for app_id={app_id}")
        return
    cur.execute(
        "INSERT INTO gq_migrate.customer_tracker "
        "(application_id, cfd_id, cfd_part_id, slug, deleted_on) "
        "VALUES (%s, NULL, NULL, %s, NULL)",
        (app_id, slug),
    )
    logger.info(f"Selfie bypass: inserted slug '{slug}' for app_id={app_id}")


@keyword("Bypass Selfie Via Database")
def bypass_selfie_via_database(app_id):
    """
    Bypasses all post-eNACH steps via customer_tracker slugs only (tracker-only
    convention — document_master_id values differ per DB instance/environment and
    aren't worth chasing; the loan-execution-guard routes purely on tracker state):
      - faceid-completed
      - selfie-completed
      - insurance-not-interested
      - insurance-step-completed
      - address-proof-uploaded

    Args:
        app_id: application id.
    """
    if not app_id:
        raise RuntimeError("Bypass Selfie failed: app_id is required")

    conn = _connect()
    try:
        with conn.cursor() as cur:
            for slug in _POST_ENACH_SLUGS:
                _insert_slug_if_missing(cur, app_id, slug)

        conn.commit()
        logger.info(f"Selfie bypass: all post-eNACH tracker slugs committed for app_id={app_id}")
    except Exception as exc:
        conn.rollback()
        raise RuntimeError(f"Selfie DB bypass rolled back: {exc}") from exc
    finally:
        conn.close()


@keyword("Bypass Address Proof Via Database")
def bypass_address_proof_via_database(app_id):
    """
    Minimal bypass for the /upload-address-proof step — inserts ONLY the
    'address-proof-uploaded' customer_tracker slug, nothing else (no document
    record). Note: this page has no self-redirect guard (confirmed from
    use-upload-address-proof-page.ts — it reads the tracker into local state but
    never acts on it), so the caller must still navigate away explicitly after
    this; a reload of the same URL will not skip it.

    Args:
        app_id: application id.
    """
    if not app_id:
        raise RuntimeError("Bypass Address Proof failed: app_id is required")

    conn = _connect()
    try:
        with conn.cursor() as cur:
            _insert_slug_if_missing(cur, app_id, "address-proof-uploaded")
        conn.commit()
        logger.info(f"Address proof bypass: inserted tracker for app_id={app_id}")
    except Exception as exc:
        conn.rollback()
        raise RuntimeError(f"Address proof DB bypass rolled back: {exc}") from exc
    finally:
        conn.close()


# Mandate (eNACH) bypass — team-confirmed UAT fixture convention, five steps:
#   1. cfd_id      = gq_internal_old_application_cfd_mapping.cfd_id for this app_id
#   2. customer_id = gq_customer_auth.id for this mobile
#   3. Duplicate gq_customer_mandate_details template row (id=3999) into a NEW row,
#      customer_id overridden — a fresh row avoids mutating the shared template
#      when runs are parallel.
#   4. Insert gq_customer_fd_cmd_mapping (cfd_id, cmd_id=<new row's id>).
#   5. Insert customer_tracker 'emandate-completed' then 'mandate-completed' —
#      the same slugs the FE itself sets after a real Digio/RPD mandate completes
#      (tracker.types.ts MandateTrackerSlug, mandate-fetch.ts completeMandate()),
#      mirroring the OKYC/selfie bypass mechanism.
_MANDATE_TEMPLATE_CMD_ID = 3999
_MANDATE_SLUGS = ["emandate-completed", "mandate-completed"]


@keyword("Bypass Mandate Via Database")
def bypass_mandate_via_database(mobile, app_id):
    """
    Bypasses the /mandate (eNACH) step via the real backend tables plus the
    frontend tracker state, so the app genuinely sees a completed mandate.
    See module-level _MANDATE_* comment above for the five-step sequence.

    After this, reload /mandate/{app_id} (or navigate to /selfie/{app_id} directly) —
    the app will see a real completed mandate and the frontend's tracker-based
    routing guard will skip past the mandate UI.

    Args:
        mobile: mobile number used to create the application (resolves customer_id).
        app_id: application id (resolves cfd_id).
    """
    if not app_id:
        raise RuntimeError("Bypass Mandate failed: app_id is required")
    if not mobile:
        raise RuntimeError("Bypass Mandate failed: mobile is required")

    conn = _connect()
    try:
        with conn.cursor() as cur:
            # 1. cfd_id for this application
            cur.execute(
                "SELECT cfd_id FROM gq_migrate.gq_internal_old_application_cfd_mapping "
                "WHERE application_id = %s ORDER BY id DESC LIMIT 1",
                (app_id,),
            )
            cfd_row = cur.fetchone()
            if not cfd_row:
                raise RuntimeError(
                    f"Bypass Mandate failed: no cfd_id in "
                    f"gq_internal_old_application_cfd_mapping for application_id={app_id}"
                )
            cfd_id = cfd_row["cfd_id"]
            logger.info(f"Mandate bypass: cfd_id={cfd_id} for app_id={app_id}")

            # 2. customer_id for this mobile
            cur.execute(
                "SELECT id FROM gq_migrate.gq_customer_auth WHERE mobile = %s",
                (mobile,),
            )
            auth_row = cur.fetchone()
            if not auth_row:
                raise RuntimeError(
                    f"Bypass Mandate failed: no customer in gq_customer_auth for mobile={mobile}"
                )
            customer_id = auth_row["id"]
            logger.info(f"Mandate bypass: customer_id={customer_id} for mobile={mobile}")

            # 3. Duplicate the template mandate record (id=3999) into a new row,
            #    overriding customer_id — never UPDATE the template row itself.
            cur.execute(
                "SELECT * FROM gq_migrate.gq_customer_mandate_details WHERE id = %s",
                (_MANDATE_TEMPLATE_CMD_ID,),
            )
            template_row = cur.fetchone()
            if not template_row:
                raise RuntimeError(
                    f"Bypass Mandate failed: template row id={_MANDATE_TEMPLATE_CMD_ID} "
                    "not found in gq_customer_mandate_details"
                )
            new_row = dict(template_row)
            new_row.pop("id", None)
            new_row["customer_id"] = customer_id
            columns = list(new_row.keys())
            placeholders = ", ".join(["%s"] * len(columns))
            column_list = ", ".join(f"`{c}`" for c in columns)
            cur.execute(
                f"INSERT INTO gq_migrate.gq_customer_mandate_details ({column_list}) "
                f"VALUES ({placeholders})",
                tuple(new_row[c] for c in columns),
            )
            new_cmd_id = cur.lastrowid
            logger.info(
                f"Mandate bypass: duplicated template cmd_id={_MANDATE_TEMPLATE_CMD_ID} "
                f"-> new cmd_id={new_cmd_id} for customer_id={customer_id}"
            )

            # 4. Map this application's cfd_id to the new mandate record.
            cur.execute(
                "INSERT INTO gq_migrate.gq_customer_fd_cmd_mapping (cfd_id, cmd_id) "
                "VALUES (%s, %s)",
                (cfd_id, new_cmd_id),
            )
            logger.info(f"Mandate bypass: mapped cfd_id={cfd_id} -> cmd_id={new_cmd_id}")

            # 5. Frontend tracker state — matches what completeMandate() itself sets.
            for slug in _MANDATE_SLUGS:
                _insert_slug_if_missing(cur, app_id, slug)

        conn.commit()
        logger.info(f"Mandate bypass: all records committed for app_id={app_id}")
    except Exception as exc:
        conn.rollback()
        raise RuntimeError(f"Mandate DB bypass rolled back: {exc}") from exc
    finally:
        conn.close()
