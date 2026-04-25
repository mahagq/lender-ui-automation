*** Settings ***
Documentation
...    Payment Gateway (PG) / Transaction History tab test suite for the GQ Customer Portal
...    Dashboard (/my-applications#direct).
...    Completely independent — opens its own browser, logs in as ${PG_MOBILE}.
...
...    PRECONDITION: ${PG_MOBILE} (7757855472) must have transaction records —
...    both online and offline — to satisfy download and filter assertions.
...    A "no data found" failure signals an account seeding need, not a test defect.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Dashboard As ${PG_MOBILE}
...      Test Setup    → Navigate To Dashboard
...      Test Teardown → NONE
...      Suite Teardown → Close Browser
...
...    Covers: TC-4003, TC-4013 to TC-4029, TC-4051, TC-4030, TC-4031

Library          Browser
Resource         ../resources/DashboardPage.robot
Resource         ../variables/variables.robot

Suite Setup      Login And Navigate To Dashboard As    ${PG_MOBILE}
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Payment Gateway

*** Test Cases ***

Payment Gateway Applications Are Visible
    [Documentation]
    ...    TC-4003: The Transaction History tab should be accessible and display
    ...    Online and Offline sub-tab navigation upon click.
    ...    Satisfies: TC-4003, U2, B1
    [Tags]    dashboard    pg    smoke
    Click Transaction History Tab And Verify
    Online And Offline Sub-tabs Should Be Visible

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
    ...    Note: Offline filter panel shows time filters only — no Paid/Failed status options.
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

PG Filter Applied Shows Inline Clear
    [Documentation]
    ...    TC-4051: After applying a filter on the Offline sub-tab, the filter-container
    ...    should display an inline "Clear" chip. Clicking it removes the applied filter.
    ...    Satisfies: TC-4051
    [Tags]    dashboard    pg    filter    inline-clear
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Open Filter Panel
    Select Time Filter    All Months
    Click Apply Filter
    Click Filter Container Clear

Download Icon Is Visible For Offline Payment
    [Documentation]
    ...    TC-4030: The download button for the first transaction row on the Offline sub-tab
    ...    should be visible.
    ...    PRECONDITION: ${PG_MOBILE} (7757855472) must have offline transaction records.
    ...    Satisfies: TC-4030, T5, B1
    [Tags]    dashboard    pg    download    offline
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    Download Button Should Be Visible For First Row

Download Icon Is Visible For Online Payment
    [Documentation]
    ...    TC-4031: The download button for the first transaction row on the Online sub-tab
    ...    should be visible.
    ...    PRECONDITION: ${PG_MOBILE} must have at least one online transaction record.
    ...    Satisfies: TC-4031, T5, B1, B3
    [Tags]    dashboard    pg    download    online
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    Download Button Should Be Visible For First Row
