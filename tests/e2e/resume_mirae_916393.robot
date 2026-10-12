*** Settings ***
Documentation
...    One-off resume: app 916393, mobile 9400799114 (Mirae Asset).
...    KYC and address-proof were already DB-bypassed manually. Resumes from
...    /sign-agreement and completes eSign -> Down Payment -> Mandate bypass -> Selfie bypass.

Library     Browser
Library     ../../libraries/kyc_bypass_db.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/DownPaymentPage.robot
Resource    ../../resources/EsignPage.robot
Resource    ../../resources/LoginPage.robot
Resource    ../../resources/OTPPage.robot
Resource    ../../variables/variables.robot

*** Variables ***
${RESUME_MOBILE}    9400799114
${RESUME_APP_ID}    916393

*** Test Cases ***
Resume App 916393 From KYC Onward
    New Browser    ${BROWSER}    headless=${HEADLESS}    args=['--start-maximized']
    Open Login Page
    Submit Login Form    ${RESUME_MOBILE}
    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    Submit OTP Form    ${TEST_OTP}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Set Suite Variable    ${LAST_USED_MOBILE}    ${RESUME_MOBILE}
    # Detect where this application actually is — earlier runs already progressed it
    # past eSign (down-payment/.../method, confirmed live) — don't force-navigate backward.
    Go To    ${BASE_URL}/sign-agreement/${RESUME_APP_ID}
    Sleep    3s
    ${cur_url}=    Get Url
    Log    Landed on: ${cur_url}    console=True
    IF    '/sign-agreement/' in '${cur_url}'
        Complete Esign Step
        Log    ✅ eSign complete    console=True
        Complete Down Payment Step    ${RESUME_APP_ID}
    ELSE IF    '/down-payment-status/' in '${cur_url}'
        Log    Already past Down Payment — on status page    console=True
    ELSE IF    '/down-payment/${RESUME_APP_ID}/method' in '${cur_url}'
        Log    Already on Step 5 (method) — resuming from payment method selection    console=True
        Down Payment Step 5 Should Be Visible
        ${has_online}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${DP_ONLINE_PAYMENT}    visible    timeout=5s
        IF    ${has_online}    Click    ${DP_ONLINE_PAYMENT}
        Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
        Wait For Elements State    ${DP_PAY_BTN}    enabled    timeout=${TIMEOUT}
        Click    ${DP_PAY_BTN}
        Complete Razorpay Payment Via UPI For App    ${RESUME_APP_ID}
        Down Payment Status Page Should Be Visible
    ELSE IF    '/down-payment/' in '${cur_url}'
        Log    On Step 1 (details) — running full Complete Down Payment Step    console=True
        Complete Down Payment Step    ${RESUME_APP_ID}
    ELSE
        Log    Already past Down Payment entirely — proceeding to final steps    console=True
    END
    Log    ✅ Down payment complete    console=True
    Enter Final Steps If Present    ${RESUME_APP_ID}
    Complete Nach And Selfie Step    ${RESUME_APP_ID}    ${RESUME_MOBILE}
    Log    ✅ Mandate + Selfie bypassed — journey complete for app ${RESUME_APP_ID}    console=True
    [Teardown]    Run Keyword And Ignore Error    Close Browser
