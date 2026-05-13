*** Settings ***
Documentation
...    EMI tab test suite for the GQ Customer Portal Dashboard (/my-applications#emi).
...    Completely independent — opens its own browser, logs in as ${DASHBOARD_MOBILE}.
...
...    PRECONDITION: ${DASHBOARD_MOBILE} (8108556708) must have active EMI applications,
...    enough to trigger the load-more pagination button.
...    A "no data found" failure signals an account seeding need, not a test defect.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Dashboard (DASHBOARD_MOBILE)
...      Test Setup    → Navigate To Dashboard
...      Test Teardown → NONE
...      Suite Teardown → Close Browser
...
...    Covers: TC-4001, TC-4011, TC-4044 to TC-4046

Library          Browser
Resource         ../../resources/DashboardPage.robot
Resource         ../../variables/variables.robot

Suite Setup      Login And Navigate To Dashboard
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:EMI

*** Test Cases ***

EMI Applications Are Visible On Dashboard
    [Documentation]
    ...    TC-4001: The dashboard EMI tab should display at least one EMI card after login.
    ...    Satisfies: TC-4001, T4, B1
    [Tags]    dashboard    emi    smoke
    EMI Cards Should Be Visible

EMI Tab Click Shows EMI Content
    [Documentation]
    ...    TC-4011: Clicking the EMI tab button should update the URL hash to #emi
    ...    and display at least one EMI card in the tab content area.
    ...    Satisfies: TC-4011, U2, T4, B1
    [Tags]    dashboard    emi    tab-navigation
    Click EMI Tab And Verify
    EMI Cards Should Be Visible

EMI Card Shows Application ID Label
    [Documentation]
    ...    TC-4044: The "Application ID:" label should be visible on the EMI card surface.
    ...    Satisfies: TC-4044, T1
    [Tags]    dashboard    emi    ui
    Click EMI Tab And Verify
    EMI App ID Label Should Be Visible

EMI Card App Copy Button Is Visible
    [Documentation]
    ...    TC-4045: The app-id-copy-button should be visible on the first EMI card.
    ...    Satisfies: TC-4045, T1
    [Tags]    dashboard    emi    ui
    Click EMI Tab And Verify
    EMI App Copy Button Should Be Visible

EMI Load More Button Is Visible
    [Documentation]
    ...    TC-4046: The load-more-button should be visible when the account has more
    ...    applications than the initial render threshold.
    ...    Satisfies: TC-4046, T1
    [Tags]    dashboard    emi    ui    pagination
    Click EMI Tab And Verify
    Load More Button Should Be Visible

EMI Load More Button Loads Previous Applications
    [Documentation]
    ...    TC-4047-LD: Clicking load-more-button should increase the number of visible EMI
    ...    cards — confirming previous applications are appended to the list.
    ...    Satisfies: TC-4047-LD, T1, U2
    [Tags]    dashboard    emi    ui    pagination
    Click EMI Tab And Verify
    Load More Loads Additional EMI Cards
