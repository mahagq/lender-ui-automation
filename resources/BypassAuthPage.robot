*** Settings ***
Documentation
...    Page object keywords for the Bypass Authentication page (/instant-eligibility).
...    Provides tokenised access via URL query params — no OTP required.
...
...    Key selectors (no data-testid on this page — uses text and alt selectors):
...      Loading text:        text=Continuing your application...
...      No-account image:    img[alt='No account found']
...      No-account message:  text=don't have an account with us
...      Sign In button:      text=Sign In
...      Login form:          data-testid='login-form' (reused from LoginPage.robot)
...
...    Flow:
...      With ?m=<mobile>  → bypassAuthPost authenticates → redirect to /applications
...                           or /student-details (based on application state).
...      Without ?m=       → useEffect detects missing param → navigateTo('/') immediately.
...      bypassAuthPost fails → showNoAccountMessage=true → no-account error state shown.
...
...    Satisfies: TC-401 to TC-404

Library     Browser
Resource    LoginPage.robot

*** Variables ***
${BYPASS_LOADING_TEXT}      text=Continuing your application...
${NO_ACCOUNT_IMAGE}         img[alt='No account found']
${NO_ACCOUNT_MESSAGE}       text=don't have an account with us
${SIGN_IN_BUTTON}           text=Sign In

*** Keywords ***
Navigate To Bypass Auth Page With Mobile
    [Documentation]
    ...    Opens a fresh browser context and navigates to /instant-eligibility?m=<mobile>.
    ...    With a valid mobile, the page authenticates via bypassAuthPost and redirects.
    ...    Satisfies: TC-401
    [Arguments]    ${mobile}
    New Context
    New Page    ${BASE_URL}/instant-eligibility?m=${mobile}

Navigate To Bypass Auth Page Without Param
    [Documentation]
    ...    Opens a fresh browser context and navigates to /instant-eligibility with no ?m=.
    ...    The page should immediately redirect to / (login) since mobile is absent.
    ...    Satisfies: TC-402
    New Context
    New Page    ${BASE_URL}/instant-eligibility

Bypass Auth Should Redirect Away From Instant Eligibility
    [Documentation]
    ...    After navigation, the URL should no longer contain /instant-eligibility.
    ...    Accepts redirect to /applications, /student-details, or / as valid outcomes.
    ...    Satisfies: TC-401
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    URL Should Not Be Instant Eligibility

URL Should Not Be Instant Eligibility
    [Documentation]    Helper — asserts URL does not contain instant-eligibility.
    ${url}=    Get Url
    Should Not Contain    ${url}    instant-eligibility

Bypass Auth Without Param Should Show Login Form
    [Documentation]
    ...    Without ?m=, the page redirects to / and the login form should be visible.
    ...    Satisfies: TC-402
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${LONG_TIMEOUT}
    ${url}=    Get Url
    Should Not Contain    ${url}    instant-eligibility

No Account Error State Should Be Visible
    [Documentation]
    ...    When bypassAuthPost fails, the no-account error state is shown.
    ...    Asserts the no-account image and message are visible.
    ...    Satisfies: TC-403
    Wait For Elements State    ${NO_ACCOUNT_IMAGE}    visible    timeout=${LONG_TIMEOUT}
    Wait For Elements State    ${NO_ACCOUNT_MESSAGE}    visible    timeout=${TIMEOUT}

Click Sign In Button On No Account State
    [Documentation]
    ...    Clicks the Sign In button on the no-account error state, which navigates to /.
    ...    Satisfies: TC-404
    Wait For Elements State    ${SIGN_IN_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SIGN_IN_BUTTON}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${LONG_TIMEOUT}
