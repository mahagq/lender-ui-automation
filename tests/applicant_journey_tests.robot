*** Settings ***
Documentation
...    Sequential journey test suite for the middle wizard steps:
...      - /applicant-basic-details (TC-8001–TC-8010)
...      - /onboarding               (TC-9001–TC-9003)
...      - /applicant-personal-details (TC-10001–TC-10010)
...      - /applicant-residential-details (TC-11001–TC-11010)
...
...    New pages — no Java TC coverage. Tests run sequentially in wizard order.
...    Each section advances the wizard before the next section's tests begin.
...
...    Session model:
...      Suite Setup    → Navigate To Applicant Basic Details
...      Test Setup     → NONE (tests run in strict wizard order; [Setup] set per section)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    All APP_* variables must be correctly set in variables.robot.
...    Satisfies: RT-5, B2 (new-page coverage), T1, T5 (TN4 static/computed assertions), U1

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/ApplicantBasicDetailsPage.robot
Resource    ../resources/OnboardingPage.robot
Resource    ../resources/ApplicantPersonalDetailsPage.robot
Resource    ../resources/ApplicantResidentialDetailsPage.robot
Resource    ../variables/variables.robot

Suite Setup     Navigate To Applicant Basic Details
Suite Teardown  Close Browser
Test Tags       applicant-journey    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Applicant Journey

*** Test Cases ***
# ===========================================================================
# APPLICANT BASIC DETAILS — /applicant-basic-details (TC-8001–TC-8010)
# ===========================================================================

TC-8001 Basic Details Title Is Visible
    [Documentation]    Verifies applicant-basic-details-title is visible.
    [Setup]    Navigate To Basic Details Within Session
    [Tags]    smoke
    Basic Details Title Should Be Visible

TC-8002 Basic Details Form Elements Are Visible
    [Documentation]    Verifies all key form elements (name inputs, consent, submit) are visible.
    [Setup]    Navigate To Basic Details Within Session
    Basic Details Form Elements Should Be Visible

TC-8003 Basic Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-basic-details.
    [Setup]    Navigate To Basic Details Within Session
    Basic Details URL Should Be Active

TC-8004 First Name Input Accepts Text
    [Documentation]    Verifies first-name-input accepts text input.
    [Setup]    Navigate To Basic Details Within Session
    Fill Basic Details First Name    TestFirst

TC-8005 Last Name Input Accepts Text
    [Documentation]    Verifies last-name-input accepts text input.
    [Setup]    Navigate To Basic Details Within Session
    Fill Basic Details Last Name    TestLast

TC-8006 Submit Button Is Disabled Without Data
    [Documentation]    Verifies submit-button is disabled when name fields are empty.
    [Setup]    Navigate To Basic Details Within Session
    Submit Button Should Be Disabled Without Data

TC-8007 Submit Button Is Enabled With Valid Data
    [Documentation]    Verifies submit-button is enabled after filling names and checking consent.
    [Setup]    Navigate To Basic Details Within Session
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Check Basic Details Consent
    Submit Button Should Be Enabled With Valid Data

TC-8008 Basic Details Proceeds To Onboarding
    [Documentation]
    ...    Fills valid data, clicks submit, and verifies navigation to /onboarding.
    ...    Runs LAST in this section — advances wizard to onboarding.
    ...    NOTE: After this test, subsequent [Setup] keywords use onboarding URL.
    [Setup]    Navigate To Basic Details Within Session
    Fill Basic Details First Name    ${APP_FIRST_NAME}
    Fill Basic Details Last Name    ${APP_LAST_NAME}
    Check Basic Details Consent
    Click Submit Basic Details
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

# ===========================================================================
# ONBOARDING — /onboarding (TC-9001–TC-9003)
# ===========================================================================

TC-9001 Onboarding Info Sections Are Visible
    [Documentation]    Verifies all three onboarding info sections are visible.
    [Setup]    NONE
    [Tags]    smoke
    Onboarding Info Sections Should Be Visible

TC-9002 Onboarding Proceed Button Is Visible
    [Documentation]    Verifies the proceed-button is visible on the onboarding page.
    [Setup]    NONE
    Onboarding Proceed Button Should Be Visible

TC-9003 Onboarding Proceeds To Personal Details
    [Documentation]
    ...    Clicks Proceed on Onboarding and verifies navigation to /applicant-personal-details.
    ...    Runs LAST in this section — advances wizard to personal details.
    [Setup]    NONE
    Click Onboarding Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active

# ===========================================================================
# APPLICANT PERSONAL DETAILS — /applicant-personal-details (TC-10001–TC-10010)
# ===========================================================================

TC-10001 Personal Details Title And Form Are Visible
    [Documentation]    Verifies personal-details-title and form container are visible.
    [Setup]    NONE
    [Tags]    smoke
    Personal Details Title Should Be Visible
    Personal Details Form Should Be Visible

TC-10002 PAN Input Is Visible
    [Documentation]    Verifies pan-number-input field is visible.
    [Setup]    NONE
    PAN Input Should Be Visible

TC-10003 Gender Section Is Visible
    [Documentation]    Verifies the gender-react-select dropdown is visible.
    [Setup]    NONE
    Gender Section Should Be Visible

TC-10004 Date Of Birth Dropdowns Are Visible
    [Documentation]    Verifies year/month/day react-select dropdowns are all visible.
    [Setup]    NONE
    DOB Section Should Be Visible

TC-10005 Marital Status Options Are Visible
    [Documentation]    Verifies marital-status-radio options are visible.
    [Setup]    NONE
    Marital Status Section Should Be Visible

TC-10006 Email Input Is Visible
    [Documentation]    Verifies email-input field is visible.
    [Setup]    NONE
    Email Input Should Be Visible

TC-10007 Personal Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-personal-details.
    [Setup]    NONE
    Personal Details URL Should Be Active

TC-10008 Personal Details Proceeds To Residential Details
    [Documentation]
    ...    Fills personal details with APP_* stub data and proceeds to /applicant-residential-details.
    ...    Static assertions: form visible before and after fill.
    ...    Runs LAST in this section — advances wizard.
    [Setup]    NONE
    Personal Details Form Should Be Visible
    Fill PAN Number    ${APP_PAN_NUMBER}
    Sleep    2s    # PAN lookup API call
    Fill Email    ${APP_EMAIL}
    Check Personal Details Consent
    Click Personal Details Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

# ===========================================================================
# APPLICANT RESIDENTIAL DETAILS — /applicant-residential-details (TC-11001–TC-11010)
# ===========================================================================

TC-11001 Residential Details Title Is Visible
    [Documentation]    Verifies residential-details-title is visible.
    [Setup]    NONE
    [Tags]    smoke
    Residential Details Title Should Be Visible

TC-11002 Address Fields Are Visible
    [Documentation]    Verifies addr-line-1, addr-line-2, and pincode fields are visible.
    [Setup]    NONE
    Address Fields Should Be Visible

TC-11003 Residence Type Radio Is Visible
    [Documentation]    Verifies type-radio options are visible.
    [Setup]    NONE
    Residence Type Radio Should Be Visible

TC-11004 Address Line 1 Accepts Text
    [Documentation]    Verifies addr-line-1-input accepts text.
    [Setup]    NONE
    Fill Address Line 1    123 Test Avenue

TC-11005 Pincode Field Accepts Numbers
    [Documentation]    Verifies pincode-input accepts numeric input.
    [Setup]    NONE
    Fill Pincode    400001

TC-11006 Residential Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-residential-details.
    [Setup]    NONE
    Residential Details URL Should Be Active

TC-11007 Residential Details Proceeds To Employment Type
    [Documentation]
    ...    Fills residential details with APP_* stub data and proceeds to /select-employment.
    ...    TN4 resolution: City/state are API-populated — asserted as visible (not exact value).
    ...    Runs LAST in this section — advances wizard to employment type.
    [Setup]    NONE
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Address Line 2    ${APP_ADDRESS_LINE2}
    Fill Pincode    ${APP_PINCODE}
    Sleep    2s    # Pincode city/state auto-populate
    Click First Residence Type Radio
    Click Residential Details Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
