*** Settings ***
Documentation
...    Page object keywords for the View Application Details page (/application-details/{app_id}).
...    All locators use data-testid CSS selectors or role-based selectors.
...    Library: Browser (Playwright).
...    Session model: shared session — Suite Setup navigates and captures APP_ID,
...    Test Setup hard-navigates to /application-details/${APP_ID}.

Library    Browser
Library    String

*** Variables ***
${VAD_TESTID_LINK}                css=[data-testid='view-application-details']
${VAD_TEXT_LINK}                  text=View application details
${VAD_APP_ID_TEXT}                text=Application ID:
${VAD_STATUS_TEXT}                text=Status:
${VAD_EMI_PLAN_TAB}               role=button[name='EMI plan details']
${VAD_STUDENT_DETAILS}            text=Student Details
${VAD_WHO_IS_APPLYING}            text=Who is Applying?
${VAD_GENERAL_DETAILS}            text=Your General Details
${VAD_RESIDENTIAL_DETAILS}        text=Your Residential Details
${VAD_EMPLOYMENT_DETAILS}         text=Your Employment Details
${VAD_REFERRAL_CODE}              text=Referral Code
${VAD_DISBURSEMENT_TAB}           role=button[name='Disbursement details']
${VAD_BACK_BTN}                   css=[data-testid='back-button']
${VAD_CLOSE_BTN}                  css=[data-testid='close-button']
${VAD_EMI_CARD_OPTION_BTN}        css=[data-testid='emi-card-option-button']

*** Keywords ***
Navigate To View Application Details Via Three Dot Menu
    [Documentation]    Click EMI card three-dot → click view-application-details testid → wait for App ID text.
    Click    ${VAD_EMI_CARD_OPTION_BTN}
    Click    ${VAD_TESTID_LINK}
    Wait For Elements State    ${VAD_APP_ID_TEXT}    visible    timeout=${TIMEOUT}

Navigate To View Application Details Via Text Link
    [Documentation]    Click EMI card three-dot → click "View application details" text → wait for App ID text.
    Click    ${VAD_EMI_CARD_OPTION_BTN}
    Click    ${VAD_TEXT_LINK}
    Wait For Elements State    ${VAD_APP_ID_TEXT}    visible    timeout=${TIMEOUT}

Navigate To View Application Details Within Session
    [Documentation]    Hard-navigate to /application-details/${APP_ID} — no re-login.
    [Arguments]    ${app_id}
    Go To    ${BASE_URL}/application-details/${app_id}
    Wait For Elements State    ${VAD_APP_ID_TEXT}    visible    timeout=${TIMEOUT}

Application Header Should Be Visible
    [Documentation]    Assert Application ID and Status labels are present on the page.
    Wait For Elements State    ${VAD_APP_ID_TEXT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_STATUS_TEXT}    visible    timeout=${TIMEOUT}

Open EMI Plan Details Tab
    [Documentation]    Click EMI plan details tab and assert Student Details section appears.
    Click    ${VAD_EMI_PLAN_TAB}
    Wait For Elements State    ${VAD_STUDENT_DETAILS}    visible    timeout=${TIMEOUT}

EMI Plan Details Sections Should Be Visible
    [Documentation]    Assert all sub-sections within EMI plan details tab are visible.
    Wait For Elements State    ${VAD_STUDENT_DETAILS}        visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_WHO_IS_APPLYING}        visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_GENERAL_DETAILS}        visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_RESIDENTIAL_DETAILS}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_EMPLOYMENT_DETAILS}     visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VAD_REFERRAL_CODE}          visible    timeout=${TIMEOUT}

Open Disbursement Details Tab
    [Documentation]    Click Disbursement details tab.
    Click    ${VAD_DISBURSEMENT_TAB}
    Wait For Elements State    ${VAD_DISBURSEMENT_TAB}    visible    timeout=${TIMEOUT}

Extract App ID From Application Details URL
    [Documentation]    Return the app_id segment from current URL (/application-details/{app_id}).
    ${url}=    Get Url
    ${parts}=    Split String    ${url}    /application-details/
    ${app_id}=    Strip String    ${parts}[1]    characters=/
    RETURN    ${app_id}
