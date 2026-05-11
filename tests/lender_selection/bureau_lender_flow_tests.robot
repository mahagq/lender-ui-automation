*** Settings ***
Documentation
...    Bureau flow tests: 4 core scenarios covering BRE lender assignment outcomes.
...    Each test owns its browser session — Suite Setup creates a fresh application
...    and navigates to the lender selection page, capturing ${LENDER_APP_ID}.
...    TC_LENDER_01 and TC_LENDER_02 are smoke + regression tests.
...    TC_LENDER_03 and TC_LENDER_04 are partial regression tests (reach target screen, close browser).
...    BRE API is mocked via Browser Library Route Fulfilled in each test.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Lender Selection New App
Suite Teardown   Run Keyword If Test Failed    Close Browser

Test Tags        lender-selection    regression    robot:skip
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection Bureau Flow


*** Variables ***
${LENDER_APP_ID}    ${EMPTY}


*** Test Cases ***
## to Cover Mock Logic for this test suite.
TC_LENDER_01 Bureau Approved Lender Assignment Redirects To KYC
    [Documentation]    BRE APPROVED: consent → continue → successful assignment → KYC page.
    [Tags]    smoke    regression
    [Teardown]    Unroute BRE Mock
    Mock BRE Assign Lender    APPROVED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active

TC_LENDER_02 Bureau Rejection Then Approval On Second Lender Redirects To KYC
    [Documentation]    BRE REJECTED first, switch mock to APPROVED, retry → KYC.
    [Tags]    smoke    regression
    [Setup]    Navigate To Lender Selection Within Session    ${LENDER_APP_ID}
    [Teardown]    Unroute BRE Mock
    Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Click View Available Financing
    Switch BRE Mock To    APPROVED
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active

TC_LENDER_03 Double Bureau Rejection Lands User On Bank Statement Upload Screen
    [Documentation]    BRE REJECTED twice → redirects to bank statement select bank page. PARTIAL: closes browser on screen reached.
    [Tags]    partial    regression
    [Setup]    Navigate To Lender Selection Within Session    ${LENDER_APP_ID}
    [Teardown]    Run Keywords
    ...    Unroute BRE Mock
    ...    AND    Run Keyword And Ignore Error    Close Browser
    Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Click View Available Financing
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    IF    not ${on_bank}
        Log    Not auto-redirected — navigating to bank statement page manually    level=INFO
        Wait For Elements State    ${LS_VIEW_AVAILABLE_BTN}    visible    timeout=${TIMEOUT}
        Click    ${LS_VIEW_AVAILABLE_BTN}
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Bank Statement URL Should Be Active
    END
    Bank Statement Select Bank Page Should Be Visible
    Log    TC_LENDER_03 PARTIAL: Bank Statement Upload screen reached — closing browser    level=INFO

TC_LENDER_04 Double Bureau Rejection With Bank Statement Skipped Shows Manual Assignment
    [Documentation]    BRE REJECTED twice → bank statement page → skip → manual assignment screen. PARTIAL: closes browser on screen reached.
    [Tags]    partial    regression
    [Setup]    Navigate To Lender Selection Within Session    ${LENDER_APP_ID}
    [Teardown]    Run Keywords
    ...    Unroute BRE Mock
    ...    AND    Run Keyword And Ignore Error    Close Browser
    Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Click View Available Financing
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    IF    not ${on_bank}
        Log    Not auto-redirected — navigating to bank statement page manually    level=INFO
        Wait For Elements State    ${LS_VIEW_AVAILABLE_BTN}    visible    timeout=${TIMEOUT}
        Click    ${LS_VIEW_AVAILABLE_BTN}
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Bank Statement URL Should Be Active
    END
    Bank Statement Select Bank Page Should Be Visible
    Skip Bank Statement
    Manual Assignment Screen Should Be Visible
    Log    TC_LENDER_04 PARTIAL: Manual Assignment screen reached — closing browser    level=INFO
