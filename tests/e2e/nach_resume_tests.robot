*** Settings ***
Documentation
...    Resume an EXISTING application that already reached the eNACH stage, so we can iterate on
...    the eNACH / Digio dialog without re-running the whole wizard (login → student → plan → BRE
...    → KYC → eSign → down payment) every time.
...
...    Provide the mobile + app id of an app already parked at eNACH:
...      robot --variable RESUME_MOBILE:9106059299 --variable RESUME_APP_ID:908036 \
...            --outputdir results/nach tests/e2e/nach_resume_tests.robot
...    (or set RESUME_MOBILE / RESUME_APP_ID env vars).

Library     Browser
Library     ../../libraries/kyc_bypass_db.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/DownPaymentPage.robot
Resource    ../../resources/EsignPage.robot
Resource    ../../resources/LoginPage.robot
Resource    ../../resources/OTPPage.robot
Resource    ../../variables/variables.robot

Test Tags   e2e    nach    resume


*** Variables ***
# Existing app already at eNACH — override on the CLI or via env vars.
${RESUME_MOBILE}        %{RESUME_MOBILE=9106059299}
${RESUME_APP_ID}        %{RESUME_APP_ID=908036}
# Additional details page fields
${FATHER_FIRST_NAME}    Kumaresan


*** Test Cases ***
Resume Existing App At eNACH
    [Documentation]
    ...    Logs in and resumes from wherever the app currently is. State-aware:
    ...      A. /additional-details  — fill father name + student ID → Start Fee Disbursal
    ...      B. /upload-address-proof — bypass via DB slugs (already inserted) → detect final state
    ...      C. /enach-checkout      — Digio mandate → selfie bypass → additional details
    ...      D. /selfie              — bypass selfie → additional details
    ...      E. /nach                — full flow: bank verification → enach-checkout → selfie → additional details
    Log    Resuming app ${RESUME_APP_ID} with mobile ${RESUME_MOBILE}    console=True
    Login And Create Application    ${RESUME_MOBILE}

    # Navigate to additional-details and see where we actually land (may redirect).
    Go To    ${BASE_URL}/additional-details/${RESUME_APP_ID}
    Sleep    3s
    ${landed_url}=    Get Url
    Log    Navigated to additional-details → landed on: ${landed_url}    console=True

    # A. Still on /additional-details/ — check if the fee disbursal button is present.
    ${is_additional}=    Evaluate    '/additional-details/' in '${landed_url}'
    IF    ${is_additional}
        ${at_additional}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=10s
        IF    ${at_additional}
            Log    State A: /additional-details — filling and submitting    console=True
            Complete Additional Details    ${RESUME_APP_ID}
        ELSE
            Log    State A: on /additional-details but no fee-disbursal button — page may be completed    console=True
            ${final}=    Get Url
            Log    ✅ Already completed — on ${final}    console=True
        END
    ELSE
        # B. Redirected to /upload-address-proof/.
        ${is_address_proof}=    Evaluate    '/upload-address-proof/' in '${landed_url}'
        IF    ${is_address_proof}
            Log    State B: /upload-address-proof — ensuring bypass slugs are in DB    console=True
            Bypass Selfie Via Database    ${RESUME_APP_ID}
            Sleep    2s
            Reload
            Sleep    3s
            ${final}=    Get Url
            Log    ✅ Address proof bypassed — now on ${final}    console=True
        ELSE
            # C0. On /esign/ — complete signing then down payment.
            Go To    ${BASE_URL}/esign/${RESUME_APP_ID}
            ${at_esign}=    Run Keyword And Return Status
            ...    Wait For Elements State    css=[data-testid='accept-terms-conditions-button']    visible    timeout=10s
            IF    ${at_esign}
                Log    State C0: /esign — completing eSign    console=True
                Complete Esign Step
                Complete Down Payment Step    ${RESUME_APP_ID}
                Bypass Selfie Via Database    ${RESUME_APP_ID}
                Go To    ${BASE_URL}/additional-details/${RESUME_APP_ID}
                Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=${LONG_TIMEOUT}
                Complete Additional Details    ${RESUME_APP_ID}
            ELSE
                # C. Not on post-eNACH pages — check /enach-checkout.
                Go To    ${BASE_URL}/enach-checkout/${RESUME_APP_ID}
            ${at_checkout}=    Run Keyword And Return Status
            ...    Wait For Elements State    css=[data-testid='e-mandate-proceed-button']    visible    timeout=15s
            IF    ${at_checkout}
                Log    State C: /enach-checkout — mandate form ready    console=True
                Complete Enach Checkout    ${RESUME_APP_ID}
                Bypass Selfie Via Database    ${RESUME_APP_ID}
                Go To    ${BASE_URL}/additional-details/${RESUME_APP_ID}
                Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=${LONG_TIMEOUT}
                Complete Additional Details    ${RESUME_APP_ID}
            ELSE
                # D. eNACH done but sitting on /selfie.
                Go To    ${BASE_URL}/selfie/${RESUME_APP_ID}
                ${at_selfie}=    Run Keyword And Return Status
                ...    Wait For Elements State    text=take your live selfie    visible    timeout=10s
                IF    ${at_selfie}
                    Log    State D: /selfie — bypassing selfie    console=True
                    Bypass Selfie Via Database    ${RESUME_APP_ID}
                    Go To    ${BASE_URL}/additional-details/${RESUME_APP_ID}
                    Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=${LONG_TIMEOUT}
                    Complete Additional Details    ${RESUME_APP_ID}
                ELSE
                    # E. Mandate not yet created — start from /nach intro.
                    Log    State E: starting from /nach intro    console=True
                    Go To    ${BASE_URL}/nach/${RESUME_APP_ID}
                    Wait For Elements State    css=[data-testid='nach-continue-to-setup-button']    visible    timeout=${LONG_TIMEOUT}
                    Complete Nach And Selfie Step    ${RESUME_APP_ID}
                    Go To    ${BASE_URL}/additional-details/${RESUME_APP_ID}
                    Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=${LONG_TIMEOUT}
                    Complete Additional Details    ${RESUME_APP_ID}
                END
            END
            END
        END
    END


*** Keywords ***
Complete Additional Details
    [Arguments]    ${app_id}
    [Documentation]
    ...    On /additional-details: fills father's first name + student ID, then clicks
    ...    START THE FEE DISBURSAL to complete the journey.
    Wait For Elements State    css=[data-testid='start-fee-disbursal-button']    visible    timeout=${LONG_TIMEOUT}
    # Father's first name (testid: middle-name — UAT field naming)
    ${father_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[data-testid='middle-name']    visible    timeout=5s
    IF    ${father_visible}
        Fill Text    css=[data-testid='middle-name']    ${FATHER_FIRST_NAME}
    END
    # Student ID — random 8-char alphanumeric
    ${rand}=    Evaluate    __import__('random').choices('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', k=8)
    ${student_id}=    Evaluate    ''.join(${rand})
    Fill Text    css=[data-testid='student-id-input']    ${student_id}
    Sleep    500ms
    Click    css=[data-testid='start-fee-disbursal-button']
    Sleep    3s
    ${final}=    Get Url
    Log    ✅ Fee disbursal started for app ${app_id} — on ${final}    console=True
