*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Basic Details page (/applicant-basic-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects the applicant's first name, last name, and consent.
...    This page applies to both Parent/Guardian and Student applicant types.
...
...    Session model (used within applicant_journey_tests.robot sequential flow):
...      Suite Setup   → Navigate To Applicant Basic Details (ApplicationCreationFlowPage.robot)
...      Test Teardown → NONE (shared session — sequential journey tests)
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (basic details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${BD_TITLE}                     css=[data-testid='applicant-basic-details-title']
${BD_NOTE}                      css=[data-testid='applicant-basic-details-note']
${BD_FIRST_NAME}                css=[data-testid='first-name-input']
${BD_LAST_NAME}                 css=[data-testid='last-name-input']
${BD_CONSENT}                   css=[data-testid='consent-checkbox']
${BD_SUBMIT_BUTTON}             css=[data-testid='submit-button']

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
    ...    Satisfies: TC-8008, U2
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
