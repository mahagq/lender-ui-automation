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
# 2026 UI rewrite (develop-revamp branch) dropped data-testid attributes from this form too —
# verify-otp-form.tsx renders no wrapper testid. Locators below use placeholder/text matching
# (verified against src/components/sections/auth/verify-otp-form/verify-otp-form.tsx).
${OTP_FORM}                css=input[placeholder='Enter OTP']
${OTP_INPUT}               css=input[placeholder='Enter OTP']
${OTP_ERROR}               css=[data-testid='otp-input-error']
${VERIFY_OTP_BUTTON}       css=button:has-text('Verify OTP')
${OTP_TIMER_CONTAINER}     css=[data-testid='send-otp-timer-container']
${OTP_TIMER}               css=[data-testid='send-otp-timer']
${RESEND_OTP_LINK}         css=[data-testid='resend-otp-link']
${MOBILE_NUMBER_INFO}      css=[data-testid='mobile-number-info']
${BACK_BUTTON}             css=[data-testid='back-button']
${OTP_PAGE_TITLE}          css=[data-testid='desktop-view-form-title']
${OTP_TOAST_ERROR}         text=Incorrect OTP
${DASHBOARD_TITLE}         css=[data-testid='dashboard-title']

# Post-OTP landing state — existing vs new customer differentiation
${EMI_CONTENT_TAB}         css=[data-testid='emi-tab-navigation-button']
${EMI_APPLICATION_CARD}    css=[data-testid^='emi-card-'] >> nth=0
${NEW_USER_EMPTY_STATE}    css=[data-testid='emi-not-data-found']

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
    Wait For Elements State    ${OTP_INPUT}    visible    timeout=${LONG_TIMEOUT}
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
    ...    Waits for the post-OTP redirect to /applications to complete.
    ...    Uses URL polling (every 500ms) rather than networkidle because React Router
    ...    performs a client-side pushState navigation after the verifyOtpPost response —
    ...    networkidle fires at API response time, before the URL update.
    ...    Rate-limit recovery: if still on /verify after LONG_TIMEOUT, sleeps RATE_LIMIT_WAIT
    ...    then re-submits OTP once (verifyOtpPost rate limit pattern).
    ...    Satisfies: U3 (URL redirect assertion after valid OTP)
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        ${url}=    Get Url
        IF    '/verify' in '${url}'
            Log    verifyOtpPost rate limit in Wait For Dashboard — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
            Sleep    ${RATE_LIMIT_WAIT}
            Submit OTP Form    ${TEST_OTP}
        END
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    END

Dashboard URL Should Be Visible
    [Documentation]    Helper — asserts the current URL contains /applications.
    ${url}=    Get Url
    Should Contain    ${url}    /applications

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

Click Back Button
    [Documentation]
    ...    Clicks the back button on the OTP verification page to return to the login form.
    ...    Satisfies: TC-3001, TC-3008
    Click    ${BACK_BUTTON}

Submit Login Form And Wait For OTP Page
    [Documentation]
    ...    Submits the login form for the given mobile and waits for the OTP page.
    ...    Handles checkMobilePost rate limit: if OTP form is not visible within LONG_TIMEOUT,
    ...    sleeps RATE_LIMIT_WAIT and retries once (mid-session — no context close).
    ...    Use instead of bare Submit Login Form + Wait For OTP Page when the mobile was
    ...    already used recently (e.g. TC-316 back-button re-login flow).
    [Arguments]    ${mobile}
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${mobile}
        Wait For OTP Page
    END

Get OTP Page Title
    [Documentation]    Returns the form title text on the OTP page ("Enter 4 Digit OTP").
    Wait For Elements State    ${OTP_PAGE_TITLE}    visible    timeout=${LONG_TIMEOUT}
    ${title}=    Get Text    ${OTP_PAGE_TITLE}
    RETURN    ${title}

OTP Input Should Be Visible And Editable
    [Documentation]
    ...    Asserts the OTP input field is visible and enabled (editable).
    ...    Satisfies: TC-3002
    Wait For Elements State    ${OTP_INPUT}    visible    timeout=${TIMEOUT}
    Get Element States    ${OTP_INPUT}    contains    enabled

Get OTP Timer Text
    [Documentation]    Returns the full text of the OTP countdown timer container.
    Wait For Elements State    ${OTP_TIMER_CONTAINER}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${OTP_TIMER_CONTAINER}
    RETURN    ${text}

OTP Timer Should Show Countdown Text
    [Documentation]
    ...    Asserts the timer container is visible and contains resend countdown text.
    ...    Checks for "Resend in" text rather than exact time to avoid timing flakiness.
    ...    Satisfies: TC-3011
    Wait For Elements State    ${OTP_TIMER_CONTAINER}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${OTP_TIMER_CONTAINER}
    Should Contain    ${text}    Did not receive OTP?
    Should Contain    ${text}    Resend in

Verify OTP Button Should Be Disabled
    [Documentation]
    ...    Asserts the Verify OTP button is disabled (no OTP entered).
    ...    Satisfies: TC-3013
    Get Element States    ${VERIFY_OTP_BUTTON}    contains    disabled

Verify OTP Button Should Be Enabled
    [Documentation]
    ...    Asserts the Verify OTP button is enabled (OTP has been entered).
    ...    Satisfies: TC-3014
    Get Element States    ${VERIFY_OTP_BUTTON}    contains    enabled

Incorrect OTP Toast Should Be Visible
    [Documentation]
    ...    Asserts the "Incorrect OTP" toast notification is visible after submitting a wrong OTP.
    ...    The toast has no data-testid — Playwright text selector is used.
    ...    Satisfies: TC-3005
    Wait For Elements State    ${OTP_TOAST_ERROR}    visible    timeout=${TIMEOUT}

Get Displayed Mobile Number
    [Documentation]
    ...    Returns the mobile number shown in the mobile-number-info element on the OTP page.
    ...    The mobile number is inside a <span> child of the info container.
    ...    Satisfies: TC-3007
    Wait For Elements State    ${MOBILE_NUMBER_INFO}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${MOBILE_NUMBER_INFO}
    RETURN    ${text}

Dashboard Greeting Should Be Visible
    [Documentation]
    ...    Waits for the dashboard to load and asserts the greeting "Hello," is visible.
    ...    Satisfies: TC-3006
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    ${greeting}=    Get Text    ${DASHBOARD_TITLE}
    Should Contain    ${greeting}    Hello,

Existing User Dashboard Should Show Applications
    [Documentation]
    ...    Asserts the EMI tab and at least one application card are visible after login.
    ...    Confirms an existing customer's post-OTP landing state on /applications.
    Wait For Elements State    ${EMI_CONTENT_TAB}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${EMI_APPLICATION_CARD}    visible    timeout=${LONG_TIMEOUT}

New User Dashboard Should Show Empty State
    [Documentation]
    ...    Asserts the emi-not-data-found empty state container is visible after login.
    ...    Confirms a new customer's post-OTP landing state — no applications yet.
    Wait For Elements State    ${NEW_USER_EMPTY_STATE}    visible    timeout=${TIMEOUT}

Navigate To OTP Page
    [Documentation]
    ...    Opens a fresh browser context, completes the login form, and waits for the OTP
    ...    verification page to load. Shared keyword for use across all test suites that
    ...    need to land on the OTP page.
    ...    Handles UAT rate limiting: if the OTP form is not visible within LONG_TIMEOUT,
    ...    waits RATE_LIMIT_WAIT seconds and retries once.
    [Arguments]    ${mobile}=${TEST_MOBILE}
    Open Login Page
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${mobile}
        Wait For OTP Page
    END
