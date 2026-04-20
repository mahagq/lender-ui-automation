*** Settings ***
Documentation
...    Page object keywords for the Login page (/).
...    All locators use data-testid attributes derived from LoginForm.jsx in gqcustomer_frontend.
...    Library: Browser (Playwright) v19.9.0 — TN3 resolution.
...
...    Key selectors confirmed from source:
...      Login form:        data-testid='login-form'        (LoginForm.jsx line 19)
...      Mobile input:      data-testid='mobile-number-input' (Input atom, testIdFor prop)
...      Mobile error:      data-testid='mobile-number-input-error' (Input atom)
...      Consent checkbox:  data-testid='consent-checkbox'  (CheckBox atom, testIdFor prop)
...      Consent error:     data-testid='consent-checkbox-error' (CheckBox atom)
...      Send OTP button:   data-testid='send-otp-button'   (LoginForm.jsx line 88)
...
...    Satisfies: T1 (data-testid locators), T5 (exact field constraints), U1 (error messages),
...               U2 (explicit waits), B1 (mobile number form), TN3 (Browser library)

Library     Browser
# Note: variables (BASE_URL, TEST_MOBILE, TIMEOUT, etc.) are imported by test suite files.
# Resource files do not import Variables directly — Robot Framework shares the suite variable scope.

*** Variables ***
# Locators — derived from data-testid attributes in gqcustomer_frontend source
# Satisfies: T1 (all locators use data-testid, no CSS classes or absolute XPath)
${LOGIN_FORM}            css=[data-testid='login-form']
${MOBILE_INPUT}          css=[data-testid='mobile-number-input']
${MOBILE_ERROR}          css=[data-testid='mobile-number-input-error']
${CONSENT_CHECKBOX}      css=[data-testid='consent-checkbox']
${CONSENT_ERROR}         css=[data-testid='consent-checkbox-error']
${SEND_OTP_BUTTON}       css=[data-testid='send-otp-button']

*** Keywords ***
Open Login Page
    [Documentation]
    ...    Opens a fresh browser context and page, navigates to the base URL, and waits
    ...    for the login form to be visible. New Context isolates cookies and localStorage
    ...    so authenticated state from a previous test does not carry over.
    ...    Satisfies: B3 (UAT environment), U2 (wait before interacting)
    New Context
    New Page    ${BASE_URL}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}

Enter Mobile Number
    [Documentation]
    ...    Types the given mobile number into the mobile number input field.
    ...    Field accepts 10-digit numeric input (maxLength=10, inputMode='numeric').
    ...    Satisfies: T1 (data-testid locator), T5 (field constraints from source)
    [Arguments]    ${mobile_number}
    Fill Text    ${MOBILE_INPUT}    ${mobile_number}

Check Consent Checkbox
    [Documentation]
    ...    Checks the consent checkbox (I agree to Terms of Services & Privacy Policy).
    ...    The checkbox input has data-testid='consent-checkbox' directly on the <input> element
    ...    (confirmed from CheckBox.jsx — testIdFor prop maps to data-testid on <input type="checkbox">).
    ...    Satisfies: T1 (data-testid locator), B1 (consent is required by the form schema)
    Check Checkbox    ${CONSENT_CHECKBOX}

Click Send OTP Button
    [Documentation]
    ...    Clicks the Send OTP submit button. The button triggers form validation
    ...    and, if valid, calls checkMobilePost API and navigates to /verify.
    ...    Satisfies: T1 (data-testid locator)
    Click    ${SEND_OTP_BUTTON}

Submit Login Form
    [Documentation]
    ...    Full login form submission: enter mobile number, check consent, click Send OTP.
    ...    Default mobile number is ${TEST_MOBILE} from variables file.
    ...    Satisfies: B1 (mobile form flow), B3 (UAT), T1, TN4 (no hardcoded values)
    [Arguments]    ${mobile_number}=${TEST_MOBILE}
    Enter Mobile Number    ${mobile_number}
    Check Consent Checkbox
    Click Send OTP Button

Get Mobile Number Error Message
    [Documentation]
    ...    Returns the validation error text rendered in data-testid='mobile-number-input-error'.
    ...    Waits for the error element to become visible before reading.
    ...    Satisfies: U1 (exact validation message assertion), T1 (data-testid), U2 (explicit wait)
    Wait For Elements State    ${MOBILE_ERROR}    visible    timeout=${TIMEOUT}
    ${error_text}=    Get Text    ${MOBILE_ERROR}
    RETURN    ${error_text}

Get Consent Error Message
    [Documentation]
    ...    Returns the validation error text rendered in data-testid='consent-checkbox-error'.
    ...    Waits for the error element to become visible before reading.
    ...    Satisfies: U1 (exact validation message assertion), T1 (data-testid), U2 (explicit wait)
    Wait For Elements State    ${CONSENT_ERROR}    visible    timeout=${TIMEOUT}
    ${error_text}=    Get Text    ${CONSENT_ERROR}
    RETURN    ${error_text}

Login Should Redirect To OTP Page
    [Documentation]
    ...    Verifies the browser URL changed to /verify after successful form submission,
    ...    and the OTP form is visible. Called after Submit Login Form completes.
    ...    Satisfies: U3 (URL redirect assertion), U2 (wait for element)
    Wait For Elements State    css=[data-testid='verify-otp-form']    visible    timeout=${LONG_TIMEOUT}
    ${url}=    Get Url
    Should Contain    ${url}    /verify
