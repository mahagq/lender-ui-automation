*** Settings ***
Documentation
...    Downpayment Change Plan E2E journey test from login through to Step 4 (ConfirmNewPlanSuccess).
...    Each test owns its own browser session (fresh mobile per test).
...    Institute: Thakkar International Academy (GILE EMI_PLAN_CHANGE=true).
...
...    TC-DP-CP-E01 — New app (Thakkar): login → wizard → Western Capital → KYC bypass →
...                  esign → sign → /down-payment/ → change plan card → Step 2 (plan selection) →
...                  Step 3 (consent + confirm) → Step 4 (ConfirmNewPlanSuccess visible).

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
