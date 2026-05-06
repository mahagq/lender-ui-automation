*** Settings ***
Library    Browser


*** Variables ***
# BankStatementSelectBank page (/bank-statement/{app_code})
# PENDING TESTID: confirm exact heading text and testids from frontend
${BSS_PAGE_HEADING}         role=heading[name='Bank Statement']
${BSS_BANK_SEARCH_INPUT}    css=[data-testid='bank-search-input']
${BSS_BANK_OPTION}          css=[data-testid='bank-option']
${BSS_PROCEED_BTN}          css=[data-testid='proceed-button']

# BankStatementManualUpload page (/bank-statement-manual-upload/{app_code})
# PENDING TESTID: confirm exact heading text and testids from frontend
${BSM_PAGE_HEADING}         role=heading[name='Upload Bank Statement']
${BSM_FILE_INPUT}           css=[data-testid='file-upload-input']
${BSM_UPLOAD_BTN}           css=[data-testid='upload-button']
${BSM_SUBMIT_BTN}           css=[data-testid='submit-button']

# BankStatementStatus page (/bank-statement-status/{app_code})
# PENDING TESTID: confirm exact heading text and testids from frontend
${BST_PAGE_HEADING}         role=heading[name='Bank Statement Status']
${BST_PENDING_TEXT}         text=Your bank statement is being processed

# URL fragments
${BSS_URL_FRAG}             /bank-statement/
${BSM_URL_FRAG}             /bank-statement-manual-upload/
${BST_URL_FRAG}             /bank-statement-status/

# Skip / Manual Assignment — TODO: confirm URL and heading from frontend team
${BS_SKIP_BTN}              css=[data-testid='skip-button']


*** Keywords ***
Bank Statement Select Bank Page Should Be Visible
    [Documentation]    Asserts the Bank Statement Select Bank page is visible by waiting for the page heading.
    Wait For Elements State    ${BSS_PAGE_HEADING}    visible    ${LONG_TIMEOUT}

Bank Statement Select Bank URL Should Be Active
    [Documentation]    Asserts current URL contains the bank statement select bank URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${BSS_URL_FRAG}

Search And Select Bank
    [Documentation]    Searches for a bank by name and selects the first matching option.
    [Arguments]    ${bank_name}
    Wait For Elements State    ${BSS_BANK_SEARCH_INPUT}    visible    ${TIMEOUT}    # PENDING TESTID
    Fill Text    ${BSS_BANK_SEARCH_INPUT}    ${bank_name}
    Wait For Elements State    ${BSS_BANK_OPTION}    visible    ${TIMEOUT}    # PENDING TESTID
    Click    ${BSS_BANK_OPTION}

Proceed To Bank Statement Upload
    [Documentation]    Clicks the proceed button and waits for navigation to the manual upload page.
    Wait For Elements State    ${BSS_PROCEED_BTN}    visible    ${TIMEOUT}
    Click    ${BSS_PROCEED_BTN}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Bank Statement Manual Upload URL Should Be Active

Bank Statement Manual Upload Page Should Be Visible
    [Documentation]    Asserts the Bank Statement Manual Upload page is visible by waiting for the page heading.
    Wait For Elements State    ${BSM_PAGE_HEADING}    visible    ${LONG_TIMEOUT}

Bank Statement Manual Upload URL Should Be Active
    [Documentation]    Asserts current URL contains the bank statement manual upload URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${BSM_URL_FRAG}

Upload Bank Statement File
    [Documentation]    Uploads a bank statement file using the file input element.
    [Arguments]    ${file_path}
    Wait For Elements State    ${BSM_FILE_INPUT}    visible    ${TIMEOUT}    # PENDING TESTID
    Upload File By Selector    ${BSM_FILE_INPUT}    ${file_path}

Submit Bank Statement
    [Documentation]    Clicks the submit button to submit the uploaded bank statement.
    Wait For Elements State    ${BSM_SUBMIT_BTN}    visible    ${TIMEOUT}    # PENDING TESTID
    Click    ${BSM_SUBMIT_BTN}

Bank Statement Status Page Should Be Visible
    [Documentation]    Asserts the Bank Statement Status page is visible by waiting for the page heading.
    Wait For Elements State    ${BST_PAGE_HEADING}    visible    ${LONG_TIMEOUT}

Bank Statement Status URL Should Be Active
    [Documentation]    Asserts current URL contains the bank statement status URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${BST_URL_FRAG}

Bank Statement Status Should Show Pending
    [Documentation]    Asserts the bank statement status page shows the pending processing message.
    Wait For Elements State    ${BST_PENDING_TEXT}    visible    ${TIMEOUT}    # PENDING TESTID

Navigate To Bank Statement Select Bank Within Session
    [Documentation]    Navigates directly to the bank statement select bank page for the given application code.
    [Arguments]    ${app_code}
    Go To    ${BASE_URL}/bank-statement/${app_code}
    Bank Statement Select Bank Page Should Be Visible

Navigate To Bank Statement Manual Upload Within Session
    [Documentation]    Navigates directly to the bank statement manual upload page for the given application code.
    [Arguments]    ${app_code}
    Go To    ${BASE_URL}/bank-statement-manual-upload/${app_code}
    Bank Statement Manual Upload Page Should Be Visible

Navigate To Bank Statement Status Within Session
    [Documentation]    Navigates directly to the bank statement status page for the given application code.
    [Arguments]    ${app_code}
    Go To    ${BASE_URL}/bank-statement-status/${app_code}
    Bank Statement Status Page Should Be Visible

Skip Bank Statement
    [Documentation]    Clicks the skip button on the bank statement page and logs the outcome.
    Wait For Elements State    ${BS_SKIP_BTN}    visible    ${TIMEOUT}    # PENDING TESTID — confirm skip button testid
    Click    ${BS_SKIP_BTN}
    Log    Clicked skip on bank statement page — checking for manual assignment redirect    level=INFO

Manual Assignment Screen Should Be Visible
    [Documentation]    Logs the current URL of the manual assignment screen without asserting a specific URL, as the page is unconfirmed.
    # TODO: confirm URL fragment and heading from frontend team
    ${url}=    Get Url
    Log    Manual assignment screen URL: ${url}    level=INFO
