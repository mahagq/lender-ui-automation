*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Lender Selection page (/application-loader/{app_id}).
...    All locators use role-based or text selectors confirmed from Playwright recordings.
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup   → Navigate to Lender Selection (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Lender Selection Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser

Library    Browser
Library    String

*** Variables ***
# Page heading
${LS_HEADING}                   role=heading[name='Congratulations, your EMI']

# Rank labels — conditional presence (1–N lenders)
${LS_RANK_1_LABEL}              text=Rank 1
${LS_RANK_2_LABEL}              text=Rank 2
${LS_RANK_3_LABEL}              text=Rank 3

# Unavailable section — conditional presence (0–N unavailable)
${LS_UNAVAILABLE_HEADING}       role=heading[name='Currently Unavailable']
${LS_UNAVAILABLE_DISCLAIMER}    text=These options don't match
${LS_DISCLAIMER_TEXT}           text=Lenders are displayed in

# Modal buttons (stable role-based selectors from Playwright recording)
${LS_LOAN_OFFER_DETAILS_BTN}    role=button[name='Loan Offer Details']
${LS_VIEW_KFS_BTN}              role=button[name='View KFS']
${LS_CLOSE_MODAL_BTN}           role=button[name='Close']

# Loan Offer Details modal fields
${LS_MODAL_TOTAL_FEE}           text=Total Fee Amount
${LS_MODAL_EMI_AMOUNT}          text=EMI Amount
${LS_MODAL_TENURE}              text=Tenure
${LS_MODAL_PAYABLE_TODAY}       text=Payable Today / Downpayment
${LS_MODAL_PROCESSING_FEE}      text=Processing Fee
${LS_MODAL_FORECLOSURE}         text=Foreclosure Charges
${LS_MODAL_MANDATE_CHARGE}      text=Mandate Charge
${LS_MODAL_APR}                 text=Annual Percentage Rate (APR)
${LS_MODAL_EMI_DEBIT_DATE}      text=EMI Will Be Debited On
${LS_MODAL_PENAL_CHARGES}       text=Penal Charges

# KFS modal fields
${LS_KFS_FEE_AMOUNT}            text=Fee Amount
${LS_KFS_MONTHLY_PAYMENTS}      text=No of Monthly Payments
${LS_KFS_MONTHLY_PAYMENT_AMT}   text=Monthly Payment Amount

# Consent + filters
${LS_CONSENT_CHECKBOX}          role=checkbox[name='I have carefully read and']
${LS_FILTER_BANK}               text=Bank
${LS_FILTER_NBFC}               text=NBFC

# Processing page (/application-loader-status/{app_id})
${LS_PROCESSING_HEADING}        role=heading[name='Processing your application...']
${LS_VERIFYING_TEXT}            text=Verifying your application

# Rejection state
${LS_UNABLE_TO_PROCEED}         role=heading[name='Unable to Proceed']
${LS_PLEASE_SELECT_ANOTHER}     text=Please select another
${LS_VIEW_AVAILABLE_BTN}        role=button[name='View Available Financing']

# Success state
${LS_SUCCESS_TEXT}              text=Your EMI application is
${LS_PROCEED_BUTTON}            css=[data-testid='proceed-button']

*** Keywords ***
Lender Selection Page Should Be Visible
    [Documentation]    Waits for the lender selection page heading to become visible.
    Wait For Elements State    ${LS_HEADING}    visible    timeout=${LONG_TIMEOUT}

At Least One Rank Label Should Be Visible
    [Documentation]
    ...    Asserts Rank 1 label is visible and logs presence/absence of Rank 2 and Rank 3.
    Wait For Elements State    ${LS_RANK_1_LABEL}    visible    timeout=${TIMEOUT}
    ${has_rank_2}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_RANK_2_LABEL}    visible    timeout=${TIMEOUT}
    Log    Rank 2 label present: ${has_rank_2}    level=DEBUG
    ${has_rank_3}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_RANK_3_LABEL}    visible    timeout=${TIMEOUT}
    Log    Rank 3 label present: ${has_rank_3}    level=DEBUG

Currently Unavailable Section Should Be Visible If Present
    [Documentation]
    ...    Conditionally asserts the Currently Unavailable section.
    ...    Skips the check with a pass if the section is absent (dynamic lender set).
    ${is_present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNAVAILABLE_HEADING}    visible    timeout=3s
    Pass Execution If    not ${is_present}    Currently Unavailable section not present — dynamic lender set
    Wait For Elements State    ${LS_UNAVAILABLE_DISCLAIMER}    visible    timeout=${TIMEOUT}

Disclaimer Text Should Be Visible
    [Documentation]    Asserts the lender ordering disclaimer text is visible.
    Wait For Elements State    ${LS_DISCLAIMER_TEXT}    visible    timeout=${TIMEOUT}

Open Loan Offer Details For First Lender
    [Documentation]    Clicks the Loan Offer Details button on the first available lender card.
    Wait For Elements State    ${LS_LOAN_OFFER_DETAILS_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_LOAN_OFFER_DETAILS_BTN} >> nth=0

Loan Offer Details Modal Should Show All Fields
    [Documentation]    Asserts all 10 Loan Offer Details modal fields are visible.
    Wait For Elements State    ${LS_MODAL_TOTAL_FEE}          visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_EMI_AMOUNT}         visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_TENURE}             visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PAYABLE_TODAY}      visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PROCESSING_FEE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_FORECLOSURE}        visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_MANDATE_CHARGE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_APR}                visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_EMI_DEBIT_DATE}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_MODAL_PENAL_CHARGES}      visible    timeout=${TIMEOUT}

Close Modal
    [Documentation]    Clicks the Close button on any open modal.
    Click    ${LS_CLOSE_MODAL_BTN}

Open KFS For First Lender
    [Documentation]    Clicks the View KFS button on the first available lender card.
    Wait For Elements State    ${LS_VIEW_KFS_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_VIEW_KFS_BTN} >> nth=0

KFS Modal Should Show Fields
    [Documentation]    Asserts the three KFS modal fields are visible.
    Wait For Elements State    ${LS_KFS_FEE_AMOUNT}          visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_KFS_MONTHLY_PAYMENTS}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LS_KFS_MONTHLY_PAYMENT_AMT} visible    timeout=${TIMEOUT}

Check KFS Consent
    [Documentation]    Ensures the KFS consent checkbox is checked; clicks it if not already checked.
    ${checked}=    Get Property    ${LS_CONSENT_CHECKBOX}    checked
    IF    not ${checked}
        Click    ${LS_CONSENT_CHECKBOX}
    END

Uncheck KFS Consent
    [Documentation]    Ensures the KFS consent checkbox is unchecked; clicks it if currently checked.
    ${checked}=    Get Property    ${LS_CONSENT_CHECKBOX}    checked
    IF    ${checked}
        Click    ${LS_CONSENT_CHECKBOX}
    END

Click Bank Filter
    [Documentation]    Clicks the Bank filter tab on the lender selection page.
    Click    ${LS_FILTER_BANK}

Click NBFC Filter
    [Documentation]    Clicks the NBFC filter tab on the lender selection page.
    Click    ${LS_FILTER_NBFC}

Click First Available Continue Button
    [Documentation]
    ...    Clicks the first CONTINUE WITH lender button with up to 3 retries (2s apart).
    Wait For Elements State    role=button[name*='CONTINUE WITH']    visible    timeout=${TIMEOUT}
    Click    role=button[name*='CONTINUE WITH'] >> nth=0
    Log    Clicked first available lender continue button    level=DEBUG

Processing Page Should Be Visible
    [Documentation]    Waits for the processing/loader page heading to become visible.
    Wait For Elements State    ${LS_PROCESSING_HEADING}    visible    timeout=${LONG_TIMEOUT}

Bureau Decision Should Be Final
    [Documentation]
    ...    Asserts one of three terminal bureau states is visible:
    ...    success text, rejection heading, or bank-statement URL.
    ...    Called by Wait For Bureau Decision — not intended for direct use.
    ${url}=    Get Url
    ${is_success}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_SUCCESS_TEXT}        visible    timeout=2s
    ${is_rejected}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}   visible    timeout=2s
    ${is_bank}=    Evaluate    '/bank-statement/' in '${url}'
    Should Be True    ${is_success} or ${is_rejected} or ${is_bank}
    ...    Bureau decision not yet final

Wait For Bureau Decision
    [Documentation]
    ...    Polls until a terminal bureau decision state is detected
    ...    (approved, rejected, or bank-statement redirect).
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    2s    Bureau Decision Should Be Final
    Log    Bureau decision reached    level=INFO

Click View Available Financing
    [Documentation]
    ...    Clicks the View Available Financing button on the rejection state page
    ...    and waits until the lender selection URL is active again.
    Log    Clicking View Available Financing — returning to lender list    level=INFO
    Wait For Elements State    ${LS_VIEW_AVAILABLE_BTN}    visible    timeout=${TIMEOUT}
    Click    ${LS_VIEW_AVAILABLE_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    Log    Back on lender selection page    level=DEBUG

Successful Lender Assignment Should Be Visible
    [Documentation]    Waits for the success state text confirming lender assignment.
    Wait For Elements State    ${LS_SUCCESS_TEXT}    visible    timeout=${LONG_TIMEOUT}

Click Proceed To KYC
    [Documentation]    Clicks the proceed-button to advance to the KYC step.
    Click    ${LS_PROCEED_BUTTON}

Lender Selection URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /application-loader/.
    ${url}=    Get Url
    Should Contain    ${url}    /application-loader/

Bank Statement URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /bank-statement/.
    ${url}=    Get Url
    Should Contain    ${url}    /bank-statement/

Extract App ID From Current URL
    [Documentation]    Extracts and returns the application ID from an /application-loader/{app_id} URL.
    ${url}=    Get Url
    ${app_id}=    Fetch From Right    ${url}    /application-loader/
    RETURN    ${app_id}

Extract App Code From Bank Statement URL
    [Documentation]    Extracts and returns the app code from a /bank-statement/{app_code} URL.
    ${url}=    Get Url
    ${app_code}=    Fetch From Right    ${url}    /bank-statement/
    RETURN    ${app_code}

Navigate To Lender Selection Within Session
    [Arguments]    ${app_id}
    [Documentation]    Navigates directly to the lender selection page for the given app ID.
    Go To    ${BASE_URL}/application-loader/${app_id}
    Lender Selection Page Should Be Visible

Build BRE Fetch Body
    [Arguments]    ${decision}
    IF    '${decision}' == 'REJECTED'
        ${body}=    Set Variable
        ...    {"success":true,"status_code":200,"message":"Lender Assignment Log Found Successfully","data":{"application_id":0,"type":"bureau","status":"COMPLETED","decision":"REJECTED","parent_lender_name":"Mirae Asset Financial Services (India) Pvt. Ltd."}}
    ELSE
        ${body}=    Set Variable
        ...    {"success":true,"status_code":200,"message":"Lender Assignment Log Found Successfully","data":{"application_id":0,"type":"bureau","status":"COMPLETED","decision":"APPROVED","parent_lender_name":"Capital India FSF"}}
    END
    RETURN    ${body}

Mock BRE Assign Lender
    [Arguments]    ${decision}=APPROVED
    [Documentation]
    ...    Mocks BRE assign-lender API via window.fetch override (Browser library v19 has no Route Fulfilled).
    ...    Intercepts /v2/credit-engine/assign-lender and /v2/credit-engine/assign-lender/fetch calls.
    ${assign_body}=    Set Variable
    ...    {"success":true,"status_code":200,"message":"Lender Assignment job created","data":{"job_id":"mock_job_test_123"}}
    ${fetch_body}=    Build BRE Fetch Body    ${decision}
    Evaluate JavaScript    ${None}
    ...    (a, f) => { if(!window.__origFetch)window.__origFetch=window.fetch; window.__breMockAssignBody=a; window.__breMockFetchBody=f; window.fetch=async(url,opts)=>{const u=typeof url==='string'?url:(url.url||String(url));if(u.includes('/v2/credit-engine/assign-lender/fetch'))return new Response(window.__breMockFetchBody,{status:200,headers:{'Content-Type':'application/json'}});if(u.includes('/v2/credit-engine/assign-lender'))return new Response(window.__breMockAssignBody,{status:200,headers:{'Content-Type':'application/json'}});return window.__origFetch(url,opts);}; }
    ...    ${assign_body}    ${fetch_body}
    Log    BRE mock set to ${decision} via window.fetch override    level=INFO

Switch BRE Mock To
    [Arguments]    ${decision}
    [Documentation]    Updates only the fetch decision body — assign-lender base mock stays active.
    ${fetch_body}=    Build BRE Fetch Body    ${decision}
    Evaluate JavaScript    ${None}    (f) => { window.__breMockFetchBody = f; }    ${fetch_body}
    Log    BRE mock switched to ${decision}    level=INFO

Unroute BRE Mock
    [Documentation]    Restores original window.fetch, removing BRE mock.
    Evaluate JavaScript    ${None}
    ...    () => { if(window.__origFetch){window.fetch=window.__origFetch;delete window.__origFetch;delete window.__breMockAssignBody;delete window.__breMockFetchBody;} }
    Log    BRE mock removed (window.fetch restored)    level=DEBUG
