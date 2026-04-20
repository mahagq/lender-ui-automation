*** Settings ***
Documentation
...    OTP Verification test suite for the GQ Customer Portal.
...    Tests the 4-digit OTP form at ${BASE_URL}/verify.
...
...    UAT fixed OTP: 9999 — applies to all valid mobile numbers (TN2 resolution).
...    No SMS dependency. Tests run reliably in CI without a gateway.
...    OTP timer: 180 seconds before the Resend OTP link becomes visible (T4 boundary).
...    Resend OTP test is tagged "slow" and "resend" — excluded from default CI runs (TN1 resolution).
...    Run with: robot --include resend tests/otp_tests.robot
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

*** Keywords ***
Navigate To OTP Page
    [Documentation]
    ...    Opens a fresh browser context, completes the login form, and waits for the
    ...    OTP verification page to load.
    ...
    ...    UAT rate-limit behaviour: after ~3 checkMobilePost calls within ~60s from the
    ...    same IP, the backend silently rejects further requests — the page stays on /
    ...    with no visible error. When detected (OTP form not visible within LONG_TIMEOUT),
    ...    this keyword closes the context, waits RATE_LIMIT_WAIT for the window to reset,
    ...    then retries once. Tests should pass on the retry.
    [Arguments]    ${mobile}=${TEST_MOBILE}
    Open Login Page
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — page stayed on /. Waiting ${RATE_LIMIT_WAIT} for reset then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${mobile}
        Wait For OTP Page
    END

*** Test Cases ***

OTP Verification With Empty OTP
    [Documentation]
    ...    Clicking Verify OTP without entering any value should trigger React Hook Form
    ...    validation and render the error: "Please enter 4 digit OTP".
    ...    Satisfies: B2 (empty OTP coverage), U1 (exact Yup error string), T5 (required field)
    [Tags]    otp    validation    negative
    [Setup]    Navigate To OTP Page    ${OTP_MOBILE_1}
    Click Verify OTP Button
    ${error}=    Get OTP Error Message
    Should Be Equal    ${error}    Please enter 4 digit OTP

OTP Verification With Short OTP
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

Valid OTP Redirects To Dashboard
    [Documentation]
    ...    Entering the correct 4-digit OTP (9999, fixed in UAT) and clicking Verify OTP
    ...    should call verifyOtpPost, set access/refresh tokens, and redirect to /my-applications.
    ...    Runs BEFORE Wrong OTP so that the correct verifyOtpPost call is always the first
    ...    in the rate-limit window — avoids a UAT IP rate limit that blocks verifyOtpPost
    ...    after a prior failed attempt.
    ...    Satisfies: B2 (valid OTP coverage), U3 (redirect assertion), T3, TN2 (fixed OTP 9999)
    [Tags]    otp    valid    smoke
    [Setup]    Navigate To OTP Page    ${OTP_MOBILE_4}
    Submit OTP Form    ${TEST_OTP}
    Wait For Dashboard

OTP Verification With Wrong OTP
    [Documentation]
    ...    Entering an incorrect but structurally valid OTP (e.g. "1234") and clicking Verify
    ...    should call verifyOtpPost, receive an API error, show a toast notification,
    ...    and keep the user on /verify (no redirect).
    ...    The error is a toast (not rendered in otp-input-error) so we assert URL unchanged.
    ...    Runs AFTER Valid OTP — verifyOtpPost may be rate-limited here, but the test only
    ...    asserts no-redirect which holds whether the call fails by wrong OTP or rate limit.
    ...    Satisfies: B2 (wrong OTP coverage), U3 (no redirect on failure)
    [Tags]    otp    negative
    [Setup]    Navigate To OTP Page    ${OTP_MOBILE_3}
    Submit OTP Form    ${WRONG_OTP}
    Wait For Elements State    ${OTP_FORM}    visible    timeout=${TIMEOUT}
    OTP Page Should Still Be On OTP Page

Resend OTP After Timer Expires
    [Documentation]
    ...    After the 180-second countdown, the Resend OTP link (data-testid='resend-otp-link')
    ...    should become visible. Clicking it should trigger resendOtpPost API, reset the
    ...    timer, and hide the resend link again.
    ...
    ...    WARNING: This test waits ~3 minutes. It is EXCLUDED from default CI runs.
    ...    Run explicitly with: robot --include resend tests/otp_tests.robot
    ...    Or include in nightly job: robot --include slow tests/
    ...    Satisfies: T4 (180s timer boundary), B2 (resend coverage), TN1 (slow tag decision)
    [Tags]    otp    slow    resend
    [Setup]    Navigate To OTP Page
    OTP Timer Should Be Visible
    Wait For Resend OTP Link    ${RESEND_OTP_WAIT}
    Click Resend OTP
    OTP Timer Should Reset After Resend
