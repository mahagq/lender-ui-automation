*** Settings ***
Documentation
...    E2E journey tests from login through to the Agreement/Esign page.
...    Each test owns its own browser session (fresh mobile per test).
...
...    TC-ESIGN-E01 — New application (dynamic fresh mobile): login → full wizard →
...                   plan 1 → Western Capital → KYC bypass → /esign/{app_id}
...    TC-ESIGN-E02 — Renewal application (${RENEWAL_MOBILE}): login → renewal wizard →
...                   plan 1 → Western Capital → KYC bypass → /esign/{app_id}

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags    agreement    lender-selection-e2e    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Agreement
...    allure.label.story:Esign E2E Journey


*** Test Cases ***
TC-ESIGN-E01 New App - Full Journey Login To Esign
    [Documentation]
    ...    Full new-application E2E: dynamic fresh mobile → plan 1 → Western Capital →
    ...    KYC DB bypass → lands on /esign/{app_id}.
    ...    Asserts esign page is visible and URL contains /esign/.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Perform KYC Bypass Journey    journey_type=new
    Esign Page Should Be Visible

TC-ESIGN-E02 Renewal App - Full Journey Login To Esign
    [Documentation]
    ...    Full renewal E2E: ${RENEWAL_MOBILE} (existing account) → plan 1 → Western Capital →
    ...    KYC DB bypass → lands on /esign/{app_id}.
    ...    Asserts esign page is visible and URL contains /esign/.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Perform KYC Bypass Journey    journey_type=renewal
    Esign Page Should Be Visible
