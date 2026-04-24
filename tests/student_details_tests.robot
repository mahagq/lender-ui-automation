*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Student Details page (/student-details).
...    New page — no Java TC coverage. TC-5001 to TC-5014.
...
...    Session model:
...      Suite Setup   → Create Application And Navigate To Student Details
...      Test Setup    → Navigate To Student Details Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-5014 (submit with valid data) runs last — it advances the wizard to /choose-plan.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-2, B2 (new-page coverage), T1, U1

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/StudentDetailsPage.robot
Resource    ../variables/variables.robot
Variables   ../variables/dynamic_variables.py

Suite Setup     Create Application And Navigate To Student Details
Suite Teardown  Close Browser
Test Setup      Navigate To Student Details Within Session
Test Tags       student-details    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Student Details

*** Test Cases ***
TC-5001 Student Details Page Title Is Visible
    [Documentation]    Verifies the student-details-title is visible on page load.
    [Tags]    smoke
    Student Details Title Should Be Visible
    Student Details Form Should Be Visible

TC-5002 GILE Institute Dropdown Is Visible
    [Documentation]    Verifies the institute-id-react-select dropdown is visible.
    GILE Institute Dropdown Should Be Visible

TC-5003 GILE Location Dropdown Is Visible
    [Documentation]    Verifies the location-id-react-select dropdown is visible.
    GILE Location Dropdown Should Be Visible

TC-5004 GILE Board Dropdown Is Visible
    [Documentation]    Verifies the board-id-react-select dropdown is visible.
    GILE Board Dropdown Should Be Visible

TC-5005 GILE Academic Year Dropdown Is Visible
    [Documentation]    Verifies the academic-year-id-react-select dropdown is visible.
    GILE Academic Year Dropdown Should Be Visible

TC-5006 Admission Type Title Is Visible
    [Documentation]
    ...    Verifies the class-id-react-select dropdown is visible in the personal details
    ...    section (replaces removed admission-type-title on UAT). Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Admission Type Title Should Be Visible

TC-5007 Annual Fee Title Is Visible
    [Documentation]
    ...    Verifies the loan-amount-input is visible in the personal details section
    ...    (replaces removed annual-fee-title on UAT). Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Annual Fee Title Should Be Visible

TC-5008 Student Details URL Is Correct
    [Documentation]    Verifies the page URL contains /student-details.
    Student Details URL Should Be Active

TC-5009 First Name Input Is Visible And Accepts Text
    [Documentation]    Verifies the first-name-input is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    First Name Input Should Be Visible
    Fill First Name    TestFirst

TC-5010 Last Name Input Is Visible And Accepts Text
    [Documentation]    Verifies the last-name-input is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Last Name Input Should Be Visible
    Fill Last Name    TestLast

TC-5011 Student Type Radio Is Visible
    [Documentation]    Verifies the student-type-radio options are visible on the page. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Student Type Radio Should Be Visible

TC-5012 Student ID Input Is Visible And Accepts Text
    [Documentation]    Verifies the student-id-input field is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Student ID Input Should Be Visible
    Fill Student ID    SD98765

TC-5013 Loan Amount Input Is Visible And Accepts Numbers
    [Documentation]    Verifies the loan-amount-input field is visible and accepts numeric input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Loan Amount Input Should Be Visible
    Fill Loan Amount    75000

TC-5014 Show Plans Button Is Visible
    [Documentation]
    ...    Verifies the show-plans-button is visible after all fields (GILE + personal details)
    ...    are filled. show-plans-button only appears when the form is complete.
    ...    This test runs last — submit is NOT called here to preserve wizard state.
    [Tags]    smoke
    [Setup]    Navigate To Student Details With All Fields Filled
    Show Plans Button Should Be Visible
