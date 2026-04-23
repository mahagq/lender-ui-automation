*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Personal Details page (/applicant-personal-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects PAN number, gender (react-select), date of birth (year/month/day react-selects),
...    marital status (radio), email address, and consent.
...
...    Session model (used within applicant_journey_tests.robot sequential flow):
...      Visited after /onboarding is submitted.
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (personal details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${PD_TITLE}                         css=[data-testid='personal-details-title']
${PD_FORM}                          css=[data-testid='applicant-personal-details-form']
${PD_PAN_DETAILS_TITLE}             css=[data-testid='pan-details-title']
${PD_PAN_INPUT}                     css=[data-testid='pan-number-input']
${PD_GENDER_TITLE}                  css=[data-testid='gender-title']
${PD_GENDER_SELECT}                 css=[data-testid='gender-react-select']
${PD_DOB_TITLE}                     css=[data-testid='dob-title']
${PD_YEAR_SELECT}                   css=[data-testid='year-react-select']
${PD_MONTH_SELECT}                  css=[data-testid='month-react-select']
${PD_DAY_SELECT}                    css=[data-testid='day-react-select']
${PD_DOB_ERROR}                     css=[data-testid='dob-error']
${PD_MARITAL_STATUS_TITLE}          css=[data-testid='marital-status-title']
${PD_MARITAL_STATUS_RADIO}          css=[data-testid='marital-status-radio']
${PD_EMAIL_TITLE}                   css=[data-testid='email-title']
${PD_EMAIL_INPUT}                   css=[data-testid='email-input']
${PD_CONSENT}                       css=[data-testid='consent-checkbox']
${PD_PROCEED_BUTTON}                css=[data-testid='proceed-button']

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
    Wait For Elements State    ${PD_MARITAL_STATUS_RADIO}    visible    timeout=${TIMEOUT}

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
    ${checked}=    Get Property    ${PD_CONSENT}    checked
    IF    not ${checked}
        Click    ${PD_CONSENT}
    END

Proceed Button Should Be Visible
    [Documentation]
    ...    Asserts the proceed-button on the personal details page is visible.
    ...    Satisfies: TC-10009, U2
    Wait For Elements State    ${PD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}

Click Personal Details Proceed
    [Documentation]
    ...    Clicks the proceed-button to advance to /applicant-residential-details.
    ...    Satisfies: TC-10010, RT-5 (proceed)
    Wait For Elements State    ${PD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${PD_PROCEED_BUTTON}

Personal Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-personal-details.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-personal-details
