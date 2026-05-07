*** Settings ***
Documentation
...    Resume Journey E2E tests — Renewal flow.
...    Verifies that clicking Close at each renewal wizard page and resuming via
...    the EMI card "Verify Now" button resumes at the correct page.
...
...    Uses ${RENEWAL_MOBILE} — must be an existing account with prior completed
...    applications so the wizard routes through the renewal path
...    (/renewal-confirmation, /renewal-details) instead of the standard ACF path.
...
...    Single shared browser session throughout — no browser reopen between tests.
...    Suite Setup creates a new renewal application and lands on /student-details.
...
...    Resume pattern per test:
...      1. Advance to target page
...      2. Click Wizard Close Button (wizard exit → dashboard)
...      3. Resume In Progress Application Via EMI Card (clicks "Verify Now" on EMI card)
...      4. Assert wizard resumes on the correct URL
...
...    Tests are SEQUENTIAL — each test continues from where the previous test's resume left off.
...    All tests use [Setup] NONE.
...
...    Note: TC-RER04 (close at /renewal-details without edits) may resume at
...    /renewal-confirmation instead of /renewal-details depending on backend wizard state
...    tracking. Assertion will be adjusted after first run if needed.
...
...    Run:
...      ./env/bin/robot --outputdir results/ tests/e2e/resume_journey_renewal_e2e_tests.robot
...
...    Tags: e2e, resume, renewal

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Create Application For Renewal Resume Tests
Suite Teardown  Close Browser
Test Tags       e2e    resume    renewal

*** Test Cases ***
TC-RER01 Resume At Student Details
    [Documentation]    Fill student details (no proceed). Close → dashboard. Resume via Verify Now → student details.
    [Setup]    NONE
    Fill Student Details Data
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active

TC-RER02 Resume At Choose Plan
    [Documentation]    Fill student details + proceed → choose plan. Close → dashboard. Resume via Verify Now → choose plan.
    [Setup]    NONE
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

TC-RER03 Resume At Welcome Back
    [Documentation]    Select plan → renewal-confirmation (Welcome Back). Close → dashboard. Resume via Verify Now → welcome back.
    [Setup]    NONE
    Click First Plan In List
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Welcome Back Screen URL Should Be Correct
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Welcome Back Screen URL Should Be Correct

TC-RER04 Close At Verify Details Resumes At Welcome Back
    [Documentation]    Continue on welcome-back → verify-details (no edits). Close → dashboard. Backend resumes at /renewal-confirmation (same pattern as personal-details → onboarding).
    [Setup]    NONE
    Click Continue With These Details
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Verify Details URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Welcome Back Screen URL Should Be Correct

TC-RER05 Resume At Confirm Application
    [Documentation]    From welcome-back, continue → verify-details → confirm and proceed → confirm application. Close → dashboard. Resume via Verify Now → confirm application.
    [Setup]    NONE
    Click Continue With These Details
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Verify Details URL Should Be Active
    Click    text=CONFIRM AND PROCEED
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Handle Referral Code Popup If Present
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
