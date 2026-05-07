*** Settings ***
Documentation
...    Resume Journey E2E tests — verifies that clicking Close at each wizard page
...    and resuming via the EMI card "Verify Now" button resumes at the correct page.
...
...    Uses ${APP_CREATION_MOBILE} (fresh account each run).
...    Single shared browser session throughout — no browser reopen between tests.
...    Suite Setup creates a fresh application and lands on /student-details.
...
...    Resume pattern per test:
...      1. Advance to target page (fill/proceed from previous page state)
...      2. Click Wizard Close Button (wizard exit → dashboard)
...      3. Resume In Progress Application Via EMI Card (clicks "Verify Now" on EMI card)
...      4. Assert wizard resumes on the correct URL
...
...    Tests are SEQUENTIAL — each test continues from where the previous test's resume left off.
...    All tests use [Setup] NONE.
...
...    Note: /select-applicant is skipped for fresh APP_CREATION_MOBILE accounts.
...    TC-RE03 covers Basic Details as the natural first stop after plan selection.
...    TC-RE08 covers Employment Details as its own close/resume step.
...
...    Run:
...      ./env/bin/robot --outputdir results/ tests/e2e/resume_journey_e2e_tests.robot
...
...    Tags: e2e, resume

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Create Application For Resume Tests
Suite Teardown  Close Browser
Test Tags       e2e    resume

*** Test Cases ***
TC-RE01 Resume At Student Details
    [Documentation]    Fill all student details (GILE + personal info) then Close → dashboard. Resume via Verify Now → student details.
    [Setup]    NONE
    Fill Student Details Data
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active

TC-RE02 Resume At Choose Plan
    [Documentation]    Fill student details + proceed → choose plan. Close → dashboard. Resume via Verify Now → choose plan.
    [Setup]    NONE
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

TC-RE03 Resume At Basic Details
    [Documentation]    Select plan + submit → basic details (wizard skips select-applicant for fresh accounts). Close → dashboard. Resume via Verify Now → basic details.
    [Setup]    NONE
    Select Plan And Wait For Basic Details
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

TC-RE04 Resume At Onboarding
    [Documentation]    Fill basic details → onboarding. Close → dashboard. Resume via Verify Now → onboarding.
    [Setup]    NONE
    Fill And Submit Basic Details
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

TC-RE05 Close At Personal Details Resumes At Onboarding
    [Documentation]    Backend does not record /personal-details as a resume position. Closing there always resumes at /onboarding. Verifies actual backend behaviour.
    [Setup]    NONE
    Click Onboarding Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

TC-RE06 Resume At Residential Details
    [Documentation]    From onboarding, proceed → fill+submit personal details → residential details. Close → dashboard. Resume via Verify Now → residential details.
    [Setup]    NONE
    Click Onboarding Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Fill Personal Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

TC-RE07 Resume At Employment Type
    [Documentation]    Fill residential details → employment type. Close → dashboard. Resume via Verify Now → employment type.
    [Setup]    NONE
    Fill Residential Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

TC-RE08 Close At Employment Details Resumes At Employment Type
    [Documentation]    Select salaried → employment details (no data filled). Close → dashboard. Backend resumes at /select-employment (same pattern as personal-details → onboarding).
    [Setup]    NONE
    Select Salaried And Wait For Employment Details
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

TC-RE09 Resume At Confirm Application
    [Documentation]    Fill salaried employment + proceed → confirm application. Close → dashboard. Resume via Verify Now → confirm application.
    [Setup]    NONE
    Select Salaried And Wait For Employment Details
    Fill Salaried Employment Data And Proceed
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
