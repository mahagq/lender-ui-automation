*** Settings ***
Library    Browser


*** Variables ***
${OKYC_URL_FRAG}    /okyc/


*** Keywords ***
OKYC Page Should Be Visible
    [Documentation]    Asserts browser is on the OKYC page by URL. Expand when KYC flow is separately automated.
    OKYC URL Should Be Active

OKYC URL Should Be Active
    [Documentation]    Asserts current URL contains the OKYC URL fragment.
    ${url}=    Get Url
    Should Contain    ${url}    ${OKYC_URL_FRAG}

Extract App ID From OKYC URL
    [Documentation]    Extracts {app_id} from current URL /okyc/{app_id}.
    ${url}=    Get Url
    ${app_id}=    Evaluate    '${url}'.split('/okyc/')[-1].split('?')[0].rstrip('/')
    RETURN    ${app_id}

Esign URL Should Be Active
    [Documentation]    Asserts current URL contains /esign/{app_id} after KYC bypass + page reload.
    [Arguments]    ${app_id}
    ${url}=    Get Url
    Should Contain    ${url}    /esign/${app_id}
