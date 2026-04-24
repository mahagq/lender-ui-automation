*** Settings ***
Documentation
...    Dashboard test suite for the GQ Customer Portal (/my-applications).
...    Covers TC-4001 to TC-4051: header, tab navigation, profile menu, EMI content,
...    Transaction History filters, download functionality, Auto Payments (AD) content,
...    AD detail modal, Insurance/AD tab navigation, and new-user empty states.
...    Ported from gq_customer_ui_automation (Java/Selenium) DashboardTestClass1-4.
...    Recorded in login_20260424_121929.js (new user) and login_20260424_122458.js (existing user).
...
...    PRECONDITION (TN2 resolution B): UAT test accounts must have pre-existing data:
...      - ${DASHBOARD_MOBILE} (8108556708): active EMI applications (TC-4001, TC-4011,
...        TC-4044 to TC-4046), enough to trigger load-more pagination.
...      - ${PG_MOBILE} (7757855472): transaction records (TC-4030, TC-4031).
...      - ${AD_MOBILE} (8763694182): active AD applications (TC-4036 to TC-4043).
...      - ${DASHBOARD_NEW_MOBILE} (dynamic): fresh mobile with no history (TC-4047 to TC-4051).
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
Variables        ../variables/dynamic_variables.py

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
    ...    TC-4002: The Auto Payments (AD) tab navigation button should be visible on the dashboard.
    ...    Auto Debit is an active feature on UAT — the tab button and URL hash are assertable.
    ...    Satisfies: TC-4002, B1
    [Tags]    dashboard    auto-debit    tab-navigation
    Wait For Elements State    ${AD_TAB}    visible    timeout=${TIMEOUT}

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

EMI Card Shows Application ID Label
    [Documentation]
    ...    TC-4044: The "Application ID:" label should be visible on the EMI card surface
    ...    without entering the card detail view.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have at least one active EMI application.
    ...    Satisfies: TC-4044, T1
    [Tags]    dashboard    emi    ui
    Click EMI Tab And Verify
    EMI App ID Label Should Be Visible

EMI Card App Copy Button Is Visible
    [Documentation]
    ...    TC-4045: The app-id-copy-button should be visible on the first EMI card.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have at least one active EMI application.
    ...    Satisfies: TC-4045, T1
    [Tags]    dashboard    emi    ui
    Click EMI Tab And Verify
    EMI App Copy Button Should Be Visible

EMI Load More Button Is Visible
    [Documentation]
    ...    TC-4046: The load-more-button should be visible on the EMI tab when the account
    ...    has more applications than the initial render threshold.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have enough EMI applications to trigger
    ...    the load-more pagination button.
    ...    Satisfies: TC-4046, T1
    [Tags]    dashboard    emi    ui    pagination
    Click EMI Tab And Verify
    Load More Button Should Be Visible

Auto Payments Tab Click
    [Documentation]
    ...    TC-4012: Clicking the Auto Payments tab button should update the URL hash to #ad.
    ...    Tab navigation is assertable with ${DASHBOARD_MOBILE} (no account switch required).
    ...    AD content assertions (App. Code:, copy button, repayment status, action button,
    ...    detail modal, schedule) require ${AD_MOBILE} (8763694182) — see TC-4036 to TC-4044.
    ...    Satisfies: TC-4012, U2, B1
    [Tags]    dashboard    auto-payments    tab-navigation
    Click AD Tab And Verify

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
    ...    TC-4025: The "This Month" time filter option should be selectable on the Offline sub-tab.
    ...    Satisfies: TC-4025, T5, B1
    [Tags]    dashboard    pg    filter    offline    time-filter
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    This Month

Filter By This Year For Offline Payments
    [Documentation]
    ...    TC-4026: The "This Year" time filter option should be selectable on the Offline sub-tab.
    ...    Satisfies: TC-4026, T5, B1
    [Tags]    dashboard    pg    filter    offline    time-filter
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    This Year

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

AD Tab App Code Label Is Visible
    [Documentation]
    ...    TC-4036: Switches to ${AD_MOBILE} (8763694182) which has active AD applications,
    ...    navigates to the Auto Payments tab, and asserts the "App. Code:" label is visible.
    ...    Subsequent AD content tests (TC-4037 to TC-4044) inherit this AD_MOBILE session.
    ...    Switch To Account logs out ${PG_MOBILE} and logs in as ${AD_MOBILE} in the same
    ...    browser context — rate limits are clear by this point in the suite.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one active AD application on UAT.
    ...    A failure signals an account seeding need, not a test defect.
    ...    Satisfies: TC-4036
    [Tags]    dashboard    auto-payments    session    smoke
    Switch To Account    ${AD_MOBILE}
    Click AD Tab And Verify
    AD App Code Label Should Be Visible

AD Tab Copy Button Is Visible
    [Documentation]
    ...    TC-4037: The copy button on the first AD application card should be visible.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application.
    ...    Satisfies: TC-4037
    [Tags]    dashboard    auto-payments    ui
    Click AD Tab And Verify
    AD Copy Button Should Be Visible

AD Tab Repayment Active Status Is Visible
    [Documentation]
    ...    TC-4038: At least one AD application card should display "Your repayment is active".
    ...    PRECONDITION: ${AD_MOBILE} must have at least one active repayment.
    ...    Satisfies: TC-4038
    [Tags]    dashboard    auto-payments    ui    status
    Click AD Tab And Verify
    AD Repayment Active Status Should Be Visible

AD Tab Repayment Pending Status Is Visible
    [Documentation]
    ...    TC-4039: At least one AD application card should display "Your repayment is pending".
    ...    PRECONDITION: ${AD_MOBILE} must have at least one pending repayment.
    ...    Satisfies: TC-4039
    [Tags]    dashboard    auto-payments    ui    status
    Click AD Tab And Verify
    AD Repayment Pending Status Should Be Visible

AD Tab Action Button Is Visible
    [Documentation]
    ...    TC-4040: The auto-debit-action-button should be visible on the first AD card.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application.
    ...    Satisfies: TC-4040
    [Tags]    dashboard    auto-payments    ui
    Click AD Tab And Verify
    AD Action Button Should Be Visible

AD Action Button Opens Detail Modal
    [Documentation]
    ...    TC-4041: Clicking the first auto-debit-action-button should open a detail modal
    ...    showing structural content: "See your active auto payment", "Summary",
    ...    "Repayment Complete", and "Student Details". Dynamic data (amounts, student name,
    ...    school) is intentionally not asserted as it varies by account seeding.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application with detail data.
    ...    Satisfies: TC-4041
    [Tags]    dashboard    auto-payments    modal
    Click AD Tab And Verify
    AD Action Button Should Open Detail Modal

AD Detail Modal Close Button Dismisses Modal
    [Documentation]
    ...    TC-4042: After opening the first AD application's detail modal, clicking the Close
    ...    button should dismiss the modal (content "See your active auto payment" becomes hidden).
    ...    Satisfies: TC-4042
    [Tags]    dashboard    auto-payments    modal
    Click AD Tab And Verify
    AD Detail Modal Close Button Should Dismiss Modal

AD Schedule Section Is Visible
    [Documentation]
    ...    TC-4043: The "Auto payments schedule" section heading should be visible on the AD tab.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application with schedule data.
    ...    Satisfies: TC-4043
    [Tags]    dashboard    auto-payments    ui
    Click AD Tab And Verify
    AD Schedule Section Should Be Visible

EMI Tab Shows No Applications For New User
    [Documentation]
    ...    TC-4047: Switches to ${DASHBOARD_NEW_MOBILE} (dynamic fresh mobile) which has no
    ...    existing applications. The EMI tab should display the "No Data Found" image and
    ...    "You have No Applications for" empty-state text.
    ...    Subsequent new-user tests (TC-4048 to TC-4051) inherit this session.
    ...    Recorded in login_20260424_121929.js.
    ...    Satisfies: TC-4047
    [Tags]    dashboard    emi    empty-state    smoke
    Switch To Account    ${DASHBOARD_NEW_MOBILE}
    Click EMI Tab And Verify
    EMI Empty State Should Be Visible

AD Tab Shows No Data Alert For New User
    [Documentation]
    ...    TC-4048: The Auto Payments tab should display an ARIA alert element when the
    ...    logged-in user has no active AD subscriptions.
    ...    PRECONDITION: Logged in as ${DASHBOARD_NEW_MOBILE} (no AD applications).
    ...    Satisfies: TC-4048
    [Tags]    dashboard    auto-payments    empty-state
    Click AD Tab And Verify
    AD Empty Alert Should Be Visible

PG Online Sub-tab Shows No Transactions For New User
    [Documentation]
    ...    TC-4049: The Online sub-tab in Transaction History should display
    ...    "Online transactions not found" text for a new user with no payment history.
    ...    PRECONDITION: Logged in as ${DASHBOARD_NEW_MOBILE} (no PG records).
    ...    Satisfies: TC-4049
    [Tags]    dashboard    pg    empty-state
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    PG Online Empty State Should Be Visible

PG Offline Sub-tab Shows No Data For New User
    [Documentation]
    ...    TC-4050: The Offline sub-tab in Transaction History should display the
    ...    "No Data Found" image and "You have not done any" text for a new user.
    ...    PRECONDITION: Logged in as ${DASHBOARD_NEW_MOBILE} (no offline transactions).
    ...    Satisfies: TC-4050
    [Tags]    dashboard    pg    empty-state
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    PG Offline Empty State Should Be Visible

PG Filter Applied Shows Inline Clear
    [Documentation]
    ...    TC-4051: After applying a filter on the Offline sub-tab, the filter-container
    ...    should display an inline "Clear" chip. Clicking it removes the applied filter.
    ...    Distinct from the clear-filter-button inside the filter panel (TC-4028).
    ...    Recorded in login_20260424_121929.js — filter interactions visible for any user.
    ...    Satisfies: TC-4051
    [Tags]    dashboard    pg    filter    inline-clear
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    All Months
    Click Apply Filter
    Click Filter Container Clear

Insurance Tab Button Is Visible On Dashboard
    [Documentation]
    ...    TC-4032: The Insurance tab navigation button (data-testid='ins-tab-navigation-button')
    ...    should be visible on the dashboard. Insurance is the second tab added in the UAT branch.
    ...    Satisfies: TC-4032
    [Tags]    dashboard    insurance    tab-navigation
    Wait For Elements State    ${INS_TAB}    visible    timeout=${TIMEOUT}

Insurance Tab Click Updates URL Hash
    [Documentation]
    ...    TC-4033: Clicking the Insurance tab should update the URL hash to #ins and load
    ...    the Insurance content area. InsuranceTab has no data-testid attributes — hash
    ...    update is the primary assertion (same pattern as EMI and PG tabs).
    ...    Satisfies: TC-4033
    [Tags]    dashboard    insurance    tab-navigation
    Click Insurance Tab And Verify

TC-4034 Create New Application Button Is Visible And Clickable In Header For Existing User
    [Documentation]
    ...    TC-4034: For a user with existing applications (${EXISTING_USER_MOBILE} = 8108556708),
    ...    the Create New Application button renders in the top navigation header
    ...    (data-testid='create-new-application-button'). Verifies the button is visible and
    ...    that clicking it produces a UI response — either a "Before you proceed" dialog
    ...    (role='dialog') or a URL change away from /my-applications.
    ...    Switches account from previous session via Switch To Account.
    ...    Satisfies: TC-4034, B1, T1
    [Tags]    dashboard    application    create-application    smoke
    Switch To Account    ${EXISTING_USER_MOBILE}
    Create New Application Button Should Be Visible And Clickable In Header

TC-4035 Create New Application Button Is Visible And Clickable In Empty State For New User
    [Documentation]
    ...    TC-4035: For a user with no existing applications (${NEW_USER_MOBILE} = 9938383856),
    ...    the Create New Application button renders inside the emi-not-data-found empty-state
    ...    container as a yellow "+ CREATE NEW APPLICATION" button. Verifies the button is
    ...    visible and that clicking it navigates away from /my-applications.
    ...    Switches account from the TC-4034 session via Switch To Account.
    ...    Satisfies: TC-4035, B1, T1
    [Tags]    dashboard    application    create-application    smoke
    Switch To Account    ${NEW_USER_MOBILE}
    Create New Application Button Should Be Visible And Clickable In Empty State

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
