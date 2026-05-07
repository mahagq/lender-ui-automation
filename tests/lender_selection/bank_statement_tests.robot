*** Settings ***
Documentation
...    Bank Statement journey tests.
...    Suite Setup triggers BRE rejection on a fresh application to land on /bank-statement/{app_code}.
...    BS_APP_CODE is captured from the redirect URL and reused across all tests.
...    All tests are tagged robot:skip until BankStatementPage.robot locators are confirmed from frontend.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../resources/BankStatementPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Bank Statement Via BRE Rejection
Suite Teardown   Close Browser
Test Setup       Navigate To Bank Statement Select Bank Within Session    ${BS_APP_CODE}
Test Tags        lender-selection    bank-statement    regression    robot:skip
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Bank Statement Upload
...    allure.label.story:Bank Statement


*** Variables ***
${BS_APP_CODE}    ${EMPTY}


*** Test Cases ***
TC-BS-01 Bank Statement Select Bank Page Is Visible After BRE Rejection
    [Documentation]    Asserts bank statement page is visible after BRE rejection redirect. Skipped until locators confirmed.
    [Tags]    robot:skip
    Bank Statement Select Bank Page Should Be Visible

TC-BS-02 Bank Search Input Is Visible And Accessible
    [Documentation]    Asserts bank search input is visible. PENDING TESTID. Skipped until locators confirmed.
    [Tags]    robot:skip
    Bank Statement Select Bank Page Should Be Visible
    Wait For Elements State    ${BSS_BANK_SEARCH_INPUT}    visible    timeout=${TIMEOUT}

TC-BS-03 Selecting A Bank Enables Proceed Button
    [Documentation]    Searches for a bank and selects it. PENDING TESTID. Skipped until locators confirmed.
    [Tags]    robot:skip
    Search And Select Bank    HDFC Bank
    Wait For Elements State    ${BSS_PROCEED_BTN}    visible    timeout=${TIMEOUT}

TC-BS-04 Proceeding From Select Bank Navigates To Manual Upload Page
    [Documentation]    Selects a bank and proceeds. Asserts manual upload page reached. PENDING TESTID.
    [Tags]    robot:skip
    Search And Select Bank    HDFC Bank
    Proceed To Bank Statement Upload
    Bank Statement Manual Upload Page Should Be Visible

TC-BS-05 Bank Statement Manual Upload Page Is Accessible
    [Documentation]    Navigates directly to manual upload page. PENDING TESTID.
    [Tags]    robot:skip
    [Setup]    Navigate To Bank Statement Manual Upload Within Session    ${BS_APP_CODE}
    Bank Statement Manual Upload Page Should Be Visible

TC-BS-06 Bank Statement Status Page Is Visible After Submission
    [Documentation]    Sequential after TC-BS-05: submits bank statement, asserts status page reached. PENDING TESTID.
    [Tags]    robot:skip
    [Setup]    NONE
    Bank Statement Manual Upload Page Should Be Visible
    Submit Bank Statement
    Bank Statement Status URL Should Be Active
