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

_OKYC_KYC_PROVIDER = "westcap"
_OKYC_REFERENCE_ID = "CRN260510163236510YW"
_OKYC_TRANSACTION_ID = "CRN260510163236510YW"
_OKYC_MASKED_AADHAAR = "xxxxxxxx6720"
_OKYC_NAME = "MAMANI DAS"
_OKYC_GENDER = "FEMALE"
_OKYC_DOB = "13-04-1989"
_OKYC_ADDRESS = json.dumps({
    "house": "D/O Ahmed Darvesh,Flat No-402 A/Wing Vohra Galaxy",
    "street": "Santacruz East,Near ICICI Bank,Mumbai,Mumbai,Vidyanagari,Mumbai,Maharashtra,400098",
    "landmark": "",
    "loc": "Vidyanagari",
    "po": "Mumbai",
    "dist": "Mumbai",
    "subdist": "Mumbai",
    "vtc": "Mumbai",
    "pc": "400098",
    "state": "Maharashtra",
    "country": "",
})
_OKYC_PHOTO_URL = (
    "https://gq-uat-media.s3.ap-south-1.amazonaws.com/customer_documents/"
    "cb41de7b-d582-4276-ace2-eefce1e089e8/okyc/9218bd6a-18ff-42e2-9f4e-0c0d44774cf6.jpg"
)
_OKYC_XML_URL = (
    "https://gq-uat-media.s3.ap-south-1.amazonaws.com/customer_documents/"
    "cb41de7b-d582-4276-ace2-eefce1e089e8/okyc/offline_xml.zip"
)
_OKYC_PASS_CODE = "1234"
_OKYC_XML_VALID = "TRUE"
_OKYC_STATUS = "SUCCESS"
_OKYC_RAW_ADDRESS = (
    "D/O Ahmed Darvesh,Flat No-402 A/Wing Vohra Galaxy,Kalina Kurla Road,"
    "Santacruz East,Near ICICI Bank,Mumbai,Mumbai,Vidyanagari,Mumbai,Maharashtra,400098"
)


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
def bypass_kyc_via_database(mobile: str, app_id=None):
    """
    Inserts mock KYC data into DB to skip Digilocker step on UAT.

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
                    NULL, %s, %s, %s, %s,
                    %s, %s, %s, %s, %s,
                    %s, 1, NULL, %s
                )
                """,
                (
                    customer_id,
                    _OKYC_KYC_PROVIDER,
                    _OKYC_REFERENCE_ID,
                    _OKYC_TRANSACTION_ID,
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

            # 6. Insert gq_application_compliance_mapping
            cur.execute(
                """
                INSERT INTO gq_migrate.gq_application_compliance_mapping (
                    code, application_id, customer_id, lender_id, vendor_id,
                    kyc_type, kyc_detail_id, is_active, deleted_on
                ) VALUES (UUID(), %s, %s, 34, 1, 'OKYC', %s, 1, NULL)
                """,
                (app_id, customer_id, okyc_id),
            )
            logger.info(f"KYC bypass: inserted compliance_mapping for app_id={app_id}")

        conn.commit()
        logger.info("KYC bypass: DB transaction committed successfully")

    except Exception as exc:
        conn.rollback()
        raise RuntimeError(f"KYC DB bypass transaction rolled back: {exc}") from exc
    finally:
        conn.close()
