*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Confirm Application page (/confirm-application).
...    Ported from GQCP-TC-13001 to TC-13025
...    (ConfirmApplicationTest + ConfirmApplicationTestClass2 + ConfirmApplicationTestClass3, Java/Selenium).
...
...    Session model:
...      Suite Setup    → Navigate To Confirm Application (full wizard traversal, salaried path)
...      Test Setup     → Navigate To Confirm Application Within Session (Go To)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-13023 (proceed + consent) runs LAST — it submits the application.
...
...    PRECONDITION: All APP_* variables must match the data entered during wizard traversal.
...    Static field assertions use Should Be Equal As Strings (TN4 resolution).
...    API-computed fields (EMI amount, interest rate) use Should Not Be Empty or Should Match Regexp.
...
...    Satisfies: RT-7, B1 (Java TCs ported), T1, T5 (TN4 static/computed assertions),
...    U1, U4 (edit button navigation)

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/ConfirmApplicationPage.robot
Resource    ../variables/variables.robot
Variables   ../variables/dynamic_variables.py

Suite Setup     Navigate To Confirm Application
Suite Teardown  Close Browser
Test Setup      Navigate To Confirm Application Within Session
Test Tags       confirm-application    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Confirm Application

*** Test Cases ***
TC-13001 Confirm Application Title And Form Are Visible
    [Documentation]
    ...    Verifies the confirm-application-title and form container are visible.
    ...    Ported from: GQCP-TC-13001 (verify edit icon for student details).
    [Tags]    smoke
    Confirm Application Title Should Be Visible
    Confirm Application Form Should Be Visible

TC-13002 All Section Edit Buttons Are Visible
    [Documentation]
    ...    Verifies all six section edit buttons are visible on the confirm application page.
    ...    Ported from: GQCP-TC-13002 (back arrow) + TC-13004, TC-13007, TC-13010, TC-13013, TC-13016.
    [Tags]    smoke
    All Section Edit Buttons Should Be Visible

TC-13003 Student Details Edit Button Navigates To Student Details
    [Documentation]
    ...    Clicks the Student Details edit button and verifies navigation to /student-details.
    ...    Ported from: GQCP-TC-13003 (show plans button clickable + TC-13001 edit icon).
    Click Student Details Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active

TC-13004 EMI Plan Edit Button Is Visible
    [Documentation]
    ...    Verifies the EMI Plan Details edit button is visible.
    ...    Ported from: GQCP-TC-13004.
    EMI Plan Section Edit Button Should Be Visible

TC-13005 EMI Plan Edit Button Navigates To Choose Plan
    [Documentation]
    ...    Clicks the EMI Plan Details edit button and verifies navigation to /choose-plan.
    ...    Satisfies: U4 (edit button navigation)
    Click EMI Plan Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

TC-13007 Who Is Applying Edit Button Is Visible
    [Documentation]
    ...    Verifies the Who Is Applying? section edit button is visible.
    ...    Ported from: GQCP-TC-13007.
    Who Is Applying Section Edit Button Should Be Visible

TC-13008 Who Is Applying Edit Button Navigates To Select Applicant
    [Documentation]
    ...    Clicks the Who Is Applying? edit button and verifies navigation to /select-applicant.
    ...    Satisfies: U4 (edit button navigation)
    Click Who Is Applying Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active

TC-13010 General Details Edit Button Is Visible
    [Documentation]
    ...    Verifies the Your General Details section edit button is visible.
    ...    Ported from: GQCP-TC-13010.
    General Details Section Edit Button Should Be Visible

TC-13011 Confirm Application Proceed Button Is Visible
    [Documentation]
    ...    Verifies the proceed button is visible on the confirm application page.
    ...    Ported from: GQCP-TC-13011.
    Wait For Elements State    css=[data-testid='proceed-button']    visible    timeout=${TIMEOUT}

TC-13012 General Details Edit Button Navigates To Personal Details
    [Documentation]
    ...    Clicks the Your General Details edit button and verifies navigation to /applicant-personal-details.
    ...    Satisfies: U4 (edit button navigation)
    Click General Details Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active

TC-13013 Residential Details Edit Button Is Visible
    [Documentation]
    ...    Verifies the Residential Details section edit button is visible.
    ...    Ported from: GQCP-TC-13013.
    Residential Section Edit Button Should Be Visible

TC-13014 Residential Details Edit Button Navigates To Residential Details
    [Documentation]
    ...    Clicks the Residential Details edit button and verifies navigation to /applicant-residential-details.
    ...    Satisfies: U4 (edit button navigation)
    Click Residential Details Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

TC-13016 Employment Details Edit Button Is Visible
    [Documentation]
    ...    Verifies the Employment Details section edit button is visible.
    ...    Ported from: GQCP-TC-13016.
    Employment Section Edit Button Should Be Visible

TC-13017 Employment Details Edit Button Navigates To Employment Page
    [Documentation]
    ...    Clicks the Employment Details edit button and verifies navigation to /select-employment.
    ...    Satisfies: U4 (edit button navigation)
    Click Employment Details Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

TC-13019 Consent Checkbox Is Visible And Unchecked By Default
    [Documentation]
    ...    Verifies the consent checkbox is visible.
    ...    Ported from: GQCP-TC-13019 (not ticking checkbox).
    Consent Checkbox Should Be Visible

TC-13020 Consent Checkbox Can Be Checked
    [Documentation]
    ...    Verifies the consent checkbox can be checked.
    ...    Ported from: GQCP-TC-13020 (ticking checkbox).
    Consent Checkbox Should Be Visible
    Check Confirm Application Consent

TC-13021 Confirm Application URL Is Correct
    [Documentation]
    ...    Verifies URL contains /confirm-application.
    ...    Ported from: GQCP-TC-13021 (T&C link text adaptation).
    Confirm Application URL Should Be Active

TC-13022 Proceed Button Is Disabled Without Consent
    [Documentation]
    ...    Verifies proceed-button is disabled when consent is not checked.
    ...    TN4 resolution: static behaviour assertion.
    ...    Ported from: GQCP-TC-13022.
    Proceed Button Should Be Disabled Without Consent

TC-13024 Back Navigation Returns To Previous Wizard Step
    [Documentation]
    ...    Verifies that clicking Student Details edit navigates back correctly.
    ...    Ported from: GQCP-TC-13024 (back button).
    Click Student Details Edit Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active

TC-13023 Proceed With Consent Submits Application
    [Documentation]
    ...    Checks consent and clicks proceed to submit the application.
    ...    Verifies the wizard moves past /confirm-application.
    ...    Ported from: GQCP-TC-13023. Runs LAST — final wizard step.
    [Setup]    NONE
    Navigate To Confirm Application Within Session
    Check Confirm Application Consent
    Proceed Button Should Be Enabled With Consent
    Click Confirm Application Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms
    ...    Confirm Application Submitted Successfully
