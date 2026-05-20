*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Down Payment pages.
...    Covers /down-payment/{app_id} (Steps 1, 5, 6) and /down-payment-status/{app_id}.
...    All locators derived from data-testid attributes in frontend source.
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup    → Navigate To Down Payment New App (E2EApplicationFlow.robot)
...      Test Setup     → Go To ${BASE_URL}/down-payment/${DP_APP_ID} + Down Payment Page Should Be Visible
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    Flow E (Razorpay) + Flow F (Status) run LAST in shared session — state-advancing.
...    Razorpay iframe selectors (DP_RZ_*) must be confirmed against live UAT modal.

Library    Browser
Library    String


*** Variables ***
${DP_URL_FRAG}                  /down-payment/
${DP_STATUS_URL_FRAG}           /down-payment-status/

# Step 1 — SelectedPlan
${DP_FORM}                      css=[data-testid='down-payment-form']
${DP_INFO}                      css=[data-testid='down-payment-info']
${DP_HEADING}                   css=[data-testid='down-payment-heading']
${DP_DETAILS}                   css=[data-testid='down-payment-details']
${DP_TENURE_VALUE}              css=[data-testid='tenure-value']
${DP_EMI_MONTHLY_VALUE}         css=[data-testid='emi-per-month-value']
${DP_INTEREST_MONTHLY_VALUE}    css=[data-testid='interest-amt.-per-month-value']
${DP_PROCEED_BTN}               css=[data-testid='proceed-to-pay-button']
${DP_CHANGE_PLAN_CARD}          css=[data-testid='change-plan-flow-card']
${DP_CHANGE_PLAN_TYPE}          css=[data-testid='change-plan-type']

# Step 5 — DownPaymentMethod
${DP_TITLE}                     css=[data-testid='make-downpayment-title']
${DP_METHOD_INFO}               css=[data-testid='info']
${DP_PAYMENT_LABEL}             css=[data-testid='payment-title']
${DP_ONLINE_PAYMENT}            css=[data-testid='online_payment']
${DP_PAY_BTN}                   css=[data-testid='pay-button']

# Step 6 — VirtualAccountBankDetails
${DP_VA_HEADING}                css=[data-testid='heading']
${DP_VA_INFO}                   css=[data-testid='info']
${DP_VA_BANK_LABEL}             css=[data-testid='bank-transfer-details-label']
${DP_VA_TIMER_NOTE}             css=[data-testid='timer-note']
${DP_VA_ACCOUNT_NAME_VALUE}     css=[data-testid='Grayquest Education Finance Private Limited-value']

# DownPaymentStatus page — /down-payment-status/{app_id}
${DP_STATUS_TITLE}              css=div[data-testid='title']
${DP_STATUS_DETAILS}            css=[data-testid='details']
${DP_STATUS_EMI_VALUE}          css=[data-testid='total-emi-value']
${DP_STATUS_PAID_ON}            css=[data-testid='paid-on-value']
${DP_STATUS_REF_ID}             css=[data-testid='reference-id-value']
${DP_STATUS_NEXT_STEP}          css=[data-testid='next-step-container']
${DP_STATUS_NACH}               css=[data-testid='nach']
${DP_STATUS_SELFIE}             css=[data-testid='selfie']
${DP_STATUS_FINAL_BTN}          css=[data-testid='complete-the-final-steps-button']

# Change Plan — Step 2 (NewPlanList) — ${DP_CHANGE_APP_ID} app only (GILE EMI_PLAN_CHANGE=true)
${DP_CP_PLAN_LIST_TITLE}        css=[data-testid='new-plan-list-title']
${DP_CP_FIRST_PLAN}             css=[data-testid^='0-']
${DP_CP_PROCEED_BTN}            css=[data-testid='proceed-button']
${DP_CP_BACK_BTN}               css=[data-testid='back-button']

# Change Plan — Step 3 (ConfirmNewPlan)
${DP_CP_CONFIRM_TITLE}          css=[data-testid='confirm-new-plan-title']
${DP_CP_VIEW_AGREEMENT_BTN}     css=[data-testid='view-agreement-button']
${DP_CP_AGREEMENT_PROCEED_BTN}  css=[data-testid='agreement-preview-proceed-button']
${DP_CP_CONSENT_LABEL}          css=[data-testid='consent-checkbox-label']
${DP_CP_CONSENT_CB}             css=[data-testid='consent-checkbox']
${DP_CP_CONSENT_ERROR}          css=[data-testid='consent-checkbox-error']
${DP_CP_CONFIRM_BTN}            css=[data-testid='confirm-new-plan-button']

# Change Plan — Step 4 (ConfirmNewPlanSuccess) — confirmed from login_20260520_154520.js
${DP_CP_STEP4_TITLE}            css=[data-testid='title']
${DP_CP_STEP4_INFO}             css=[data-testid='info']
${DP_CP_PLAN_DETAILS_TITLE}     css=[data-testid='plan-details-title']
${DP_CP_EMI_AMOUNT_VALUE}       css=[data-testid='emi-amount-value']
${DP_CP_EMI_COUNT_VALUE}        css=[data-testid='emi-count-value']
${DP_CP_TOTAL_LOAN_AMOUNT}      css=[data-testid='total-loan-amount']
${DP_CP_APR_VALUE}              css=[data-testid='apr-value']
${DP_CP_PROCEED_NEXT_BTN}       css=[data-testid='proceed-to-next-button']
${DP_CP_CLOSE_BTN}              css=[data-testid='close-button']

# Razorpay iframe — all selectors confirmed from Playwright recording (login_20260518_174915.js)
# Selector syntax for Browser library: iframe >>> [data-testid='...']
${DP_RAZORPAY_FRAME}            iframe
${DP_RZ_CLOSE_BTN}              iframe >>> [data-testid='checkout-close']
${DP_RZ_CONFIRM_CLOSE}          iframe >>> [data-testid='confirm-positive']
${DP_RZ_UPI_TAB}                iframe >>> [data-testid='upi']
${DP_RZ_UPI_INPUT}              iframe >>> [placeholder='example@okhdfcbank']
${DP_RZ_SUBMIT_BTN}             iframe >>> [data-testid='vpa-submit']
${DP_RZ_FEE_BEARER_CTA}         iframe >>> [data-testid='fee-bearer-cta']
${DP_RZ_PAYMENT_STATUS}         iframe >>> [data-testid='payment-status-heading']
${DP_RZ_TEST_UPI_ID}            success@razorpay


*** Keywords ***
# ── Page visibility ──────────────────────────────────────────────────────────

Down Payment Page Should Be Visible
    Wait For Elements State    ${DP_DETAILS}    visible    timeout=${LONG_TIMEOUT}

Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_TITLE}    visible    timeout=${LONG_TIMEOUT}

Down Payment Step 6 Should Be Visible
    Wait For Elements State    ${DP_VA_BANK_LABEL}    visible    timeout=${LONG_TIMEOUT}

Down Payment Status Page Should Be Visible
    Wait For Elements State    ${DP_STATUS_DETAILS}    visible    timeout=${LONG_TIMEOUT}

# ── URL assertions ────────────────────────────────────────────────────────────

Down Payment URL Should Contain App ID
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /down-payment/${app_id}

Down Payment Status URL Should Contain App ID
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /down-payment-status/${app_id}

# ── Step navigation helpers ───────────────────────────────────────────────────

Navigate To Step 6 Via Bank Transfer
    [Documentation]
    ...    Goes to Step 5, selects Bank Transfer, submits form.
    ...    Triggers POST /v1/services/virtual-account (creates VA if not exists).
    ...    Waits for Step 6 bank transfer label to be visible.
    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    Down Payment Step 5 Should Be Visible
    Click    text=Pay via bank transfer
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_PAY_BTN}
    Down Payment Step 6 Should Be Visible

# ── Change Plan step visibility ──────────────────────────────────────────────

Down Payment Change Plan Step 2 Should Be Visible
    Wait For Elements State    ${DP_CP_PLAN_LIST_TITLE}    visible    timeout=${LONG_TIMEOUT}

Down Payment Change Plan Step 3 Should Be Visible
    Wait For Elements State    ${DP_CP_CONFIRM_TITLE}    visible    timeout=${LONG_TIMEOUT}

Down Payment Change Plan Step 4 Should Be Visible
    Wait For Elements State    ${DP_CP_PLAN_DETAILS_TITLE}    visible    timeout=${LONG_TIMEOUT}

# ── Change Plan step navigation helpers ──────────────────────────────────────

Navigate To Change Plan Step 2
    [Documentation]    Goes to Step 1 for change plan app, clicks change-plan-flow-card, waits for Step 2.
    Go To    ${BASE_URL}/down-payment/${DP_CHANGE_APP_ID}
    Down Payment Page Should Be Visible
    Click    ${DP_CHANGE_PLAN_CARD}
    Down Payment Change Plan Step 2 Should Be Visible

Navigate To Change Plan Step 3
    [Documentation]    Goes through Step 2: selects first plan, proceeds to Step 3.
    Navigate To Change Plan Step 2
    Click    ${DP_CP_FIRST_PLAN}
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_CP_PROCEED_BTN}
    Down Payment Change Plan Step 3 Should Be Visible

Navigate To Change Plan Step 4
    [Documentation]
    ...    Goes through Step 3: checks consent, clicks confirm-new-plan-button → Step 4.
    ...    State-advancing — changes plan in DB. Call once per suite run.
    Navigate To Change Plan Step 3
    Check Checkbox    ${DP_CP_CONSENT_CB}
    Click    ${DP_CP_CONFIRM_BTN}
    Down Payment Change Plan Step 4 Should Be Visible

# ── Step navigation helpers ───────────────────────────────────────────────────

Close Razorpay Modal
    [Documentation]    Closes the Razorpay checkout iframe via the close + confirm buttons.
    Wait For Razorpay Modal
    Click    ${DP_RZ_CLOSE_BTN}
    Click    ${DP_RZ_CONFIRM_CLOSE}

# ── Razorpay modal ────────────────────────────────────────────────────────────

Wait For Razorpay Modal
    [Documentation]    Waits for Razorpay checkout iframe to become visible after clicking Pay button.
    Wait For Elements State    ${DP_RAZORPAY_FRAME}    visible    timeout=${LONG_TIMEOUT}

Complete Razorpay Payment Via UPI
    [Documentation]
    ...    Interacts with Razorpay test-mode modal using UPI test ID success@razorpay.
    ...    Selectors confirmed from Playwright recording (login_20260518_174915.js).
    ...    Flow: UPI tab → fill UPI ID → vpa-submit → fee-bearer-cta → payment-status-heading → redirect.
    ...    Assumes Online Payment is selected and pay-button has been clicked.
    Wait For Razorpay Modal
    Click    ${DP_RZ_UPI_TAB}
    Wait For Elements State    ${DP_RZ_UPI_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${DP_RZ_UPI_INPUT}    ${DP_RZ_TEST_UPI_ID}
    Click    ${DP_RZ_SUBMIT_BTN}
    Wait For Elements State    ${DP_RZ_FEE_BEARER_CTA}    visible    timeout=${TIMEOUT}
    Click    ${DP_RZ_FEE_BEARER_CTA}
    Wait For Elements State    ${DP_RZ_PAYMENT_STATUS}    visible    timeout=${TIMEOUT}
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    1s
    ...    Down Payment Status URL Should Contain App ID    ${DP_APP_ID}
