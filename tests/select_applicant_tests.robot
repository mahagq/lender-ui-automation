*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Select Applicant Type page (/select-applicant).
...    Ported from GQCP-TC-7001 to TC-7011 (SelectApplicantTest + SelectApplicantTestClass2, Java/Selenium).
...
...    Session model:
...      Suite Setup   → Navigate To Select Applicant (creates app + traverses student-details + choose-plan)
...      Test Setup    → Navigate To Select Applicant Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-7008 (selection + proceed) runs last — it advances the wizard.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-4, B1 (Java TCs ported), T1, U1, U2

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/SelectApplicantPage.robot
Resource    ../variables/variables.robot

Suite Setup     Navigate To Select Applicant
Suite Teardown  Close Browser
Test Setup      Navigate To Select Applicant Within Session
Test Tags       select-applicant    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Select Applicant

*** Test Cases ***
TC-7001 Select Applicant Title And Info Are Visible
    [Documentation]
    ...    Verifies the select-applicant-title and select-applicant-note are visible.
    ...    Ported from: GQCP-TC-7001 (institute name display).
    [Tags]    smoke
    Select Applicant Title Should Be Visible
    Select Applicant Note Should Be Visible

TC-7002 Both Applicant Options Are Visible
    [Documentation]
    ...    Verifies both Parent/Guardian and Student option cards are visible.
    ...    Ported from: GQCP-TC-7002 (selection of options from two).
    [Tags]    smoke
    Both Applicant Options Should Be Visible

TC-7003 Parent Guardian Option Can Be Selected
    [Documentation]
    ...    Verifies the Parent/Guardian option card (data-testid='Parent/Guardian-0') is clickable.
    ...    Ported from: GQCP-TC-7003.
    Select Parent Guardian Option

TC-7004 Student Option Can Be Selected
    [Documentation]
    ...    Verifies the Student option card (data-testid='Student-1') is clickable.
    ...    Ported from: GQCP-TC-7004.
    Select Student Option

TC-7005 Age Consent Checkbox Appears After Student Selection
    [Documentation]
    ...    Verifies the age-checkbox appears after clicking the Student option.
    ...    Ported from: GQCP-TC-7005.
    Select Student Option
    Age Consent Checkbox Should Appear After Student Selection

TC-7006 Salary Consent Checkbox Appears After Student Selection
    [Documentation]
    ...    Verifies the salary-checkbox appears after clicking the Student option.
    ...    Ported from: GQCP-TC-7006.
    Select Student Option
    Salary Consent Checkbox Should Appear After Student Selection

TC-7007 Submit Button Is Disabled Before Selection
    [Documentation]
    ...    Verifies the submit-applicant-type-button is disabled before any option is selected.
    ...    Ported from: GQCP-TC-7007.
    Submit Button Should Be Disabled Without Selection

TC-7009 Page URL Contains /select-applicant
    [Documentation]
    ...    Verifies the URL contains /select-applicant on this page.
    ...    Ported from: GQCP-TC-7009 (Help Page link — URL check adaptation).
    Select Applicant URL Should Be Active

TC-7011 Select Applicant Page Loads After Navigation
    [Documentation]
    ...    Verifies the page loads correctly (title visible) via direct session navigation.
    ...    Ported from: GQCP-TC-7011 (close button — session persistence).
    Select Applicant Title Should Be Visible

TC-7008 Select Parent Guardian Enables Submit And Proceed
    [Documentation]
    ...    Verifies: (a) selecting Parent/Guardian enables the submit button,
    ...    (b) clicking submit advances the wizard to /applicant-basic-details.
    ...    Ported from: GQCP-TC-7008. Runs LAST — advances wizard to next step.
    [Setup]    NONE
    Navigate To Select Applicant Within Session
    Select Parent Guardian Option
    Submit Button Should Be Enabled After Selection
    Click Submit Applicant Type Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active
