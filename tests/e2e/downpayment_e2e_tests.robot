*** Settings ***
Documentation
...    Downpayment E2E journey tests from login through to the Down Payment page and status.
...    Each test owns its own browser session (fresh mobile per test).
...
...    TC-DP-E01 — New app: login → wizard (plan 1) → Western Capital → KYC bypass →
...               esign → sign agreement → lands on /down-payment/{app_id} (Step 1 visible).
...
...    TC-DP-E02 — New app: full Razorpay UPI payment E2E — login → wizard → KYC bypass →
...               esign → sign → /down-payment/ → Step 5 → online payment → Razorpay UPI →
...               /down-payment-status/{app_id} (payment success).

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/DownPaymentPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags    down-payment    regression    lender-selection-e2e
...          allure.label.epic:CP UI Automation
...          allure.label.feature:Downpayment
...          allure.label.story:Downpayment E2E Journey


*** Test Cases ***
TC-DP-E01 New App - Full Journey Login To Down Payment
    [Documentation]
    ...    Full new-application E2E: dynamic fresh mobile → plan 1 → Western Capital →
    ...    KYC DB bypass → sign agreement → lands on /down-payment/{app_id}.
    ...    Asserts Step 1 (down-payment-details) is visible and URL contains /down-payment/.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Navigate To Down Payment New App
    Down Payment Page Should Be Visible
    Down Payment URL Should Contain App ID    ${DP_APP_ID}

TC-DP-E02 New App - Full Journey Login To Down Payment Status Via Razorpay UPI
    [Documentation]
    ...    Full new-application E2E with Razorpay UPI payment: dynamic fresh mobile → plan 1 →
    ...    Western Capital → KYC DB bypass → sign agreement → /down-payment/ → Step 5 →
    ...    online payment → Razorpay UPI (success@razorpay test mode) → /down-payment-status/.
    ...    Asserts status page (down-payment-details) is visible and URL contains /down-payment-status/.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Navigate To Down Payment New App
    Down Payment Page Should Be Visible
    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    Down Payment Step 5 Should Be Visible
    Click    ${DP_ONLINE_PAYMENT}
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_PAY_BTN}
    Complete Razorpay Payment Via UPI
    Down Payment Status Page Should Be Visible
    Down Payment Status URL Should Contain App ID    ${DP_APP_ID}
