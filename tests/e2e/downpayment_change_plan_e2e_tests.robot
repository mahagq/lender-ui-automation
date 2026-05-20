*** Settings ***
Documentation
...    Downpayment Change Plan E2E journey tests from login through to final step.
...    Each test owns its own browser session (fresh mobile per test).
...
...    TC-DP-CP-E01 — New app (Thakkar): login → wizard → Western Capital → KYC bypass →
...                  esign → sign → /down-payment/ → change plan card → Step 2 (plan selection) →
...                  Step 3 (consent + confirm) → Step 4 (ConfirmNewPlanSuccess → NACH).
...
...    TC-DP-CP-E02 — New app (Ashvini Varhade, Lower EMI): login → wizard → Western Capital →
...                  KYC bypass → esign → sign → /down-payment/ → lower EMI card → Step 2 →
...                  Step 3 (consent + confirm) → Step 4 → proceed → Down Payment Step 5 →
...                  Razorpay UPI → /down-payment-status/ → NACH.

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/DownPaymentPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags    down-payment    change-plan    regression    lender-selection-e2e
...          allure.label.epic:CP UI Automation
...          allure.label.feature:Downpayment Change Plan
...          allure.label.story:Change Plan E2E Journey

*** Variables ***
${DP_LOWER_EMI_APP_ID}    ${EMPTY}


*** Test Cases ***
TC-DP-CP-E01 New App (Thakkar) - Full Journey Login To Change Plan Step 4
    [Documentation]
    ...    Full change-plan E2E: dynamic fresh mobile → Thakkar International Academy (EMI_PLAN_CHANGE=true)
    ...    → plan 1 → Western Capital → KYC DB bypass → sign agreement → /down-payment/ →
    ...    change-plan-flow-card → Step 2 (select first plan + proceed) →
    ...    Step 3 (consent checkbox + confirm) → Step 4 (ConfirmNewPlanSuccess).
    ...    Asserts plan-details-title visible on Step 4. Creates real DB entries for plan change.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Navigate To Down Payment Change Plan App
    Down Payment Page Should Be Visible
    Wait For Elements State    ${DP_CHANGE_PLAN_CARD}    visible    timeout=${TIMEOUT}
    Navigate To Change Plan Step 4
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${DP_CP_EMI_AMOUNT_VALUE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${DP_CP_PROCEED_NEXT_BTN}    visible    timeout=${TIMEOUT}

TC-DP-CP-E02 New App (Ashvini Varhade) - Lower EMI Change Plan Full Journey To Status Page
    [Documentation]
    ...    Full lower EMI change-plan E2E: dynamic fresh mobile → Ashvini Varhade (EMI_PLAN_CHANGE=true)
    ...    → plan 1 → Western Capital → KYC DB bypass → sign agreement → /down-payment/ →
    ...    lower-emi-flow-card → Step 2 (select first lower EMI plan + proceed) →
    ...    Step 3 (consent checkbox + confirm) → Step 4 (ConfirmNewPlanSuccess) →
    ...    proceed-to-next → Down Payment Step 5 → Razorpay UPI (success@razorpay) →
    ...    /down-payment-status/ (payment success).
    ...    Creates real DB entries for plan change + Razorpay payment.
    [Tags]    robot:skip
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Navigate To Down Payment Lower EMI App
    Down Payment Page Should Be Visible
    Wait For Elements State    ${DP_LE_CARD}    visible    timeout=${TIMEOUT}
    Navigate To Lower EMI Change Plan Step 4
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${DP_CP_PROCEED_NEXT_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms
    ...    Down Payment URL Should Contain App ID    ${DP_LOWER_EMI_APP_ID}
    Down Payment Step 5 Should Be Visible
    Click    ${DP_ONLINE_PAYMENT}
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_PAY_BTN}
    Complete Razorpay Payment Via UPI
    Down Payment Status Page Should Be Visible
    Down Payment Status URL Should Contain App ID    ${DP_LOWER_EMI_APP_ID}
