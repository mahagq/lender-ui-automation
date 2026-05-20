*** Settings ***
Documentation
...    Downpayment Flow D — Change Plan (Steps 2→3→4).
...    Institute: Thakkar International Academy (GILE EMI_PLAN_CHANGE=true).
...    Own browser session — Suite Setup creates fresh app, Suite Teardown closes browser.
...
...    Flow D — Step 1 (5 TCs):  change-plan-flow-card visible; click navigates to Step 2.
...    Flow D — Step 2 (8 TCs):  NewPlanList — TC-006 navigates once; TC-007–011 NONE; TC-012/013 fresh.
...    Flow D — Step 3 (11 TCs): ConfirmNewPlan — TC-014 navigates once; TC-015–022 NONE; TC-023/024 fresh.
...    Flow D — Step 4 (10 TCs): ConfirmNewPlanSuccess — plan details, CTA (state-advancing, LAST).
...
...    State-advancing: TC-DP-D-025 [Setup: Navigate To Change Plan Step 4] changes plan in DB.
...    TC-DP-D-026 to TC-DP-D-034 use [Setup: NONE] — inherit Step 4 browser state.

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/DownPaymentPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Down Payment Change Plan App
Suite Teardown   Close Browser
Test Setup       Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_CHANGE_APP_ID}
...              AND    Down Payment Page Should Be Visible

Test Tags    down-payment    change-plan    regression
...          allure.label.epic:CP UI Automation
...          allure.label.feature:Downpayment Change Plan

*** Variables ***
${DP_CHANGE_APP_ID}    ${EMPTY}


*** Test Cases ***
# ════════════════════════════════════════════════════════
# FLOW D — Step 1: Change Plan Card (GILE-configured app)
# Default Test Setup: Go To /down-payment/${DP_CHANGE_APP_ID}
# ════════════════════════════════════════════════════════

TC-DP-D-001 Change Plan Card Is Visible
    [Documentation]    Asserts change-plan-flow-card visible for EMI_PLAN_CHANGE=true institute.
    [Tags]    change-plan-step1
    Wait For Elements State    ${DP_CHANGE_PLAN_CARD}    visible    timeout=${TIMEOUT}

TC-DP-D-002 Change Plan Type Text Is Visible
    [Documentation]    Asserts change-plan-type element is visible on the change plan card.
    [Tags]    change-plan-step1
    Wait For Elements State    ${DP_CHANGE_PLAN_TYPE}    visible    timeout=${TIMEOUT}

TC-DP-D-003 Change Plan Card Has Descriptive Text
    [Documentation]    Asserts "Click on this card to change" text is visible on change plan card.
    [Tags]    change-plan-step1
    Wait For Elements State    text=Click on this card to change    visible    timeout=${TIMEOUT}

TC-DP-D-004 Zero Downpayment Option Available Text Is Visible
    [Documentation]    Asserts "Zero Downpayment option available" label is visible on change plan card.
    [Tags]    change-plan-step1
    Wait For Elements State    text=Zero Downpayment option available    visible    timeout=${TIMEOUT}

TC-DP-D-005 Clicking Change Plan Card Navigates To Step 2
    [Documentation]    Clicking change-plan-flow-card loads NewPlanList (new-plan-list-title visible).
    [Tags]    change-plan-step1
    Click    ${DP_CHANGE_PLAN_CARD}
    Down Payment Change Plan Step 2 Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW D — Step 2: NewPlanList
# TC-DP-D-013 navigates to Step 2 first — back button returns to Step 1.
# TC-DP-D-006 navigates to Step 2 again — TC-007 to TC-012 use [Setup: NONE].
# Total: 2 navigations to Step 2.
# ════════════════════════════════════════════════════════

TC-DP-D-013 Back Button On Step 2 Returns To Step 1
    [Documentation]    Navigates to Step 2 first. Clicking back-button returns to Step 1 (down-payment-details visible).
    [Tags]    change-plan-step2
    [Setup]    Navigate To Change Plan Step 2
    Click    ${DP_CP_BACK_BTN}
    Down Payment Page Should Be Visible

TC-DP-D-006 New Plan List Title Is Visible
    [Documentation]    Navigates to Step 2. Asserts new-plan-list-title is visible.
    [Tags]    change-plan-step2
    [Setup]    Navigate To Change Plan Step 2
    Wait For Elements State    ${DP_CP_PLAN_LIST_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-007 Current EMI Plan Heading Is Visible
    [Documentation]    Asserts "Your current EMI plan" heading is visible on Step 2.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Wait For Elements State    role=heading[name='Your current EMI plan']    visible    timeout=${TIMEOUT}

TC-DP-D-008 Current Plan Amount Details Are Visible
    [Documentation]    Asserts current plan amount (₹) is displayed in down-payment-details on Step 2.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_DETAILS}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_DETAILS}
    Should Contain    ${text}    ₹

TC-DP-D-009 Select New EMI Plan Label Is Visible
    [Documentation]    Asserts "Select new EMI Plan" section label is visible on Step 2.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Wait For Elements State    text=Select new EMI Plan    visible    timeout=${TIMEOUT}

TC-DP-D-010 First Plan Item Is Visible In List
    [Documentation]    Asserts first plan item (data-testid^='0-') is visible on Step 2.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_FIRST_PLAN}    visible    timeout=${TIMEOUT}

TC-DP-D-011 Proceed Button Is Visible On Step 2
    [Documentation]    Asserts proceed-button is visible on Step 2.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}

TC-DP-D-012 Selecting First Plan And Clicking Proceed Navigates To Step 3
    [Documentation]    Selects first plan, clicks proceed-button, asserts Step 3 (confirm-new-plan-title) visible.
    [Tags]    change-plan-step2
    [Setup]    NONE
    Click    ${DP_CP_FIRST_PLAN}
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_CP_PROCEED_BTN}
    Down Payment Change Plan Step 3 Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW D — Step 3: ConfirmNewPlan
# TC-DP-D-024 navigates to Step 3 first — back button returns to Step 2.
# TC-DP-D-014 navigates to Step 3 again — TC-015 to TC-022 use [Setup: NONE].
# TC-DP-D-023 needs fresh Step 3 (consent unchecked).
# Total: 3 navigations to Step 3.
# ════════════════════════════════════════════════════════

TC-DP-D-024 Back Button On Step 3 Returns To Step 2
    [Documentation]    Navigates to Step 3 first. Clicking back-button returns to Step 2 (new-plan-list-title visible).
    [Tags]    change-plan-step3
    [Setup]    Navigate To Change Plan Step 3
    Click    ${DP_CP_BACK_BTN}
    Down Payment Change Plan Step 2 Should Be Visible

TC-DP-D-014 Confirm New Plan Title Is Visible
    [Documentation]    Navigates to Step 3. Asserts confirm-new-plan-title is visible.
    [Tags]    change-plan-step3
    [Setup]    Navigate To Change Plan Step 3
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-015 Your New EMI Plan Section Is Visible
    [Documentation]    Asserts "Your new EMI plan" text is visible on Step 3.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Wait For Elements State    text=Your new EMI plan    visible    timeout=${TIMEOUT}

TC-DP-D-016 Revised Loan Agreement Info Is Visible
    [Documentation]    Asserts "The revised loan agreement" info text is visible on Step 3.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Wait For Elements State    text=The revised loan agreement    visible    timeout=${TIMEOUT}

TC-DP-D-017 View Agreement Button Is Visible
    [Documentation]    Asserts view-agreement-button is visible on Step 3.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_VIEW_AGREEMENT_BTN}    visible    timeout=${TIMEOUT}

TC-DP-D-018 View Agreement Button Opens Agreement Preview
    [Documentation]    Clicking view-agreement-button renders agreement content (agreement-preview-proceed-button visible). Closes modal via Close button to restore confirm screen.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    ${DP_CP_AGREEMENT_PROCEED_BTN}    visible    timeout=${LONG_TIMEOUT}
    Click    role=button[name='Close']
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-019 Agreement Preview Proceed Button Returns To Confirm Screen
    [Documentation]    Clicking agreement-preview-proceed-button closes preview and returns to Step 3 confirm screen.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    ${DP_CP_AGREEMENT_PROCEED_BTN}    visible    timeout=${LONG_TIMEOUT}
    Click    ${DP_CP_AGREEMENT_PROCEED_BTN}
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-020 Agreement Modal Close Button Works
    [Documentation]    Clicking Close in agreement modal returns to Step 3 confirm screen.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    role=button[name='Close']    visible    timeout=${LONG_TIMEOUT}
    Click    role=button[name='Close']
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-021 Consent Checkbox Is Present And Unchecked By Default
    [Documentation]    Asserts consent-checkbox is present and unchecked by default on Step 3.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_CONSENT_CB}    visible    timeout=${TIMEOUT}
    ${checked}=    Get Property    ${DP_CP_CONSENT_CB}    checked
    Should Be Equal    ${checked}    ${FALSE}

TC-DP-D-022 Consent Label Toggles Checkbox
    [Documentation]    Clicking consent-checkbox-label toggles the consent checkbox to checked.
    [Tags]    change-plan-step3
    [Setup]    NONE
    Click    ${DP_CP_CONSENT_LABEL}
    ${checked}=    Get Property    ${DP_CP_CONSENT_CB}    checked
    Should Be Equal    ${checked}    ${TRUE}

TC-DP-D-023 Confirm Button Without Consent Shows Error
    [Documentation]    Fresh Step 3 (consent unchecked). Clicking confirm-new-plan-button without consent shows consent-checkbox-error.
    [Tags]    change-plan-step3
    [Setup]    Navigate To Change Plan Step 3
    Click    ${DP_CP_CONFIRM_BTN}
    Wait For Elements State    ${DP_CP_CONSENT_ERROR}    visible    timeout=${TIMEOUT}


# ════════════════════════════════════════════════════════
# FLOW D — Step 4: ConfirmNewPlanSuccess (state-advancing — LAST)
# TC-DP-D-025 uses Navigate To Change Plan Step 4 — changes plan in DB.
# TC-DP-D-026 to TC-DP-D-034 use [Setup: NONE] — inherit Step 4 browser state.
# ════════════════════════════════════════════════════════

TC-DP-D-025 Confirming Plan With Consent Navigates To Step 4
    [Documentation]
    ...    State-advancing. Checks consent, clicks confirm-new-plan-button.
    ...    Asserts Step 4 ConfirmNewPlanSuccess (plan-details-title) is visible.
    ...    Creates real DB entries for plan change. Subsequent tests use [Setup: NONE].
    [Tags]    change-plan-step4
    [Setup]    Navigate To Change Plan Step 4
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-026 Step 4 Success Title Is Visible
    [Documentation]    Asserts data-testid='title' is visible on Step 4 ConfirmNewPlanSuccess.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_STEP4_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-027 Step 4 Info Text Is Visible
    [Documentation]    Asserts data-testid='info' paragraph is visible on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_STEP4_INFO}    visible    timeout=${TIMEOUT}

TC-DP-D-028 Plan Details Title Is Visible
    [Documentation]    Asserts plan-details-title element is visible on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-D-029 EMI Amount Value Is Displayed
    [Documentation]    Asserts emi-amount-value element is visible with numeric content on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_EMI_AMOUNT_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_EMI_AMOUNT_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-D-030 EMI Count Value Is Displayed
    [Documentation]    Asserts emi-count-value (tenure) element is visible with numeric content on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_EMI_COUNT_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_EMI_COUNT_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-D-031 Total Loan Amount Is Displayed
    [Documentation]    Asserts total-loan-amount element is visible with numeric content on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_TOTAL_LOAN_AMOUNT}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_TOTAL_LOAN_AMOUNT}
    Should Match Regexp    ${text}    [0-9]

TC-DP-D-032 APR Value Is Displayed
    [Documentation]    Asserts apr-value element is visible with numeric content on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_APR_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_APR_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-D-033 Proceed To Next Button Is Visible
    [Documentation]    Asserts proceed-to-next-button is visible on Step 4.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PROCEED_NEXT_BTN}    visible    timeout=${TIMEOUT}

TC-DP-D-034 Close Button Is Visible On Step 4
    [Documentation]    Asserts close-button is visible on Step 4 ConfirmNewPlanSuccess.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_CLOSE_BTN}    visible    timeout=${TIMEOUT}

TC-DP-D-035 Proceed To Next Button Navigates To NACH Step
    [Documentation]
    ...    State-advancing. Clicks proceed-to-next-button on Step 4.
    ...    Asserts URL contains /nach/{app_id} — navigates to NACH EMI setup step.
    [Tags]    change-plan-step4
    [Setup]    NONE
    Click    ${DP_CP_PROCEED_NEXT_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Nach URL Should Be Active    ${DP_CHANGE_APP_ID}
