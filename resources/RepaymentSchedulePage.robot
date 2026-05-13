*** Settings ***
Documentation
...    Page object keywords for the Repayment Schedule page (/repayment/{app_id}).
...    All locators use data-testid CSS selectors or role-based selectors.
...    Library: Browser (Playwright).
...    Session model: shared session — Suite Setup navigates and captures APP_ID,
...    Test Setup hard-navigates to /repayment/${APP_ID}.

Library    Browser
Library    String

*** Variables ***
${RS_HEADING}                     role=heading[name='See your active EMI repayment schedule here']
${RS_COL_DUE_ON}                  role=columnheader[name='DUE ON']
${RS_COL_EMI_AMOUNT}              role=columnheader[name='EMI AMOUNT']
${RS_COL_CHARGES}                 role=columnheader[name='CHARGES/FEES']
${RS_COL_PAID_AMOUNT}             role=columnheader[name='PAID AMOUNT']
${RS_COL_PAYMENT_STATUS}          role=columnheader[name='PAYMENT STATUS']
${RS_TOTAL_CELL}                  role=cell[name='Total']
${RS_PAY_NOW_BTN}                 css=[data-testid='pay-now-button']
${RS_SOA_LINK}                    text=Get your statement of account
${RS_SOA_CANCEL_BTN}              role=button[name='Cancel']
${RS_SOA_SEND_BTN}                role=button[name='Send']
${RS_ACTIVE_EMI_TEXT}             text=See your active EMI repayment
${RS_EMI_CARD_OPTION_BTN}         css=[data-testid='emi-card-option-button']
${RS_EMI_CARD_ACTION_BTN}         css=[data-testid='emi-card-action-button']
${RS_BACK_BTN}                    css=[data-testid='back-button']
${RS_CLOSE_BTN}                   css=[data-testid='close-button']
${RS_REPAYMENT_SCHEDULE_OPTION}   text=Repayment Schedule

*** Keywords ***
Navigate To Repayment Schedule Via Three Dot Menu
    [Documentation]    Click EMI card three-dot menu → click "Repayment Schedule" → wait for page heading.
    Click    ${RS_EMI_CARD_OPTION_BTN}
    Click    ${RS_REPAYMENT_SCHEDULE_OPTION}
    Wait For Elements State    ${RS_HEADING}    visible    timeout=${TIMEOUT}

Navigate To Repayment Schedule Via Action Button
    [Documentation]    Click EMI card action button → click "See your active EMI repayment" → wait for page heading.
    Click    ${RS_EMI_CARD_ACTION_BTN}
    Click    ${RS_ACTIVE_EMI_TEXT}
    Wait For Elements State    ${RS_HEADING}    visible    timeout=${TIMEOUT}

Navigate To Repayment Schedule Within Session
    [Documentation]    Hard-navigate to /repayment/${APP_ID} — no re-login.
    [Arguments]    ${app_id}
    Go To    ${BASE_URL}/repayment/${app_id}
    Wait For Elements State    ${RS_HEADING}    visible    timeout=${TIMEOUT}

Repayment Table Should Be Visible
    [Documentation]    Assert all 5 column headers and Total row cell are present.
    Wait For Elements State    ${RS_COL_DUE_ON}          visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_COL_EMI_AMOUNT}      visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_COL_CHARGES}         visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_COL_PAID_AMOUNT}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_COL_PAYMENT_STATUS}  visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_TOTAL_CELL}          visible    timeout=${TIMEOUT}

Open Statement Of Account
    [Documentation]    Click Statement of Account link and wait for Cancel/Send buttons to appear.
    Click    ${RS_SOA_LINK}
    Wait For Elements State    ${RS_SOA_CANCEL_BTN}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_SOA_SEND_BTN}      visible    timeout=${TIMEOUT}

Repayment Schedule Heading Should Be Visible
    [Documentation]    Assert EMI Repayment Schedule heading is visible on the page.
    Wait For Elements State    ${RS_HEADING}    visible    timeout=${TIMEOUT}

Extract App ID From Repayment URL
    [Documentation]    Return the app_id segment from current URL (/repayment/{app_id}).
    ${url}=    Get Url
    ${parts}=    Split String    ${url}    /repayment/
    ${app_id}=    Strip String    ${parts}[1]    characters=/
    RETURN    ${app_id}
