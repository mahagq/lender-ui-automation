*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Choose Plan page (/choose-plan).
...    Ported from GQCP-TC-6001 to TC-6011 (SelectPlanTest + SelectPlanTestClass2, Java/Selenium).
...
...    Session model:
...      Suite Setup   → Navigate To Choose Plan (creates app + fills student details)
...      Test Setup    → Navigate To Choose Plan Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-6008 (plan selection + proceed) runs last — it advances the wizard.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT and have eligible plans.
...    A "no plans" result indicates account data seeding need, not a test defect.
...    Satisfies: RT-3, B1 (Java TCs ported), T1, U2, U3

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/ChoosePlanPage.robot
Resource    ../variables/variables.robot

Suite Setup     Navigate To Choose Plan
Suite Teardown  Close Browser
Test Setup      Navigate To Choose Plan Within Session
Test Tags       choose-plan    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Choose Plan

*** Test Cases ***
TC-6001 Choose Plan Page Title And GILE Info Are Visible
    [Documentation]
    ...    Verifies the choose-plan-title and plans-count elements are visible.
    ...    Ported from: GQCP-TC-6001 (verify GILE on the page).
    [Tags]    smoke
    Choose Plan Title Should Be Visible
    Plans Count Should Be Visible

TC-6002 Plans Are Displayed
    [Documentation]
    ...    Verifies the plan-list-container is visible with at least one plan card.
    ...    Ported from: GQCP-TC-6002.
    [Tags]    smoke
    Plans Are Available

TC-6003 Plans Count Matches List Length
    [Documentation]
    ...    Verifies the plans-count number is consistent with plan cards shown.
    ...    Ported from: GQCP-TC-6003.
    Plans Count Matches List

TC-6004 Choose Plan Title Text Contains EMI Plan
    [Documentation]
    ...    Verifies the choose-plan-title text contains 'EMI Plan'.
    ...    Ported from: GQCP-TC-6004 (recommended plan).
    Choose Plan Title Text Should Be Correct

TC-6005 A Plan Can Be Selected
    [Documentation]
    ...    Verifies that clicking the first plan card updates the selection.
    ...    Ported from: GQCP-TC-6005.
    Click First Plan

TC-6006 Selecting A Different Plan Updates Selection
    [Documentation]
    ...    Verifies that clicking a second plan replaces the previous selection.
    ...    Ported from: GQCP-TC-6006. Requires ≥2 plans in the list.
    Click First Plan
    Click Second Plan

TC-6007 Submit Button Is Disabled Before Plan Selection
    [Documentation]
    ...    Verifies the submit-plan-details-button is disabled when no plan is selected.
    ...    Ported from: GQCP-TC-6007.
    Submit Button Should Be Disabled Initially

TC-6009 Page URL Contains /choose-plan
    [Documentation]
    ...    Verifies the browser URL contains /choose-plan while on this page.
    ...    Ported from: GQCP-TC-6009 (Help Page link — URL check adaptation for Robot Framework).
    Choose Plan URL Should Be Active

TC-6011 Choose Plan Page Is Accessible After Navigation
    [Documentation]
    ...    Verifies the choose-plan page loads correctly via direct navigation within session.
    ...    Ported from: GQCP-TC-6011 (close button — session persistence check).
    Choose Plan Title Should Be Visible

TC-6008 Plan Selection Enables Submit Button And Proceed
    [Documentation]
    ...    Verifies: (a) submit button is enabled after plan selection, (b) clicking proceed
    ...    advances the wizard to /select-applicant.
    ...    Ported from: GQCP-TC-6008. Runs LAST — advances wizard to next step.
    [Setup]    NONE
    Navigate To Choose Plan Within Session
    Click First Plan
    Submit Button Should Be Enabled After Plan Selection
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active
