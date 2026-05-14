*** Settings ***
Documentation
...    Agreement/Esign page tests for the GQ Customer Portal (/esign/{app_id}).
...    Suite Setup: full journey — login (fresh dynamic mobile) → wizard (plan 1) →
...    Western Capital lender → KYC DB bypass → lands on /esign/{app_id}.
...    Every UI field and interaction has a dedicated test case.
...
...    Edge cases:
...      TC-AG-DP-001  — Plan 1 (has downpayment) → after esign → /down-payment/{app_id}
...      TC-AG-NACH-001 — Plan 6 (no downpayment) → after esign → /nach/{app_id}
...
...    State-advancing tests (TC-AG-030, TC-AG-031, TC-AG-033, TC-AG-DP-001, TC-AG-NACH-001)
...    run LAST. TC-AG-033, TC-AG-DP-001 and TC-AG-NACH-001 own fresh browser sessions.

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Esign New App
Suite Teardown   Close Browser
Test Setup       Run Keywords    Go To    ${BASE_URL}/esign/${ESIGN_APP_ID}    AND    Esign Page Should Be Visible

Test Tags    agreement    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Agreement


*** Variables ***
${ESIGN_APP_ID}     ${EMPTY}
${NACH_APP_ID}      ${EMPTY}
${DP_APP_ID}        ${EMPTY}


*** Test Cases ***
TC-AG-001 Esign Page Loads At Correct URL
    [Documentation]    Asserts browser is at /esign/{app_id} after KYC bypass.
    Esign URL Should Contain App ID    ${ESIGN_APP_ID}

TC-AG-002 Agreement Summary Title Is Visible
    [Documentation]    Asserts the top-level agreement summary title element is visible.
    Agreement Summary Title Should Be Visible

TC-AG-003 Agreement Inner Title Is Visible
    [Documentation]    Asserts the agreement-title element inside the summary is visible.
    Agreement Inner Title Should Be Visible

TC-AG-004 Applicant Name Field Is Visible
    [Documentation]    Asserts the customer-name field is visible on the agreement page.
    Esign Applicant Name Field Should Be Visible

TC-AG-005 Educational Institute Name Field Is Visible
    [Documentation]    Asserts the institute_name field is visible on the agreement page.
    Institute Name Field Should Be Visible

TC-AG-006 Student Name Field Is Visible
    [Documentation]    Asserts the student_name field is visible on the agreement page.
    Student Name Field Should Be Visible

TC-AG-007 Total Fee Amount Field Is Visible
    [Documentation]    Asserts the total-fee-amount field is visible on the agreement page.
    Total Fee Amount Field Should Be Visible

TC-AG-008 EMI Amount Field Is Visible
    [Documentation]    Asserts the emi-amount field is visible on the agreement page.
    EMI Amount Field Should Be Visible

TC-AG-009 Tenure Field Is Visible
    [Documentation]    Asserts the tenure field is visible on the agreement page.
    Tenure Field Should Be Visible

TC-AG-010 Payable Today Downpayment Field Is Visible
    [Documentation]    Asserts the first payable-today element (downpayment) is visible.
    Payable Today Downpayment Field Should Be Visible

TC-AG-011 Processing Fee Field Is Visible
    [Documentation]    Asserts the second payable-today element (processing fee) is visible.
    Processing Fee Field Should Be Visible

TC-AG-012 Platform Fee Field Is Visible
    [Documentation]    Asserts the third payable-today element (platform fee) is visible.
    Platform Fee Field Should Be Visible

TC-AG-013 Mandate Charge Field Is Visible
    [Documentation]    Asserts the mandate-repayment-charges field is visible.
    Mandate Charge Field Should Be Visible

TC-AG-014 EMI Debit Date Field Is Visible
    [Documentation]    Asserts the debited-date field is visible on the agreement page.
    EMI Debit Date Field Should Be Visible

TC-AG-015 Lender Name Field Is Visible
    [Documentation]    Asserts the lender-name field is visible on the agreement page.
    Lender Name Field Should Be Visible

TC-AG-016 APR Field Is Visible
    [Documentation]    Asserts the apr-value field is visible on the agreement page.
    APR Field Should Be Visible

TC-AG-017 Lender Grievance Redressal Section Is Visible
    [Documentation]    Asserts the lender grievance redressal section container is visible.
    Lender Grievance Redressal Section Should Be Visible

TC-AG-018 Lender Grievance Name Value Is Visible
    [Documentation]    Asserts the name-value inside the lender grievance section is visible.
    Lender Grievance Name Value Should Be Visible

TC-AG-019 Lender Grievance Email Value Is Visible
    [Documentation]    Asserts the email-value inside the lender grievance section is visible.
    Lender Grievance Email Value Should Be Visible

TC-AG-020 Lender Grievance Mobile Number Value Is Visible
    [Documentation]    Asserts the mobile-number-value inside the lender grievance section is visible.
    Lender Grievance Mobile Number Value Should Be Visible

TC-AG-021 GrayQuest Grievance Redressal Section Is Visible
    [Documentation]    Asserts the grayquest grievance redressal section is visible.
    GrayQuest Grievance Redressal Section Should Be Visible

TC-AG-022 Consent Checkbox Is Unchecked By Default
    [Documentation]    Asserts the consent checkbox is unchecked when the page loads.
    Consent Checkbox Should Be Unchecked

TC-AG-023 Consent Label Click Checks Checkbox
    [Documentation]    Clicks the consent label and asserts the checkbox becomes checked.
    Consent Label Click Should Check Checkbox

TC-AG-024 Accept Terms Without Consent Shows Validation Error
    [Documentation]
    ...    Unchecks consent and clicks Accept Terms button.
    ...    Asserts consent-checkbox-error becomes visible.
    Submit Without Consent Shows Error

TC-AG-025 View Agreement Button Opens Modal
    [Documentation]    Clicks the view-agreement-button and asserts the dialog modal appears.
    Click View Agreement Button
    Agreement Modal Should Be Visible

TC-AG-026 Agreement Modal Can Be Closed
    [Documentation]    Opens the agreement modal then closes it via the Close button.
    Click View Agreement Button
    Agreement Modal Should Be Visible
    Close Agreement Modal

TC-AG-027 Language Selector Is Visible In Agreement Modal
    [Documentation]    Opens the agreement modal and asserts the language selector is visible.
    Click View Agreement Button
    Agreement Modal Should Be Visible
    Language Selector Should Be Visible In Modal

TC-AG-028 Agreement Language Can Be Changed To MARATHI
    [Documentation]    Opens modal, selects MARATHI from the language dropdown.
    Click View Agreement Button
    Agreement Modal Should Be Visible
    Select MARATHI Language In Modal

TC-AG-029 Agreement Preview Proceed Button Closes Modal
    [Documentation]    Opens modal, clicks the proceed button, asserts modal closes.
    Click View Agreement Button
    Agreement Modal Should Be Visible
    Click Agreement Preview Proceed Button

TC-AG-032 Back Button On Esign Page Stays On Esign Page
    [Documentation]
    ...    Clicks the back-button on the agreement page and asserts the URL still contains
    ...    /esign/{app_id} — the back button does not navigate away from the agreement page.
    Click Esign Back Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Esign URL Should Contain App ID    ${ESIGN_APP_ID}

TC-AG-030 Accept Terms With Consent Allows Agreement Signing
    [Documentation]
    ...    Checks consent and clicks the Accept Terms button.
    ...    UAT redirects directly — asserts URL moves away from /esign/ confirming signing initiated.
    ...    This test consumes the suite session; subsequent tests run LAST with own browsers.
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Signing Initiated Successfully

TC-AG-031 Successful Signing Redirects To Down Payment Or NACH
    [Documentation]
    ...    Continues from TC-AG-030 (Setup: NONE — inherits redirected state).
    ...    Suite uses plan 1 (has downpayment) so redirect lands on /down-payment/{app_id}.
    ...    Asserts URL contains /down-payment/ or /nach/ (plan-dependent).
    [Setup]    NONE
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Redirect URL Should Be Down Payment Or NACH

TC-AG-033 Close Button On Esign Page Redirects To Dashboard
    [Documentation]
    ...    Own browser session (suite session consumed by TC-AG-030/031).
    ...    Opens fresh esign page, clicks close-button, asserts redirect to /my-applications.
    [Setup]    Navigate To Esign New App
    [Teardown]    Close Browser
    Esign Page Should Be Visible
    Click Esign Close Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

TC-AG-DP-001 Plan 1 Esign Redirects To Down Payment Page
    [Documentation]
    ...    Own browser session with plan 1 (has downpayment).
    ...    Navigates fresh to esign, signs agreement, asserts redirect to /down-payment/{app_id}.
    [Setup]    Navigate To Esign New App
    [Teardown]    Close Browser
    Esign Page Should Be Visible
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Down Payment URL Should Be Active    ${ESIGN_APP_ID}

TC-AG-NACH-001 Plan 6 Esign Redirects To NACH Page
    [Documentation]
    ...    Own browser session with plan 6 (no downpayment — NACH flow).
    ...    Navigates fresh to esign via plan 6, signs agreement, asserts redirect to /nach/{app_id}.
    [Setup]    Navigate To Esign New App With Plan    plan_index=6
    [Teardown]    Close Browser
    Esign Page Should Be Visible
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Nach URL Should Be Active    ${NACH_APP_ID}
