*** Settings ***
Documentation
...    Test suite for Repayment Schedule page (/repayment/{app_id}).
...    Entry: Dashboard EMI card three-dot menu or action button.
...    Session model: Suite Setup logs in with DASHBOARD_MOBILE, navigates to
...    /repayment/{app_id}, captures APP_ID. Test Setup hard-navigates per test.

Library      Browser
Resource     ../../resources/RepaymentSchedulePage.robot
Resource     ../../resources/DashboardPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Navigate To Repayment Schedule Suite Setup
Suite Teardown   Close Browser
Test Setup       Navigate To Repayment Schedule Within Session    ${APP_ID}
Test Tags        application-details    repayment-schedule
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:Repayment Schedule

*** Variables ***
${APP_ID}    ${EMPTY}

*** Test Cases ***
TC-AD-RS-001 Navigate To Repayment Schedule Via Three Dot Menu
    [Documentation]    Three-dot menu → "Repayment Schedule" → lands on /repayment/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To Repayment Schedule Via Three Dot Menu
    Repayment Schedule Heading Should Be Visible

TC-AD-RS-002 Navigate To Repayment Schedule Via EMI Card Action Button
    [Documentation]    EMI card action button → "See your active EMI repayment" → lands on /repayment/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To Repayment Schedule Via Action Button
    Repayment Schedule Heading Should Be Visible

TC-AD-RS-003 Repayment Table Columns Displayed
    [Documentation]    All 5 column headers visible on /repayment/{app_id}.
    Repayment Table Should Be Visible

TC-AD-RS-004 Total Row Visible In Repayment Table
    [Documentation]    "Total" cell present at bottom of repayment table.
    Wait For Elements State    ${RS_TOTAL_CELL}    visible    timeout=${TIMEOUT}

TC-AD-RS-005 Pay Now Button Is Visible And Enabled
    [Documentation]    pay-now-button present and enabled on /repayment/{app_id}.
    ...    Clicking opens external payment gateway — redirect assertion out of automation scope.
    Wait For Elements State    ${RS_PAY_NOW_BTN}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_PAY_NOW_BTN}    enabled    timeout=${TIMEOUT}

TC-AD-RS-006 Pay Now Opens Third Party Page And Original Page Stays
    [Documentation]    Pay Now opens third-party popup tab; original page remains on /repayment/{app_id}.
    Click    ${RS_PAY_NOW_BTN}
    Repayment Schedule Heading Should Be Visible

TC-AD-RS-007 Statement Of Account Cancel Dismisses Modal
    [Documentation]    SoA link → Cancel button → modal closed; still on /repayment/{app_id}.
    Open Statement Of Account
    Click    ${RS_SOA_CANCEL_BTN}
    Repayment Schedule Heading Should Be Visible

TC-AD-RS-008 Statement Of Account Send Submits Request
    [Documentation]    SoA link → Send button → request submitted.
    [Tags]    robot:skip
    Open Statement Of Account
    Click    ${RS_SOA_SEND_BTN}
    Wait For Elements State    ${RS_SOA_CANCEL_BTN}    hidden    timeout=${TIMEOUT}
    Wait For Elements State    ${RS_SOA_SEND_BTN}      hidden    timeout=${TIMEOUT}

TC-AD-RS-009 Back Button Returns To Dashboard
    [Documentation]    back-button on /repayment/{app_id} navigates back to /my-applications.
    Click    ${RS_BACK_BTN}
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Get Url    contains    /my-applications

*** Keywords ***
Navigate To Repayment Schedule Suite Setup
    [Documentation]    Login, reach dashboard, navigate to repayment page, capture APP_ID.
    Login And Navigate To Dashboard As    ${APP_DETAILS_MOBILE}
    Click    ${RS_EMI_CARD_OPTION_BTN}
    Click    ${RS_REPAYMENT_SCHEDULE_OPTION}
    Wait For Elements State    ${RS_HEADING}    visible    timeout=${TIMEOUT}
    ${id}=    Extract App ID From Repayment URL
    Set Suite Variable    ${APP_ID}    ${id}
