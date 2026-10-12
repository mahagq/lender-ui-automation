*** Settings ***
Documentation
...    Generic resume: logs in with an existing mobile/app_id combo and continues
...    the journey from wherever it currently stands — detects the actual landed
...    page (eSign / Down Payment step 1 / Down Payment step 5 / already past) rather
...    than assuming a fixed starting point. Useful whenever a run was interrupted
...    partway through, or a step was manually DB-bypassed and needs the automation
...    to pick back up.
...
...    Usage:
...      robot --variable RESUME_MOBILE:9400799114 --variable RESUME_APP_ID:916393 \
...            --variable RESUME_LENDER_NAME:"Mirae Asset" \
...            --outputdir results/resume tests/e2e/resume_journey_tests.robot
...    (or set RESUME_MOBILE / RESUME_APP_ID / RESUME_LENDER_NAME env vars).

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
${RESUME_MOBILE}         %{RESUME_MOBILE=9106059299}
${RESUME_APP_ID}         %{RESUME_APP_ID=908036}
${RESUME_LENDER_NAME}    %{RESUME_LENDER_NAME=${EMPTY}}

*** Test Cases ***
Resume Existing Application From Current State
    [Documentation]
    ...    State-aware resume. Logs in, navigates toward /sign-agreement/{app_id} (the
    ...    guard redirects to wherever the app actually is), then branches on the landed
    ...    URL to continue from exactly that point through to Mandate + Selfie bypass.
    New Browser    ${BROWSER}    headless=${HEADLESS}    args=['--start-maximized']
    Open Login Page
    Submit Login Form    ${RESUME_MOBILE}
    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    Submit OTP Form    ${TEST_OTP}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Set Suite Variable    ${LAST_USED_MOBILE}    ${RESUME_MOBILE}

    Go To    ${BASE_URL}/sign-agreement/${RESUME_APP_ID}
    Sleep    3s
    Resume From Current URL    ${RESUME_APP_ID}    ${RESUME_MOBILE}
    [Teardown]    Run Keyword And Ignore Error    Close Browser

*** Keywords ***
Resume From Current URL
    [Arguments]    ${app_id}    ${mobile}
    [Documentation]
    ...    Branches on wherever the app actually landed and drives the rest of the
    ...    journey to completion. Reusable from any entry point — call this after
    ...    logging in and navigating toward the app, not just for Down Payment.
    ${cur_url}=    Get Url
    Log    Resuming from: ${cur_url}    console=True
    # Address proof can surface before anything else resolves.
    Handle Address Proof Page If Present    ${app_id}
    ${cur_url}=    Get Url

    IF    '/kyc/' in '${cur_url}'
        Log    On /kyc/ — DB-bypassing KYC    console=True
        Bypass KYC Via Database    ${mobile}    ${app_id}    lender_name=${RESUME_LENDER_NAME}
        Reload
        Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Esign URL Should Be Active    ${app_id}
        ${cur_url}=    Get Url
    END

    IF    '/sign-agreement/' in '${cur_url}'
        Complete Esign Step
        Log    ✅ eSign complete    console=True
        Complete Down Payment Step    ${app_id}
    ELSE IF    '/down-payment/${app_id}/method' in '${cur_url}'
        Log    On Step 5 (method) — resuming from payment method selection    console=True
        Down Payment Step 5 Should Be Visible
        ${has_online}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${DP_ONLINE_PAYMENT}    visible    timeout=5s
        IF    ${has_online}    Click    ${DP_ONLINE_PAYMENT}
        Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
        Wait For Elements State    ${DP_PAY_BTN}    enabled    timeout=${TIMEOUT}
        Click    ${DP_PAY_BTN}
        Complete Razorpay Payment Via UPI For App    ${app_id}
        Down Payment Status Page Should Be Visible
    ELSE IF    '/down-payment/' in '${cur_url}'
        Log    On Step 1 (details) — running full Complete Down Payment Step    console=True
        Complete Down Payment Step    ${app_id}
    ELSE IF    '/down-payment-status/' in '${cur_url}'
        Log    Already past Down Payment — on status page    console=True
    ELSE
        Log    Already past Down Payment entirely — proceeding to final steps    console=True
    END

    Log    ✅ Down payment complete    console=True

    # Re-check: we may already be well past Down Payment (e.g. resuming straight into
    # /additional-details/) — don't blindly call Enter Final Steps If Present, which
    # assumes starting from /down-payment-status/ and would hang waiting for text
    # that only appears there.
    ${cur_url}=    Get Url
    IF    '/additional-details/' in '${cur_url}'
        Log    Already on /additional-details/ — skipping straight to final step    console=True
    ELSE IF    '/down-payment-status/' in '${cur_url}'
        Enter Final Steps If Present    ${app_id}
        Complete Nach And Selfie Step    ${app_id}    ${mobile}
        Log    ✅ Mandate + Selfie bypassed    console=True
    ELSE
        Log    On ${cur_url} — attempting Mandate/Selfie bypass directly    console=True
        Complete Nach And Selfie Step    ${app_id}    ${mobile}
        Log    ✅ Mandate + Selfie bypassed    console=True
    END

    Complete Additional Details Step    ${app_id}
    Log    ✅ Journey complete for app ${app_id}    console=True
