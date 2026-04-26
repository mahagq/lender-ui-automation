*** Settings ***
Documentation
...    Independent test suite for the GQ Customer Portal Applicant Basic Details page (/applicant-basic-details).
...    Covers TC-8001–TC-8014-S and TC-8008 (proceed to onboarding).
...
...    Session model:
...      Suite Setup    → Navigate To Applicant Basic Details (full wizard traversal)
...      Test Setup     → Navigate To Basic Details Within Session (Go To)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    TC-8008 (proceed → onboarding) runs LAST — advances wizard past basic-details.
...    TC-8013 + TC-8014 are sequential (close → resume). TC-8014-S is the standalone version.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-5, T1, U1, U2

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/ApplicantBasicDetailsPage.robot
Resource    ../variables/variables.robot
Variables   ../variables/dynamic_variables.py

Suite Setup     Navigate To Applicant Basic Details
Suite Teardown  Close Browser
Test Setup      Navigate To Basic Details Within Session
Test Tags       applicant-basic-details    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Applicant Basic Details

*** Test Cases ***
TC-8001 Basic Details Title Is Visible
    [Documentation]    Verifies applicant-basic-details-title is visible.
    [Tags]    smoke
    Basic Details Title Should Be Visible

TC-8002 Basic Details Form Elements Are Visible
    [Documentation]    Verifies all key form elements (name inputs, consent, submit) are visible.
    Basic Details Form Elements Should Be Visible

TC-8003 Basic Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-basic-details.
    Basic Details URL Should Be Active

TC-8004 First Name Input Accepts Text
    [Documentation]    Verifies first-name-input accepts text input.
    Fill Basic Details First Name    TestFirst

TC-8005 Last Name Input Accepts Text
    [Documentation]    Verifies last-name-input accepts text input.
    Fill Basic Details Last Name    TestLast

TC-8006 Submit Empty Form Shows Errors And User Cannot Proceed
    [Documentation]
    ...    Verifies clicking submit with all fields empty shows both first-name and
    ...    last-name validation errors and user stays on /applicant-basic-details.
    ...    Ref: recordings/login_20260426_204159.js
    Fill Basic Details First Name    ${EMPTY}
    Fill Basic Details Last Name    ${EMPTY}
    Uncheck Basic Details Consent
    Click Submit Basic Details
    First Name Error Should Be Visible
    Last Name Error Should Be Visible
    Basic Details URL Should Be Active

TC-8007 Submit Button Is Enabled With Valid Data
    [Documentation]    Verifies submit-button is enabled after filling names and checking consent.
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Check Basic Details Consent
    Submit Button Should Be Enabled With Valid Data

TC-8009 Basic Details Info Section Is Visible
    [Documentation]    Verifies applicant-basic-details-info element is visible.
    Basic Details Info Should Be Visible

TC-8N-01 Submit Empty Form Shows First And Last Name Errors
    [Documentation]
    ...    Verifies both first-name-input-error and last-name-input-error appear
    ...    when submit is clicked with both name fields empty.
    [Tags]    negative
    Click Submit Basic Details
    First Name Error Should Be Visible
    Last Name Error Should Be Visible

TC-8N-02 Submit With Only First Name Shows Last Name Error
    [Documentation]    Verifies last-name-input-error appears when only first name is filled.
    [Tags]    negative
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Click Submit Basic Details
    Last Name Error Should Be Visible

TC-8N-03 Submit With Only Last Name Shows First Name Error
    [Documentation]    Verifies first-name-input-error appears when only last name is filled.
    [Tags]    negative
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Click Submit Basic Details
    First Name Error Should Be Visible

TC-8N-04 Submit With Valid Names And Consent Unchecked Shows Consent Error
    [Documentation]
    ...    Verifies consent-checkbox-error appears when names are filled but consent is unchecked.
    [Tags]    negative
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Uncheck Basic Details Consent
    Click Submit Basic Details
    Consent Error Should Be Visible

TC-8N-05 Submit With Only Consent Checked Shows Name Errors And User Cannot Proceed
    [Documentation]
    ...    Verifies that clicking submit with consent checked but both name fields empty
    ...    shows first-name and last-name errors and user stays on /applicant-basic-details.
    [Tags]    negative
    Check Basic Details Consent
    Click Submit Basic Details
    First Name Error Should Be Visible
    Last Name Error Should Be Visible
    Basic Details URL Should Be Active

TC-8N-06 Submit With First Name And Consent But No Last Name Shows Last Name Error
    [Documentation]
    ...    Verifies that clicking submit with first name and consent filled but last name
    ...    empty shows last-name error and user stays on /applicant-basic-details.
    [Tags]    negative
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Check Basic Details Consent
    Click Submit Basic Details
    Last Name Error Should Be Visible
    Basic Details URL Should Be Active

TC-8N-07 Numeric First Name Shows First Name Error
    [Documentation]    Verifies first-name-input-error appears when first name contains only numbers.
    [Tags]    negative
    Fill Basic Details First Name    12345
    Click Submit Basic Details
    First Name Error Should Be Visible

TC-8N-08 Numeric Last Name Shows Last Name Error
    [Documentation]    Verifies last-name-input-error appears when last name contains only numbers.
    [Tags]    negative
    Fill Basic Details Last Name    12345
    Click Submit Basic Details
    Last Name Error Should Be Visible

TC-8N-09 Special Chars In First Name Show First Name Error
    [Documentation]    Verifies first-name-input-error appears when first name contains special characters.
    [Tags]    negative
    Fill Basic Details First Name    Test@#1
    Click Submit Basic Details
    First Name Error Should Be Visible

TC-8N-10 Special Chars In Last Name Show Last Name Error
    [Documentation]    Verifies last-name-input-error appears when last name contains special characters.
    [Tags]    negative
    Fill Basic Details Last Name    Test@#1
    Click Submit Basic Details
    Last Name Error Should Be Visible

TC-8012 Back Button Navigates To Select Applicant
    [Documentation]    Verifies back-button on /applicant-basic-details navigates to /select-applicant.
    Navigate Back From Basic Details
    ${url}=    Get Url
    Should Contain    ${url}    /select-applicant

TC-8013 Close Button Navigates To Dashboard
    [Documentation]    Verifies close-button on /applicant-basic-details navigates to /my-applications.
    Click Close Button Basic Details
    ${url}=    Get Url
    Should Contain    ${url}    /my-applications

#in sequence with TC-8013
TC-8014 Resume Application Returns To Basic Details
    [Documentation]
    ...    Verifies that resuming the in-progress application from the dashboard
    ...    navigates back to /applicant-basic-details.
    ...    Runs sequentially after TC-8013 (which leaves session on /my-applications).
    [Setup]    NONE
    Resume Existing Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

#seperate test case for standalone version of TC-8014
TC-8014-S Close And Resume Basic Details Standalone
    [Documentation]
    ...    Standalone version of TC-8013 + TC-8014 combined.
    ...    Navigates to /applicant-basic-details, clicks close to go to /my-applications,
    ...    resumes the application via the dashboard card, and verifies return to /applicant-basic-details.
    ...    Can be run independently without relying on TC-8013 session state.
    Click Close Button Basic Details
    ${url}=    Get Url
    Should Contain    ${url}    /my-applications
    Resume Existing Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

TC-8008 Basic Details Proceeds To Onboarding
    [Documentation]
    ...    Fills valid data, clicks submit, and verifies navigation to /onboarding.
    ...    Runs LAST — advances wizard past basic-details.
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Check Basic Details Consent
    Click Submit Basic Details
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active
