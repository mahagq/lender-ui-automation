*** Settings ***
Documentation
...    New-user empty state test suite for the GQ Customer Portal Dashboard (/my-applications).
...    Completely independent — opens its own browser, logs in as ${DASHBOARD_NEW_MOBILE}.
...
...    PRECONDITION: ${DASHBOARD_NEW_MOBILE} (dynamic fresh mobile) must have no applications,
...    no AD subscriptions, and no transaction records — guaranteed for any dynamically
...    generated number.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Dashboard As ${DASHBOARD_NEW_MOBILE}
...      Test Setup    → Navigate To Dashboard
...      Test Teardown → NONE
...      Suite Teardown → Close Browser
...
...    Covers: TC-4047 to TC-4050

Library          Browser
Resource         ../resources/DashboardPage.robot
Resource         ../variables/variables.robot
Variables        ../variables/dynamic_variables.py

Suite Setup      Login And Navigate To Dashboard As    ${DASHBOARD_NEW_MOBILE}
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:New User Empty States

*** Test Cases ***

EMI Tab Shows No Applications For New User
    [Documentation]
    ...    TC-4047: A fresh user with no existing applications should see the "No Data Found"
    ...    image and "You have No Applications for" empty-state text on the EMI tab.
    ...    Satisfies: TC-4047
    [Tags]    dashboard    emi    empty-state    smoke
    Click EMI Tab And Verify
    EMI Empty State Should Be Visible

AD Tab Shows No Data Alert For New User
    [Documentation]
    ...    TC-4048: The Auto Payments tab should display an ARIA alert element when the
    ...    logged-in user has no active AD subscriptions.
    ...    Satisfies: TC-4048
    [Tags]    dashboard    auto-payments    empty-state
    Click AD Tab And Verify
    AD Empty Alert Should Be Visible

PG Online Sub-tab Shows No Transactions For New User
    [Documentation]
    ...    TC-4049: The Online sub-tab in Transaction History should display
    ...    "Online transactions not found" text for a new user with no payment history.
    ...    Satisfies: TC-4049
    [Tags]    dashboard    pg    empty-state
    Click Transaction History Tab And Verify
    Click Online Sub-tab
    PG Online Empty State Should Be Visible

PG Offline Sub-tab Shows No Data For New User
    [Documentation]
    ...    TC-4050: The Offline sub-tab in Transaction History should display the
    ...    "No Data Found" image and "You have not done any" text for a new user.
    ...    Satisfies: TC-4050
    [Tags]    dashboard    pg    empty-state
    Click Transaction History Tab And Verify
    Click Offline Sub-tab
    PG Offline Empty State Should Be Visible
