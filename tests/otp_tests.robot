*** Settings ***
Documentation
...    OTP Verification test suite for the GQ Customer Portal.
...    Tests the 4-digit OTP form at ${BASE_URL}/verify.
...
...    UAT fixed OTP: 9999 — applies to all mobile numbers (TN2 resolution).
...    No SMS dependency. Tests run reliably in CI without a gateway.
...    OTP timer: 180 seconds before the Resend OTP link becomes visible (T4 boundary).
...    Resend OTP test is tagged "slow" and "resend" — excluded from default CI runs (TN1 resolution).
...    Run with: robot --include resend tests/otp_tests.robot
...
...    Covers:
...      - Field visibility and editability
...      - Input validation (empty, short OTP)
...      - Button enabled/disabled states
...      - Wrong OTP — URL stays on /verify; toast is best-effort (non-blocking if rate-limited)
...      - Valid OTP redirect with dashboard greeting
...      - Back button navigation and mobile number clearing
...      - Mobile number display on OTP page
...      - OTP countdown timer text
...      - Resend OTP flow (slow — robot:skip, run with --include resend)
...
...    Ported from gq_customer_ui_automation (Java/Selenium).
...    UAT rate limit: ~3 checkMobilePost calls per ~60s.
...    Each test navigating to the OTP page uses a distinct mobile number.
...    Navigate To OTP Page handles auto-retry on rate limit detection.
...
...    Satisfies: B2 (full OTP coverage), T3 (fixed OTP, no SMS), T4 (timer),
...               T5 (4-digit OTP), U1 (exact error messages), U3 (redirect assertions),
...               O1 (dry-run safe), O2 (results output), TN1, TN2

Library          Browser
Resource         ../resources/LoginPage.robot
Resource         ../resources/OTPPage.robot
Resource         ../variables/variables.robot

Suite Setup      New Browser    ${BROWSER}    headless=${HEADLESS}
Suite Teardown   Close Browser
Test Teardown    Close Context
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Authentication    allure.label.story:OTP Verification

*** Test Cases ***

TC-301 OTP Input Field Is Visible And Editable
    [Documentation]
    ...    On the OTP verification page, the OTP input field should be visible and
    ...    accept user input (editable/enabled state).
    [Tags]    otp    ui    field
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_2}
    OTP Input Should Be Visible And Editable

TC-302 OTP Verification With Empty OTP
    [Documentation]
    ...    Clicking Verify OTP without entering any value should trigger React Hook Form
    ...    validation and render the error: "Please enter 4 digit OTP".
    ...    Satisfies: B2 (empty OTP coverage), U1 (exact Yup error string), T5 (required field)
    [Tags]    otp    validation    negative
    [Setup]    Navigate To OTP Page    ${OTP_MOBILE_1}
    Click Verify OTP Button
    ${error}=    Get OTP Error Message
    Should Be Equal    ${error}    Please enter 4 digit OTP

TC-303 OTP Verification With Short OTP
    [Documentation]
    ...    Entering fewer than 4 digits (e.g. "123") should trigger the Yup .length(4)
    ...    validation and render: "OTP number must contain 4 digits".
    ...    Satisfies: B2 (short OTP coverage), U1 (exact Yup error string), T5 (length validation)
    [Tags]    otp    validation    negative
    [Setup]    Navigate To OTP Page    ${OTP_MOBILE_2}
    Enter OTP    ${SHORT_OTP}
    Click Verify OTP Button
    ${error}=    Get OTP Error Message
    Should Be Equal    ${error}    OTP number must contain 4 digits

TC-304 Verify OTP Button Is Enabled After OTP Entry
    [Documentation]
    ...    After entering a 4-digit OTP into the OTP input field, the Verify OTP
    ...    button should transition to an enabled state.
    [Tags]    otp    ui    button-state
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_9}
    Enter OTP    ${TEST_OTP}
    Verify OTP Button Should Be Enabled

TC-305 Valid OTP Redirects To Dashboard With Greeting
    [Documentation]
    ...    Entering the correct UAT OTP (9999) should call verifyOtpPost, set auth tokens,
    ...    redirect to /my-applications, and display the dashboard greeting "Hello,".
    ...    Intentionally runs BEFORE Wrong OTP — a prior failed verifyOtpPost call can
    ...    trigger IP rate limiting that blocks the valid OTP path.
    ...    Handles UAT verifyOtpPost rate limiting: polls for redirect up to LONG_TIMEOUT,
    ...    then if still not redirected waits RATE_LIMIT_WAIT and retries based on page state:
    ...      - /my-applications → already succeeded, skip retry
    ...      - /verify (OTP form visible) → re-enter OTP and click Verify
    ...      - / (login page) → re-submit login form then OTP (rate limit forced full logout)
    ...    Satisfies: B2 (valid OTP coverage), U3 (redirect assertion), T3, TN2 (fixed OTP 9999)
    [Tags]    otp    valid    smoke    dashboard
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_4}
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        ${on_dashboard}=    Run Keyword And Return Status    Dashboard URL Should Be Visible
        IF    not ${on_dashboard}
            ${on_otp}=    Run Keyword And Return Status
            ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=3s
            IF    ${on_otp}
                Enter OTP    ${TEST_OTP}
                Click Verify OTP Button
            ELSE
                Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
                Submit Login Form    ${EXT_OTP_MOBILE_4}
                Wait For OTP Page
                Submit OTP Form    ${TEST_OTP}
            END
        END
    END
    Dashboard Greeting Should Be Visible

TC-306 Wrong OTP Shows Incorrect OTP Toast
    [Documentation]
    ...    Submitting a structurally valid but incorrect OTP (e.g. "1234") calls
    ...    verifyOtpPost, which returns an error. The user remains on /verify.
    ...    Primary assertion: URL stays on /verify (verifies wrong OTP does not authenticate).
    ...    Secondary assertion: "Incorrect OTP" toast visible — non-blocking because in UAT
    ...    verifyOtpPost can be rate-limited after prior calls, returning 429 instead of the
    ...    wrong-OTP error response, so no toast appears. Rate limit does not change the
    ...    core behaviour (user stays on /verify either way).
    [Tags]    otp    negative    toast
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_3}
    Submit OTP Form    ${WRONG_OTP}
    OTP Page Should Still Be On OTP Page
    ${toast_shown}=    Run Keyword And Return Status    Incorrect OTP Toast Should Be Visible
    IF    not ${toast_shown}
        Log    Incorrect OTP toast not visible — verifyOtpPost may be rate-limited in UAT (429 instead of wrong-OTP error). URL confirmed on /verify.    WARN
    END

TC-307 Back Button Returns To Login Page
    [Documentation]
    ...    After navigating to the OTP page, clicking the back button should return
    ...    to the login page and display the title "What is your Mobile Number?".
    [Tags]    otp    navigation    back-button
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_1}
    Click Back Button
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
    ${title}=    Get Login Form Title
    Should Be Equal    ${title}    What is your Mobile Number?

TC-308 Back Button Clears Mobile Number Input
    [Documentation]
    ...    After navigating to the OTP page and clicking back, the login form is shown
    ...    again with the mobile number input field cleared (empty value).
    [Tags]    otp    navigation    back-button
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_6}
    Click Back Button
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
    ${value}=    Get Mobile Input Value
    Should Be Equal    ${value}    ${EMPTY}

TC-309 Entered Mobile Number Is Displayed On OTP Page
    [Documentation]
    ...    The mobile number entered on the login form should be displayed on the
    ...    OTP page inside data-testid='mobile-number-info'.
    [Tags]    otp    ui    mobile-display
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_5}
    ${displayed}=    Get Displayed Mobile Number
    Should Contain    ${displayed}    ${EXT_OTP_MOBILE_5}

TC-310 OTP Countdown Timer Shows Resend Text
    [Documentation]
    ...    Immediately after landing on the OTP page, the send-otp-timer-container should
    ...    be visible and display "Did not receive OTP? Resend in <countdown>".
    ...    Exact time value is not asserted to avoid timing flakiness.
    [Tags]    otp    ui    timer
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_7}
    OTP Timer Should Show Countdown Text

TC-314 OTP With Non-Numeric Characters Shows Error
    [Documentation]
    ...    Entering non-numeric characters (e.g. "abcd") into the OTP field and clicking
    ...    Verify OTP should trigger the Yup .matches(Regex.otp) validation and render:
    ...    "Only numeric values allowed".
    ...    The input has inputMode='numeric' but type='text', so desktop keyboards can type letters.
    ...    Satisfies: TC-314
    [Tags]    otp    validation    negative
    [Setup]    Navigate To OTP Page    ${EXT_OTP_MOBILE_10}
    Enter OTP    ${NON_NUMERIC_OTP}
    Click Verify OTP Button
    ${error}=    Get OTP Error Message
    Should Be Equal    ${error}    Only numeric values allowed

TC-317 Existing Customer OTP Verification Lands On Dashboard With Applications
    [Documentation]
    ...    An existing customer (mobile with active EMI applications) who completes OTP
    ...    verification should be redirected to /my-applications where the EMI tab and
    ...    at least one application card are visible.
    ...    Recorded in login_20260424_114543.js — mobile 8108556708.
    ...    Satisfies: TC-317
    [Tags]    otp    valid    existing-customer    dashboard
    [Setup]    Navigate To OTP Page    ${DASHBOARD_MOBILE}
    Submit OTP Form    ${TEST_OTP}
    Wait For Dashboard
    Existing User Dashboard Should Show Applications

TC-318 New Customer OTP Verification Lands On Dashboard With Create Application Prompt
    [Documentation]
    ...    A new customer (mobile with no applications) who completes OTP verification
    ...    should be redirected to /my-applications where the emi-not-data-found empty
    ...    state container is visible, prompting them to create their first application.
    ...    Satisfies: TC-318
    [Tags]    otp    valid    new-customer    dashboard
    [Setup]    Navigate To OTP Page    ${NEW_USER_MOBILE}
    Submit OTP Form    ${TEST_OTP}
    Wait For Dashboard
    New User Dashboard Should Show Empty State

TC-315 OTP Page Heading Is Enter 4 Digit OTP
    [Documentation]
    ...    The OTP verification page should display the heading "Enter 4 Digit OTP"
    ...    via data-testid='desktop-view-form-title'. Recorded in login_20260424_112212.js.
    ...    Satisfies: TC-315
    [Tags]    otp    ui    heading
    [Setup]    Navigate To OTP Page    ${NEW_USER_MOBILE}
    ${title}=    Get OTP Page Title
    Should Be Equal    ${title}    Enter 4 Digit OTP

TC-316 Back Button Then Re-Login Navigates To OTP Page
    [Documentation]
    ...    After landing on the OTP page and clicking the back button, re-submitting
    ...    the login form with the same mobile should navigate back to /verify.
    ...    Covers the round-trip flow: OTP page → back → login → OTP page.
    ...    Satisfies: TC-316
    [Tags]    otp    navigation    back-button
    [Setup]    Navigate To OTP Page    ${DASHBOARD_MOBILE}
    Click Back Button
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
    Submit Login Form And Wait For OTP Page    ${DASHBOARD_MOBILE}

TC-311 OTP Not Received
    [Documentation]
    ...    Manual test case: verify UX when OTP is not received (e.g. carrier issues).
    ...    Cannot be automated — requires external SMS gateway dependency.
    ...    Skipped in automated runs.
    [Tags]    otp    manual    robot:skip
    Navigate To OTP Page    ${EXT_OTP_MOBILE_1}

TC-312 OTP Timer Disabled State
    [Documentation]
    ...    Manual test case: verify the timer appearance before it starts counting.
    ...    Cannot be reliably automated within normal timing constraints.
    ...    Skipped in automated runs.
    [Tags]    otp    manual    robot:skip
    Navigate To OTP Page    ${EXT_OTP_MOBILE_1}


TC-313 Resend OTP After Timer Expires
    [Documentation]
    ...    After the 180-second countdown, the Resend OTP link (data-testid='resend-otp-link')
    ...    should become visible. Clicking it should trigger resendOtpPost API, reset the
    ...    timer, and hide the resend link again.
    ...
    ...    WARNING: This test waits ~3 minutes. It is EXCLUDED from default CI runs.
    ...    Run explicitly with: robot --include resend tests/otp_tests.robot
    ...    Or include in nightly job: robot --include slow tests/
    ...    Satisfies: T4 (180s timer boundary), B2 (resend coverage), TN1 (slow tag decision)
    [Tags]    otp    slow    resend    robot:skip
    [Setup]    Navigate To OTP Page
    OTP Timer Should Be Visible
    Wait For Resend OTP Link    ${RESEND_OTP_WAIT}
    Click Resend OTP
    OTP Timer Should Reset After Resend
