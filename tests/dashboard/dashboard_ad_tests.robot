*** Settings ***
Documentation
...    Auto Debit (AD) tab test suite for the GQ Customer Portal Dashboard (/my-applications#ad).
...    Completely independent — opens its own browser, logs in as ${AD_MOBILE}.
...
...    PRECONDITION: ${AD_MOBILE} (8763694182) must have active AD applications
...    (at least one active repayment, one pending repayment, and schedule data).
...    A "no data found" failure signals an account seeding need, not a test defect.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Dashboard As ${AD_MOBILE}
...      Test Setup    → Navigate To Dashboard
...      Test Teardown → NONE
...      Suite Teardown → Close Browser
...
...    Covers: TC-4002, TC-4012, TC-4036 to TC-4043

Library          Browser
Resource         ../../resources/DashboardPage.robot
Resource         ../../variables/variables.robot

Suite Setup      Login And Navigate To Dashboard As    ${AD_MOBILE}
Suite Teardown   Close Browser
Test Setup       Navigate To Dashboard
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Auto Debit

*** Test Cases ***

Auto Debit Applications On Dashboard
    [Documentation]
    ...    TC-4002: The Auto Payments (AD) tab navigation button should be visible on the dashboard.
    ...    Satisfies: TC-4002, B1
    [Tags]    dashboard    auto-debit    tab-navigation
    Wait For Elements State    ${AD_TAB}    visible    timeout=${TIMEOUT}

Auto Payments Tab Click
    [Documentation]
    ...    TC-4012: Clicking the Auto Payments tab button should update the URL hash to #ad.
    ...    Satisfies: TC-4012, U2, B1
    [Tags]    dashboard    auto-payments    tab-navigation
    Click AD Tab And Verify

AD Tab App Code Label Is Visible
    [Documentation]
    ...    TC-4036: Navigates to the Auto Payments tab and asserts the "App. Code:" label is visible.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one active AD application on UAT.
    ...    Satisfies: TC-4036
    [Tags]    dashboard    auto-payments    ui    smoke
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
    ...    "Repayment Complete", and "Student Details".
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application with detail data.
    ...    Satisfies: TC-4041
    [Tags]    dashboard    auto-payments    modal
    Click AD Tab And Verify
    AD Action Button Should Open Detail Modal

AD Detail Modal Close Button Dismisses Modal
    [Documentation]
    ...    TC-4042: After opening the first AD application's detail modal, clicking the Close
    ...    button should dismiss the modal.
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
