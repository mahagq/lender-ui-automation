*** Settings ***
Documentation
...    Bank Statement journey tests.
...    Suite Setup creates fresh app (plan 2), selects lender, lands on /bank-statement/{app_code}.
...    BS_APP_CODE is captured from the redirect URL and reused across all tests.
...    All tests are tagged robot:skip until BankStatementPage.robot locators are confirmed from frontend.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../resources/BankStatementPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Bank Statement Via Plan Two
Suite Teardown   Close Browser
Test Setup       Navigate To Bank Statement Select Bank Within Session    ${BS_APP_CODE}
Test Tags        lender-selection    bank-statement    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Bank Statement Upload
...    allure.label.story:Bank Statement


*** Variables ***
${BS_APP_CODE}    ${EMPTY}


*** Test Cases ***
TC-BS-01 Bank Statement Select Bank Page Is Visible After Bureau Rejection
    [Documentation]    Asserts bank statement page is visible after BRE rejection redirect. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible

TC-BS-02 Bank Statement Page Heading Is Visible
    [Documentation]    Asserts bank statement page heading is visible. PENDING TESTID. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_PAGE_HEADING}    visible    timeout=${TIMEOUT}

TC-BS-03 Bank Statement Page Subheading Is Visible
    [Documentation]    Asserts bank statement page subheading is visible. PENDING TESTID. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_PAGE_SUBHEADING}    visible    timeout=${TIMEOUT}

TC-BS-04 Bank Statement Choose Your Bank Option Is Visible
    [Documentation]    Asserts the "Choose your bank" text/option is visible. PENDING TESTID. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_CHOOSE_BANK_TEXT}    visible    timeout=${TIMEOUT}

TC-BS-05 Bank Statement POPULAR BANKS Section Is Visible
    [Documentation]    Asserts the "POPULAR BANKS" section is visible. PENDING TESTID. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_POPULAR_BANKS_SECTION}    visible    timeout=${TIMEOUT}

TC-BS-06 Bank Search Input Is Visible And Accessible
    [Documentation]    Asserts bank search input is visible. PENDING TESTID. Skipped until locators confirmed.
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_BANK_SEARCH_INPUT}    visible    timeout=${TIMEOUT}

TC-BS-07 Selecting A Bank Enables Option for Banking
    [Documentation]    Searches for a bank and selects it. PENDING TESTID. Skipped until locators confirmed.
    #[Tags]    robot:skip
    Search And Select Bank    HDFC Bank


TC-BS-08 Selecting A Bank Enables Option for Banking
    [Documentation]    Searches for a bank and selects it. PENDING TESTID. Skipped until locators confirmed.
    [Tags]    robot:skip
    Search And Select Bank    HDFC Bank
    Wait For Elements State    ${BSS_PROCEED_BTN}    visible    timeout=${TIMEOUT}
