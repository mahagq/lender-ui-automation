*** Settings ***
Documentation
...    Login test suite for the GQ Customer Portal.
...    Tests the mobile number login form at ${BASE_URL}.
...
...    Form collects: mobile number (10-digit) + consent checkbox.
...    There is NO email or password field — all tests use mobile number.
...    On valid submission: calls checkMobilePost API → navigates to /verify.
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

Valid Login With Correct Mobile Number
    [Documentation]
    ...    Entering a valid 10-digit mobile number with the consent checkbox checked
    ...    and clicking Send OTP should call checkMobilePost and redirect to /verify.
    ...    Satisfies: B1 (mobile form), B2 (valid path coverage), B3 (UAT), U3 (redirect)
    [Tags]    login    valid    smoke
    Open Login Page
    Submit Login Form    ${TEST_MOBILE}
    Login Should Redirect To OTP Page

Login With Empty Mobile Number
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

Login With Invalid Mobile Number Format
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

Login With Short Mobile Number
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

Login Without Consent
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
