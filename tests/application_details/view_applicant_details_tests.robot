*** Settings ***
Documentation
...    Test suite for View Application Details page (/application-details/{app_id}).
...    Entry: Dashboard EMI card three-dot menu.
...    Session model: Suite Setup logs in with DASHBOARD_MOBILE, navigates to
...    /application-details/{app_id}, captures APP_ID. Test Setup hard-navigates per test.

Library      Browser
Resource     ../../resources/ViewApplicantDetailsPage.robot
Resource     ../../resources/DashboardPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Navigate To View Application Details Suite Setup
Suite Teardown   Close Browser
Test Setup       Navigate To View Application Details Within Session    ${APP_ID}
Test Tags        application-details    view-applicant-details
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:View Application Details

*** Variables ***
${APP_ID}    ${EMPTY}

*** Test Cases ***
TC-AD-VA-001 Navigate Via Three Dot Menu Using Testid Link
    [Documentation]    Three-dot menu → view-application-details testid → lands on /application-details/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To View Application Details Via Three Dot Menu
    Application Header Should Be Visible

TC-AD-VA-002 Navigate Via Three Dot Menu Using Text Link
    [Documentation]    Three-dot menu → "View application details" text → lands on /application-details/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To View Application Details Via Text Link
    Application Header Should Be Visible

TC-AD-VA-003 Application ID And Status Are Visible
    [Documentation]    "Application ID:" and "Status:" labels present on /application-details/{app_id}.
    Application Header Should Be Visible

TC-AD-VA-004 EMI Plan Details Tab Opens Student Details Section
    [Documentation]    Clicking "EMI plan details" tab reveals all sub-sections.
    Open EMI Plan Details Tab
    EMI Plan Details Sections Should Be Visible

TC-AD-VA-005 EMI Plan Details Sub Sections All Visible
    [Documentation]    Student Details, Who is Applying?, General, Residential, Employment, Referral Code all present.
    Open EMI Plan Details Tab
    EMI Plan Details Sections Should Be Visible

TC-AD-VA-006 Disbursement Details Tab Expands Section
    [Documentation]    Clicking "Disbursement details" tab reveals disbursement section.
    Open Disbursement Details Tab

TC-AD-VA-007 Close Button Returns To Dashboard
    [Documentation]    close-button on /application-details/{app_id} navigates back to /my-applications.
    Click    ${VAD_CLOSE_BTN}
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Get Url    contains    /my-applications

TC-AD-VA-008 Back Button Returns To Dashboard
    [Documentation]    browser back from /application-details/{app_id} navigates back to /my-applications.
    [Setup]    Navigate To Dashboard
    Navigate To View Application Details Via Text Link
    Application Header Should Be Visible
    Click      ${VAD_BACK_BTN}
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Get Url    contains    /my-applications

*** Keywords ***
Navigate To View Application Details Suite Setup
    [Documentation]    Login, reach dashboard, navigate to application details page, capture APP_ID.
    Login And Navigate To Dashboard As    ${APP_DETAILS_MOBILE}
    Click    ${VAD_EMI_CARD_OPTION_BTN}
    Click    ${VAD_TESTID_LINK}
    Wait For Elements State    ${VAD_APP_ID_TEXT}    visible    timeout=${TIMEOUT}
    ${id}=    Extract App ID From Application Details URL
    Set Suite Variable    ${APP_ID}    ${id}
