*** Settings ***
Documentation
...    Test suite for Upload Documents page (/dms/{app_id}).
...    Entry: Dashboard EMI card three-dot menu.
...    Session model: Suite Setup logs in with DASHBOARD_MOBILE, navigates to
...    /dms/{app_id}, captures APP_ID. Test Setup hard-navigates per test.

Library      Browser
Resource     ../../resources/UploadDocumentsPage.robot
Resource     ../../resources/DashboardPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Navigate To Upload Documents Suite Setup
Suite Teardown   Close Browser
Test Setup       Navigate To Upload Documents Within Session    ${APP_ID}
Test Tags        application-details    upload-documents
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:Upload Documents

*** Variables ***
${APP_ID}    ${EMPTY}

*** Test Cases ***
TC-AD-UD-001 Navigate Via Three Dot Menu Using Testid Link
    [Documentation]    Three-dot menu → upload-documents testid → lands on /dms/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To Upload Documents Via Three Dot Menu
    Additional Documents Section Should Be Visible

TC-AD-UD-002 Navigate Via Three Dot Menu Using Text Link
    [Documentation]    Three-dot menu → "Upload documents" text → lands on /dms/{app_id}.
    [Setup]    Navigate To Dashboard
    Navigate To Upload Documents Via Text Link
    Additional Documents Section Should Be Visible

TC-AD-UD-003 Additional Documents Required Section Visible
    [Documentation]    additional-documents-required-title and fee disbursal text present on /dms/{app_id}.
    Additional Documents Section Should Be Visible

TC-AD-UD-004 Add Files Button Visible
    [Documentation]    ADD FILES button is visible and available for interaction.
    Additional Documents Section Should Be Visible
    Add Files Button Should Be Visible

TC-AD-UD-005 Back Button Returns To Dashboard
    [Documentation]    back-button on /dms/{app_id} navigates back to /my-applications.
    Click    ${UD_BACK_BTN}
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Get Url    contains    /my-applications

TC-AD-UD-006 Close Button Returns To Dashboard
    [Documentation]    close-button on /dms/{app_id} navigates back to /my-applications.
    Click    ${UD_CLOSE_BTN}
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Get Url    contains    /my-applications

*** Keywords ***
Navigate To Upload Documents Suite Setup
    [Documentation]    Login, reach dashboard, navigate to upload documents page, capture APP_ID.
    Login And Navigate To Dashboard As    ${APP_DETAILS_MOBILE}
    Click    ${UD_EMI_CARD_OPTION_BTN}
    Click    ${UD_TESTID_LINK}
    Wait For Elements State    ${UD_ADDITIONAL_DOCS_TITLE}    visible    timeout=${TIMEOUT}
    ${id}=    Extract App ID From DMS URL
    Set Suite Variable    ${APP_ID}    ${id}
