*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Basic Details page (/applicant-basic-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects the applicant's first name, last name, and consent.
...    This page applies to both Parent/Guardian and Student applicant types.
...
...    Session model (applicant_basic_details_tests.robot):
...      Suite Setup   → Navigate To Applicant Basic Details (ApplicationCreationFlowPage.robot)
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (basic details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${BD_TITLE}                     css=[data-testid='applicant-basic-details-title']
${BD_NOTE}                      css=[data-testid='applicant-basic-details-note']
${BD_INFO}                      css=[data-testid='applicant-basic-details-info']
${BD_FIRST_NAME}                css=[data-testid='first-name-input']
${BD_LAST_NAME}                 css=[data-testid='last-name-input']
${BD_FIRST_NAME_ERROR}          css=[data-testid='first-name-input-error']
${BD_LAST_NAME_ERROR}           css=[data-testid='last-name-input-error']
${BD_CONSENT}                   css=[data-testid='consent-checkbox']
${BD_CONSENT_ERROR}             css=[data-testid='consent-checkbox-error']
${BD_SUBMIT_BUTTON}             css=[data-testid='submit-button']
${BD_BACK_BUTTON}               css=[data-testid='back-button']
${BD_CLOSE_BUTTON}              css=[data-testid='close-button']

*** Keywords ***
Basic Details Title Should Be Visible
    [Documentation]
    ...    Asserts the applicant-basic-details-title element is visible.
    ...    Satisfies: TC-8001, RT-5, U1
    Wait For Elements State    ${BD_TITLE}    visible    timeout=${TIMEOUT}

Basic Details Form Elements Should Be Visible
    [Documentation]
    ...    Asserts all key form elements on the basic details page are visible.
    ...    Satisfies: TC-8001, U1
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${BD_LAST_NAME}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${BD_CONSENT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${BD_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}

Fill Basic Details First Name
    [Documentation]    Fills the first-name-input field.
    [Arguments]    ${value}
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${value}

Fill Basic Details Last Name
    [Documentation]    Fills the last-name-input field.
    [Arguments]    ${value}
    Wait For Elements State    ${BD_LAST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_LAST_NAME}    ${value}

Check Basic Details Consent
    [Documentation]
    ...    Checks the consent-checkbox if it is not already checked.
    ...    Satisfies: TC-8007
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    not ${checked}
        Click    ${BD_CONSENT}
    END

Submit Button Should Be Disabled Without Data
    [Documentation]
    ...    Asserts the submit-button is disabled when required fields are empty.
    ...    NOTE: /applicant-basic-details submit button does NOT use the HTML disabled
    ...    attribute or aria-disabled. Button is always clickable; validation errors appear
    ...    on submit. TC-8006, TC-8N-05, TC-8N-06 are skipped pending UX clarification.
    ...    Satisfies: TC-8006, U2
    Wait For Elements State    ${BD_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${BD_SUBMIT_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Submit button should be disabled when name fields are empty.

Submit Button Should Be Enabled With Valid Data
    [Documentation]
    ...    Asserts the submit-button is enabled when all required fields are filled.
    ...    Satisfies: TC-8009, U2
    Wait For Elements State    ${BD_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${BD_SUBMIT_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Submit button should be enabled with valid name and consent.

Click Submit Basic Details
    [Documentation]
    ...    Clicks the submit-button to proceed to /onboarding.
    ...    Satisfies: TC-8010, RT-5 (proceed)
    Wait For Elements State    ${BD_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${BD_SUBMIT_BUTTON}

Basic Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-basic-details.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-basic-details

Basic Details Info Should Be Visible
    [Documentation]
    ...    Asserts applicant-basic-details-info element is visible.
    ...    Satisfies: TC-8009
    Wait For Elements State    ${BD_INFO}    visible    timeout=${TIMEOUT}

First Name Error Should Be Visible
    [Documentation]
    ...    Asserts first-name-input-error is visible after submit with empty first name.
    ...    Satisfies: TC-8N-01, TC-8N-03
    Wait For Elements State    ${BD_FIRST_NAME_ERROR}    visible    timeout=${TIMEOUT}

Last Name Error Should Be Visible
    [Documentation]
    ...    Asserts last-name-input-error is visible after submit with empty last name.
    ...    Satisfies: TC-8N-01, TC-8N-02
    Wait For Elements State    ${BD_LAST_NAME_ERROR}    visible    timeout=${TIMEOUT}

Consent Error Should Be Visible
    [Documentation]
    ...    Asserts consent-checkbox-error is visible after submit without consent.
    ...    Satisfies: TC-8N-04
    Wait For Elements State    ${BD_CONSENT_ERROR}    visible    timeout=${TIMEOUT}

Uncheck Basic Details Consent
    [Documentation]    Unchecks the consent-checkbox if it is currently checked.
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    ${checked}
        Click    ${BD_CONSENT}
    END

Navigate Back From Basic Details
    [Documentation]
    ...    Clicks back-button on /applicant-basic-details to return to /select-applicant.
    ...    Satisfies: TC-8012
    Wait For Elements State    ${BD_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${BD_BACK_BUTTON}

Click Close Button Basic Details
    [Documentation]
    ...    Clicks the close-button on /applicant-basic-details and waits for dashboard URL.
    ...    Satisfies: TC-8013
    Wait For Elements State    ${BD_CLOSE_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${BD_CLOSE_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Resume Existing Application
    [Documentation]
    ...    Clicks the EMI card action button to resume the in-progress application.
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    1s    Click    css=[data-testid='emi-card-action-button']    
