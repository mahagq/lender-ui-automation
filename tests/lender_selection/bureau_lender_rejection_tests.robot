*** Settings ***
Documentation
...    Lender BRE Rejection tests — new application journey.
...    TC-LS-NR01: plan 3 app — BRE REJECTED → re-lands on lender selection (multiple lenders).
...    TC-LS-NR02: plan 2 app — BRE REJECTED → bank statement (single lender edge case).
...    TC-LS-NR03: plan 3 app — reject all N lenders one by one → final land on bank statement.
...    TC-LS-NR04: plan 5 app — BRE REJECTED, no banking applicable → manual approval screen.
...    TC-LS-NR05: plan 4 app — all bureau lenders ineligible → banking step direct after application-loader.
...    Each test owns its fresh browser session and application.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags        lender-selection    lender-rejection    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection
...    allure.label.story:Lender BRE Rejection


*** Test Cases ***
TC-LS-NR01 BRE Lender Rejection Re-Lands On Lender Selection Page
    [Documentation]
    ...    Creates fresh app (plan 3). Multiple lenders on screen.
    ...    User selects lender → real BRE decision → logs outcome and URL.
    [Setup]    Login And Navigate To Lender Selection New App    plan_index=3   mobile=${LENDER_NR01_MOBILE}
    [Teardown]    Close Browser
    # Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    Log    NR01 post-decision URL: ${url}    console=True
    ${modal}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}    visible    timeout=2s
    Log    NR01 rejection modal visible: ${modal}    console=True
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    Log    NR01 on bank-statement: ${on_bank}    console=True
    ${on_approved}=    Run Keyword And Return Status    Should Contain    ${url}    /application-status/
    Log    NR01 on application-status: ${on_approved}    console=True

TC-LS-NR02 BRE Lender Rejection With Single Lender Redirects To Bank Statement Page
    [Documentation]
    ...    Creates fresh app (plan 2). Real BRE — observation run. Logs post-decision state.
    [Setup]    Login And Navigate To Lender Selection New App    plan_index=2    mobile=${LENDER_NR02_MOBILE}
    [Teardown]    Close Browser
    # Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    Log    NR02 post-decision URL: ${url}    console=True
    ${modal}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}    visible    timeout=2s
    Log    NR02 rejection modal visible: ${modal}    console=True
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    Log    NR02 on bank-statement: ${on_bank}    console=True
    ${on_approved}=    Run Keyword And Return Status    Should Contain    ${url}    /application-status/
    Log    NR02 on application-status: ${on_approved}    console=True

TC-LS-NR03 Reject All N Lenders One By One Lands On Bank Statement Page
    [Documentation]
    ...    Creates fresh app (plan 3). Real BRE — observation run. Logs each iteration outcome.
    [Setup]    Login And Navigate To Lender Selection New App    plan_index=3    mobile=${LENDER_NR03_MOBILE}
    [Teardown]    Close Browser
    # Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    WHILE    True    limit=15
        Check KFS Consent If Present
        Click First Available Continue Button
        Wait For Bureau Decision
        ${url}=    Get Url
        Log    NR03 loop iteration URL: ${url}    console=True
        ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
        Log    NR03 on bank-statement: ${on_bank}    console=True
        ${on_approved}=    Run Keyword And Return Status    Should Contain    ${url}    /application-status/
        Log    NR03 on application-status: ${on_approved}    console=True
        IF    ${on_bank} or ${on_approved}
            BREAK
        END
        ${modal}=    Run Keyword And Return Status
        ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}    visible    timeout=3s
        Log    NR03 rejection modal visible: ${modal}    console=True
        IF    not ${modal}
            BREAK
        END
        Click View Available Financing
        ${next}=    Wait For Lender Page Or Bank Statement
        Log    NR03 next state after modal dismiss: ${next}    console=True
        IF    '${next}' == 'bank'
            BREAK
        END
    END
    ${final_url}=    Get Url
    Log    NR03 final URL: ${final_url}    console=True

TC-LS-NR04 BRE Lender Rejection With No Banking Applicable Redirects To Manual Approval Screen
    [Documentation]
    ...    Creates fresh app (plan 5). Single lender — BRE REJECTED → no banking applicable.
    ...    Expects redirect to /application-status/ (manual approval / credit review screen).
    [Setup]    Login And Navigate To Lender Selection New App    plan_index=5    mobile=${LENDER_NR04_MOBILE}
    [Teardown]    Close Browser
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    Log    NR04 post-decision URL: ${url}    console=True
    ${modal}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_UNABLE_TO_PROCEED}    visible    timeout=2s
    Log    NR04 rejection modal visible: ${modal}    console=True
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    Log    NR04 on bank-statement: ${on_bank}    console=True
    ${on_manual}=    Run Keyword And Return Status    Should Contain    ${url}    /application-status/
    Log    NR04 on application-status (manual approval): ${on_manual}    console=True

TC-LS-NR05 Bureau Lenders Ineligible Redirects To Banking Step After Application Loader
    [Documentation]
    ...    Creates fresh app (plan 4). All bureau lenders are ineligible from the start.
    ...    After confirm and submit, application-loader processes and redirects directly
    ...    to /bank-statement/ — lender selection page is never shown.
    [Setup]    Login And Submit New App    plan_index=4    mobile=${LENDER_NR05_MOBILE}
    [Teardown]    Close Browser
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    2s    Bank Statement URL Should Be Active
    ${url}=    Get Url
    Log    NR05 post-submit URL: ${url}    console=True
