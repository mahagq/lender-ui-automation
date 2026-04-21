*** Settings ***
Documentation
...    Bypass Authentication test suite for the GQ Customer Portal.
...    Tests the /instant-eligibility page used for tokenised ERP access without OTP.
...
...    The page authenticates via bypassAuthPost using a mobile number in the ?m= query param.
...    On success → redirects to /my-applications or /student-details.
...    Without ?m= → redirects immediately to / (login page).
...    On bypassAuthPost failure → shows no-account error state with Sign In button.
...
...    TC-403 and TC-404 require a mobile number that fails bypassAuthPost (no ERP account).
...    These are tagged robot:skip pending identification of a suitable UAT test mobile.
...
...    Satisfies: TC-401 to TC-404

Library          Browser
Resource         ../resources/BypassAuthPage.robot
Resource         ../variables/variables.robot

Suite Setup      New Browser    ${BROWSER}    headless=${HEADLESS}
Suite Teardown   Close Browser
Test Teardown    Close Context
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Authentication    allure.label.story:Bypass Authentication

*** Test Cases ***

Bypass Auth With Valid Mobile Redirects Away From Instant Eligibility
    [Documentation]
    ...    Navigating to /instant-eligibility?m=<valid_mobile> should authenticate via
    ...    bypassAuthPost and redirect the user away from /instant-eligibility to either
    ...    /my-applications or /student-details depending on application state.
    ...    Satisfies: TC-401
    [Tags]    bypass-auth    smoke    redirect
    Navigate To Bypass Auth Page With Mobile    ${TEST_MOBILE}
    Bypass Auth Should Redirect Away From Instant Eligibility

Bypass Auth Without Query Param Redirects To Login Page
    [Documentation]
    ...    Navigating to /instant-eligibility without the ?m= query param should immediately
    ...    redirect to / (login page), where the login form is visible.
    ...    The redirect is triggered by the useEffect in BypassAuthentication.jsx when
    ...    queryParams.get('m') is null.
    ...    Satisfies: TC-402
    [Tags]    bypass-auth    redirect    negative
    Navigate To Bypass Auth Page Without Param
    Bypass Auth Without Param Should Show Login Form

Bypass Auth No Account Error State Is Visible
    [Documentation]
    ...    When bypassAuthPost fails (mobile has no ERP account), the no-account error state
    ...    should display the error image and message:
    ...    "Its Looks like you don't have an account with us."
    ...    Skipped — requires a UAT mobile that fails bypassAuthPost.
    ...    Satisfies: TC-403
    [Tags]    bypass-auth    negative    robot:skip
    Navigate To Bypass Auth Page With Mobile    ${TEST_MOBILE}
    No Account Error State Should Be Visible

Sign In Button On No Account State Navigates To Login
    [Documentation]
    ...    When the no-account error state is shown, clicking the Sign In button
    ...    should navigate to / (login page) with the login form visible.
    ...    Skipped — depends on bypassAuthPost failure state (TC-403 precondition).
    ...    Satisfies: TC-404
    [Tags]    bypass-auth    negative    navigation    robot:skip
    Navigate To Bypass Auth Page With Mobile    ${TEST_MOBILE}
    No Account Error State Should Be Visible
    Click Sign In Button On No Account State
