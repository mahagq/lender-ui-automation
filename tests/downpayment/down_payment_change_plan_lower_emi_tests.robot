*** Settings ***
Documentation
...    Downpayment Flow E — Change Plan Lower EMI (Steps 2→3→4→DP Payment).
...    Institute: Ashvini Varhade (GILE EMI_PLAN_CHANGE=true, plans include downpayment).
...    Own browser session — Suite Setup creates fresh app, Suite Teardown closes browser.
...
...    LOCATOR NOTE: ${DP_LE_CARD} and ${DP_LE_CARD_TYPE} in DownPaymentPage.robot are marked
...    TBD — update from Playwright recording once available.
...
...    Flow E — Step 1 (5 TCs):   lower-emi-flow-card visible; click navigates to Step 2.
...    Flow E — Step 2 (8 TCs):   NewPlanList — plan selection, proceed, back.
...    Flow E — Step 3 (11 TCs):  ConfirmNewPlan — agreement, consent, validation, back.
...    Flow E — Step 4 (10 TCs):  ConfirmNewPlanSuccess — plan details, CTA.
...    Flow E — Step 5+ (2 TCs):  Proceed → Down Payment page → Razorpay UPI → status (LAST).
...
...    State-advancing: TC-DP-LE-025 [Setup: Navigate To Lower EMI Change Plan Step 4] changes plan in DB.
...    TC-DP-LE-026 to TC-DP-LE-034 use [Setup: NONE] — inherit Step 4 browser state.
...    TC-DP-LE-035 clicks proceed-to-next → Down Payment Step 5.
...    TC-DP-LE-036 completes Razorpay UPI payment → /down-payment-status/ (LAST, state-advancing).

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/DownPaymentPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Down Payment Lower EMI App
Suite Teardown   Close Browser
Test Setup       Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_LOWER_EMI_APP_ID}
...              AND    Down Payment Page Should Be Visible

Test Tags    down-payment    change-plan    change-plan-lower-emi    regression    robot:skip
...          allure.label.epic:CP UI Automation
...          allure.label.feature:Downpayment Change Plan Lower EMI

*** Variables ***
${DP_LOWER_EMI_APP_ID}    ${EMPTY}


*** Test Cases ***
# ════════════════════════════════════════════════════════
# FLOW E — Step 1: Lower EMI Change Plan Card
# Default Test Setup: Go To /down-payment/${DP_LOWER_EMI_APP_ID}
# ════════════════════════════════════════════════════════

TC-DP-LE-001 Lower EMI Change Plan Card Is Visible
    [Documentation]    Asserts lower-emi-flow-card visible for EMI_PLAN_CHANGE=true institute.
    [Tags]    change-plan-lower-emi-step1
    Wait For Elements State    ${DP_LE_CARD}    visible    timeout=${TIMEOUT}

TC-DP-LE-002 Lower EMI Change Plan Type Text Is Visible
    [Documentation]    Asserts lower-emi-type element is visible on the lower EMI change plan card.
    [Tags]    change-plan-lower-emi-step1
    Wait For Elements State    ${DP_LE_CARD_TYPE}    visible    timeout=${TIMEOUT}

TC-DP-LE-003 Lower EMI Change Plan Card Has Descriptive Text
    [Documentation]    Asserts descriptive text visible on lower EMI change plan card.
    [Tags]    change-plan-lower-emi-step1
    Wait For Elements State    text=Lower EMI    visible    timeout=${TIMEOUT}

TC-DP-LE-004 Change Plan Card Is Also Visible
    [Documentation]    Asserts the zero downpayment change-plan-flow-card is also visible on Step 1.
    [Tags]    change-plan-lower-emi-step1
    Wait For Elements State    ${DP_CHANGE_PLAN_CARD}    visible    timeout=${TIMEOUT}

TC-DP-LE-005 Clicking Lower EMI Card Navigates To Step 2
    [Documentation]    Clicking lower-emi-flow-card loads NewPlanList (new-plan-list-title visible).
    [Tags]    change-plan-lower-emi-step1
    Click    ${DP_LE_CARD}
    Down Payment Change Plan Step 2 Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW E — Step 2: NewPlanList (Lower EMI plans)
# TC-DP-LE-013 navigates first (back button), TC-DP-LE-006 navigates again.
# TC-DP-LE-007 to TC-DP-LE-012 use [Setup: NONE].
# ════════════════════════════════════════════════════════

TC-DP-LE-013 Back Button On Step 2 Returns To Step 1
    [Documentation]    Navigates to Step 2 first. Clicking back-button returns to Step 1 (down-payment-details visible).
    [Tags]    change-plan-lower-emi-step2
    [Setup]    Navigate To Lower EMI Change Plan Step 2
    Click    ${DP_CP_BACK_BTN}
    Down Payment Page Should Be Visible

TC-DP-LE-006 New Plan List Title Is Visible
    [Documentation]    Navigates to Step 2. Asserts new-plan-list-title is visible.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    Navigate To Lower EMI Change Plan Step 2
    Wait For Elements State    ${DP_CP_PLAN_LIST_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-007 Current EMI Plan Heading Is Visible
    [Documentation]    Asserts "Your current EMI plan" heading is visible on Step 2.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Wait For Elements State    role=heading[name='Your current EMI plan']    visible    timeout=${TIMEOUT}

TC-DP-LE-008 Current Plan Amount Details Are Visible
    [Documentation]    Asserts current plan amount (₹) is displayed in down-payment-details on Step 2.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_DETAILS}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_DETAILS}
    Should Contain    ${text}    ₹

TC-DP-LE-009 Select New EMI Plan Label Is Visible
    [Documentation]    Asserts "Select new EMI Plan" section label is visible on Step 2.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Wait For Elements State    text=Select new EMI Plan    visible    timeout=${TIMEOUT}

TC-DP-LE-010 First Plan Item Is Visible In List
    [Documentation]    Asserts first plan item (data-testid^='0-') is visible on Step 2.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_FIRST_PLAN}    visible    timeout=${TIMEOUT}

TC-DP-LE-011 Proceed Button Is Visible On Step 2
    [Documentation]    Asserts proceed-button is visible on Step 2.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}

TC-DP-LE-012 Selecting First Plan And Clicking Proceed Navigates To Step 3
    [Documentation]    Selects first lower EMI plan, clicks proceed-button, asserts Step 3 (confirm-new-plan-title) visible.
    [Tags]    change-plan-lower-emi-step2
    [Setup]    NONE
    Click    ${DP_CP_FIRST_PLAN}
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_CP_PROCEED_BTN}
    Down Payment Change Plan Step 3 Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW E — Step 3: ConfirmNewPlan
# TC-DP-LE-024 navigates first (back button), TC-DP-LE-014 navigates again.
# TC-DP-LE-015 to TC-DP-LE-022 use [Setup: NONE].
# TC-DP-LE-023 needs fresh Step 3 (consent unchecked).
# ════════════════════════════════════════════════════════

TC-DP-LE-024 Back Button On Step 3 Returns To Step 2
    [Documentation]    Navigates to Step 3 first. Clicking back-button returns to Step 2 (new-plan-list-title visible).
    [Tags]    change-plan-lower-emi-step3
    [Setup]    Navigate To Lower EMI Change Plan Step 3
    Click    ${DP_CP_BACK_BTN}
    Down Payment Change Plan Step 2 Should Be Visible

TC-DP-LE-014 Confirm New Plan Title Is Visible
    [Documentation]    Navigates to Step 3. Asserts confirm-new-plan-title is visible.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    Navigate To Lower EMI Change Plan Step 3
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-015 Your New EMI Plan Section Is Visible
    [Documentation]    Asserts "Your new EMI plan" text is visible on Step 3.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Wait For Elements State    text=Your new EMI plan    visible    timeout=${TIMEOUT}

TC-DP-LE-016 Revised Loan Agreement Info Is Visible
    [Documentation]    Asserts "The revised loan agreement" info text is visible on Step 3.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Wait For Elements State    text=The revised loan agreement    visible    timeout=${TIMEOUT}

TC-DP-LE-017 View Agreement Button Is Visible
    [Documentation]    Asserts view-agreement-button is visible on Step 3.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_VIEW_AGREEMENT_BTN}    visible    timeout=${TIMEOUT}

TC-DP-LE-018 View Agreement Button Opens Agreement Preview
    [Documentation]    Clicking view-agreement-button renders agreement content. Closes modal to restore confirm screen.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    ${DP_CP_AGREEMENT_PROCEED_BTN}    visible    timeout=${LONG_TIMEOUT}
    Click    role=button[name='Close']
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-019 Agreement Preview Proceed Button Returns To Confirm Screen
    [Documentation]    Clicking agreement-preview-proceed-button closes preview and returns to Step 3 confirm screen.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    ${DP_CP_AGREEMENT_PROCEED_BTN}    visible    timeout=${LONG_TIMEOUT}
    Click    ${DP_CP_AGREEMENT_PROCEED_BTN}
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-020 Agreement Modal Close Button Works
    [Documentation]    Clicking Close in agreement modal returns to Step 3 confirm screen.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Click    ${DP_CP_VIEW_AGREEMENT_BTN}
    Wait For Elements State    role=button[name='Close']    visible    timeout=${LONG_TIMEOUT}
    Click    role=button[name='Close']
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-021 Consent Checkbox Is Present And Unchecked By Default
    [Documentation]    Asserts consent-checkbox is present and unchecked by default on Step 3.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_CONSENT_CB}    visible    timeout=${TIMEOUT}
    ${checked}=    Get Property    ${DP_CP_CONSENT_CB}    checked
    Should Be Equal    ${checked}    ${FALSE}

TC-DP-LE-022 Consent Label Toggles Checkbox
    [Documentation]    Clicking consent-checkbox-label toggles the consent checkbox to checked.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    NONE
    Click    ${DP_CP_CONSENT_LABEL}
    ${checked}=    Get Property    ${DP_CP_CONSENT_CB}    checked
    Should Be Equal    ${checked}    ${TRUE}

TC-DP-LE-023 Confirm Button Without Consent Shows Error
    [Documentation]    Fresh Step 3 (consent unchecked). Clicking confirm-new-plan-button without consent shows consent-checkbox-error.
    [Tags]    change-plan-lower-emi-step3
    [Setup]    Navigate To Lower EMI Change Plan Step 3
    Click    ${DP_CP_CONFIRM_BTN}
    Wait For Elements State    ${DP_CP_CONSENT_ERROR}    visible    timeout=${TIMEOUT}


# ════════════════════════════════════════════════════════
# FLOW E — Step 4: ConfirmNewPlanSuccess (state-advancing — changes plan in DB)
# TC-DP-LE-025 uses Navigate To Lower EMI Change Plan Step 4.
# TC-DP-LE-026 to TC-DP-LE-034 use [Setup: NONE] — inherit Step 4 browser state.
# ════════════════════════════════════════════════════════

TC-DP-LE-025 Confirming Plan With Consent Navigates To Step 4
    [Documentation]
    ...    State-advancing. Checks consent, clicks confirm-new-plan-button.
    ...    Asserts Step 4 ConfirmNewPlanSuccess (plan-details-title) is visible.
    ...    Creates real DB entries for plan change. Subsequent tests use [Setup: NONE].
    [Tags]    change-plan-lower-emi-step4
    [Setup]    Navigate To Lower EMI Change Plan Step 4
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-026 Step 4 Success Title Is Visible
    [Documentation]    Asserts data-testid='title' is visible on Step 4 ConfirmNewPlanSuccess.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_STEP4_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-027 Step 4 Info Text Is Visible
    [Documentation]    Asserts data-testid='info' paragraph is visible on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_STEP4_INFO}    visible    timeout=${TIMEOUT}

TC-DP-LE-028 Plan Details Title Is Visible
    [Documentation]    Asserts plan-details-title element is visible on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-LE-029 EMI Amount Value Is Displayed
    [Documentation]    Asserts emi-amount-value element is visible with numeric content on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_EMI_AMOUNT_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_EMI_AMOUNT_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-LE-030 EMI Count Value Is Displayed
    [Documentation]    Asserts emi-count-value (tenure) element is visible with numeric content on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_EMI_COUNT_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_EMI_COUNT_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-LE-031 Total Loan Amount Is Displayed
    [Documentation]    Asserts total-loan-amount element is visible with numeric content on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_TOTAL_LOAN_AMOUNT}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_TOTAL_LOAN_AMOUNT}
    Should Match Regexp    ${text}    [0-9]

TC-DP-LE-032 APR Value Is Displayed
    [Documentation]    Asserts apr-value element is visible with numeric content on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_APR_VALUE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_CP_APR_VALUE}
    Should Match Regexp    ${text}    [0-9]

TC-DP-LE-033 Proceed To Next Button Is Visible
    [Documentation]    Asserts proceed-to-next-button is visible on Step 4.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_PROCEED_NEXT_BTN}    visible    timeout=${TIMEOUT}

TC-DP-LE-034 Close Button Is Visible On Step 4
    [Documentation]    Asserts close-button is visible on Step 4 ConfirmNewPlanSuccess.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Wait For Elements State    ${DP_CP_CLOSE_BTN}    visible    timeout=${TIMEOUT}


# ════════════════════════════════════════════════════════
# FLOW E — Post Step 4: Down Payment → Razorpay → Status (state-advancing — LAST)
# TC-DP-LE-035 clicks proceed-to-next → lands on Down Payment Step 5.
# TC-DP-LE-036 completes Razorpay UPI payment → /down-payment-status/ (LAST).
# ════════════════════════════════════════════════════════

TC-DP-LE-035 Proceed To Next Button Navigates To Down Payment Step
    [Documentation]
    ...    State-advancing. Clicks proceed-to-next-button on Step 4.
    ...    Selected lower EMI plan has downpayment — asserts redirect to /down-payment/ Step 5 (payment method).
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Click    ${DP_CP_PROCEED_NEXT_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms
    ...    Down Payment URL Should Contain App ID    ${DP_LOWER_EMI_APP_ID}
    Down Payment Step 5 Should Be Visible

TC-DP-LE-036 Complete Razorpay UPI Payment And Reach Status Page
    [Documentation]
    ...    State-advancing. Completes Razorpay UPI test payment (success@razorpay).
    ...    Asserts redirect to /down-payment-status/{app_id} and status page visible.
    ...    Creates real DB entries. MUST run LAST.
    [Tags]    change-plan-lower-emi-step4
    [Setup]    NONE
    Click    ${DP_ONLINE_PAYMENT}
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_PAY_BTN}
    Complete Razorpay Payment Via UPI
    Down Payment Status Page Should Be Visible
    Down Payment Status URL Should Contain App ID    ${DP_LOWER_EMI_APP_ID}
