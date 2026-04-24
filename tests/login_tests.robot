*** Settings ***
Documentation
...    Login test suite for the GQ Customer Portal.
...    Tests the mobile number login form at ${BASE_URL}.
...
...    Form collects: mobile number (10-digit) + consent checkbox.
...    There is NO email or password field — all tests use mobile number.
...    On valid submission: calls checkMobilePost API → navigates to /verify.
...
...    Covers:
...      - Core login scenarios (valid, empty, invalid format, short, no consent)
...      - URL and title verification
...      - Field visibility and editability
...      - Input validation (spaces, alphabets, alphanumeric, special chars, max length)
...      - OTP redirect with valid mobile numbers
...      - Consent form navigation links (T&C, Privacy Policy)
...      - Send OTP button enabled/disabled states
...
...    Ported from gq_customer_ui_automation (Java/Selenium) — loginPageTest.java.
...    Satisfies: TC-201, TC-207 to TC-220 (excluding TC-202 to TC-206 in left component suite)
...
...    Satisfies: B1 (mobile form, not email/password), B2 (full login coverage),
...               B3 (UAT target), U1 (exact error messages), U3 (redirect assertions),
...               S1 (credentials in variables file), O1 (dry-run safe), O2 (results output)

Library          Browser
Resource         ../resources/LoginPage.robot
Resource         ../resources/OTPPage.robot
Resource         ../variables/variables.robot

Suite Setup      New Browser    ${BROWSER}    headless=${HEADLESS}
Suite Teardown   Close Browser
Test Teardown    Close Context
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Authentication    allure.label.story:Login

*** Test Cases ***

TC-201 Login Page URL And Title Match
    [Documentation]
    ...    Navigates to the base URL and verifies the page URL and browser tab title.
    ...    Tab title: 'Customer Portal: GrayQuest Education Finance' (updated 2026-04-21).
    [Tags]    login    smoke    url
    Open Login Page
    ${url}=    Get Url
    Should Be Equal    ${url}    ${BASE_URL}/
    ${title}=    Get Title
    Should Contain    ${title}    GrayQuest Education Finance

TC-207 Valid Login With Correct Mobile Number
    [Documentation]
    ...    Entering a valid 10-digit mobile number with the consent checkbox checked
    ...    and clicking Send OTP should call checkMobilePost and redirect to /verify.
    ...    Satisfies: B1 (mobile form), B2 (valid path coverage), B3 (UAT), U3 (redirect)
    [Tags]    login    valid    smoke
    Open Login Page
    Submit Login Form    ${TEST_MOBILE}
    Login Should Redirect To OTP Page

TC-208 Mobile Number Input Field Is Visible And Editable
    [Documentation]
    ...    Verifies the mobile number input field is visible and accepts user input.
    [Tags]    login    ui    field
    Open Login Page
    Mobile Input Should Be Visible And Editable

TC-209 Login With Empty Mobile Number
    [Documentation]
    ...    Clicking Send OTP without entering a mobile number should trigger React Hook Form
    ...    validation and render the error: "Please enter your mobile number".
    ...    Satisfies: B2 (empty input coverage), U1 (exact Yup error string), T5 (required field)
    [Tags]    login    validation    negative
    Open Login Page
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter your mobile number

TC-210 Login With Spaces In Mobile Number
    [Documentation]
    ...    Entering only whitespace in the mobile field should be treated as empty
    ...    by React Hook Form — the numeric input filters spaces, leaving the field
    ...    empty and triggering: "Please enter your mobile number".
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${SPACES_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter your mobile number

TC-211 Login With Alphabets In Mobile Number
    [Documentation]
    ...    Entering a purely alphabetic string triggers the mobile regex validation:
    ...    "Please enter valid mobile number".
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${ALPHA_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter valid mobile number

TC-212 Login With Invalid Mobile Number Format
    [Documentation]
    ...    Entering a mobile number containing letters (e.g. "123abc4567") should trigger
    ...    the Regex.mobille_number Yup validation and render: "Please enter valid mobile number".
    ...    Satisfies: B2 (invalid format coverage), U1 (exact Yup error string), T5 (regex validation)
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${WRONG_FORMAT_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter valid mobile number

TC-213 Login With Alphanumeric Mobile Number
    [Documentation]
    ...    Entering a mix of letters and digits triggers the mobile regex validation:
    ...    "Please enter valid mobile number".
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${ALPHANUMERIC_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter valid mobile number

TC-214 Login With Special Characters In Mobile Number
    [Documentation]
    ...    Entering special characters triggers the mobile regex validation:
    ...    "Please enter valid mobile number".
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${SPECIAL_CHAR_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter valid mobile number

TC-215 Login With Short Mobile Number
    [Documentation]
    ...    Entering fewer than 10 digits (e.g. "12345") triggers Yup validation.
    ...    Yup evaluates regex before length — the regex check fires first and renders:
    ...    "Please enter valid mobile number" (same message as invalid format).
    ...    Satisfies: B2 (short input coverage), U1 (exact Yup error string), T5 (length validation)
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${INVALID_MOBILE}
    Check Consent Checkbox
    Click Send OTP Button
    ${error}=    Get Mobile Number Error Message
    Should Be Equal    ${error}    Please enter valid mobile number

TC-216 Mobile Number Field Enforces 10 Digit Max Length
    [Documentation]
    ...    The mobile input has maxLength=10. Entering a 14-digit string should result
    ...    in only the first 10 digits being accepted and stored in the field.
    [Tags]    login    validation    field
    Open Login Page
    Enter Mobile Number    ${LONG_MOBILE}
    ${value}=    Get Mobile Input Value
    Should Be Equal    ${value}    1234567890

TC-217 Valid Mobile Starting With 6 To 9 Navigates To OTP Page
    [Documentation]
    ...    A valid 10-digit mobile number starting with 6, 7, 8, or 9 with consent
    ...    checked should call checkMobilePost and redirect to /verify, showing
    ...    the OTP page title "Enter 4 Digit OTP".
    [Tags]    login    valid    otp-redirect
    Open Login Page
    Submit Login Form    ${EXT_LOGIN_MOBILE_1}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${EXT_LOGIN_MOBILE_1}
        Wait For OTP Page
    END
    ${title}=    Get OTP Page Title
    Should Be Equal    ${title}    Enter 4 Digit OTP

TC-218 Login Without Consent
    [Documentation]
    ...    Entering a valid mobile number but NOT checking the consent checkbox should trigger
    ...    the Yup bool().oneOf([true]) validation and render:
    ...    "Please accept Terms and Conditions".
    ...    Satisfies: B2 (consent coverage), U1 (exact Yup error string), B1 (consent required)
    [Tags]    login    validation    negative
    Open Login Page
    Enter Mobile Number    ${TEST_MOBILE}
    Click Send OTP Button
    ${error}=    Get Consent Error Message
    Should Be Equal    ${error}    Please accept Terms and Conditions

TC-219 Send OTP With Consent Checked Navigates To OTP Page
    [Documentation]
    ...    Entering a valid mobile number and explicitly checking the consent checkbox
    ...    should navigate to /verify and show "Enter 4 Digit OTP".
    [Tags]    login    valid    otp-redirect
    Open Login Page
    Submit Login Form    ${EXT_LOGIN_MOBILE_2}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${EXT_LOGIN_MOBILE_2}
        Wait For OTP Page
    END
    ${title}=    Get OTP Page Title
    Should Be Equal    ${title}    Enter 4 Digit OTP

TC-220 Send OTP Button Is Enabled With Mobile And Consent
    [Documentation]
    ...    Entering a valid mobile number AND checking the consent checkbox
    ...    should enable the Send OTP button.
    [Tags]    login    validation    button-state
    Open Login Page
    Enter Mobile Number    ${TEST_MOBILE}
    Check Consent Checkbox
    Send OTP Button Should Be Enabled

TC-221 Login Form Title Is Visible
    [Documentation]
    ...    The login form should display the title "What is your Mobile Number?"
    ...    via data-testid='desktop-view-form-title'. Satisfies: TC-221
    [Tags]    login    ui    title
    Open Login Page
    ${title}=    Get Login Form Title
    Should Be Equal    ${title}    What is your Mobile Number?

TC-222 Mobile Input Note Text Is Visible
    [Documentation]
    ...    When there is no validation error, a note should appear below the mobile input:
    ...    "Please enter the mobile number which you generally use for your banking purposes."
    ...    data-testid='mobile-number-input-note'. Satisfies: TC-222
    [Tags]    login    ui    note
    Open Login Page
    Mobile Note Should Be Visible
    ${text}=    Get Text    ${MOBILE_NOTE}
    Should Contain    ${text}    Please enter the mobile number which you generally use for your banking purposes

TC-223 Terms Of Service Link In Consent Opens New Tab
    [Documentation]
    ...    The "Terms of Services" link inside the consent label (data-testid='terms-link')
    ...    should open the T&C page in a new tab. Satisfies: TC-223
    [Tags]    login    ui    consent    navigation
    Open Login Page
    ${title}=    Terms Link In Form Opens New Tab
    Should Contain    ${title}    Terms

TC-224 Privacy Policy Link In Consent Opens New Tab
    [Documentation]
    ...    The "Privacy Policy" link inside the consent label (data-testid='privacy-policy-link')
    ...    should open the Privacy Policy page in a new tab. Satisfies: TC-224
    [Tags]    login    ui    consent    navigation
    Open Login Page
    ${title}=    Privacy Link In Form Opens New Tab
    Should Contain    ${title}    Privacy

TC-225 Mobile Number Prefill Via Query Param Navigates To OTP Page
    [Documentation]
    ...    Navigating to /?m=<mobile> pre-fills the mobile field, auto-checks consent,
    ...    and auto-submits (useEffect in Login.jsx). The result should be a redirect to /verify.
    ...    Satisfies: TC-225
    [Tags]    login    valid    query-param
    Open Login Page With Prefill    ${EXT_LOGIN_MOBILE_3}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected during query param prefill test — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page With Prefill    ${EXT_LOGIN_MOBILE_3}
        Wait For OTP Page
    END
    ${url}=    Get Url
    Should Contain    ${url}    /verify

TC-226 Mobile Footer Is Present On Login Page
    [Documentation]
    ...    The MobileFooter component (data-testid='mobile-footer-container') should be
    ...    present in the DOM on the login page. It is rendered for mobile viewports and
    ...    contains the same links/logo as the left panel. Satisfies: TC-226
    [Tags]    login    ui    mobile-footer
    Open Login Page
    Mobile Footer Should Be Present

TC-227 Consent Label Text Contains Sign In Agreement
    [Documentation]
    ...    The consent label (data-testid='consent-checkbox-label') should be visible and
    ...    contain the text "By signing in, I agree to the".
    ...    Satisfies: TC-227
    [Tags]    login    ui    consent
    Open Login Page
    ${text}=    Get Consent Label Text
    Should Contain    ${text}    By signing in, I agree to the

TC-228 Consent Checkbox Label Click Checks Consent Checkbox
    [Documentation]
    ...    Clicking the consent label element (data-testid='consent-checkbox-label') should
    ...    check the underlying consent-checkbox input — the label is wired to the input
    ...    via htmlFor/id in CheckBox.jsx.
    ...    Satisfies: TC-228
    [Tags]    login    ui    consent
    Open Login Page
    Click Consent Checkbox Label
    Get Element States    ${CONSENT_CHECKBOX}    contains    checked
