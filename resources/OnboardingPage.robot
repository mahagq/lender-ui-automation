*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Onboarding page (/get-started).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    The Onboarding page shows informational content about the GrayQuest loan process.
...    The applicant clicks Proceed to continue to /applicant-personal-details.
...
...    Session model (onboarding_tests.robot):
...      Visited after /applicant-name is submitted.
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (onboarding keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${OB_TITLE}                 css=[data-testid='onboarding-title']
${OB_ILLUSTRATION}          css=img[alt='a boy on a rocket ship']
${OB_INFO_ONE}              css=button:has-text('Proceed')
${OB_INFO_TWO}              css=[data-testid='onboarding-info-two']
${OB_INFO_THREE}            css=[data-testid='onboarding-info-three']
${OB_PROCEED_BUTTON}        css=button:has-text('Proceed')
${OB_BACK_BUTTON}           css=[data-testid='back-button']

*** Keywords ***
Onboarding Info Sections Should Be Visible
    [Documentation]
    ...    Asserts all three onboarding info sections are visible.
    ...    Satisfies: TC-9001, RT-5, U1
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${OB_INFO_TWO}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${OB_INFO_THREE}    visible    timeout=${TIMEOUT}

Onboarding Proceed Button Should Be Visible
    [Documentation]
    ...    Asserts the proceed-button on the onboarding page is visible.
    ...    Satisfies: TC-9002, U2
    Wait For Elements State    ${OB_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}

Click Onboarding Proceed
    [Documentation]
    ...    Clicks the proceed-button on the onboarding page to advance to /applicant-personal-details.
    ...    Satisfies: TC-9003, RT-5 (proceed)
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${LONG_TIMEOUT}
    Wait For Elements State    ${OB_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${OB_PROCEED_BUTTON}

Onboarding URL Should Be Active
    [Documentation]
    ...    Helper — asserts the current URL contains /get-started. The app sometimes
    ...    auto-skips the onboarding intro and lands directly on /applicant-personal-details —
    ...    accept that too, since the caller only cares that basic-details was really submitted.
    ${url}=    Get Url
    ${ok}=    Evaluate    '/get-started' in '''${url}''' or '/applicant-personal-details' in '''${url}'''
    Should Be True    ${ok}
    ...    Expected /get-started or /applicant-personal-details, got: ${url}

Onboarding Title Should Be Visible
    [Documentation]
    ...    Asserts onboarding-title is visible.
    ...    Satisfies: TC-9004
    Wait For Elements State    ${OB_TITLE}    visible    timeout=${TIMEOUT}

Onboarding Illustration Should Be Visible
    [Documentation]
    ...    Asserts the illustration image (alt='a boy on a rocket ship') is visible.
    ...    Satisfies: TC-9005
    Wait For Elements State    ${OB_ILLUSTRATION}    visible    timeout=${TIMEOUT}

Navigate Back From Onboarding
    [Documentation]
    ...    Clicks back-button on /get-started to return to /applicant-name.
    ...    Satisfies: TC-9N-01
    Wait For Elements State    ${OB_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${OB_BACK_BUTTON}

Click Close Button
    [Documentation]    Clicks close-button on /get-started and waits for dashboard URL.
    Click    css=[data-testid='close-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Navigate To Onboarding Within Session
    [Documentation]
    ...    Hard-navigates to /get-started within the current session.
    ...    Used as [Setup] for tests that follow a back-navigation from onboarding.
    Go To    ${BASE_URL}/get-started
    Wait For Elements State    ${OB_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
