*** Settings ***
Documentation
...    Resume Journey E2E tests — verifies that closing the browser at each wizard page
...    and re-logging in resumes the application at the correct page.
...
...    Uses ${RESUME_MOBILE} — a UAT account kept perpetually in-progress
...    (the application is never submitted so the resume dialog always appears).
...
...    Session model per test:
...      1. Login with ${RESUME_MOBILE}
...      2. Navigate to the target page within the existing in-progress session
...      3. Close browser
...      4. New browser → re-login with ${RESUME_MOBILE}
...      5. Click header "Create new application" → "Before you proceed" dialog
...      6. Click "CONTINUE EXISTING APPLICATION"
...      7. Assert wizard resumes on the correct URL / element
...
...    Run:
...      ./venv/bin/robot --outputdir results/ tests/e2e/resume_journey_e2e_tests.robot
...
...    Tags: e2e, resume

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../variables/variables.robot

Suite Setup     Login With Resume Mobile
Suite Teardown  Close Browser
Test Tags       e2e    resume    robot:skip

*** Keywords ***
Login With Resume Mobile
    [Documentation]    Opens browser and logs in with ${RESUME_MOBILE}.
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${RESUME_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Go To    ${BASE_URL}
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${RESUME_MOBILE}
        Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    END
    Submit OTP Form    ${TEST_OTP}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Close And Relogin With Resume Mobile
    [Documentation]    Closes current browser, opens a new one, and logs back in with ${RESUME_MOBILE}.
    Close Browser
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${RESUME_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Go To    ${BASE_URL}
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${RESUME_MOBILE}
        Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    END
    Submit OTP Form    ${TEST_OTP}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

*** Test Cases ***
TC-RE01 Resume At Student Details
    [Documentation]    Close browser at /student-details and verify resume lands back on /student-details.
    [Setup]    Navigate To Student Details Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active

TC-RE02 Resume At Choose Plan
    [Documentation]    Close browser at /choose-plan and verify resume lands back on /choose-plan.
    [Setup]    Navigate To Choose Plan Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

TC-RE03 Resume At Select Applicant
    [Documentation]    Close browser at /select-applicant and verify resume lands back on /select-applicant.
    [Setup]    Navigate To Select Applicant Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active

TC-RE04 Resume At Basic Details
    [Documentation]    Close browser at /applicant-basic-details and verify resume returns there.
    [Setup]    Navigate To Basic Details Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

TC-RE05 Resume At Onboarding
    [Documentation]    Close browser at /onboarding and verify resume returns there.
    [Setup]    Navigate To Onboarding Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

TC-RE06 Resume At Personal Details
    [Documentation]    Close browser at /applicant-personal-details and verify resume returns there.
    [Setup]    Navigate To Personal Details Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active

TC-RE07 Resume At Residential Details
    [Documentation]    Close browser at /applicant-residential-details and verify resume returns there.
    [Setup]    Navigate To Residential Details Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

TC-RE08 Resume At Employment Type
    [Documentation]    Close browser at /select-employment and verify resume returns there.
    [Setup]    Navigate To Employment Type Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

TC-RE09 Resume At Confirm Application
    [Documentation]    Close browser at /confirm-application and verify resume returns there.
    [Setup]    Navigate To Confirm Application Within Session
    Close And Relogin With Resume Mobile
    Resume In Progress Application
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
