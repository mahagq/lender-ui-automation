*** Settings ***
Documentation
...    Renewal Journey — Choose Plan page (/choose-plan).
...    Entry via header "Create new application" button using ${RENEWAL_MOBILE} (existing account).
...    The Choose Plan UI is identical to the first-application flow.
...
...    Session model:
...      Suite Setup    → Navigate To Choose Plan Via Renewal
...      Test Setup     → Navigate To Choose Plan Within Session
...      Suite Teardown → Close Browser

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/ChoosePlanPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Choose Plan Via Renewal
Suite Teardown  Close Browser
Test Setup      Navigate To Choose Plan Within Session
Test Tags       renewal    choose-plan    renewal-journey-flow    allure.label.epic:CP UI Automation    allure.label.feature:Renewal Journey Flow    allure.label.story:Choose Plan

*** Test Cases ***
TC-R6001 Choose Plan Title Is Visible
    [Tags]    smoke
    Choose Plan Title Should Be Visible

TC-R6002 Plans Are Displayed
    Plans Are Available

TC-R6003 Choose Plan URL Is Correct
    Choose Plan URL Should Be Active

TC-R6004 First EMI Plan Card Is Visible
    First EMI Plan Card Should Be Visible

TC-R6005 Most Popular Badge Is Visible
    Most Popular Badge Should Be Visible

TC-R6006 A Plan Can Be Selected
    Click First Plan
    Submit Button Should Be Enabled After Plan Selection

TC-R6007 Submit Without Plan Selection Shows Error
    Submit Button Should Require Plan Selection

TC-R6008 Submit Button Enabled After Plan Selection And Proceed
    [Documentation]    Selects a plan and proceeds to the Welcome Back screen (renewal divergence point).
    Click First Plan In List
    Click Submit Plan Button
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}
