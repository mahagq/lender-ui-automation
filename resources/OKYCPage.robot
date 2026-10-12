*** Settings ***
Library    Browser


*** Variables ***
${OKYC_URL_FRAG}           /kyc/
${OKYC_EKYC_OPTION}        css=[data-testid='ekyc-option']
${OKYC_VIDEO_OPTION}       css=[data-testid='video-kyc-option']
${OKYC_PROCEED_BUTTON}     css=[data-testid='kyc-method-proceed']


*** Keywords ***
OKYC Page Should Be Visible
    [Documentation]    Asserts browser is on the OKYC page by URL. Expand when KYC flow is separately automated.
    OKYC URL Should Be Active

OKYC URL Should Be Active
    [Documentation]    Asserts current URL contains the OKYC URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${OKYC_URL_FRAG}

Extract App ID From OKYC URL
    [Documentation]    Extracts {app_id} from current URL /kyc/{app_id}.
    ${url}=    Get Url
    ${app_id}=    Evaluate    '${url}'.split('/kyc/')[-1].split('?')[0].split('#')[0].rstrip('/')
    RETURN    ${app_id}

Select E-KYC Method
    [Documentation]    Selects E-KYC option and clicks Proceed.
    ...                E-KYC is usually pre-selected — if option not found, goes straight to Proceed.
    ${found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OKYC_EKYC_OPTION}    visible    timeout=5s
    IF    ${found}    Click    ${OKYC_EKYC_OPTION}
    Click KYC Proceed Button

Select Video KYC Method
    [Documentation]    Selects Video KYC option and clicks Proceed.
    ${found}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OKYC_VIDEO_OPTION}    visible    timeout=5s
    IF    ${found}    Click    ${OKYC_VIDEO_OPTION}
    Click KYC Proceed Button

Click KYC Proceed Button
    [Documentation]
    ...    Scrolls to and clicks the Proceed button on the KYC method selection page.
    ...    data-testid='kyc-method-proceed'
    ...    Clicking can trigger the Digio SDK / a navigation, so we force the click and
    ...    do not wait for navigation to settle (noWaitAfter). If the Playwright click is
    ...    intercepted, we fall back to a direct DOM click via JavaScript.
    Wait For Elements State    ${OKYC_PROCEED_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Wait For Elements State    ${OKYC_PROCEED_BUTTON}    enabled    timeout=${LONG_TIMEOUT}
    Scroll To Element         ${OKYC_PROCEED_BUTTON}
    ${clicked}=    Run Keyword And Return Status
    ...    Click With Options    ${OKYC_PROCEED_BUTTON}    force=True    noWaitAfter=True
    IF    not ${clicked}
        Log    Playwright click did not land — using JS DOM click fallback    level=WARN
        Evaluate JavaScript    ${OKYC_PROCEED_BUTTON}    (el) => el.click()
    END
    Log    ✅ KYC Proceed button clicked    console=True

Esign URL Should Be Active
    [Documentation]    Asserts current URL contains /sign-agreement/{app_id} after KYC bypass + page reload.
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /sign-agreement/${app_id}
