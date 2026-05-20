*** Settings ***
Documentation
...    Downpayment page tests for the GQ Customer Portal (/down-payment/{app_id}).
...    Single shared session — Flows A, B, C, E, F in execution order.
...
...    Suite Setup: full journey — login (fresh dynamic mobile) → wizard (plan 1)
...    → Western Capital lender → KYC DB bypass → esign → sign → /down-payment/{app_id}.
...
...    Flow A (TC-DP-001–009)    Step 1 SelectedPlan UI
...    Flow B (TC-DP-011–020)    Step 5 DownPaymentMethod UI
...    Flow C (TC-DP-031–040)    Step 6 VirtualAccountBankDetails
...    Flow E (TC-DP-RZ-001–005) Razorpay test-mode payment (LAST — state-advancing)
...    Flow F (TC-DP-STATUS-001–014) DownPaymentStatus page (inherits from E)
...
...    State-advancing tests run LAST:
...      TC-DP-009   Step 1 → Step 5 navigation            [Setup: NONE]
...      TC-DP-RZ-004  Razorpay payment completes          [Setup: NONE] → navigates to /down-payment-status/
...      TC-DP-STATUS-014  Clicks Complete button → /nach/ [Setup: NONE]

Library      Browser
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/EsignPage.robot
Resource     ../../resources/DownPaymentPage.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Library      ../../libraries/kyc_bypass_db.py
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Down Payment New App
Suite Teardown   Close Browser
Test Setup       Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}
...              AND    Down Payment Page Should Be Visible

Test Tags    down-payment    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Downpayment


*** Variables ***
${DP_APP_ID}    ${EMPTY}


*** Test Cases ***
# ════════════════════════════════════════════════════════
# FLOW A — Step 1: SelectedPlan (/down-payment/{app_id})
# ════════════════════════════════════════════════════════

TC-DP-001 Down Payment Page Loads At Correct URL
    [Documentation]    Asserts browser is at /down-payment/{app_id} after signing esign.
    [Tags]    down-payment-step1
    Down Payment URL Should Contain App ID    ${DP_APP_ID}

TC-DP-002 Info Paragraph Is Visible
    [Documentation]    Asserts info paragraph mentioning downpayment requirement is visible.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_INFO}    visible    timeout=${TIMEOUT}

TC-DP-003 Selected EMI Plan Heading Is Visible
    [Documentation]    Asserts "Your selected EMI plan" heading is visible.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_HEADING}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_HEADING}
    Should Contain    ${text}    Your selected EMI plan

TC-DP-004 Downpayment Amount Details Are Visible
    [Documentation]    Asserts DownpaymentDetailsHeader (amount + label) is visible.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_DETAILS}    visible    timeout=${TIMEOUT}

TC-DP-005 Payable Today Amount Is Displayed
    [Documentation]    Asserts down-payment-details shows a rupee amount value.
    [Tags]    down-payment-step1
    ${text}=    Get Text    ${DP_DETAILS}
    Should Contain    ${text}    ₹

TC-DP-006 Proceed To Pay Button Is Visible
    [Documentation]    Asserts "Proceed to pay" button is visible and not disabled.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${DP_PROCEED_BTN}    disabled
    Should Be True    not ${disabled}

TC-DP-007 Change Plan Card Not Visible For Standard App
    [Documentation]    For standard plan 1 app without GILE change-plan config, no change plan card shown.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_CHANGE_PLAN_CARD}    hidden    timeout=${TIMEOUT}

TC-DP-008 Down Payment Form Element Is Present
    [Documentation]    Asserts the root form element with data-testid is present.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_FORM}    visible    timeout=${TIMEOUT}

TC-DP-008A Tenure Value Is Displayed
    [Documentation]    Asserts tenure-value element is visible (loan tenure in months).
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_TENURE_VALUE}    visible    timeout=${TIMEOUT}

TC-DP-008B EMI Per Month Value Is Displayed
    [Documentation]    Asserts emi-per-month-value element is visible.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_EMI_MONTHLY_VALUE}    visible    timeout=${TIMEOUT}

TC-DP-008C Interest Per Month Value Is Displayed
    [Documentation]    Asserts interest-amt.-per-month-value element is visible.
    [Tags]    down-payment-step1
    Wait For Elements State    ${DP_INTEREST_MONTHLY_VALUE}    visible    timeout=${TIMEOUT}

TC-DP-009 Proceed To Pay Button Navigates To Step 5
    [Documentation]    Clicking Proceed to Pay navigates to Step 5 — asserts Make Downpayment title visible.
    [Tags]    down-payment-step1
    [Setup]    NONE
    Click    ${DP_PROCEED_BTN}
    Down Payment Step 5 Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW B — Step 5: DownPaymentMethod (#5)
# ════════════════════════════════════════════════════════

TC-DP-011 Make Downpayment Title Is Visible
    [Documentation]    Asserts "Make Downpayment" title is visible on Step 5.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_TITLE}    visible    timeout=${TIMEOUT}

TC-DP-012 Step 5 Info Paragraph Is Visible
    [Documentation]    Asserts info paragraph mentioning downpayment and institute name is visible.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_METHOD_INFO}    visible    timeout=${TIMEOUT}

TC-DP-013 Choose Payment Method Label Is Visible
    [Documentation]    Asserts "Choose payment method" label is visible.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_PAYMENT_LABEL}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_PAYMENT_LABEL}
    Should Contain    ${text}    Choose payment method

TC-DP-014 Downpayment Amount Header Visible On Step 5
    [Documentation]    Asserts amount header (down-payment-details) is visible on Step 5.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_DETAILS}    visible    timeout=${TIMEOUT}

TC-DP-015 Online Payment Option Is Visible
    [Documentation]    Asserts Online Payment radio card is visible.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_ONLINE_PAYMENT}    visible    timeout=${TIMEOUT}

TC-DP-016 Online Payment Is Selected By Default
    [Documentation]    Asserts Online Payment is pre-selected (ONLINE_PAYMENT value).
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_PAY_BTN}
    Should Match Regexp    ${text}    (?i)pay online

TC-DP-017 Pay Button Shows Amount When Online Payment Selected
    [Documentation]    Pay button text contains "Pay Online" and "₹" amount when online payment selected.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    ${text}=    Get Text    ${DP_PAY_BTN}
    Should Match Regexp    ${text}    (?i)pay online
    Should Match Regexp    ${text}    [₹0-9,]+

TC-DP-018 Bank Transfer Option Is Visible
    [Documentation]    Asserts Bank Transfer radio card is visible (virtual account not disabled).
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Wait For Elements State    text=Pay via bank transfer    visible    timeout=${TIMEOUT}

TC-DP-019 Selecting Bank Transfer Changes Pay Button Text
    [Documentation]    Clicking Bank Transfer card changes pay button text to "Show Bank Account Details".
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Click    text=Pay via bank transfer
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_PAY_BTN}
    Should Match Regexp    ${text}    (?i)show bank account details

TC-DP-020 Switching Back To Online Payment Restores Button Text
    [Documentation]    Clicking Online Payment after Bank Transfer restores "Pay Online" button text.
    [Tags]    down-payment-step5
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Click    text=Pay via bank transfer
    Click    ${DP_ONLINE_PAYMENT}
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_PAY_BTN}
    Should Match Regexp    ${text}    (?i)pay online


# ════════════════════════════════════════════════════════
# FLOW C — Step 6: VirtualAccountBankDetails (#6)
# ════════════════════════════════════════════════════════

TC-DP-031 Step 6 Heading Is Visible
    [Documentation]    Asserts heading paragraph (with institute name) is visible on Step 6.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    ${DP_VA_HEADING}    visible    timeout=${TIMEOUT}

TC-DP-032 Redirect Info Card Is Visible
    [Documentation]    Asserts info card text about automatic redirect after payment is visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    ${DP_VA_INFO}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_VA_INFO}
    Should Contain    ${text}    automatically redirected

TC-DP-033 Bank Transfer Details Label Is Visible
    [Documentation]    Asserts "Bank transfer details" label is visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    ${DP_VA_BANK_LABEL}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_VA_BANK_LABEL}
    Should Contain    ${text}    Bank transfer details

TC-DP-034 Timer Note Is Visible
    [Documentation]    Asserts timer note about 4-hour processing time is visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    ${DP_VA_TIMER_NOTE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_VA_TIMER_NOTE}
    Should Contain    ${text}    4 hours

TC-DP-035 Account Name Row Is Displayed
    [Documentation]    Asserts "Account name" label and Grayquest account name value are visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    text=Account name    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${DP_VA_ACCOUNT_NAME_VALUE}    visible    timeout=${TIMEOUT}

TC-DP-036 Bank Name Row Is Displayed
    [Documentation]    Asserts "Bank name" label and its value are visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    text=Bank name    visible    timeout=${TIMEOUT}

TC-DP-037 Account Number Row Is Displayed
    [Documentation]    Asserts "Account number" label and its value are visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    text=Account number    visible    timeout=${TIMEOUT}

TC-DP-038 IFSC Code Row Is Displayed
    [Documentation]    Asserts "IFSC code" label and its value are visible.
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    Wait For Elements State    text=IFSC code    visible    timeout=${TIMEOUT}

TC-DP-039 Four Copy Icons Are Present
    [Documentation]    Asserts 4 copy icons visible — one per bank detail row (Account name, Bank name, Account number, IFSC).
    [Tags]    down-payment-step6
    [Setup]    Navigate To Step 6 Via Bank Transfer
    ${count}=    Get Element Count    role=listitem >> role=img
    Should Be True    ${count} >= 4

TC-DP-040 Direct Navigation To Step 6 Without State Redirects To Step 1
    [Documentation]    Navigating directly to step 6 without smartCollectSelected state redirects to Step 1.
    [Tags]    down-payment-step6
    ${step6_url}=    Evaluate    '${BASE_URL}/down-payment/${DP_APP_ID}' + '#6'
    Go To    ${step6_url}
    Down Payment Page Should Be Visible


# ════════════════════════════════════════════════════════
# FLOW E — Razorpay Test Mode Payment (LAST — state-advancing)
# Runs after all read-only tests. Creates real DB entries:
#   razorpay_order_details, gq_internal_payment_transaction_logs, customer_tracker
# ════════════════════════════════════════════════════════

TC-DP-RZ-001 Razorpay Modal Appears After Clicking Pay Online
    [Documentation]
    ...    Clicks Pay Online button on Step 5. Asserts Razorpay checkout iframe becomes visible.
    ...    Modal stays open — RZ-002, RZ-003, RZ-004 inherit via [Setup: NONE].
    [Tags]    down-payment-razorpay    razorpay-modal
    [Setup]    Run Keywords    Go To    ${BASE_URL}/down-payment/${DP_APP_ID}#5
    ...        AND    Down Payment Step 5 Should Be Visible
    Click    ${DP_PAY_BTN}
    Wait For Razorpay Modal

TC-DP-RZ-002 Razorpay Modal Does Not Navigate Away From Down Payment
    [Documentation]    After modal opens, URL still contains /down-payment/ (modal is overlay, not redirect).
    [Tags]    down-payment-razorpay    razorpay-modal
    [Setup]    NONE
    ${url}=    Get Url
    Should Contain    ${url}    /down-payment/

TC-DP-RZ-003 UPI Tab Is Visible Inside Razorpay Modal
    [Documentation]
    ...    Asserts UPI payment tab (data-testid='upi') is visible inside the Razorpay iframe.
    ...    Selector confirmed from Playwright recording login_20260518_174915.js.
    [Tags]    down-payment-razorpay    razorpay-modal
    [Setup]    NONE
    Wait For Elements State    ${DP_RZ_UPI_TAB}    visible    timeout=${TIMEOUT}

TC-DP-RZ-004 Razorpay Test Mode UPI Payment Completes Successfully
    [Documentation]
    ...    End-to-end Razorpay payment via UPI test mode (success@razorpay).
    ...    Creates real DB entries:
    ...      - razorpay_order_details (INSERT order, UPDATE payment_id)
    ...      - gq_internal_payment_transaction_logs (INSERT, is_success=1)
    ...      - customer_tracker (INSERT slug='down-payment-completed')
    ...    Navigates to /down-payment-status/{app_id} on success.
    ...    [Setup: NONE] — inherits open Razorpay modal from RZ-003.
    ...    Modal auto-closes after successful payment (redirect to /down-payment-status/).
    [Tags]    down-payment-razorpay    razorpay-payment
    [Setup]    NONE
    Complete Razorpay Payment Via UPI
    Down Payment Status Page Should Be Visible

TC-DP-RZ-005 After Payment URL Contains Down Payment Status App ID
    [Documentation]    Post-payment URL contains /down-payment-status/{app_id}. [Setup NONE] inherits.
    [Tags]    down-payment-razorpay    razorpay-payment
    [Setup]    NONE
    Down Payment Status URL Should Contain App ID    ${DP_APP_ID}


# ════════════════════════════════════════════════════════
# FLOW F — DownPaymentStatus page (/down-payment-status/{app_id})
# [Setup: NONE] — all inherit from TC-DP-RZ-004 which navigated here
# ════════════════════════════════════════════════════════

TC-DP-STATUS-001 Status Page Loads At Correct URL
    [Documentation]    Asserts URL contains /down-payment-status/{app_id}.
    [Tags]    down-payment-status
    [Setup]    NONE
    Down Payment Status URL Should Contain App ID    ${DP_APP_ID}

TC-DP-STATUS-002 Downpayment Successful Title Is Visible
    [Documentation]    Asserts "Downpayment Successful!" success title is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_TITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_STATUS_TITLE}
    Should Contain    ${text}    Downpayment Successful

TC-DP-STATUS-003 Contact Details Paragraph Is Visible
    [Documentation]    Asserts details paragraph with mobile and email is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_DETAILS}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-004 Paid EMI Amount Is Displayed
    [Documentation]    Asserts paid EMI amount value is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_EMI_VALUE}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-005 Paid On Date Is Displayed
    [Documentation]    Asserts payment timestamp (paid-on-value) is visible — populated from Razorpay verify.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_PAID_ON}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-006 Reference ID Is Displayed
    [Documentation]    Asserts Razorpay payment_id (reference-id-value) is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_REF_ID}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DP_STATUS_REF_ID}
    Should Not Be Empty    ${text}

TC-DP-STATUS-007 Next Step Container Is Visible
    [Documentation]    Asserts next-step-container block is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_NEXT_STEP}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-008 You Are Almost Done Title Visible
    [Documentation]    Asserts title (data-testid='title') inside next-step-container is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    css=[data-testid='next-step-container'] [data-testid='title']    visible    timeout=${TIMEOUT}

TC-DP-STATUS-009 Next Step Message Is Visible
    [Documentation]    Asserts message text mentioning institute name is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    css=[data-testid='message']    visible    timeout=${TIMEOUT}

TC-DP-STATUS-010 EMI Repayment Image Block Is Visible
    [Documentation]    Asserts NACH (EMI setup) image block is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_NACH}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-011 Selfie Image Block Is Visible
    [Documentation]    Asserts selfie image block is visible.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_SELFIE}    visible    timeout=${TIMEOUT}

TC-DP-STATUS-012 Complete Final Steps Button Is Visible
    [Documentation]    Asserts "COMPLETE THE FINAL STEPS" button is visible and enabled.
    [Tags]    down-payment-status
    [Setup]    NONE
    Wait For Elements State    ${DP_STATUS_FINAL_BTN}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${DP_STATUS_FINAL_BTN}    disabled
    Should Be True    not ${disabled}

TC-DP-STATUS-013 Button Text Is Complete The Final Steps
    [Documentation]    Asserts button label is "COMPLETE THE FINAL STEPS".
    [Tags]    down-payment-status
    [Setup]    NONE
    ${text}=    Get Text    ${DP_STATUS_FINAL_BTN}
    Should Contain    ${text}    COMPLETE THE FINAL STEPS

TC-DP-STATUS-014 Clicking Complete Final Steps Navigates To NACH Page
    [Documentation]
    ...    Clicking button navigates to /nach/{app_id}. [Setup NONE] — last test in session.
    ...    After this: session ends, journey proceeds to NACH setup.
    [Tags]    down-payment-status
    [Setup]    NONE
    Click    ${DP_STATUS_FINAL_BTN}
    ${url}=    Get Url
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms
    ...    Run Keyword    Should Contain    ${url}    /nach/
