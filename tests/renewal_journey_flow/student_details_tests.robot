*** Settings ***
Documentation
...    Renewal Journey — Student Details page (/student-details).
...    Entry via header "Create new application" button using ${RENEWAL_MOBILE} (existing account).
...    The Student Details UI is identical to the first-application flow.
...
...    Session model:
...      Suite Setup    → Navigate To Student Details Via Renewal
...      Test Setup     → Navigate To Student Details Within Session
...      Suite Teardown → Close Browser

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/StudentDetailsPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Student Details Via Renewal
Suite Teardown  Close Browser
Test Setup      Navigate To Student Details Within Session
Test Tags       renewal    student-details    renewal-journey-flow    allure.label.epic:CP UI Automation    allure.label.feature:Renewal Journey Flow    allure.label.story:Student Details

*** Test Cases ***
TC-R5001 Student Details Title Is Visible
    [Tags]    smoke
    Student Details Title Should Be Visible

TC-R5002 Student Details Form Is Visible
    Student Details Form Should Be Visible

TC-R5003 Institute Search Field Is Visible
    GILE Institute Dropdown Should Be Visible

TC-R5004 Loan Amount Field Is Visible
    Loan Amount Input Should Be Visible

TC-R5005 Student Details URL Is Correct
    Student Details URL Should Be Active

TC-R5006 Student First Name Field Is Visible
    [Documentation]    Personal fields appear after GILE dropdowns are filled.
    [Setup]    Navigate To Student Details With GILE Filled
    First Name Input Should Be Visible

TC-R5007 Student Last Name Field Is Visible
    [Setup]    Navigate To Student Details With GILE Filled
    Last Name Input Should Be Visible
