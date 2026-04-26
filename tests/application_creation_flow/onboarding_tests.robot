*** Settings ***
Documentation
...    Independent test suite for the GQ Customer Portal Onboarding page (/onboarding).
...    All tests are self-contained — no dependency on applicant_journey_tests.robot.
...
...    Session model:
...      Suite Setup    → Navigate To Onboarding (full wizard traversal to /onboarding)
...      Test Setup     → Navigate To Onboarding Within Session (Go To)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    TC-9003 (Proceed → /applicant-personal-details) runs LAST with [Setup] NONE
...    because TC-9N-01 navigates away from /onboarding.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-5, T1, U1, U2

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/OnboardingPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Onboarding
Suite Teardown  Close Browser
Test Setup      Navigate To Onboarding Within Session
Test Tags       onboarding    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Onboarding

*** Test Cases ***
TC-9004 Onboarding Title Is Visible
    [Documentation]    Verifies onboarding-title is visible on the onboarding page.
    [Tags]    smoke
    Onboarding Title Should Be Visible

TC-9001 Onboarding Info Sections Are Visible
    [Documentation]    Verifies all three onboarding info sections are visible.
    [Tags]    smoke
    Onboarding Info Sections Should Be Visible

TC-9002 Onboarding Proceed Button Is Visible
    [Documentation]    Verifies the proceed-button is visible on the onboarding page.
    Onboarding Proceed Button Should Be Visible

TC-9005 Onboarding Illustration Is Visible
    [Documentation]    Verifies the illustration image is visible on the onboarding page.
    Onboarding Illustration Should Be Visible

TC-9006 Onboarding URL Is Correct
    [Documentation]    Verifies the URL contains /onboarding.
    Onboarding URL Should Be Active

TC-9N-01 Back Button On Onboarding Navigates To Basic Details
    [Documentation]
    ...    Verifies back-button on /onboarding navigates to /applicant-basic-details.
    [Tags]    negative
    Navigate Back From Onboarding
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-basic-details

TC-9003 Onboarding Proceeds To Personal Details
    [Documentation]
    ...    Clicks Proceed on /onboarding and verifies navigation to /applicant-personal-details.
    ...    Runs LAST — advances wizard past onboarding.
    ...    Uses explicit setup because TC-9N-01 navigates away from /onboarding.
    [Setup]    Navigate To Onboarding Within Session
    Click Onboarding Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
