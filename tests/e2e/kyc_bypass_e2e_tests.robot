*** Settings ***
Documentation
...    KYC bypass E2E tests.
...    Approach: when browser lands on /okyc/{app_id}, a Python DB script inserts mock KYC records
...    (gq_okyc_details, customer_tracker × 2, gq_application_compliance_mapping), then page reloads
...    to /esign/{app_id} — bypassing the Digilocker third-party redirect entirely.
...    Requires .env.db in project root with DB_HOST, DB_USER, DB_PASSWORD, DB_NAME.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags    kyc-bypass    regression    lender-selection-e2e
...    allure.label.epic:CP UI Automation
...    allure.label.feature:KYC Bypass


*** Test Cases ***
TC-KYC-E01: New App - KYC Bypass Via DB Script
    [Documentation]
    ...    Full 13-step wizard (dynamic fresh mobile) → plan 1 → Western Capital lender → BRE APPROVED
    ...    → lands on /okyc/{app_id} → DB script inserts mock KYC → reload → asserts /esign/{app_id}.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Perform KYC Bypass Journey    journey_type=new

TC-KYC-E02: Renewal App - KYC Bypass Via DB Script
    [Documentation]
    ...    Renewal flow (${RENEWAL_MOBILE}) → plan 1 → Western Capital lender → BRE APPROVED
    ...    → lands on /okyc/{app_id} → DB script inserts mock KYC → reload → asserts /esign/{app_id}.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Perform KYC Bypass Journey    journey_type=renewal
