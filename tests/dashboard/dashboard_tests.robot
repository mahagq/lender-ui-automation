*** Settings ***
Documentation
...    Dashboard test suite for the GQ Customer Portal (/my-applications).
...    Covers header/general tests, create-application flow, insurance tab navigation,
...    and logout — all using DASHBOARD_MOBILE with one account switch to NEW_USER_MOBILE.
...
...    EMI tests      → dashboard_emi_tests.robot       (DASHBOARD_MOBILE, independent)
...    AD tests       → dashboard_ad_tests.robot        (AD_MOBILE, independent)
...    PG tests       → dashboard_pg_tests.robot        (PG_MOBILE, independent)
...    New-user tests → dashboard_new_user_tests.robot  (DASHBOARD_NEW_MOBILE, independent)
...    INS tests      → dashboard_ins_tests.robot       (INS_MOBILE, independent)
...    INS new-user   → dashboard_ins_new_user_tests.robot (DASHBOARD_NEW_MOBILE, independent)
...
...    PRECONDITION:
...      - ${DASHBOARD_MOBILE} (8108556708): active applications (TC-4034).
...      - ${NEW_USER_MOBILE} (9938383856): no applications — empty-state create-app (TC-4035).
...
...    Session model — 3 logins total:
...      Suite Setup:    Opens browser, logs in as DASHBOARD_MOBILE, lands on /my-applications.
...      Test Setup:     Navigates to /my-applications (resets tab/filter/dropdown/scroll state).
...      Test Teardown:  NONE — shared session is preserved between tests.
...      Suite Teardown: Closes browser.
...      Account switch: TC-4035 → NEW_USER_MOBILE
...      TC-4009 setup: Switch To Account → DASHBOARD_MOBILE (independent fresh login)
...    ⚠ TC-4009 (logout) MUST remain the final test in this file (TN1 resolution).

Library          Browser
Resource         ../../resources/DashboardPage.robot
Resource         ../../variables/variables.robot

Suite Setup      Login And Navigate To Dashboard
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Dashboard

*** Test Cases ***

# ──────────────────────────────────────────────────────────────────────────────
# HEADER / GENERAL  (session: DASHBOARD_MOBILE 8108556708)
# ──────────────────────────────────────────────────────────────────────────────

Stages And CTA Of Stages
    [Documentation]
    ...    TC-4004: Validates stages and call-to-action elements on the dashboard.
    ...    Skipped — empty body in Java suite; no data-testid identified for stage elements.
    [Tags]    dashboard    stages    robot:skip
    Log    Skipped — TC-4004 had empty body in Java suite; no stage element data-testid confirmed

Back Button Is Not Present On Dashboard
    [Documentation]
    ...    TC-4005: Verifies back button behaviour on the dashboard.
    ...    Skipped — empty body in Java suite; dashboard has no back button element.
    [Tags]    dashboard    navigation    robot:skip
    Log    Skipped — TC-4005 had empty body in Java suite; no back button on dashboard

GrayQuest Logo Is Visible On Dashboard
    [Documentation]
    ...    TC-4006: The GrayQuest desktop logo should be visible on the dashboard header.
    ...    Also asserts dashboard title contains "Hello," and subtitle contains "Autopay subscriptions".
    ...    Satisfies: TC-4006, T1, U1, TN6
    [Tags]    dashboard    logo    ui    smoke
    GQ Logo Should Be Visible On Dashboard
    Dashboard Title Should Say Hello
    Dashboard Subtitle Should Contain Product Names

Profile Icon Shows FAQ And Logout Options
    [Documentation]
    ...    TC-4007: Clicking the profile icon should reveal a dropdown containing
    ...    both FAQ and Logout options.
    ...    Satisfies: TC-4007, U3, B1
    [Tags]    dashboard    profile    ui
    Open Profile Menu
    Profile Menu Should Show FAQ And Logout

FAQ Link Navigates To FAQ Page
    [Documentation]
    ...    TC-4008: Clicking the FAQ option in the profile dropdown should navigate
    ...    to the FAQ page. Asserted via URL contains /faq.
    ...    Satisfies: TC-4008, T1, TN3, B1
    [Tags]    dashboard    profile    navigation
    Open Profile Menu
    Click FAQ Option And Verify Navigation

Create New Application Button Has Visible Effect
    [Documentation]
    ...    TC-4010: Clicking the Create New Application button should produce a visible
    ...    response — either a modal becomes visible OR the URL changes from /my-applications.
    ...    Satisfies: TC-4010, O2, TN5, B1
    [Tags]    dashboard    application    smoke
    Click Create New Application And Verify Response

# ──────────────────────────────────────────────────────────────────────────────
# CREATE APP — EXISTING USER  (session: DASHBOARD_MOBILE 8108556708 — no switch)
# ──────────────────────────────────────────────────────────────────────────────

TC-4034 Create New Application Button Is Visible And Clickable In Header For Existing User
    [Documentation]
    ...    TC-4034: For a user with existing applications (${DASHBOARD_MOBILE} = 8108556708),
    ...    the Create New Application button renders in the top navigation header.
    ...    Verifies the button is visible and that clicking it produces a UI response.
    ...    No account switch — already on ${DASHBOARD_MOBILE}.
    ...    Satisfies: TC-4034, B1, T1
    [Tags]    dashboard    application    create-application    smoke
    Create New Application Button Should Be Visible And Clickable In Header

# ──────────────────────────────────────────────────────────────────────────────
# INSURANCE TAB NAVIGATION  (session: DASHBOARD_MOBILE 8108556708 — no switch)
# ──────────────────────────────────────────────────────────────────────────────

Insurance Tab Button Is Visible On Dashboard
    [Documentation]
    ...    TC-4032: The Insurance tab navigation button (data-testid='ins-tab-navigation-button')
    ...    should be visible on the dashboard.
    ...    Satisfies: TC-4032
    [Tags]    dashboard    insurance    tab-navigation
    Wait For Elements State    ${INS_TAB}    visible    timeout=${TIMEOUT}

Insurance Tab Click Updates URL Hash
    [Documentation]
    ...    TC-4033: Clicking the Insurance tab should update the URL hash to #ins and load
    ...    the Insurance content area.
    ...    Satisfies: TC-4033
    [Tags]    dashboard    insurance    tab-navigation
    Click Insurance Tab And Verify

# ──────────────────────────────────────────────────────────────────────────────
# CREATE APP — NEW USER  (session: → NEW_USER_MOBILE 9938383856)
# ──────────────────────────────────────────────────────────────────────────────

TC-4035 Create New Application Button Is Visible And Clickable In Empty State For New User
    [Documentation]
    ...    TC-4035: For a user with no existing applications (${NEW_USER_MOBILE} = 9938383856),
    ...    the Create New Application button renders inside the emi-not-data-found empty-state
    ...    container as a yellow "+ CREATE NEW APPLICATION" button. Verifies the button is
    ...    visible and that clicking it navigates away from /my-applications.
    ...    Satisfies: TC-4035, B1, T1
    [Tags]    dashboard    application    create-application    smoke
    Switch To Account    ${NEW_USER_MOBILE}
    Create New Application Button Should Be Visible And Clickable In Empty State

# ──────────────────────────────────────────────────────────────────────────────
# LOGOUT  (independent — logs in as DASHBOARD_MOBILE, then logs out)
# ⚠ MUST REMAIN LAST — destroys shared session (TN1 resolution)
# ──────────────────────────────────────────────────────────────────────────────

Logout Returns To Login Page
    [Documentation]
    ...    TC-4009: Clicking Logout in the profile dropdown should clear the authenticated
    ...    session and redirect to the login page at the base URL.
    ...    Independent — setup logs in fresh as ${DASHBOARD_MOBILE} via Switch To Account,
    ...    removing any dependency on the previous test's session state.
    ...    ⚠ ORDERING CONSTRAINT (TN1 resolution): This test MUST remain LAST in this file.
    ...    After logout the shared browser session is destroyed — all subsequent dashboard
    ...    tests would fail. Suite Teardown closes the browser immediately after.
    ...    Satisfies: TC-4009, TN1, O1, S1, B1
    [Setup]    Login Fresh And Navigate To Dashboard As    ${DASHBOARD_MOBILE}
    [Tags]    dashboard    profile    logout    session
    Open Profile Menu
    Logout And Verify Redirect To Login
