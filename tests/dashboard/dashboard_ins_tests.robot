*** Settings ***
Documentation
...    Insurance tab test suite for the GQ Customer Portal Dashboard (/my-applications#ins).
...    Tests the Insurance tab UI for both existing-policy users and new users.
...    Recorded in login_20260424_124334.js (existing user: 8668768645) and
...    login_20260424_121929.js (new user: 9373938938 / dynamic ${DASHBOARD_NEW_MOBILE}).
...
...    PRECONDITION:
...      - TC-4101 to TC-4111: ${INS_MOBILE} (8668768645) must have active insurance policies:
...          at least one Status: Issued and one Status: Applied.
...      - TC-4112 to TC-4115: ${DASHBOARD_NEW_MOBILE} (dynamic fresh mobile) must have no
...          insurance policies — this is guaranteed for any newly generated number.
...    A policy-card assertion failure on TC-4101–TC-4111 signals an account seeding need.
...
...    Session model:
...      Suite Setup   → Login And Navigate To Insurance Tab (login once with ${INS_MOBILE})
...      Test Setup    → Navigate To Insurance Tab (hard-nav to /my-applications + click INS tab)
...      Test Teardown → NONE (shared session preserved — no Close Context)
...      Suite Teardown → Close Browser
...    Covers: TC-4101 to TC-4111
...    Satisfies: B2 (insurance tab coverage), T1 (data-testid locators), U1 (exact assertions),
...               U2 (explicit waits), U3 (redirect and URL hash assertions), O1 (shared session)

Library          Browser
Resource         ../../resources/InsuranceDashboardPage.robot
Resource         ../../variables/variables.robot
Variables        ../../variables/dynamic_variables.py

Suite Setup      Login And Navigate To Insurance Tab
Suite Teardown   Close Browser
Test Setup       Navigate To Insurance Tab
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Dashboard    allure.label.story:Insurance Tab

*** Test Cases ***

Insurance Tab Click Updates URL Hash
    [Documentation]
    ...    Clicking the Insurance tab navigation button should update the URL hash to #ins.
    ...    Satisfies: TC-4101
    [Tags]    dashboard    insurance    navigation    smoke
    Insurance Tab URL Should Be Active

Education Banner Image Is Visible
    [Documentation]
    ...    The "Education costs illustration" image should be visible in the Insurance tab banner.
    ...    Satisfies: TC-4102
    [Tags]    dashboard    insurance    ui    banner
    Education Banner Image Should Be Visible

Education Banner Heading Is Correct
    [Documentation]
    ...    The insurance banner heading "Education costs are rising" should be visible.
    ...    Satisfies: TC-4103
    [Tags]    dashboard    insurance    ui    banner
    Education Banner Heading Should Be Correct

Education Banner Subtext Is Visible
    [Documentation]
    ...    The banner subtext "Education inflation is real." should be visible below the heading.
    ...    Satisfies: TC-4104
    [Tags]    dashboard    insurance    ui    banner
    Education Banner Subtext Should Be Visible

Guardian One Logo Is Visible
    [Documentation]
    ...    The Guardian One insurance provider logo should be visible in the banner area.
    ...    Satisfies: TC-4105
    [Tags]    dashboard    insurance    ui    banner
    Guardian One Logo Should Be Visible

Your Policies Heading Is Visible
    [Documentation]
    ...    The "Your Policies" section heading should be visible on the Insurance tab.
    ...    Satisfies: TC-4106
    [Tags]    dashboard    insurance    ui    policies
    Policies Heading Should Be Visible

Policy App ID Copy Button Is Visible
    [Documentation]
    ...    The app-id-copy-button should be visible on the first policy card.
    ...    PRECONDITION: ${INS_MOBILE} must have at least one active policy.
    ...    Satisfies: TC-4107
    [Tags]    dashboard    insurance    ui    policies
    Policy Copy Button Should Be Visible

Policy Status Issued Badge Is Visible
    [Documentation]
    ...    At least one policy card should display "Status: Issued".
    ...    PRECONDITION: ${INS_MOBILE} must have at least one issued policy.
    ...    Satisfies: TC-4108
    [Tags]    dashboard    insurance    ui    policies
    Policy Status Issued Should Be Visible

Policy Status Applied Badge Is Visible
    [Documentation]
    ...    At least one policy card should display "Status: Applied".
    ...    PRECONDITION: ${INS_MOBILE} must have at least one applied policy.
    ...    Satisfies: TC-4109
    [Tags]    dashboard    insurance    ui    policies
    Policy Status Applied Should Be Visible

Policy Download Button Is Visible And Enabled
    [Documentation]
    ...    The download button on the first policy card should be visible and enabled.
    ...    PRECONDITION: ${INS_MOBILE} must have at least one policy with a downloadable document.
    ...    Satisfies: TC-4110
    [Tags]    dashboard    insurance    ui    policies
    Policy Download Button Should Be Visible And Enabled

Calculate Now Button Opens New Tab
    [Documentation]
    ...    Clicking the "CALCULATE NOW" CTA button should open the insurance calculator
    ...    in a new browser tab. The new tab is closed after verification.
    ...    Satisfies: TC-4111
    [Tags]    dashboard    insurance    navigation    calculator
    Calculate Now Button Opens New Tab
