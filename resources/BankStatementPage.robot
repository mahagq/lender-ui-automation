*** Settings ***
Library    Browser


*** Variables ***
# BankStatementSelectBank page (/upload-bank-statements/{app_code})
# PENDING TESTID: confirm exact heading text and testids from frontend
${BSS_PAGE_HEADING}             css=h1[data-testid="verify-your-income-title"]
${BSS_PAGE_SUBHEADING}          css=div[data-testid="business-info"]
${BSS_CHOOSE_BANK_TEXT}         css=label[data-testid="choose-your-bank"]
${BSS_POPULAR_BANKS_SECTION}    xpath=//div[text()="POPULAR BANKS"]
${BSS_BANK_SEARCH_INPUT}        xpath=//input[@role="combobox"]
${BSS_BANK_OPTION}              role=option >> nth=0
${BSS_PROCEED_BTN}              css=[data-testid='proceed-button']

# URL fragments
${BSS_URL_FRAG}             /upload-bank-statements/


*** Keywords ***
Bank Statement Select Bank Page Should Be Visible
    [Documentation]    Asserts the Bank Statement Select Bank page is visible by waiting for the page heading.
    Wait For Elements State    ${BSS_PAGE_HEADING}    visible    ${LONG_TIMEOUT}

Bank Statement Select Bank URL Should Be Active
    [Documentation]    Asserts current URL contains the bank statement select bank URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${BSS_URL_FRAG}

Search And Select Bank
    [Documentation]    Types bank name into React Select search, waits for option, selects via keyboard.
    [Arguments]    ${bank_name}
    Click    ${BSS_BANK_SEARCH_INPUT}
    Type Text    ${BSS_BANK_SEARCH_INPUT}    ${bank_name}
    Wait For Elements State    ${BSS_BANK_OPTION}    visible    ${LONG_TIMEOUT}
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Proceed To Bank Statement Upload
    [Documentation]    Clicks the proceed button and waits for navigation to the manual upload page.
    Wait For Elements State    ${BSS_PROCEED_BTN}    visible    ${TIMEOUT}
    Click    ${BSS_PROCEED_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Bank Statement Manual Upload URL Should Be Active

Bank Statement Status URL Should Be Active
    [Documentation]    Asserts current URL contains the bank statement status URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${BST_URL_FRAG}

Navigate To Bank Statement Select Bank Within Session
    [Documentation]    Navigates directly to the bank statement select bank page for the given application code.
    [Arguments]    ${app_code}
    Go To    ${BASE_URL}/upload-bank-statements/${app_code}
    Bank Statement Select Bank Page Should Be Visible

Navigate To Bank Statement Status Within Session
    [Documentation]    Navigates directly to the bank statement status page for the given application code.
    [Arguments]    ${app_code}
    Go To    ${BASE_URL}/verifying-bank-statements/${app_code}
    Bank Statement Status Page Should Be Visible
