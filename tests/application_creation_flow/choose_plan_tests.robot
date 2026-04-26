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

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/ChoosePlanPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

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
    ...    Verifies the plans-count label is visible and shows a positive number.
    ...    Count is GILE-specific and may differ from total rendered cards — exact match is not asserted.
    ...    Ported from: GQCP-TC-6003.
    Plans Count Matches List

TC-6004 Choose Plan Title Text Contains EMI Plan
    [Documentation]
    ...    Verifies the choose-plan-title text contains 'EMI Plan'.
    ...    Ported from: GQCP-TC-6004 (recommended plan).
    Choose Plan Title Text Should Be Correct

TC-6007 Submit Button Should Require Plan Selection
    [Documentation]
    ...    Verifies the submit-plan-details-button is disabled when no plan is selected.
    ...    Ported from: GQCP-TC-6007.
    Submit Button Should Require Plan Selection

TC-6009 Page URL Contains /choose-plan
    [Documentation]
    ...    Verifies the browser URL contains /choose-plan while on this page.
    ...    Ported from: GQCP-TC-6009 (Help Page link — URL check adaptation for Robot Framework).
    Choose Plan URL Should Be Active

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

TC-6011 Choose Plan Page Is Accessible After Navigation
    [Documentation]
    ...    Verifies the choose-plan page loads correctly via direct navigation within session.
    ...    Ported from: GQCP-TC-6011 (close button — session persistence check).
    Choose Plan Title Should Be Visible

TC-6010 Fee Paying To Text Is Visible
    [Documentation]
    ...    Verifies the "Fee paying to" text is visible on the choose-plan page.
    ...    Satisfies: TC-6010
    Fee Paying To Text Should Be Visible

TC-6013 First EMI Plan Card Is Visible
    [Documentation]
    ...    Verifies the emi-card-action-button is visible on the first plan card.
    ...    PRECONDITION: ${APP_CREATION_MOBILE} must have at least one eligible plan.
    ...    Satisfies: TC-6013
    First EMI Plan Card Should Be Visible

TC-6012 Most Popular Badge Is Visible
    [Documentation]
    ...    Verifies the "Most Popular" badge is visible in the plan detail view
    ...    after clicking the emi-card-action-button.
    ...    Satisfies: TC-6012
    Click EMI Card Action Button
    Most Popular Badge Should Be Visible

TC-6014 Plan Detail Shows Interest Per Month And Payable Today
    [Documentation]
    ...    Verifies the plan detail view (opened via emi-card-action-button) shows
    ...    "Interest per month" and "Payable Today" texts on plan cards.
    ...    Satisfies: TC-6014
    Plan Detail Shows Interest And Payable Today

TC-6015 Submit Without Plan Selection Shows Please Select Plan Error
    [Documentation]
    ...    Verifies clicking the submit-plan-details-button without selecting a plan
    ...    shows the "Please select plan" validation message.
    ...    Recording login_20260424_145708.js (line 109) confirms the button is clickable
    ...    and triggers the validation message when no plan is selected.
    ...    Satisfies: TC-6015
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CP_SUBMIT_BUTTON}
    Please Select Plan Error Should Be Visible

TC-6016 Back Button Returns To Student Details URL
    [Documentation]
    ...    Verifies the back-button on the choose-plan page navigates back to /student-details.
    ...    Satisfies: TC-6016
    ChoosePlanPage.Click Back Button
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    Student Details URL Should Be Active

TC-6018 Selecting Plan After Error Clears Validation Message
    [Documentation]
    ...    Verifies that after clicking submit with no plan selected (triggering the
    ...    "Please select plan" error), selecting a plan clears the error message
    ...    and enables the submit button.
    ...    Satisfies: TC-6018
    [Tags]    negative
    Click Submit Plan Button
    Please Select Plan Error Should Be Visible
    Click First Plan
    Please Select Plan Error Should Not Be Visible
    Submit Button Should Be Enabled After Plan Selection

TC-6017 Close Button Navigates To Dashboard
    [Documentation]
    ...    Verifies clicking the close-button on the choose-plan page navigates the user
    ...    to the dashboard (/my-applications).
    ...    Satisfies: TC-6017
    ChoosePlanPage.Click Close Button
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    ChoosePlanPage.Dashboard URL Should Be Active

TC-6008 Plan Selection Enables Submit Button And Proceed
    [Documentation]
    ...    Verifies: (a) submit button is enabled after plan selection, (b) clicking proceed
    ...    advances the wizard past /choose-plan (to /select-applicant or /applicant-basic-details,
    ...    depending on whether the applicant type was already set for the application).
    ...    Ported from: GQCP-TC-6008. Runs LAST — advances wizard to next step.
    ...    Uses full Navigate To Choose Plan setup to handle cases where a prior test
    ...    (e.g. TC-6017 close-button) has navigated away from the wizard session.
    [Setup]    Navigate To Choose Plan
    Click First Plan
    Submit Button Should Be Enabled After Plan Selection
    Please Select Plan Error Should Not Be Visible
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan Wizard Advanced
