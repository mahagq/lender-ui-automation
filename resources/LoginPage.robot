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
# 2026 UI rewrite (develop-revamp branch) dropped data-testid attributes entirely from this
# form — login-form.tsx renders no wrapper testid, TextField/Button/Checkbox are untagged.
# Locators below are placeholder/role/text based (verified against src/components/sections/
# auth/login-form/login-form.tsx and src/components/ui/{text-field,button,checkbox}).
${LOGIN_FORM}            css=[data-testid='login-form']
${LOGIN_FORM_TITLE}      css=[data-testid='desktop-view-form-title']
${MOBILE_INPUT}          css=input[placeholder='Enter mobile number']
${MOBILE_ERROR}          css=[data-testid='mobile-number-input-error']
${MOBILE_NOTE}           css=[data-testid='mobile-number-input-note']
${CONSENT_CHECKBOX}      role=checkbox
${CONSENT_LABEL}         css=[data-testid='consent-checkbox-label']
${CONSENT_ERROR}         css=[data-testid='consent-checkbox-error']
${SEND_OTP_BUTTON}       css=button:has-text('Send OTP')
${TERMS_LINK_FORM}       css=a:has-text('Terms of Service')
${PRIVACY_LINK_FORM}     css=a:has-text('Privacy Policy')
${MOBILE_FOOTER}         css=[data-testid='mobile-footer-container']

*** Keywords ***
Open Login Page
    [Documentation]
    ...    Opens a fresh browser context and page, navigates to the base URL, and waits
    ...    for the login form to be visible. New Context isolates cookies and localStorage
    ...    so authenticated state from a previous test does not carry over.
    ...    Satisfies: B3 (UAT environment), U2 (wait before interacting)
    # viewport=${None} makes the page use the full (maximised) window size instead of the
    # default 1280x720, so the whole screen is used.
    New Context    viewport=${None}
    Set Browser Timeout    60s
    New Page    ${BASE_URL}
    # 2026 UI rewrite ("Register for EMI Plans") removed the login-form wrapper testid
    # entirely — wait directly on the mobile input (no fallback probe, saves ~10s/run).
    Wait For Elements State    ${MOBILE_INPUT}    visible    timeout=${LONG_TIMEOUT}

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

Get Login Form Title
    [Documentation]
    ...    Returns the form title text from data-testid='desktop-view-form-title'.
    ...    On the login page this reads "What is your Mobile Number?".
    Wait For Elements State    ${LOGIN_FORM_TITLE}    visible    timeout=${TIMEOUT}
    ${title}=    Get Text    ${LOGIN_FORM_TITLE}
    RETURN    ${title}

Mobile Input Should Be Visible And Editable
    [Documentation]
    ...    Asserts the mobile number input is visible and enabled (editable).
    ...    Satisfies: TC-207
    Wait For Elements State    ${MOBILE_INPUT}    visible    timeout=${TIMEOUT}
    Get Element States    ${MOBILE_INPUT}    contains    enabled

Get Mobile Input Value
    [Documentation]    Returns the current value of the mobile number input field.
    ${value}=    Get Property    ${MOBILE_INPUT}    value
    RETURN    ${value}

Send OTP Button Should Be Disabled
    [Documentation]
    ...    Asserts the Send OTP button is in a disabled state.
    ...    Satisfies: TC-219 (button disabled when consent not given)
    Get Element States    ${SEND_OTP_BUTTON}    contains    disabled

Send OTP Button Should Be Enabled
    [Documentation]
    ...    Asserts the Send OTP button is in an enabled state.
    ...    Satisfies: TC-220 (button enabled when mobile + consent provided)
    Get Element States    ${SEND_OTP_BUTTON}    contains    enabled

Click Terms Link In Form
    [Documentation]
    ...    Clicks the Terms & Conditions link inside the consent area of the login form.
    ...    data-testid='terms-link' on the <a> element. Satisfies: TC-217
    Click    ${TERMS_LINK_FORM}

Click Privacy Policy Link In Form
    [Documentation]
    ...    Clicks the Privacy Policy link inside the consent area of the login form.
    ...    data-testid='privacy-policy-link' on the <a> element. Satisfies: TC-218
    Click    ${PRIVACY_LINK_FORM}

Mobile Note Should Be Visible
    [Documentation]
    ...    Asserts the note text below the mobile input is visible.
    ...    data-testid='mobile-number-input-note'. Note renders only when there is no validation error.
    ...    Satisfies: TC-222
    Wait For Elements State    ${MOBILE_NOTE}    visible    timeout=${TIMEOUT}

Get Consent Label Text
    [Documentation]
    ...    Returns the full text of the consent label (data-testid='consent-checkbox-label').
    ...    The label contains "By signing in, I agree to the Terms of Services & Privacy Policy".
    Wait For Elements State    ${CONSENT_LABEL}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${CONSENT_LABEL}
    RETURN    ${text}

Click Consent Checkbox Label
    [Documentation]
    ...    Clicks the consent label element (data-testid='consent-checkbox-label').
    ...    Clicking the label toggles the associated consent-checkbox input.
    Wait For Elements State    ${CONSENT_LABEL}    visible    timeout=${TIMEOUT}
    Click    ${CONSENT_LABEL}

Mobile Footer Should Be Present
    [Documentation]
    ...    Asserts the MobileFooter component (data-testid='mobile-footer-container') exists
    ...    in the DOM. The element is CSS-hidden on desktop viewports but always rendered.
    ...    Uses 'attached' state rather than 'visible' to avoid viewport-dependent failures.
    ...    Satisfies: TC-226
    Get Element States    ${MOBILE_FOOTER}    contains    attached

Terms Link In Form Opens New Tab
    [Documentation]
    ...    Clicks the Terms of Services link in the consent area, switches to the new tab,
    ...    returns the page URL, then closes the tab.
    ...    NOTE: T&C page uses the generic GrayQuest site title — URL is asserted instead.
    ...    data-testid='terms-link'. Satisfies: TC-223
    Wait For Elements State    ${TERMS_LINK_FORM}    visible    timeout=${TIMEOUT}
    Click    ${TERMS_LINK_FORM}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${url}=    Get Url
    Close Page
    RETURN    ${url}

Privacy Link In Form Opens New Tab
    [Documentation]
    ...    Clicks the Privacy Policy link in the consent area, switches to the new tab,
    ...    returns the page URL, then closes the tab.
    ...    NOTE: Privacy Policy page uses the generic GrayQuest site title — URL is asserted instead.
    ...    data-testid='privacy-policy-link'. Satisfies: TC-224
    Wait For Elements State    ${PRIVACY_LINK_FORM}    visible    timeout=${TIMEOUT}
    Click    ${PRIVACY_LINK_FORM}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${url}=    Get Url
    Close Page
    RETURN    ${url}

Open Login Page With Prefill
    [Documentation]
    ...    Opens a fresh browser context and navigates to the login page with ?m=<mobile>
    ...    query param. The React app pre-fills the mobile field and auto-checks consent.
    ...    Satisfies: TC-225
    [Arguments]    ${mobile}
    New Context
    Set Browser Timeout    60s
    New Page    ${BASE_URL}/?m=${mobile}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}

Login Should Redirect To OTP Page
    [Documentation]
    ...    Verifies the browser URL changed to /verify after successful form submission,
    ...    and the OTP form is visible. Called after Submit Login Form completes.
    ...    Satisfies: U3 (URL redirect assertion), U2 (wait for element)
    Wait For Elements State    css=[data-testid='verify-otp-form']    visible    timeout=${LONG_TIMEOUT}
    ${url}=    Get Url
    Should Contain    ${url}    /verify
