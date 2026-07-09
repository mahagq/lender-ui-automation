*** Settings ***
Documentation
...    Smoke E2E — complete customer journey from Login → Lender → KYC DB bypass → eSign.
...
...    Flow:
...      Login → Dashboard → Student Details → Choose Plan → Select Applicant →
...      Basic Details → Onboarding → Personal Details → Residential Details →
...      Employment (Salaried) → Confirm Application → Lender Selection →
...      KYC DB bypass (inserts mock records) → eSign page
...
...    Lender is DYNAMIC:
...      - Set LENDER_NAME in variables/variables.robot  e.g. "CSB Bank"
...      - Leave blank to auto-select first available lender
...
...    Requires .env.db in project root with DB credentials for KYC bypass.
...
...    Run:
...      robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot

Library     ../../libraries/ApplicationDataReader.py
Library     ../../libraries/kyc_bypass_db.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../resources/LenderSelectionPage.robot
Resource    ../../resources/OKYCPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Test Tags   e2e    smoke

*** Test Cases ***
Smoke E2E Full Journey — Login To eSign
    [Documentation]
    ...    Complete happy-path journey: new user, salaried, Parent/Guardian.
    ...    Mobile auto-generated each run. Lender from LENDER_NAME variable.
    ...    KYC is bypassed via DB insert — no Digilocker redirect needed.
    [Teardown]    Print Journey Summary
    ${app_id}=    Perform KYC Bypass Journey
    ...    journey_type=new
    ...    lender_name=${LENDER_NAME}
    Log    ✅ Full journey complete — eSign signed, down payment paid    console=True
