*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Personal Details page (/applicant-personal-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects PAN number, gender (react-select), date of birth (year/month/day react-selects),
...    marital status (radio), email address, and consent.
...
...    Session model (personal_details_tests.robot):
...      Visited after /get-started is submitted.
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (personal details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${PD_TITLE}                         css=[data-testid='personal-details-title']
${PD_FORM}                          css=input[placeholder='PAN number']
${PD_PAN_DETAILS_TITLE}             css=[data-testid='pan-details-title']
${PD_PAN_INPUT}                     css=input[placeholder='PAN number']
${PD_GENDER_TITLE}                  css=[data-testid='gender-title']
${PD_GENDER_SELECT}                 css=[data-testid='gender-title']
${PD_DOB_TITLE}                     css=[data-testid='dob-title']
${PD_YEAR_SELECT}                   css=[data-testid='year-react-select']
${PD_MONTH_SELECT}                  css=[data-testid='month-react-select']
${PD_DAY_SELECT}                    css=[data-testid='day-react-select']
${PD_DOB_ERROR}                     css=[data-testid='dob-error']
${PD_GENDER_ERROR}                  css=[data-testid='gender-react-select-error']
${PD_MARITAL_STATUS_ERROR}          css=[data-testid='marital-status-radio-error']
${PD_MARITAL_STATUS_TITLE}          css=[data-testid='marital-status-title']
${PD_MARITAL_STATUS_RADIO}          css=[data-testid='marital-status-radio']
${PD_EMAIL_TITLE}                   css=[data-testid='email-title']
${PD_EMAIL_INPUT}                   css=input[placeholder='Email address']
${PD_CONSENT}                       role=checkbox
${PD_PROCEED_BUTTON}                css=button:has-text('Proceed')
${PD_PAN_ERROR}                     css=[data-testid='pan-number-input-error']
${PD_EMAIL_ERROR}                   css=[data-testid='email-input-error']
${PD_CONSENT_ERROR}                 css=[data-testid='consent-checkbox-error']
${PD_GENDER_MALE_RADIO}             css=button[value='MALE']

*** Keywords ***
Personal Details Title Should Be Visible
    [Documentation]
    ...    Asserts the personal-details-title element is visible.
    ...    Satisfies: TC-10001, RT-5, U1
    Wait For Elements State    ${PD_TITLE}    visible    timeout=${TIMEOUT}

Personal Details Form Should Be Visible
    [Documentation]
    ...    Asserts the applicant-personal-details-form container is visible.
    ...    Satisfies: TC-10001, U1
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}

PAN Input Should Be Visible
    [Documentation]
    ...    Asserts the pan-number-input field is visible.
    ...    Satisfies: TC-10002, U1
    Wait For Elements State    ${PD_PAN_INPUT}    visible    timeout=${TIMEOUT}

Gender Section Should Be Visible
    [Documentation]
    ...    Asserts the gender-react-select dropdown is visible.
    ...    Satisfies: TC-10003, U1
    Wait For Elements State    ${PD_GENDER_SELECT}    visible    timeout=${TIMEOUT}

DOB Section Should Be Visible
    [Documentation]
    ...    Asserts all three DOB react-selects (year/month/day) are visible.
    ...    Satisfies: TC-10004, U1
    Wait For Elements State    ${PD_YEAR_SELECT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${PD_MONTH_SELECT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${PD_DAY_SELECT}    visible    timeout=${TIMEOUT}

Marital Status Section Should Be Visible
    [Documentation]
    ...    Asserts at least one marital-status-radio option is visible.
    ...    Satisfies: TC-10005, U1
    Wait For Elements State    ${PD_MARITAL_STATUS_TITLE}    visible    timeout=${TIMEOUT}
    ${count}=    Get Element Count    ${PD_MARITAL_STATUS_RADIO}
    Should Be Equal As Integers    ${count}    3

Email Input Should Be Visible
    [Documentation]
    ...    Asserts the email-input field is visible.
    ...    Satisfies: TC-10006, U1
    Wait For Elements State    ${PD_EMAIL_INPUT}    visible    timeout=${TIMEOUT}

Fill PAN Number
    [Documentation]    Fills the pan-number-input field. PAN is auto-uppercased by the form.
    [Arguments]    ${value}
    Wait For Elements State    ${PD_PAN_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${PD_PAN_INPUT}    ${value}

Fill Email
    [Documentation]    Fills the email-input field.
    [Arguments]    ${value}
    Wait For Elements State    ${PD_EMAIL_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${PD_EMAIL_INPUT}    ${value}

Check Personal Details Consent
    [Documentation]    Checks the consent-checkbox if not already checked.
    ${checked}=    Get Attribute    ${PD_CONSENT}    aria-checked
    IF    '${checked}' != 'true'
        Click    ${PD_CONSENT}
    END

Proceed Button Should Be Visible
    [Documentation]
    ...    Asserts the proceed-button on the personal details page is visible.
    ...    Satisfies: TC-10009, U2
    Wait For Elements State    ${PD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}

Select Gender Male
    [Documentation]
    ...    Selects the Male gender radio button using css=button[value='MALE'].
    ...    Uses the value attribute (MALE/FEMALE) to avoid strict mode — both radio buttons share data-testid='gender-react-select'.
    ...    Satisfies: TC-10N-04, TC-10N-07, TC-10N-08, TC-10N-09, TC-10N-10, TC-10008
    Wait For Elements State    ${PD_GENDER_MALE_RADIO}    visible    timeout=${TIMEOUT}
    Click    ${PD_GENDER_MALE_RADIO}

Click Personal Details Proceed
    [Documentation]
    ...    Waits for the proceed-button to become enabled, then clicks it to advance to /applicant-address.
    ...    Uses LONG_TIMEOUT to allow React form state to settle after all fields are filled.
    ...    Satisfies: TC-10010, RT-5 (proceed)
    Wait For Elements State    ${PD_PROCEED_BUTTON}    enabled    timeout=${LONG_TIMEOUT}
    Click    ${PD_PROCEED_BUTTON}

Force Click Personal Details Proceed
    [Documentation]
    ...    Triggers form validation on the proceed-button even when it is disabled.
    ...    Used for tests where a required field (gender/DOB/marital) is intentionally omitted.
    ...    Uses Evaluate JavaScript to dispatch a bubbling MouseEvent — bypasses the browser's
    ...    disabled-element click suppression and reaches React's root event delegation listener.
    ...    Satisfies: TC-10N-08, TC-10N-09, TC-10N-10
    Evaluate JavaScript    ${PD_PROCEED_BUTTON}    (element) => element.dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true}))
    Sleep    500ms

Click Close Button
    [Documentation]    Clicks close-button on /applicant-personal-details and waits for dashboard URL.
    Click    css=[data-testid='close-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Personal Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-personal-details.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-personal-details

PAN Error Should Be Visible
    [Documentation]
    ...    Asserts pan-number-input-error is visible after proceed with invalid/empty PAN.
    ...    Satisfies: TC-10N-01, TC-10N-02, TC-10N-03
    Wait For Elements State    ${PD_PAN_ERROR}    visible    timeout=${TIMEOUT}

Email Error Should Be Visible
    [Documentation]
    ...    Asserts email-input-error is visible after proceed with invalid/empty email.
    ...    Satisfies: TC-10N-04, TC-10N-05, TC-10N-06
    Wait For Elements State    ${PD_EMAIL_ERROR}    visible    timeout=${TIMEOUT}

Personal Details Consent Error Should Be Visible
    [Documentation]
    ...    Asserts consent-checkbox-error is visible after proceed without consent checked.
    ...    Satisfies: TC-10N-07
    Wait For Elements State    ${PD_CONSENT_ERROR}    visible    timeout=${TIMEOUT}

Uncheck Personal Details Consent
    [Documentation]    Unchecks the consent-checkbox on personal details if currently checked.
    ${checked}=    Get Attribute    ${PD_CONSENT}    aria-checked
    IF    '${checked}' == 'true'
        Click    ${PD_CONSENT}
    END

Gender Error Should Be Visible
    [Documentation]
    ...    Asserts gender-error is visible after proceed without selecting gender.
    ...    Satisfies: TC-10N-08
    Wait For Elements State    ${PD_GENDER_ERROR}    visible    timeout=${TIMEOUT}

DOB Error Should Be Visible
    [Documentation]
    ...    Asserts dob-error is visible after proceed without completing date of birth.
    ...    Satisfies: TC-10N-09
    Wait For Elements State    ${PD_DOB_ERROR}    visible    timeout=${TIMEOUT}

Marital Status Error Should Be Visible
    [Documentation]
    ...    Asserts marital-status-error is visible after proceed without selecting marital status.
    ...    Satisfies: TC-10N-10
    Wait For Elements State    ${PD_MARITAL_STATUS_ERROR}    visible    timeout=${TIMEOUT}
