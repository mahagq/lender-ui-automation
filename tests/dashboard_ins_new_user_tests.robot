*** Settings ***
Documentation
...    Insurance tab new-user test suite for the GQ Customer Portal (/my-applications#ins).
...    Tests the Insurance plan selection screen shown to users with no existing policies.
...    Completely independent of dashboard_ins_tests.robot — opens its own browser.
...    Recorded in login_20260424_121929.js (fresh mobile 9373938938, no policies).
...
...    PRECONDITION:
...      ${DASHBOARD_NEW_MOBILE} (dynamic fresh mobile) must have no insurance policies —
...      guaranteed for any dynamically generated number.
...
...    Session model:
...      Suite Setup   → Navigate To Insurance Tab New User (fresh browser + login as DASHBOARD_NEW_MOBILE)
...      Test Setup    → Navigate To Insurance Tab (hard-nav to /my-applications + click INS tab)
...      Test Teardown → NONE (shared session preserved)
...      Suite Teardown → Close Browser
...
...    Covers: TC-4112 to TC-4115

Library          Browser
Resource         ../resources/InsuranceDashboardPage.robot
Resource         ../variables/variables.robot
Variables        ../variables/dynamic_variables.py

Suite Setup      Navigate To Insurance Tab New User
Suite Teardown   Close Browser
Test Setup       Navigate To Insurance Tab
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Insurance Tab New User

*** Test Cases ***

Insurance Plan Heading Is Visible For New User
    [Documentation]
    ...    TC-4112: For a new user with no insurance policies, the Insurance tab should display
    ...    the "Choose your Insurance Plan" plan selection heading instead of existing policy cards.
    ...    Satisfies: TC-4112
    [Tags]    dashboard    insurance    ui    new-user    smoke
    Insurance Plan Heading Should Be Visible

Education Coverage Plan Is Visible For New User
    [Documentation]
    ...    TC-4113: The "Education Coverage" insurance plan card should be visible on the
    ...    plan selection screen for a new user.
    ...    Satisfies: TC-4113
    [Tags]    dashboard    insurance    ui    new-user
    Insurance Plan Heading Should Be Visible
    Education Coverage Plan Should Be Visible

Recommended Plan Badge Is Visible For New User
    [Documentation]
    ...    TC-4114: A "Recommended" badge should be visible on one of the insurance plan cards
    ...    on the plan selection screen.
    ...    Satisfies: TC-4114
    [Tags]    dashboard    insurance    ui    new-user
    Insurance Plan Heading Should Be Visible
    Recommended Plan Badge Should Be Visible

Complete Life Plan Is Visible For New User
    [Documentation]
    ...    TC-4115: The "Complete Life" insurance plan card should be visible on the plan
    ...    selection screen for a new user.
    ...    Satisfies: TC-4115
    [Tags]    dashboard    insurance    ui    new-user
    Insurance Plan Heading Should Be Visible
    Complete Life Plan Should Be Visible
