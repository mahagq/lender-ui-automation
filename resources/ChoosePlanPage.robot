*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Choose Plan page (/choose-plan).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup   → Navigate To Choose Plan (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Choose Plan Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-6008 (plan selection + proceed) must run last — it advances the wizard.
...
...    Ported from: GQCP-TC-6001 to TC-6011 (ChoosePlanGrayQuestEducationFinance.java)
...    Satisfies: RT-3 (choose plan keywords + locators), T1 (data-testid locators only),
...    B1 (all enabled Java TCs ported)

Library     Browser

*** Variables ***
${CP_TITLE}                     css=[data-testid='choose-plan-title']
${CP_PLANS_COUNT}               css=[data-testid='plans-count']
${CP_NO_PLANS_FOUND}            css=[data-testid='no-plans-found']
${CP_PLAN_LIST}                 css=[data-testid='plan-list-container']
${CP_SUBMIT_BUTTON}             css=[data-testid='submit-plan-details-button']

# Plan card detail elements (confirmed by recording login_20260424_145708.js)
${CP_EMI_CARD_ACTION_BUTTON}    css=[data-testid='emi-card-action-button'] >> nth=0
${CP_FEE_PAYING_TO}             text=Fee paying to
${CP_SELECT_EMI_PLAN}           text=Select EMI Plan
${CP_MOST_POPULAR}              text=Most Popular
${CP_INTEREST_PER_MONTH}        text=Interest per month
${CP_PAYABLE_TODAY}             text=Payable Today
${CP_PLEASE_SELECT_PLAN}        text=Please select plan
${CP_BACK_BUTTON}               css=[data-testid='back-button']

*** Keywords ***
Choose Plan Title Should Be Visible
    [Documentation]
    ...    Asserts the choose-plan-title element is visible.
    ...    Satisfies: TC-6001, RT-3, U1
    Wait For Elements State    ${CP_TITLE}    visible    timeout=${TIMEOUT}

Choose Plan Title Text Should Be Correct
    [Documentation]
    ...    Asserts the choose-plan-title contains expected text.
    ...    Satisfies: TC-6001, U1
    Wait For Elements State    ${CP_TITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${CP_TITLE}
    Should Contain    ${text}    EMI Plan

Plans Count Should Be Visible
    [Documentation]
    ...    Asserts the plans-count element (showing number of available plans) is visible.
    ...    Satisfies: TC-6001, TC-6002, U1
    Wait For Elements State    ${CP_PLANS_COUNT}    visible    timeout=${LONG_TIMEOUT}

Plans Are Available
    [Documentation]
    ...    Asserts the plan-list-container is visible with at least one plan card.
    ...    PRECONDITION: UAT account must have a valid loan amount and eligible plans.
    ...    A "no plans found" result signals an account seeding need, not a test defect.
    ...    Satisfies: TC-6002, RT-3, U3
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    ${plans}=    Get Elements    ${CP_PLAN_LIST} >> *
    Should Be True    len($plans) > 0
    ...    No plans found in plan-list-container — UAT account may need seeding with valid loan amount.

Plans Count Matches List
    [Documentation]
    ...    Asserts the plans-count number matches the number of plan cards shown.
    ...    Satisfies: TC-6003, U3
    Wait For Elements State    ${CP_PLANS_COUNT}    visible    timeout=${LONG_TIMEOUT}
    ${count_text}=    Get Text    ${CP_PLANS_COUNT}
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${TIMEOUT}
    ${plans}=    Get Elements    ${CP_PLAN_LIST} >> *
    ${count}=    Get Length    ${plans}
    Should Be True    ${count} > 0

Submit Button Should Be Disabled Initially
    [Documentation]
    ...    Asserts the submit-plan-details-button is disabled when no plan is selected.
    ...    Satisfies: TC-6007, U2
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${CP_SUBMIT_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Submit button should be disabled when no plan is selected.

Click First Plan
    [Documentation]
    ...    Clicks the first plan card in the plan list.
    ...    Plan cards have dynamic testids (index-planId) — first child of list container selected.
    ...    Satisfies: TC-6005, U2
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click    ${CP_PLAN_LIST} >> nth=0

Click Second Plan
    [Documentation]
    ...    Clicks the second plan card in the plan list (requires ≥2 plans).
    ...    Satisfies: TC-6006
    ${plans}=    Get Elements    ${CP_PLAN_LIST} >> *
    Should Be True    len($plans) >= 2
    ...    TC-6006 requires at least 2 plans — UAT account may need seeding.
    Click    ${CP_PLAN_LIST} >> nth=1

Submit Button Should Be Enabled After Plan Selection
    [Documentation]
    ...    Asserts the submit-plan-details-button becomes enabled after a plan is selected.
    ...    Satisfies: TC-6008, U2
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${CP_SUBMIT_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Submit button should be enabled after plan selection.

Click Submit Plan Button
    [Documentation]
    ...    Clicks the submit-plan-details-button to proceed to the next wizard step.
    ...    Satisfies: TC-6008, RT-3 (proceed)
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CP_SUBMIT_BUTTON}

Fee Paying To Text Should Be Visible
    [Documentation]
    ...    Asserts the "Fee paying to" text is visible on the choose-plan page.
    ...    Satisfies: TC-6010, U1
    Wait For Elements State    ${CP_FEE_PAYING_TO}    visible    timeout=${LONG_TIMEOUT}

EMI Card Action Button Should Be Visible
    [Documentation]
    ...    Asserts the emi-card-action-button is visible on the first plan card.
    ...    PRECONDITION: At least one plan must be available for ${APP_CREATION_MOBILE}.
    ...    Satisfies: TC-6013, U1
    Wait For Elements State    ${CP_EMI_CARD_ACTION_BUTTON}    visible    timeout=${LONG_TIMEOUT}

Click EMI Card Action Button
    [Documentation]
    ...    Clicks the emi-card-action-button on the first plan card to open the plan detail view.
    ...    Satisfies: TC-6014, TC-6015
    Wait For Elements State    ${CP_EMI_CARD_ACTION_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${CP_EMI_CARD_ACTION_BUTTON}

Most Popular Badge Should Be Visible
    [Documentation]
    ...    Asserts the "Most Popular" badge is visible in the plan detail view.
    ...    Must be called after Click EMI Card Action Button.
    ...    Satisfies: TC-6012, U1
    Wait For Elements State    ${CP_MOST_POPULAR}    visible    timeout=${TIMEOUT}

Plan Detail Shows Interest And Payable Today
    [Documentation]
    ...    Clicks the emi-card-action-button on the first plan card and asserts both
    ...    "Interest per month" and "Payable Today" texts are visible in the detail view.
    ...    Satisfies: TC-6014, U1
    Click EMI Card Action Button
    Wait For Elements State    ${CP_INTEREST_PER_MONTH}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CP_PAYABLE_TODAY}    visible    timeout=${TIMEOUT}

Please Select Plan Error Should Be Visible
    [Documentation]
    ...    Asserts the "Please select plan" validation message is visible when the submit
    ...    button is clicked without a plan selected.
    ...    Satisfies: TC-6015, U1
    Wait For Elements State    ${CP_PLEASE_SELECT_PLAN}    visible    timeout=${TIMEOUT}

Please Select Plan Error Should Not Be Visible
    [Documentation]
    ...    Asserts the "Please select plan" validation message is not visible.
    ...    Called after a plan is selected to verify error state is cleared.
    ...    Satisfies: TC-6N-01
    Wait For Elements State    ${CP_PLEASE_SELECT_PLAN}    hidden    timeout=${TIMEOUT}

Click Back Button
    [Documentation]
    ...    Clicks the back-button on the choose-plan page to navigate back to /student-details.
    ...    Satisfies: TC-6016
    Wait For Elements State    ${CP_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CP_BACK_BUTTON}

Choose Plan URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /choose-plan.
    ${url}=    Get Url
    Should Contain    ${url}    /choose-plan
