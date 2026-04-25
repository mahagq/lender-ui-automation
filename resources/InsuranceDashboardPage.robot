*** Settings ***
Documentation
...    Page object keywords for the Insurance tab (/my-applications#ins).
...    All data-testid locators derived from gqcustomer_frontend UAT branch.
...    Non-testid elements use alt-text or text selectors — no CSS class selectors.
...    Library: Browser (Playwright) — TN3 resolution.
...
...    PRECONDITION: ${INS_MOBILE} (8668768645) must have at least one active insurance
...    policy (Status: Issued or Status: Applied) for policy-card assertions to pass.
...    A "no data found" failure signals an account seeding need, not a test defect.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Insurance Tab (login once, land on #ins)
...      Test Setup    → Navigate To Insurance Tab (hard-nav to /my-applications + click INS tab)
...      Test Teardown → NONE (shared session preserved)
...      Suite Teardown → Close Browser
...    Satisfies: T1 (data-testid locators), U2 (explicit waits)

Library     Browser
Resource    DashboardPage.robot

*** Variables ***
# Insurance tab — education banner (no data-testids; stable alt/text attributes used per T1 exception)
${INS_BANNER_IMAGE}             css=img[alt='Education costs illustration with graduation cap and coins']
${INS_BANNER_HEADING}           text=Education costs are rising
${INS_BANNER_SUBTEXT}           text=Education inflation is real.
${GUARDIAN_ONE_LOGO}            css=img[alt='Guardian One logo']

# Insurance tab — policies section
${POLICIES_HEADING}             text=Your Policies
${POLICY_COPY_BUTTON}           css=[data-testid='app-id-copy-button'] >> nth=0
${POLICY_DOWNLOAD_BUTTON}       css=[data-testid='download-button'] >> nth=0
${STATUS_ISSUED}                text=Status: Issued >>nth=0
${STATUS_APPLIED}               text=Status: Applied >> nth=0

# Insurance tab — calculator CTA (no data-testid; button text selector used)
${CALCULATE_NOW_BUTTON}         css=button:has-text("CALCULATE NOW")

# Insurance tab — new user plan selection screen (no existing policies)
# Recorded in login_20260424_121929.js — mobile 9373938938 (fresh, no policies)
${INS_PLAN_HEADING}             text=Choose your Insurance Plan
${INS_EDUCATION_PLAN}           text=Education Coverage
${INS_RECOMMENDED_BADGE}        text=Recommended
${INS_COMPLETE_LIFE_PLAN}       text=Complete Life

*** Keywords ***
Login And Navigate To Insurance Tab
    [Documentation]
    ...    Suite Setup keyword. Opens a browser, logs in with ${INS_MOBILE},
    ...    submits OTP, and clicks the Insurance tab so all tests start on #ins.
    ...    Includes checkMobilePost and verifyOtpPost rate-limit retry handling.
    ...    Satisfies: T2, T3, O1, S1
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${INS_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit during Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${INS_MOBILE}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit during Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Enter OTP    ${TEST_OTP}
        Click Verify OTP Button
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${INS_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_INS}

Navigate To Insurance Tab
    [Documentation]
    ...    Per-test navigation reset. Hard-navigates to /my-applications and clicks the
    ...    Insurance tab so every test starts cleanly on #ins with no stale scroll/state.
    ...    Satisfies: RT-2, O1
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${INS_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_INS}

Insurance Tab URL Should Be Active
    [Documentation]
    ...    Asserts the current URL hash is #ins after clicking the Insurance tab.
    ...    Satisfies: TC-4101, U2
    URL Should Contain Hash    ${HASH_INS}

Education Banner Image Should Be Visible
    [Documentation]
    ...    Asserts the "Education costs illustration" banner image is visible on the Insurance tab.
    ...    Satisfies: TC-4102
    Wait For Elements State    ${INS_BANNER_IMAGE}    visible    timeout=20s

Education Banner Heading Should Be Correct
    [Documentation]
    ...    Asserts the education banner heading "Education costs are rising" is visible.
    ...    Satisfies: TC-4103
    Wait For Elements State    ${INS_BANNER_HEADING}    visible    timeout=${TIMEOUT}

Education Banner Subtext Should Be Visible
    [Documentation]
    ...    Asserts the education banner subtext "Education inflation is real." is visible.
    ...    Satisfies: TC-4104
    Wait For Elements State    ${INS_BANNER_SUBTEXT}    visible    timeout=${TIMEOUT}

Guardian One Logo Should Be Visible
    [Documentation]
    ...    Asserts the Guardian One insurance provider logo is visible in the banner.
    ...    Satisfies: TC-4105
    Wait For Elements State    ${GUARDIAN_ONE_LOGO}    visible    timeout=${TIMEOUT}

Policies Heading Should Be Visible
    [Documentation]
    ...    Asserts the "Your Policies" section heading is visible.
    ...    Satisfies: TC-4106
    Wait For Elements State    ${POLICIES_HEADING}    visible    timeout=${TIMEOUT}

Policy Copy Button Should Be Visible
    [Documentation]
    ...    Asserts the app-id-copy-button is visible on the first policy card.
    ...    PRECONDITION: ${INS_MOBILE} must have at least one policy.
    ...    Satisfies: TC-4107
    Wait For Elements State    ${POLICY_COPY_BUTTON}    visible    timeout=${TIMEOUT}

Policy Status Issued Should Be Visible
    [Documentation]
    ...    Asserts at least one policy card shows "Status: Issued".
    ...    PRECONDITION: ${INS_MOBILE} must have at least one issued policy.
    ...    Satisfies: TC-4108
    Wait For Elements State    ${STATUS_ISSUED}    visible    timeout=${TIMEOUT}

Policy Status Applied Should Be Visible
    [Documentation]
    ...    Asserts at least one policy card shows "Status: Applied".
    ...    PRECONDITION: ${INS_MOBILE} must have at least one applied policy.
    ...    Satisfies: TC-4109
    Wait For Elements State    ${STATUS_APPLIED}    visible    timeout=${TIMEOUT}

Policy Download Button Should Be Visible And Enabled
    [Documentation]
    ...    Asserts the download button on the first policy card is visible and enabled.
    ...    PRECONDITION: ${INS_MOBILE} must have at least one policy with a download link.
    ...    Satisfies: TC-4110
    Wait For Elements State    ${POLICY_DOWNLOAD_BUTTON}    visible    timeout=${TIMEOUT}
    Get Element States    ${POLICY_DOWNLOAD_BUTTON}    contains    enabled

Calculate Now Button Opens New Tab
    [Documentation]
    ...    Clicks the "CALCULATE NOW" CTA button and asserts it opens a new browser tab.
    ...    Closes the new tab and returns to the dashboard after verification.
    ...    Satisfies: TC-4111
    Wait For Elements State    ${CALCULATE_NOW_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CALCULATE_NOW_BUTTON}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${url}=    Get Url
    Close Page
    Should Not Be Empty    ${url}

Navigate To Insurance Tab New User
    [Documentation]
    ...    Suite Setup for dashboard_ins_new_user_tests.robot.
    ...    Opens a brand-new browser and logs in as ${DASHBOARD_NEW_MOBILE} (dynamically
    ...    generated mobile with no insurance policies). Completely standalone — no dependency
    ...    on any prior suite or session. Navigates to the Insurance tab.
    ...    A fresh mobile shows the plan selection screen ("Choose your Insurance Plan").
    ...    Satisfies: TC-4112 to TC-4115
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page    ${BASE_URL}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
    Submit Login Form    ${DASHBOARD_NEW_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit in Navigate To Insurance Tab New User — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Browser
        Sleep    ${RATE_LIMIT_WAIT}
        New Browser    ${BROWSER}    headless=${HEADLESS}
        New Context
        New Page    ${BASE_URL}
        Submit Login Form    ${DASHBOARD_NEW_MOBILE}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Enter OTP    ${TEST_OTP}
        Click Verify OTP Button
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${INS_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_INS}

Insurance Plan Heading Should Be Visible
    [Documentation]
    ...    Asserts the "Choose your Insurance Plan" heading is visible on the Insurance tab
    ...    for a new user with no existing policies.
    ...    Satisfies: TC-4112
    Wait For Elements State    ${INS_PLAN_HEADING}    visible    timeout=${TIMEOUT}

Education Coverage Plan Should Be Visible
    [Documentation]
    ...    Asserts the "Education Coverage" plan card is visible in the Insurance tab
    ...    plan selection screen.
    ...    Satisfies: TC-4113
    Wait For Elements State    ${INS_EDUCATION_PLAN}    visible    timeout=${TIMEOUT}

Recommended Plan Badge Should Be Visible
    [Documentation]
    ...    Asserts the "Recommended" badge is visible on one of the Insurance plan cards.
    ...    Corresponds to the "⭐ Recommended Complete Life" plan in the recording.
    ...    Satisfies: TC-4114
    Wait For Elements State    ${INS_RECOMMENDED_BADGE}    visible    timeout=${TIMEOUT}

Complete Life Plan Should Be Visible
    [Documentation]
    ...    Asserts the "Complete Life" plan card is visible in the Insurance tab
    ...    plan selection screen.
    ...    Satisfies: TC-4115
    Wait For Elements State    ${INS_COMPLETE_LIFE_PLAN}    visible    timeout=${TIMEOUT}
