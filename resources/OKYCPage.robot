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
