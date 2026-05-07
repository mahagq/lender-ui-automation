*** Settings ***
Documentation
...    Resume Journey E2E tests — Self-Employed variant.
...    Verifies that closing at each SE-relevant wizard page and resuming via
...    the EMI card "Verify Now" button resumes at the correct page.
...
...    Uses ${APP_CREATION_MOBILE} (fresh account each run) — completely independent
...    of resume_journey_e2e_tests.robot (salaried flow) to avoid cross-contamination.
...
...    Suite Setup traverses all wizard steps (student-details → residential-details)
...    and lands on /select-employment ready for TC-RESE01.
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
...    Run:
...      ./env/bin/robot --outputdir results/ tests/e2e/resume_journey_se_e2e_tests.robot
...
...    Tags: e2e, resume, self-employed

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Create Application For SE Resume Tests
Suite Teardown  Close Browser
Test Tags       e2e    resume    self-employed

*** Test Cases ***
TC-RESE01 Close At SE Employment Details Resumes At Employment Type
    [Documentation]    Select self-employed → employment details (no data filled). Close → dashboard. Backend resumes at /select-employment (same pattern as salaried TC-RE08).
    [Setup]    NONE
    Select Self Employed And Wait For Employment Details
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

TC-RESE02 Resume At Confirm Application Via SE Employment
    [Documentation]    From /select-employment, select self-employed → fill SE details → proceed → confirm application. Close → dashboard. Resume via Verify Now → confirm application.
    [Setup]    NONE
    Select Self Employed And Wait For Employment Details
    Fill SE Employment Data And Proceed
    Click Wizard Close Button
    Resume In Progress Application Via EMI Card
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
