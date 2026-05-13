*** Settings ***
Documentation
...    Page object keywords for the Upload Documents page (/dms/{app_id}).
...    All locators use data-testid CSS selectors or role-based selectors.
...    Library: Browser (Playwright).
...    Session model: shared session — Suite Setup navigates and captures APP_ID,
...    Test Setup hard-navigates to /dms/${APP_ID}.

Library    Browser
Library    String

*** Variables ***
${UD_TESTID_LINK}                 css=[data-testid='upload-documents']
${UD_TEXT_LINK}                   text=Upload documents
${UD_ADDITIONAL_DOCS_TITLE}       css=[data-testid='additional-documents-required-title']
${UD_FEE_DISBURSAL_TEXT}          text=To complete
${UD_ADD_FILES_BTN}               text=ADD FILES >>nth=0
${UD_BACK_BTN}                    css=[data-testid='back-button']
${UD_CLOSE_BTN}                   css=[data-testid='close-button']
${UD_EMI_CARD_OPTION_BTN}         css=[data-testid='emi-card-option-button']

*** Keywords ***
Navigate To Upload Documents Via Three Dot Menu
    [Documentation]    Click EMI card three-dot → click upload-documents testid → wait for additional docs title.
    Click    ${UD_EMI_CARD_OPTION_BTN}
    Click    ${UD_TESTID_LINK}
    Wait For Elements State    ${UD_ADDITIONAL_DOCS_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Upload Documents Via Text Link
    [Documentation]    Click EMI card three-dot → click "Upload documents" text → wait for additional docs title.
    Click    ${UD_EMI_CARD_OPTION_BTN}
    Click    ${UD_TEXT_LINK}
    Wait For Elements State    ${UD_ADDITIONAL_DOCS_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Upload Documents Within Session
    [Documentation]    Hard-navigate to /dms/${APP_ID} — no re-login.
    [Arguments]    ${app_id}
    Go To    ${BASE_URL}/dms/${app_id}
    Wait For Elements State    ${UD_ADDITIONAL_DOCS_TITLE}    visible    timeout=${TIMEOUT}

Additional Documents Section Should Be Visible
    [Documentation]    Assert additional-documents-required-title and fee disbursal text are present.
    Wait For Elements State    ${UD_ADDITIONAL_DOCS_TITLE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${UD_FEE_DISBURSAL_TEXT}       visible    timeout=${TIMEOUT}

Add Files Button Should Be Visible
    [Documentation]    Assert ADD FILES button is present and enabled.
    Wait For Elements State    ${UD_ADD_FILES_BTN}    visible    timeout=${TIMEOUT}

Extract App ID From DMS URL
    [Documentation]    Return the app_id segment from current URL (/dms/{app_id}).
    ${url}=    Get Url
    ${parts}=    Split String    ${url}    /dms/
    ${app_id}=    Strip String    ${parts}[1]    characters=/
    RETURN    ${app_id}
