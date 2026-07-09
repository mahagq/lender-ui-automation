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

# Change Plan — Lower EMI flow (Step 1) — ${DP_LOWER_EMI_APP_ID} app only (Ashvini Varhade)
# TBD — update all DP_LE_* locators from Playwright recording once available
${DP_LE_CARD}                   css=[data-testid='lower-emi-flow-card']
${DP_LE_CARD_TYPE}              css=[data-testid='lower-emi-type']

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

# ── Lower EMI Change Plan step navigation helpers ────────────────────────────

Navigate To Lower EMI Change Plan Step 2
    [Documentation]    Goes to Step 1 for lower EMI app, clicks lower-emi-flow-card, waits for Step 2.
    Go To    ${BASE_URL}/down-payment/${DP_LOWER_EMI_APP_ID}
    Down Payment Page Should Be Visible
    Click    ${DP_LE_CARD}
    Down Payment Change Plan Step 2 Should Be Visible

Navigate To Lower EMI Change Plan Step 3
    [Documentation]    Goes through Step 2: selects first plan, proceeds to Step 3.
    Navigate To Lower EMI Change Plan Step 2
    Click    ${DP_CP_FIRST_PLAN}
    Wait For Elements State    ${DP_CP_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    Click    ${DP_CP_PROCEED_BTN}
    Down Payment Change Plan Step 3 Should Be Visible

Navigate To Lower EMI Change Plan Step 4
    [Documentation]
    ...    Goes through Step 3: checks consent, clicks confirm-new-plan-button → Step 4.
    ...    State-advancing — changes plan in DB. Call once per suite run.
    Navigate To Lower EMI Change Plan Step 3
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

Complete Razorpay Payment Via UPI For App
    [Arguments]    ${app_id}
    [Documentation]
    ...    Same as Complete Razorpay Payment Via UPI but waits for the status redirect for a
    ...    dynamic ${app_id} (used by the end-to-end journey rather than a fixed suite app).
    Wait For Razorpay Modal
    Click    ${DP_RZ_UPI_TAB}
    Wait For Elements State    ${DP_RZ_UPI_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${DP_RZ_UPI_INPUT}    ${DP_RZ_TEST_UPI_ID}
    Click    ${DP_RZ_SUBMIT_BTN}
    Wait For Elements State    ${DP_RZ_FEE_BEARER_CTA}    visible    timeout=${TIMEOUT}
    Click    ${DP_RZ_FEE_BEARER_CTA}
    Wait For Elements State    ${DP_RZ_PAYMENT_STATUS}    visible    timeout=${LONG_TIMEOUT}
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    1s
    ...    Down Payment Status URL Should Contain App ID    ${app_id}

Dump Page Testids
    [Arguments]    ${label}
    [Documentation]    Logs every data-testid present on the current page (exploration helper).
    ${ids}=    Evaluate JavaScript    ${None}
    ...    () => [...new Set([...document.querySelectorAll('[data-testid]')].map(e => e.getAttribute('data-testid')))]
    Log    [${label}] URL: ${{ "current" }}    console=True
    ${url}=    Get Url
    Log    [${label}] ${url}    console=True
    Log    [${label}] testids: ${ids}    console=True
    RETURN    ${ids}

Enach Checkout URL Should Be Active
    [Arguments]    ${app_id}
    [Documentation]    Asserts the URL has advanced to /enach-checkout/{app_id} (mandate form created).
    ${url}=    Get Url
    Should Contain    ${url}    /enach-checkout/${app_id}

Fill Manual Bank Details And Proceed
    [Documentation]
    ...    On /bank-verification: selects SBI, fills account number + IFSC, picks Savings, clicks Proceed.
    ...    Re-selecting/re-filling is safe to call repeatedly (used by the refresh-retry loop).
    Wait For Elements State    css=[data-testid='choose-your-bank-react-select']    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='choose-your-bank-react-select']
    Sleep    500ms
    # Close the react-select dropdown (it floats over the SBI tile and intercepts clicks).
    Keyboard Key    press    Escape
    Sleep    300ms
    Click    css=[data-testid='sbi-bank-option']
    Wait For Elements State    css=[data-testid='cust-bank-accont-number']    visible    timeout=${TIMEOUT}
    Fill Text    css=[data-testid='cust-bank-accont-number']    ${NACH_ACCOUNT_NUMBER}
    Fill Text    css=[data-testid='cust-ifsc-code']    ${NACH_IFSC}
    Click    css=[data-testid='select-bank-account-type-radio-container-0']
    Sleep    500ms
    Click    css=[data-testid='nach-bank-verifcation-proceed-button']

Complete Nach Bank Verification
    [Arguments]    ${app_id}    ${attempts}=4
    [Documentation]
    ...    From the /nach intro page: Continue to Setup → Manual Entry → fill SBI account → Proceed.
    ...    UAT intermittently returns "Failed to create mandate form" (server/vendor hiccup); per the
    ...    known workaround we refresh the page and retry up to ${attempts} times. Succeeds when the
    ...    URL advances to /enach-checkout/{app_id}.
    Wait For Elements State    css=[data-testid='nach-continue-to-setup-button']    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='nach-continue-to-setup-button']
    Sleep    2s
    # Some lenders (e.g. Tata Capital) skip the UPI/Manual choice and go straight to bank selection.
    ${has_manual_entry}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[data-testid='manual_entry']    visible    timeout=8s
    IF    ${has_manual_entry}    Click    css=[data-testid='manual_entry']
    FOR    ${i}    IN RANGE    ${attempts}
        Fill Manual Bank Details And Proceed
        ${reached}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    15s    1s    Enach Checkout URL Should Be Active    ${app_id}
        IF    ${reached}
            Log    ✅ eNACH mandate form created — at /enach-checkout/${app_id}    console=True
            RETURN
        END
        ${on_lender}=    Lender Selection Page Is Visible
        IF    ${on_lender}
            Fail    eNACH bounced to lender-selection page — not refreshing (would reset the journey)
        END
        Log    "Failed to create mandate form" (attempt ${i + 1}/${attempts}) — refreshing per UAT workaround    level=WARN
        Reload
        Sleep    3s
        ${on_method}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=[data-testid='manual_entry']    visible    timeout=8s
        IF    ${on_method}    Click    css=[data-testid='manual_entry']
    END
    Fail    eNACH mandate form could not be created after ${attempts} attempts — UAT likely down

Lender Selection Page Is Visible
    [Documentation]    True if the "More partners ready to help you!" lender-selection heading is showing.
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    role=heading[name=More partners ready to help you!]    visible    timeout=2s
    RETURN    ${visible}

Dump Page Iframes
    [Arguments]    ${label}
    [Documentation]    Logs the src of every iframe on the page (to spot the Digio/third-party frame).
    ${frames}=    Evaluate JavaScript    ${None}
    ...    () => [...document.querySelectorAll('iframe')].map(f => ({ src: f.src, id: f.id, cls: f.className }))
    Log    [${label}] iframes: ${frames}    console=True
    RETURN    ${frames}

Dump Digio Frame
    [Arguments]    ${label}
    [Documentation]
    ...    The Digio mandate dialog renders in a SAME-ORIGIN iframe (id starts digio-ifm-),
    ...    so we can reach into contentDocument and enumerate its testids, inputs, radios and
    ...    buttons. This is what lets us drive the verification-mode + consent + Submit step.
    ${info}=    Evaluate JavaScript    ${None}
    ...    () => {
    ...        const f = document.querySelector("iframe[id^='digio-ifm-']");
    ...        if (!f || !f.contentDocument) return { error: 'no same-origin digio iframe' };
    ...        const d = f.contentDocument;
    ...        const testids = [...new Set([...d.querySelectorAll('[data-testid]')].map(e => e.getAttribute('data-testid')))];
    ...        const inputs = [...d.querySelectorAll('input')].map(i => ({ type: i.type, name: i.name, id: i.id, value: i.value, testid: i.getAttribute('data-testid') }));
    ...        const buttons = [...d.querySelectorAll('button')].map(b => ({ text: (b.innerText || '').trim(), id: b.id, testid: b.getAttribute('data-testid'), disabled: b.disabled }));
    ...        const labels = [...d.querySelectorAll('label')].map(l => (l.innerText || '').trim()).filter(Boolean);
    ...        return { testids, inputs, buttons, labels };
    ...    }
    Log    [${label}] digio: ${info}    console=True
    RETURN    ${info}

Dump Digio Frame Playwright
    [Arguments]    ${label}
    [Documentation]
    ...    The Digio mandate dialog is a CROSS-ORIGIN iframe, so contentDocument JS is blocked.
    ...    Playwright (Browser lib) pierces frames with the ' >>> ' selector. Enumerate buttons,
    ...    inputs and labels inside the frame so we can build the verification-mode + consent + Submit step.
    ${btns}=    Get Elements    css=iframe[id^="digio-ifm-"] >>> button
    Log    [${label}] frame button count: ${{ len($btns) }}    console=True
    FOR    ${b}    IN    @{btns}
        ${txt}=    Run Keyword And Return Status    Get Text    ${b}
        ${t}=      Run Keyword And Ignore Error    Get Text    ${b}
        Log    [${label}] button: ${t}    console=True
    END
    ${inputs}=    Get Elements    css=iframe[id^="digio-ifm-"] >>> input
    Log    [${label}] frame input count: ${{ len($inputs) }}    console=True
    FOR    ${i}    IN    @{inputs}
        ${ty}=    Run Keyword And Ignore Error    Get Property    ${i}    type
        ${nm}=    Run Keyword And Ignore Error    Get Property    ${i}    name
        ${idv}=   Run Keyword And Ignore Error    Get Attribute    ${i}    id
        ${vv}=    Run Keyword And Ignore Error    Get Attribute    ${i}    value
        Log    [${label}] input: type=${ty} name=${nm} id=${idv} value=${vv}    console=True
    END
    ${labels}=    Get Elements    css=iframe[id^="digio-ifm-"] >>> label
    Log    [${label}] frame label count: ${{ len($labels) }}    console=True
    FOR    ${l}    IN    @{labels}
        ${lt}=    Run Keyword And Ignore Error    Get Text    ${l}
        Log    [${label}] label: ${lt}    console=True
    END

Complete Enach Checkout
    [Arguments]    ${app_id}
    [Documentation]
    ...    On /enach-checkout: clicks the e-mandate proceed button to open the Digio dialog,
    ...    then drives the Debit Card mandate (Submit Digio Mandate Debit Card → NPCI Accept).
    Wait For Elements State    css=[data-testid='e-mandate-proceed-button']    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='e-mandate-proceed-button']
    Sleep    5s
    Submit Digio Mandate Debit Card

Submit Digio Mandate Debit Card
    [Documentation]
    ...    Drives the Digio mandate dialog (cross-origin iframe — Playwright ' >>> ' frame piercing,
    ...    because contentDocument is blocked):
    ...      1. Select the Debit Card verification mode (radio is identified only by its label text).
    ...      2. Tick the authorization consent checkbox (last checkbox in the dialog).
    ...      3. Click Submit — enabled once mode + consent are set.
    ...    Submit opens a SEPARATE Digio popup window (ext.digio.in NPCI Simulation, Accept/Reject).
    ...    In UAT, Accept completes the e-mandate. We switch to that popup, click Accept, then return.
    ${frame}=    Set Variable    css=iframe[id^="digio-ifm-"]
    Wait For Elements State    ${frame} >>> text=Debit Card    visible    timeout=${LONG_TIMEOUT}
    Click    ${frame} >>> text=Debit Card
    Sleep    1s
    # Consent checkbox: the real <input> is hidden behind a styled box, so force-checking the input
    # sets .checked but never fires the click/change event Digio's component listens to (Submit stays
    # disabled). Click the visible label instead — a real click bubbles into Digio's handler and flips
    # its state. Fall back to force-checking the input only if the label click didn't enable Submit.
    Scroll To Element    ${frame} >>> input[type=checkbox] >> nth=-1
    Sleep    500ms
    Click    ${frame} >>> label >> nth=-1
    Sleep    500ms
    ${submit_enabled}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${frame} >>> button:has-text('Submit')    enabled    timeout=5s
    IF    not ${submit_enabled}
        Log    Label click did not enable Submit — falling back to force-check on input    console=True
        Check Checkbox    ${frame} >>> input[type=checkbox] >> nth=-1    force=True
        Sleep    500ms
    END
    Wait For Elements State    ${frame} >>> button:has-text('Submit')    enabled    timeout=${LONG_TIMEOUT}
    Take Screenshot    fullPage=True
    Click    ${frame} >>> button:has-text('Submit')
    # Submit pops a new Digio window (NPCI Simulation). Wait for it to open then switch to it.
    Sleep    4s
    Switch Page    NEW
    ${npci_url}=    Get Url
    Log    Digio NPCI simulation popup — URL: ${npci_url}    console=True
    Wait For Elements State    text=Accept    visible    timeout=${LONG_TIMEOUT}
    Take Screenshot    fullPage=True
    Click    text=Accept
    Sleep    5s
    # Close the NPCI popup and switch back to the main checkout page.
    Close Page
    Sleep    2s
    ${url}=    Get Url
    Log    eNACH mandate accepted — back on ${url}    console=True
    Take Screenshot    fullPage=True

Complete Nach And Selfie Step
    [Arguments]    ${app_id}
    [Documentation]
    ...    Full post-down-payment flow:
    ...      1. eNACH: intro → bank verification (refresh-retry) → enach-checkout
    ...      2. Digio Debit Card mandate → NPCI Accept (mandate completed)
    ...      3. eNACH success lands on the selfie page — bypass selfie via DB insert
    ...         (customer_tracker slug 'selfie-completed'), then reload to advance.
    Complete Nach Bank Verification    ${app_id}
    Complete Enach Checkout    ${app_id}
    ${after_enach}=    Get Url
    Log    ✅ eNACH mandate completed — landed on ${after_enach} (expecting selfie)    console=True
    Bypass Selfie Via Database    ${app_id}
    Log    ✅ Selfie bypassed via DB (selfie-completed) for ${app_id}    console=True
    Reload
    Sleep    3s
    ${final_url}=    Get Url
    Log    ✅ After selfie bypass — on ${final_url}    console=True
    Take Screenshot    fullPage=True
    RETURN    ${final_url}

Explore Nach Flow
    [Arguments]    ${app_id}
    [Documentation]    Back-compat alias — delegates to Complete Nach And Selfie Step.
    ${url}=    Complete Nach And Selfie Step    ${app_id}
    RETURN    ${url}

Enter Final Steps If Present
    [Arguments]    ${app_id}
    [Documentation]
    ...    On the down-payment-status page, detects whether the eNACH and Selfie next-steps
    ...    are offered. Logs what is present. If the "Complete the final steps" button exists,
    ...    clicks it to enter the NACH/selfie flow, then logs the resulting URL.
    ...    Returns the URL after entering (or the status URL if no final-steps button).
    Down Payment Status Page Should Be Visible
    ${nach_present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DP_STATUS_NACH}    visible    timeout=5s
    ${selfie_present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DP_STATUS_SELFIE}    visible    timeout=2s
    ${final_btn_present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DP_STATUS_FINAL_BTN}    visible    timeout=5s
    Log    Final steps — eNACH present: ${nach_present} | Selfie present: ${selfie_present} | Button present: ${final_btn_present}    console=True
    IF    ${final_btn_present}
        Click    ${DP_STATUS_FINAL_BTN}
        Sleep    2s
        ${url}=    Get Url
        Log    Entered final steps — now at: ${url}    console=True
        RETURN    ${url}
    END
    ${url}=    Get Url
    Log    No "complete final steps" button present — staying at: ${url}    console=True
    RETURN    ${url}

Complete Down Payment Step
    [Arguments]    ${app_id}
    [Documentation]
    ...    Happy-path down payment for the E2E journey (online / Razorpay UPI test path).
    ...    Step 1 (plan summary) → proceed-to-pay → Step 5 (method) → select online payment →
    ...    pay → Razorpay UPI success@razorpay → /down-payment-status/{app_id}.
    # After eSign the app may land on /pkyc/ (physical KYC) — skip it by navigating directly.
    ${cur_url}=    Get Url
    IF    '/pkyc/' in '${cur_url}'
        Log    Landed on /pkyc/ — navigating directly to /down-payment/${app_id}    console=True
        Go To    ${BASE_URL}/down-payment/${app_id}
    END
    Down Payment Page Should Be Visible
    Wait For Elements State    ${DP_PROCEED_BTN}    visible    timeout=${LONG_TIMEOUT}
    Wait For Elements State    ${DP_PROCEED_BTN}    enabled    timeout=${LONG_TIMEOUT}
    Click    ${DP_PROCEED_BTN}
    # Step 5 — payment method selection
    Down Payment Step 5 Should Be Visible
    ${has_online}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${DP_ONLINE_PAYMENT}    visible    timeout=5s
    IF    ${has_online}    Click    ${DP_ONLINE_PAYMENT}
    Wait For Elements State    ${DP_PAY_BTN}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${DP_PAY_BTN}    enabled    timeout=${TIMEOUT}
    Click    ${DP_PAY_BTN}
    # Razorpay test-mode UPI payment
    Complete Razorpay Payment Via UPI For App    ${app_id}
    Down Payment Status Page Should Be Visible
    Log    ✅ Down payment complete — reached down-payment-status for ${app_id}    console=True
