*** Settings ***
Documentation
...    Independent test suite for the GQ Customer Portal Applicant Personal Details page (/applicant-personal-details).
...    All tests are self-contained — no dependency on applicant_journey_tests.robot.
...
...    Session model:
...      Suite Setup    → Navigate To Personal Details (full wizard traversal to /applicant-personal-details)
...      Test Setup     → Navigate To Personal Details Within Session (Go To)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    TC-10008 (proceed → /applicant-residential-details) runs LAST.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-5, T1, U1, U2

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/ApplicantPersonalDetailsPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Personal Details
Suite Teardown  Close Browser
Test Setup      Navigate To Personal Details Within Session
Test Tags       personal-details    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Applicant Personal Details

*** Test Cases ***
TC-10001 Personal Details Title And Form Are Visible
    [Documentation]    Verifies personal-details-title and form container are visible.
    [Tags]    smoke
    Personal Details Title Should Be Visible
    Personal Details Form Should Be Visible

TC-10002 PAN Input Is Visible
    [Documentation]    Verifies pan-number-input field is visible.
    PAN Input Should Be Visible

TC-10003 Gender Section Is Visible
    [Documentation]    Verifies the gender-react-select dropdown is visible.
    Gender Section Should Be Visible

TC-10004 Date Of Birth Dropdowns Are Visible
    [Documentation]    Verifies year/month/day react-select dropdowns are all visible.
    DOB Section Should Be Visible

TC-10005 Marital Status Options Are Visible
    [Documentation]    Verifies marital-status-radio options are visible.
    Marital Status Section Should Be Visible

TC-10006 Email Input Is Visible
    [Documentation]    Verifies email-input field is visible.
    Email Input Should Be Visible

TC-10007 Personal Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-personal-details.
    Personal Details URL Should Be Active

TC-10N-01 Submit Empty PAN Shows PAN Error And User Cannot Proceed
    [Documentation]
    ...    Verifies clicking proceed with empty PAN shows pan-number-input-error
    ...    and user stays on /applicant-personal-details.
    [Tags]    negative
    Fill PAN Number    ${EMPTY}
    Click Personal Details Proceed
    PAN Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-02 Invalid PAN Format Shows PAN Error
    [Documentation]
    ...    Verifies pan-number-input-error appears when PAN has wrong format
    ...    (valid PAN: 5 letters + 4 digits + 1 letter, e.g. ABCDE1234F).
    [Tags]    negative
    Fill PAN Number    12345ABCDE
    PAN Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-03 PAN With Special Characters Shows PAN Error
    [Documentation]    Verifies pan-number-input-error appears when PAN contains special characters.
    [Tags]    negative
    Fill PAN Number    ABCDE@#$%F
    PAN Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-04 Submit Empty Email Shows Email Error And User Cannot Proceed
    [Documentation]
    ...    Verifies clicking proceed with empty email shows email-input-error
    ...    and user stays on /applicant-personal-details.
    ...    Consent must be checked — if both email and consent are missing the form shows consent error first.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    ${EMPTY}
    Check Personal Details Consent
    Click Personal Details Proceed
    Email Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-05 Email Missing At Symbol Shows Email Error
    [Documentation]    Verifies email-input-error appears when email is missing the @ symbol.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    invalidemail.com
    Click Personal Details Proceed
    Email Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-06 Email Without Domain Shows Email Error
    [Documentation]    Verifies email-input-error appears when email has no domain (e.g. test@).
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    test@
    Click Personal Details Proceed
    Email Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-07 Valid Data Without Consent Shows Consent Error And User Cannot Proceed
    [Documentation]
    ...    Verifies that clicking proceed with valid PAN and email but consent unchecked
    ...    shows consent-checkbox-error and user stays on /applicant-personal-details.
    ...    Proceed button is enabled without consent — consent error appears on click.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    ${APP_EMAIL}
    Uncheck Personal Details Consent
    Click Personal Details Proceed
    Personal Details Consent Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-08 Submit Without Gender Shows Gender Error
    [Documentation]
    ...    Verifies gender-error appears when proceed is clicked without selecting a gender.
    ...    All other required fields (PAN, DOB, marital status, email, consent) are filled.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    ${APP_EMAIL}
    Check Personal Details Consent
    Click Personal Details Proceed
    Gender Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-09 Submit Without DOB Shows DOB Error
    [Documentation]
    ...    Verifies dob-error appears when proceed is clicked without selecting any date of birth.
    ...    All other required fields (PAN, gender, marital status, email, consent) are filled.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    ${APP_EMAIL}
    Check Personal Details Consent
    Click Personal Details Proceed
    DOB Error Should Be Visible
    Personal Details URL Should Be Active

TC-10N-10 Submit Without Marital Status Shows Marital Status Error
    [Documentation]
    ...    Verifies marital-status-error appears when proceed is clicked without selecting a marital status.
    ...    All other required fields (PAN, gender, DOB, email, consent) are filled.
    [Tags]    negative
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Fill Email    ${APP_EMAIL}
    Check Personal Details Consent
    Click Personal Details Proceed
    Marital Status Error Should Be Visible
    Personal Details URL Should Be Active

TC-10008 Personal Details Proceeds To Residential Details
    [Documentation]
    ...    Fills personal details with APP_* stub data and proceeds to /applicant-residential-details.
    ...    Runs LAST — advances wizard past personal details.
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s    # PAN lookup API call
    Select Gender Male
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Email    ${APP_EMAIL}
    Check Personal Details Consent
    Click Personal Details Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active
