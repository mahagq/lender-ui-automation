*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Agreement/Esign page (/esign/{app_id}).
...    All locators derived from Playwright recording (login_20260513_194822.js).
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup   → Navigate To Esign New App (E2EApplicationFlow.robot)
...      Test Setup    → Go To ${BASE_URL}/esign/${ESIGN_APP_ID}
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser

Library    Browser
Library    String


*** Variables ***
${ESIGN_URL_FRAG}               /esign/
${DOWN_PAYMENT_URL_FRAG}        /down-payment/
${NACH_URL_FRAG}                /nach/

# Page headers
${ESIGN_SUMMARY_TITLE}          css=[data-testid='agreement-summary-title']
${ESIGN_AGREEMENT_TITLE}        css=[data-testid='agreement-title']

# Loan summary fields
${ESIGN_CUSTOMER_NAME}          css=[data-testid='customer-name']
${ESIGN_INSTITUTE_NAME}         css=[data-testid='institute_name']
${ESIGN_STUDENT_NAME}           css=[data-testid='student_name']
${ESIGN_TOTAL_FEE_AMOUNT}       css=[data-testid='total-fee-amount']
${ESIGN_EMI_AMOUNT}             css=[data-testid='emi-amount']
${ESIGN_TENURE}                 css=[data-testid='tenure']
${ESIGN_PAYABLE_TODAY_DP}       css=[data-testid='payable-today'] >> nth=0
${ESIGN_PAYABLE_TODAY_PF}       css=[data-testid='payable-today'] >> nth=1
${ESIGN_PAYABLE_TODAY_PLT}      css=[data-testid='payable-today'] >> nth=2
${ESIGN_MANDATE_CHARGES}        css=[data-testid='mandate-repayment-charges']
${ESIGN_DEBITED_DATE}           css=[data-testid='debited-date']

# Lender details
${ESIGN_LENDER_NAME}            css=[data-testid='lender-name']
${ESIGN_APR_VALUE}              css=[data-testid='apr-value']

# Grievance redressal sections
${ESIGN_LENDER_GRIEVANCE}           css=[data-testid='lender-grievance-redressal-office-details']
${ESIGN_LENDER_GRIEVANCE_NAME}      css=[data-testid='lender-grievance-redressal-office-details'] [data-testid='name-value']
${ESIGN_LENDER_GRIEVANCE_EMAIL}     css=[data-testid='lender-grievance-redressal-office-details'] [data-testid='email-value']
${ESIGN_LENDER_GRIEVANCE_MOBILE}    css=[data-testid='lender-grievance-redressal-office-details'] [data-testid='mobile-number-value']
${ESIGN_GQ_GRIEVANCE}               css=[data-testid='grayquest-grievance-redressal-office-details']

# Consent
${ESIGN_CONSENT_CHECKBOX}       css=[data-testid='consent-checkbox']
${ESIGN_CONSENT_LABEL}          css=[data-testid='consent-checkbox-label']
${ESIGN_CONSENT_ERROR}          css=[data-testid='consent-checkbox-error']

# Action buttons
${ESIGN_VIEW_AGREEMENT_BTN}     css=[data-testid='view-agreement-button']
${ESIGN_ACCEPT_TERMS_BTN}       css=[data-testid='accept-terms-conditions-button']
${ESIGN_CLOSE_BTN}              css=[data-testid='close-button']
${ESIGN_PREVIEW_PROCEED_BTN}    css=[data-testid='agreement-preview-proceed-button']
${ESIGN_BACK_BTN}               css=[data-testid='back-button']


*** Keywords ***
Esign Page Should Be Visible
    Wait For Elements State    ${ESIGN_SUMMARY_TITLE}    visible    timeout=${LONG_TIMEOUT}

Esign URL Should Contain App ID
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /esign/${app_id}

Extract App ID From Esign URL
    ${url}=    Get Url
    ${app_id}=    Evaluate    '${url}'.split('/esign/')[-1].split('?')[0].rstrip('/')
    RETURN    ${app_id}

Down Payment URL Should Be Active
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /down-payment/${app_id}

Nach URL Should Be Active
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /nach/${app_id}

Signing Initiated Successfully
    ${url}=    Get Url
    Should Not Contain    ${url}    /esign/

Redirect URL Should Be Down Payment Or NACH
    ${url}=    Get Url
    ${is_dp}=    Evaluate    '/down-payment/' in '${url}'
    ${is_nach}=    Evaluate    '/nach/' in '${url}'
    Should Be True    ${is_dp} or ${is_nach}    Expected /down-payment/ or /nach/ in URL but got: ${url}

Agreement Summary Title Should Be Visible
    Wait For Elements State    ${ESIGN_SUMMARY_TITLE}    visible    timeout=${TIMEOUT}

Agreement Inner Title Should Be Visible
    Wait For Elements State    ${ESIGN_AGREEMENT_TITLE}    visible    timeout=${TIMEOUT}

Esign Applicant Name Field Should Be Visible
    Wait For Elements State    ${ESIGN_CUSTOMER_NAME}    visible    timeout=${TIMEOUT}

Institute Name Field Should Be Visible
    Wait For Elements State    ${ESIGN_INSTITUTE_NAME}    visible    timeout=${TIMEOUT}

Student Name Field Should Be Visible
    Wait For Elements State    ${ESIGN_STUDENT_NAME}    visible    timeout=${TIMEOUT}

Total Fee Amount Field Should Be Visible
    Wait For Elements State    ${ESIGN_TOTAL_FEE_AMOUNT}    visible    timeout=${TIMEOUT}

EMI Amount Field Should Be Visible
    Wait For Elements State    ${ESIGN_EMI_AMOUNT}    visible    timeout=${TIMEOUT}

Tenure Field Should Be Visible
    Wait For Elements State    ${ESIGN_TENURE}    visible    timeout=${TIMEOUT}

Payable Today Downpayment Field Should Be Visible
    Wait For Elements State    ${ESIGN_PAYABLE_TODAY_DP}    visible    timeout=${TIMEOUT}

Processing Fee Field Should Be Visible
    Wait For Elements State    ${ESIGN_PAYABLE_TODAY_PF}    visible    timeout=${TIMEOUT}

Platform Fee Field Should Be Visible
    Wait For Elements State    ${ESIGN_PAYABLE_TODAY_PLT}    visible    timeout=${TIMEOUT}

Mandate Charge Field Should Be Visible
    Wait For Elements State    ${ESIGN_MANDATE_CHARGES}    visible    timeout=${TIMEOUT}

EMI Debit Date Field Should Be Visible
    Wait For Elements State    ${ESIGN_DEBITED_DATE}    visible    timeout=${TIMEOUT}

Lender Name Field Should Be Visible
    Wait For Elements State    ${ESIGN_LENDER_NAME}    visible    timeout=${TIMEOUT}

APR Field Should Be Visible
    Wait For Elements State    ${ESIGN_APR_VALUE}    visible    timeout=${TIMEOUT}

Lender Grievance Redressal Section Should Be Visible
    Wait For Elements State    ${ESIGN_LENDER_GRIEVANCE}    visible    timeout=${TIMEOUT}

Lender Grievance Name Value Should Be Visible
    Wait For Elements State    ${ESIGN_LENDER_GRIEVANCE_NAME}    visible    timeout=${TIMEOUT}

Lender Grievance Email Value Should Be Visible
    Wait For Elements State    ${ESIGN_LENDER_GRIEVANCE_EMAIL}    visible    timeout=${TIMEOUT}

Lender Grievance Mobile Number Value Should Be Visible
    Wait For Elements State    ${ESIGN_LENDER_GRIEVANCE_MOBILE}    visible    timeout=${TIMEOUT}

GrayQuest Grievance Redressal Section Should Be Visible
    Wait For Elements State    ${ESIGN_GQ_GRIEVANCE}    visible    timeout=${TIMEOUT}

Consent Checkbox Should Be Unchecked
    ${checked}=    Get Property    ${ESIGN_CONSENT_CHECKBOX}    checked
    Should Be True    not ${checked}

Consent Label Click Should Check Checkbox
    Click    ${ESIGN_CONSENT_LABEL}
    ${checked}=    Get Property    ${ESIGN_CONSENT_CHECKBOX}    checked
    Should Be True    ${checked}

Check Esign Consent
    ${checked}=    Get Property    ${ESIGN_CONSENT_CHECKBOX}    checked
    IF    not ${checked}
        Click    ${ESIGN_CONSENT_CHECKBOX}
    END

Uncheck Esign Consent
    ${checked}=    Get Property    ${ESIGN_CONSENT_CHECKBOX}    checked
    IF    ${checked}
        Click    ${ESIGN_CONSENT_CHECKBOX}
    END

Submit Without Consent Shows Error
    Uncheck Esign Consent
    Click    ${ESIGN_ACCEPT_TERMS_BTN}
    Wait For Elements State    ${ESIGN_CONSENT_ERROR}    visible    timeout=${TIMEOUT}

Click View Agreement Button
    Wait For Elements State    ${ESIGN_VIEW_AGREEMENT_BTN}    visible    timeout=${TIMEOUT}
    Click    ${ESIGN_VIEW_AGREEMENT_BTN}

Agreement Modal Should Be Visible
    Wait For Elements State    role=dialog    visible    timeout=${TIMEOUT}

Close Agreement Modal
    Click    role=button[name='Close']
    Wait For Elements State    role=dialog    hidden    timeout=${TIMEOUT}

Language Selector Should Be Visible In Modal
    Wait For Elements State    text=Select Language    visible    timeout=${TIMEOUT}

Select MARATHI Language In Modal
    Click    text=Select Language
    Wait For Elements State    role=option[name='MARATHI']    visible    timeout=${TIMEOUT}
    Click    role=option[name='MARATHI']

Click Agreement Preview Proceed Button
    Wait For Elements State    ${ESIGN_PREVIEW_PROCEED_BTN}    visible    timeout=${TIMEOUT}
    Click    ${ESIGN_PREVIEW_PROCEED_BTN}
    Wait For Elements State    role=dialog    hidden    timeout=${TIMEOUT}

Click Esign Back Button
    Wait For Elements State    ${ESIGN_BACK_BTN}    visible    timeout=${TIMEOUT}
    Click    ${ESIGN_BACK_BTN}

Click Esign Close Button
    Wait For Elements State    ${ESIGN_CLOSE_BTN}    visible    timeout=${TIMEOUT}
    Click    ${ESIGN_CLOSE_BTN}

Accept Terms And Sign Agreement
    Check Esign Consent
    Click    ${ESIGN_ACCEPT_TERMS_BTN}
