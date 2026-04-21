*** Settings ***
Documentation
...    Dashboard test suite for the GQ Customer Portal (/my-applications).
...    Covers TC-4001 to TC-4031: header, tab navigation, profile menu, EMI content,
...    Transaction History filters, and download functionality.
...    Ported from gq_customer_ui_automation (Java/Selenium) DashboardTestClass1-4.
...
...    PRECONDITION (TN2 resolution B): The UAT test account (${DASHBOARD_MOBILE}) must have:
...      - At least one active EMI application for TC-4001 and TC-4011 to be assertable.
...      - At least one transaction record for TC-4013 through TC-4031 to be assertable.
...    A failure indicating "no data found" signals an account seeding need, not a test defect.
...
...    Session model (O1 + TN4 + TN1 resolutions):
...      Suite Setup:    Opens browser, logs in once, lands on /my-applications.
...      Test Setup:     Navigates to /my-applications (resets tab/filter/dropdown/scroll state).
...      Test Teardown:  NONE — shared session is preserved between tests (no Close Context).
...      Suite Teardown: Closes browser.
...    ⚠ TC-4009 (logout) MUST remain the final test in this file (TN1 resolution).
...    Robot Framework executes tests in file order; the logout test destroys the session.

Library          Browser
Resource         ../resources/DashboardPage.robot
Resource         ../variables/variables.robot

Suite Setup      Login And Navigate To Dashboard
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Dashboard

*** Test Cases ***

EMI Applications Are Visible On Dashboard
    [Documentation]
    ...    TC-4001: The dashboard EMI tab should display at least one EMI card after login.
    ...    ${DASHBOARD_MOBILE} (8108556708) has active EMI applications — no account switch needed.
    ...    Satisfies: TC-4001, T4, B1
    [Tags]    dashboard    emi    smoke
    EMI Cards Should Be Visible

Auto Debit Applications On Dashboard
    [Documentation]
    ...    TC-4002: Dashboard should display Auto Debit applications.
    ...    Skipped — disabled in Java suite (Auto Debit feature not active in UAT environment).
    [Tags]    dashboard    auto-debit    robot:skip
    Log    Skipped — TC-4002 disabled in Java suite (Auto Debit not active in UAT)

Payment Gateway Applications Are Visible
    [Documentation]
    ...    TC-4003: The Transaction History tab should be accessible and display
    ...    Online and Offline sub-tab navigation upon click.
    ...    Satisfies: TC-4003, U2, B1
    [Tags]    dashboard    pg    smoke
    Click Transaction History Tab And Verify
    Online And Offline Sub-tabs Should Be Visible

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
    ...    Also asserts dashboard title contains "Hello," and subtitle contains "Autopay subscriptions"
    ...    (U1/TN6 assertions — no dedicated TC exists for header text in the Java suite).
    ...    Satisfies: TC-4006, T1, U1, TN6
    [Tags]    dashboard    logo    ui    smoke
    GQ Logo Should Be Visible On Dashboard
    Dashboard Title Should Say Hello
    Dashboard Subtitle Should Contain Product Names

Profile Icon Shows FAQ And Logout Options
    [Documentation]
    ...    TC-4007: Clicking the profile icon should reveal a dropdown containing
    ...    both FAQ and Logout options. Container must be visible before asserting options (U3).
    ...    Satisfies: TC-4007, U3, B1
    [Tags]    dashboard    profile    ui
    Open Profile Menu
    Profile Menu Should Show FAQ And Logout

FAQ Link Navigates To FAQ Page
    [Documentation]
    ...    TC-4008: Clicking the FAQ option in the profile dropdown should navigate
    ...    to the FAQ page. Asserted via URL contains /faq + browser title contains FAQ.
    ...    No DOM element assertion — FAQ page h1 has no data-testid (TN3 resolution).
    ...    Satisfies: TC-4008, T1, TN3, B1
    [Tags]    dashboard    profile    navigation
    Open Profile Menu
    Click FAQ Option And Verify Navigation

Create New Application Button Has Visible Effect
    [Documentation]
    ...    TC-4010: Clicking the Create New Application button should produce a visible
    ...    response — either a modal becomes visible OR the URL changes from /my-applications.
    ...    Covers accounts with existing applications (modal) and clean accounts (redirect).
    ...    Satisfies: TC-4010, O2, TN5, B1
    [Tags]    dashboard    application    smoke
    Click Create New Application And Verify Response

EMI Tab Click Shows EMI Content
    [Documentation]
    ...    TC-4011: Clicking the EMI tab button should update the URL hash to #emi
    ...    and display at least one EMI card in the tab content area.
    ...    PRECONDITION: UAT account must have at least one active EMI application (TN2).
    ...    Satisfies: TC-4011, U2, T4, B1
    [Tags]    dashboard    emi    tab-navigation
    Click EMI Tab And Verify
    EMI Cards Should Be Visible

Auto Payments Tab Click
    [Documentation]
    ...    TC-4012: Clicking the Auto Payments tab should display Auto Debit content.
    ...    Skipped — disabled in Java suite (Auto Payments not active in UAT environment).
    [Tags]    dashboard    auto-payments    robot:skip
    Log    Skipped — TC-4012 disabled in Java suite (Auto Payments not active in UAT)

Transaction History Tab Click
    [Documentation]
    ...    TC-4013: Clicking the Transaction History tab should update the URL hash to #direct
    ...    and display the Online and Offline sub-tabs for navigation.
    ...    Satisfies: TC-4013, U2, B1
    [Tags]    dashboard    pg    tab-navigation    smoke
    Click Transaction History Tab And Verify
    Online And Offline Sub-tabs Should Be Visible

Offline Payments Sub-tab Is Accessible
    [Documentation]
    ...    TC-4014: The Offline Payments sub-tab should be visible and clickable
    ...    within the Transaction History tab.
    ...    Satisfies: TC-4014, B1
    [Tags]    dashboard    pg    sub-tab
    Click Transaction History Tab And Verify
    Click Offline Sub-tab

Online Payments Sub-tab Is Accessible
    [Documentation]
    ...    TC-4015: The Online Payments sub-tab should be visible and clickable
    ...    within the Transaction History tab.
    ...    Satisfies: TC-4015, B1
    [Tags]    dashboard    pg    sub-tab
    Click Transaction History Tab And Verify
    Click Online Sub-tab

Filter Panel Is Visible For Online Payments
    [Documentation]
    ...    TC-4016: After clicking the filter button on the Online sub-tab, all time and
    ...    status filter options should be visible in the filter panel.
    ...    Satisfies: TC-4016, T5, B1
    [Tags]    dashboard    pg    filter    online
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Filter Options Should Be Visible

Filter By All Months For Online Payments
    [Documentation]
    ...    TC-4017: The "All Months" time filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4017, T5, B1
    [Tags]    dashboard    pg    filter    online    time-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    All Months

Filter By This Month For Online Payments
    [Documentation]
    ...    TC-4018: The "This Month" time filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4018, T5, B1
    [Tags]    dashboard    pg    filter    online    time-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    This Month

Filter By This Year For Online Payments
    [Documentation]
    ...    TC-4019: The "This Year" time filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4019, T5, B1
    [Tags]    dashboard    pg    filter    online    time-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    This Year

Filter By Last Year For Online Payments
    [Documentation]
    ...    TC-4020: The "Last Year" time filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4020, T5, B1
    [Tags]    dashboard    pg    filter    online    time-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    Last Year

Filter By Status Paid For Online Payments
    [Documentation]
    ...    TC-4021: The "Paid" status filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4021, T5, B1
    [Tags]    dashboard    pg    filter    online    status-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Status Filter    Paid

Filter By Status Failed For Online Payments
    [Documentation]
    ...    TC-4022: The "Failed" status filter option should be selectable on the Online sub-tab.
    ...    Satisfies: TC-4022, T5, B1
    [Tags]    dashboard    pg    filter    online    status-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Status Filter    Failed

Filter Panel Is Visible For Offline Payments
    [Documentation]
    ...    TC-4023: After clicking the filter button on the Offline sub-tab, time filter
    ...    options should be visible in the filter panel.
    ...    Note: Offline filter panel shows time filters only — no Paid/Failed status options
    ...    (confirmed UAT behaviour; Online sub-tab has status filters, Offline does not).
    ...    Satisfies: TC-4023, T5, B1
    [Tags]    dashboard    pg    filter    offline
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Offline Filter Options Should Be Visible

Filter By All Months For Offline Payments
    [Documentation]
    ...    TC-4024: The "All Months" time filter option should be selectable on the Offline sub-tab.
    ...    Satisfies: TC-4024, T5, B1
    [Tags]    dashboard    pg    filter    offline    time-filter
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    All Months

Filter By This Month For Offline Payments
    [Documentation]
    ...    TC-4025: "This Month" time filter for Offline sub-tab.
    ...    Skipped — disabled in Java suite.
    [Tags]    dashboard    pg    filter    offline    time-filter    robot:skip
    Log    Skipped — TC-4025 disabled in Java suite

Filter By This Year For Offline Payments
    [Documentation]
    ...    TC-4026: "This Year" time filter for Offline sub-tab.
    ...    Skipped — disabled in Java suite.
    [Tags]    dashboard    pg    filter    offline    time-filter    robot:skip
    Log    Skipped — TC-4026 disabled in Java suite

Filter By Last Year For Offline Payments
    [Documentation]
    ...    TC-4027: The "Last Year" time filter option should be selectable on the Offline sub-tab.
    ...    Satisfies: TC-4027, T5, B1
    [Tags]    dashboard    pg    filter    offline    time-filter
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    Last Year

Clear Filter Button Works
    [Documentation]
    ...    TC-4028: After opening the filter panel and selecting a time filter, the clear
    ...    filter button should be visible and clickable, resetting the filter selection.
    ...    Satisfies: TC-4028, T5, B1
    [Tags]    dashboard    pg    filter    clear-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    This Month
    Click Clear Filter

Apply Filter Button Works
    [Documentation]
    ...    TC-4029: After opening the filter panel and selecting a time filter, the apply
    ...    filter button should be visible and clickable, applying the filter.
    ...    Satisfies: TC-4029, T5, B1
    [Tags]    dashboard    pg    filter    apply-filter
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Open Filter Panel
    Select Time Filter    This Month
    Click Apply Filter

Download Icon Is Visible For Offline Payment
    [Documentation]
    ...    TC-4030: The download button for the first transaction row on the Offline sub-tab
    ...    should be visible.
    ...    Switches to ${PG_MOBILE} (7757855472) which has transaction records (TN2 resolution).
    ...    Switch To Account logs out 8108556708 and logs in as 7757855472 within the same
    ...    browser context — no context close/reopen. Rate limits clear by this point in the
    ...    suite (~3 min after Suite Setup). TC-4031 inherits the PG_MOBILE session.
    ...    Satisfies: TC-4030, T5, B1
    [Tags]    dashboard    pg    download    offline
    Switch To Account    ${PG_MOBILE}
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Download Button Should Be Visible For First Row

Download Icon Is Visible For Online Payment
    [Documentation]
    ...    TC-4031: The download button for the first transaction row on the Online sub-tab
    ...    should be visible. Canonical from DashboardTestClass3 (enabled); Class4 duplicate skipped (B3).
    ...    PRECONDITION: UAT account must have at least one online transaction record (TN2).
    ...    Satisfies: TC-4031, T5, B1, B3
    [Tags]    dashboard    pg    download    online
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Download Button Should Be Visible For First Row

Logout Returns To Login Page
    [Documentation]
    ...    TC-4009: Clicking Logout in the profile dropdown should clear the authenticated
    ...    session and redirect to the login page at the base URL.
    ...    ⚠ ORDERING CONSTRAINT (TN1 resolution): This test MUST remain LAST in this file.
    ...    After logout the shared browser session is destroyed — all subsequent dashboard
    ...    tests would fail. Suite Teardown closes the browser immediately after.
    ...    Satisfies: TC-4009, TN1, O1, S1, B1
    [Tags]    dashboard    profile    logout    session
    Open Profile Menu
    Logout And Verify Redirect To Login
