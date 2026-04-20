*** Settings ***
Documentation
...    Page object keywords for the OTP Verification page (/verify).
...    All locators use data-testid attributes derived from VerifyOTPForm.jsx and
...    SendOtpTimer.jsx in gqcustomer_frontend.
...    Library: Browser (Playwright) v19.9.0 — TN3 resolution.
...
...    Key selectors confirmed from source:
...      OTP form:          data-testid='verify-otp-form'    (VerifyOTPForm.jsx line 38)
...      OTP input:         data-testid='otp-input'          (Input atom, testIdFor prop)
...      OTP error:         data-testid='otp-input-error'    (Input atom)
...      Verify button:     data-testid='verify-otp-button'  (VerifyOTPForm.jsx line 92, dynamic)
...      Timer container:   data-testid='send-otp-timer-container' (SendOtpTimer.jsx line 24)
...      OTP timer:         data-testid='send-otp-timer'     (SendOtpTimer.jsx line 29)
...      Resend OTP link:   data-testid='resend-otp-link'    (SendOtpTimer.jsx line 38)
...      Mobile info:       data-testid='mobile-number-info' (VerifyOTPForm.jsx line 54)
...
...    OTP is 4 digits. UAT fixed OTP: 9999 (TN2 resolution — no SMS dependency).
...    Resend OTP link only visible after 180-second countdown (T4 boundary).
...    Satisfies: T1 (data-testid locators), T4 (timer boundary), T5 (4-digit OTP),
...               U1 (error messages), U2 (explicit waits), U3 (redirect assertions), TN1, TN2

Library     Browser
# Note: variables (TEST_OTP, TIMEOUT, LONG_TIMEOUT, etc.) are imported by test suite files.
# Resource files do not import Variables directly — Robot Framework shares the suite variable scope.

*** Variables ***
# Locators — derived from data-testid attributes in gqcustomer_frontend source
# Satisfies: T1 (all locators use data-testid, no CSS classes or absolute XPath)
${OTP_FORM}                css=[data-testid='verify-otp-form']
${OTP_INPUT}               css=[data-testid='otp-input']
${OTP_ERROR}               css=[data-testid='otp-input-error']
${VERIFY_OTP_BUTTON}       css=[data-testid='verify-otp-button']
${OTP_TIMER_CONTAINER}     css=[data-testid='send-otp-timer-container']
${OTP_TIMER}               css=[data-testid='send-otp-timer']
${RESEND_OTP_LINK}         css=[data-testid='resend-otp-link']
${MOBILE_NUMBER_INFO}      css=[data-testid='mobile-number-info']

*** Keywords ***
Wait For OTP Page
    [Documentation]
    ...    Waits for the OTP verification form to be visible and asserts the URL
    ...    contains /verify. Called after successful login form submission.
    ...    Satisfies: U2 (explicit wait), U3 (URL assertion after redirect)
    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    ${url}=    Get Url
    Should Contain    ${url}    /verify

Enter OTP
    [Documentation]
    ...    Types a value into the OTP input field.
    ...    Field accepts 4-digit numeric input (maxLength=4, inputMode='numeric').
    ...    Satisfies: T1 (data-testid locator), T5 (4-digit field constraint from source)
    [Arguments]    ${otp_value}
    Fill Text    ${OTP_INPUT}    ${otp_value}

Click Verify OTP Button
    [Documentation]
    ...    Clicks the Verify OTP submit button. Triggers form validation and,
    ...    if valid, calls verifyOtpPost API.
    ...    Satisfies: T1 (data-testid locator)
    Click    ${VERIFY_OTP_BUTTON}

Submit OTP Form
    [Documentation]
    ...    Full OTP form submission: enter OTP and click Verify OTP.
    ...    Default OTP is ${TEST_OTP} (9999 — fixed in UAT, TN2 resolution).
    ...    Satisfies: T1, T5, TN2 (fixed OTP)
    [Arguments]    ${otp_value}=${TEST_OTP}
    Enter OTP    ${otp_value}
    Click Verify OTP Button

Get OTP Error Message
    [Documentation]
    ...    Returns the validation error text rendered in data-testid='otp-input-error'.
    ...    Only appears for client-side validation errors (empty, wrong length, non-numeric).
    ...    API errors (wrong OTP) are shown as toast notifications, not in this element.
    ...    Satisfies: U1 (exact validation message assertion), T1, U2 (explicit wait)
    Wait For Elements State    ${OTP_ERROR}    visible    timeout=${TIMEOUT}
    ${error_text}=    Get Text    ${OTP_ERROR}
    RETURN    ${error_text}

Wait For Dashboard
    [Documentation]
    ...    Waits for the post-OTP redirect to /my-applications to complete.
    ...    Uses URL polling (every 500ms) rather than networkidle because React Router
    ...    performs a client-side pushState navigation after the verifyOtpPost response —
    ...    networkidle fires at API response time, before the URL update.
    ...    Satisfies: U3 (URL redirect assertion after valid OTP)
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Dashboard URL Should Be Visible
    [Documentation]    Helper — asserts the current URL contains /my-applications.
    ${url}=    Get Url
    Should Contain    ${url}    /my-applications

OTP Page Should Still Be On OTP Page
    [Documentation]
    ...    Asserts the current URL still contains /verify — the user was NOT redirected
    ...    after OTP submission. Used to verify wrong-OTP rejection without depending
    ...    on toast notification DOM structure.
    ...    Satisfies: B2 (wrong OTP coverage), U3 (no redirect on failure)
    ${url}=    Get Url
    Should Contain    ${url}    /verify

OTP Timer Should Be Visible
    [Documentation]
    ...    Asserts the OTP countdown timer container is visible on the OTP page.
    ...    The timer runs for 180 seconds before the Resend OTP link appears.
    ...    Satisfies: T4 (timer boundary awareness), U2 (explicit wait)
    Wait For Elements State    ${OTP_TIMER_CONTAINER}    visible    timeout=${TIMEOUT}

Wait For Resend OTP Link
    [Documentation]
    ...    Waits up to ${wait_timeout} for the Resend OTP link to become visible.
    ...    The link appears only after the 180-second countdown expires (T4 boundary).
    ...    Default timeout is ${RESEND_OTP_WAIT} (185s — 5s buffer over the 180s timer).
    ...    NOTE: This keyword introduces a ~3-minute wait. Only called in slow-tagged tests.
    ...    Satisfies: T4 (180s timer), B2 (resend OTP coverage), TN1 (slow tag strategy)
    [Arguments]    ${wait_timeout}=${RESEND_OTP_WAIT}
    Wait For Elements State    ${RESEND_OTP_LINK}    visible    timeout=${wait_timeout}

Click Resend OTP
    [Documentation]
    ...    Clicks the Resend OTP link. The link must already be visible before calling this.
    ...    After clicking, the timer resets and a new OTP is sent to the mobile number.
    ...    Satisfies: T4 (resend interaction), B2 (resend OTP test coverage)
    Click    ${RESEND_OTP_LINK}

OTP Timer Should Reset After Resend
    [Documentation]
    ...    After clicking Resend OTP, verifies the timer container is visible again
    ...    (indicating a new countdown started). The resend link should no longer be visible.
    ...    Satisfies: T4, B2 (resend OTP post-click assertion)
    Wait For Elements State    ${OTP_TIMER_CONTAINER}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RESEND_OTP_LINK}    hidden    timeout=${TIMEOUT}
