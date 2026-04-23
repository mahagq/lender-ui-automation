*** Settings ***
Documentation
...    Wizard Navigation Infrastructure for the GQ Customer Portal Application Creation Flow.
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    This file provides Suite Setup keywords for each wizard-page test suite.
...    Each keyword logs in with ${APP_CREATION_MOBILE}, creates a new application, and
...    navigates through all preceding wizard steps to reach the target page.
...    Traversal helpers use stub data from variables.robot (APP_* variables).
...
...    NOTE: react-select traversal uses .react-select__option (react-select library class,
...    not CSS Modules — stable across builds). This is an approved exception to the
...    data-testid-only rule (T1) for Suite Setup navigation helpers ONLY.
...    All test assertions in page resource files use data-testid exclusively.
...
...    Session model (TN1 + TN2 resolutions):
...      Suite Setup   → Navigate To <Page> (login once, traverse preceding wizard steps)
...      Test Setup    → Navigate To <Page> Within Session (Go To + wait — no new login)
...      Test Teardown → NONE (shared session preserved)
...      Suite Teardown → Close Browser
...
...    ⚡ Satisfies: RT-1 (Wizard Navigation Infrastructure), T2 (wizard session model),
...    T7 (single login per suite), S1 (auth abort-on-fail), S2 (dedicated test mobile),
...    O1 (single application per suite run), TN1 resolution, TN2 resolution

Library     Browser
Resource    LoginPage.robot
Resource    OTPPage.robot
Resource    DashboardPage.robot
Resource    StudentDetailsPage.robot
Resource    ChoosePlanPage.robot
Resource    SelectApplicantPage.robot
Resource    ApplicantBasicDetailsPage.robot
Resource    OnboardingPage.robot
Resource    ApplicantPersonalDetailsPage.robot
Resource    ApplicantResidentialDetailsPage.robot
Resource    EmploymentTypePage.robot
Resource    ApplicantEmploymentPage.robot
Resource    ConfirmApplicationPage.robot

*** Variables ***
# Wizard page URL fragments — used by Test Setup Go To calls in each test suite
${URL_STUDENT_DETAILS}          /student-details
${URL_CHOOSE_PLAN}              /choose-plan
${URL_SELECT_APPLICANT}         /select-applicant
${URL_BASIC_DETAILS}            /applicant-basic-details
${URL_ONBOARDING}               /onboarding
${URL_PERSONAL_DETAILS}         /applicant-personal-details
${URL_RESIDENTIAL_DETAILS}      /applicant-residential-details
${URL_EMPLOYMENT_TYPE}          /select-employment
${URL_EMPLOYMENT_DETAILS}       /applicant-employment-details
${URL_CONFIRM_APPLICATION}      /confirm-application

# Student details locators (traversal use)
# NOTE: testid renamed from student-details-title to gile-form-title on UAT (2026-04-23)
${SD_TITLE}                     css=[data-testid='gile-form-title']
${SD_FIRST_NAME}                css=[data-testid='first-name-input']
${SD_LAST_NAME}                 css=[data-testid='last-name-input']
${SD_STUDENT_TYPE_RADIO}        css=[data-testid='student-type-radio']
${SD_STUDENT_ID}                css=[data-testid='student-id-input']
${SD_LOAN_AMOUNT}               css=[data-testid='loan-amount-input']
# NOTE: show-plans-button uses 'testidfor' attribute, not 'data-testid'
${SD_SHOW_PLANS_BUTTON}         css=[testidfor='show-plans-button']
${SD_FORM}                      css=[data-testid='student-details-form']

# Choose Plan locators (traversal use)
${CP_PLAN_LIST}                 css=[data-testid='plan-list-container']
${CP_SUBMIT_BUTTON}             css=[data-testid='submit-plan-details-button']

# Select Applicant locators (traversal use)
${SA_PARENT_OPTION}             css=[data-testid='Parent/Guardian-0']
${SA_SUBMIT_BUTTON}             css=[data-testid='submit-applicant-type-button']

# Applicant Basic Details locators (traversal use)
${BD_FIRST_NAME}                css=[data-testid='first-name-input']
${BD_LAST_NAME}                 css=[data-testid='last-name-input']
${BD_CONSENT}                   css=[data-testid='consent-checkbox']
${BD_SUBMIT_BUTTON}             css=[data-testid='submit-button']

# Onboarding locators (traversal use)
${OB_INFO_ONE}                  css=[data-testid='onboarding-info-one']
${OB_PROCEED_BUTTON}            css=[data-testid='proceed-button']

# Personal Details locators (traversal use)
${PD_FORM}                      css=[data-testid='applicant-personal-details-form']
${PD_PAN_INPUT}                 css=[data-testid='pan-number-input']
${PD_EMAIL_INPUT}               css=[data-testid='email-input']
${PD_CONSENT}                   css=[data-testid='consent-checkbox']
${PD_PROCEED_BUTTON}            css=[data-testid='proceed-button']

# Residential Details locators (traversal use)
${RD_ADDR_LINE1}                css=[data-testid='addr-line-1-input']
${RD_ADDR_LINE2}                css=[data-testid='addr-line-2-input']
${RD_PINCODE}                   css=[data-testid='pincode-input']
${RD_RESIDENCE_TYPE_RADIO}      css=[data-testid='type-radio']
${RD_PROCEED_BUTTON}            css=[data-testid='proceed-button']

# Employment Type locators (traversal use)
${ET_SALARIED_CARD}             css=[data-testid='salaried']
${ET_SELF_EMPLOYED_CARD}        css=[data-testid='self-employed']
${ET_TITLE}                     css=[data-testid='select-employment-type-title']

# Salaried Employment Details locators (traversal use)
${SED_EMPLOYER_NAME}            css=[data-testid='employer-name-input']
${SED_SALARY}                   css=[data-testid='net-monthly-salary-input']
${SED_CONSENT}                  css=[data-testid='consent-checkbox']
${SED_PROCEED_BUTTON}           css=[data-testid='proceed-button']

# Confirm Application locators (traversal use)
${CA_FORM}                      css=[data-testid='confirm-application-form']
${CA_TITLE}                     css=[data-testid='confirm-application-title']

*** Keywords ***
Login And Create Application
    [Documentation]
    ...    Shared login step for all application-creation suite setups.
    ...    Opens browser, logs in with ${APP_CREATION_MOBILE}, handles checkMobilePost and
    ...    verifyOtpPost rate limits (same pattern as Login And Navigate To Dashboard).
    ...    Leaves browser on /my-applications (dashboard) after completion.
    ...    Satisfies: RT-1, T7, S2, TN2 resolution
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${APP_CREATION_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit in App Creation Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${APP_CREATION_MOBILE}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit in App Creation Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Enter OTP    ${TEST_OTP}
        Click Verify OTP Button
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}

Click Create Application Button And Wait For Student Details
    [Documentation]
    ...    Clicks the Create New Application button on the dashboard and waits for /student-details.
    ...    Handles two dashboard states:
    ...      (a) No applications — button is inside css=[data-testid='emi-not-data-found'] button
    ...      (b) Existing applications — button is in header, targeted via text selector
    ...    Also handles modal (existing-application confirmation modal).
    ...    NOTE: 'create-new-application-button' testid removed from UAT.
    ...    Satisfies: RT-1, TN1, O1
    Wait For Elements State    ${EMI_TAB}    visible    timeout=${TIMEOUT}
    Click    ${EMI_TAB}
    Sleep    1s
    # Try header button first (present when account has existing applications)
    ${has_header_btn}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${CREATE_APP_BUTTON}    visible    timeout=4s
    IF    ${has_header_btn}
        Click    ${CREATE_APP_BUTTON}
    ELSE
        # Fresh account (no applications) — button is in the empty-state container
        Wait For Elements State    ${CREATE_APP_BUTTON_EMPTY}    visible    timeout=${TIMEOUT}
        Click    ${CREATE_APP_BUTTON_EMPTY}
    END
    # After clicking, a "Before you proceed" dialog may appear when an in-progress application
    # exists. The dialog (Radix UI, role='dialog') has a "+ CREATE NEW APPLICATION" button.
    ${dialog_appeared}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[role='dialog']    visible    timeout=4s
    IF    ${dialog_appeared}
        Log    "Before you proceed" dialog detected — clicking Create New Application inside dialog.    console=True
        Click    css=[role='dialog'] >> text=CREATE NEW APPLICATION
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Student Details URL Should Be Active
    Wait For Elements State    ${SD_TITLE}    visible    timeout=${TIMEOUT}

Create Application And Navigate To Student Details
    [Documentation]
    ...    ⚡ BINDING CONSTRAINT — Suite Setup for student_details_tests.robot.
    ...    Logs in, creates a new application, and lands on /student-details.
    ...    Satisfies: RT-1, RT-2, T2, T7, S1, S2, O1
    Login And Create Application
    Click Create Application Button And Wait For Student Details

Navigate To Choose Plan
    [Documentation]
    ...    Suite Setup for choose_plan_tests.robot.
    ...    Traverses from login → create app → student-details (quick fill) → /choose-plan.
    ...    Uses stub data from APP_* variables. Selects first option in each GILE dropdown.
    ...    Satisfies: RT-1, RT-3
    Login And Create Application
    Click Create Application Button And Wait For Student Details
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

Navigate To Select Applicant
    [Documentation]
    ...    Suite Setup for select_applicant_tests.robot.
    ...    Traverses through student-details and choose-plan to reach /select-applicant.
    ...    Satisfies: RT-1, RT-4
    Navigate To Choose Plan
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click First Plan In List
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CP_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active

Navigate To Applicant Basic Details
    [Documentation]
    ...    Suite Setup for applicant_journey_tests.robot (basic details section).
    ...    Traverses through student-details, choose-plan, and select-applicant to reach /applicant-basic-details.
    ...    Satisfies: RT-1, RT-5
    Navigate To Select Applicant
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_PARENT_OPTION}
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

Navigate To Onboarding
    [Documentation]
    ...    Suite Setup for the Onboarding section in applicant_journey_tests.robot.
    ...    Fills basic details and proceeds to /onboarding.
    ...    Satisfies: RT-1, RT-5
    Navigate To Applicant Basic Details
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${APP_FIRST_NAME}
    Fill Text    ${BD_LAST_NAME}    ${APP_LAST_NAME}
    ${consent_checked}=    Run Keyword And Return Status
    ...    Get Property    ${BD_CONSENT}    checked
    IF    not ${consent_checked}
        Click    ${BD_CONSENT}
    END
    Click    ${BD_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}

Navigate To Personal Details
    [Documentation]
    ...    Suite Setup for the Personal Details section in applicant_journey_tests.robot.
    ...    Clicks Proceed on Onboarding to reach /applicant-personal-details.
    ...    Satisfies: RT-1, RT-5
    Navigate To Onboarding
    Click    ${OB_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}

Navigate To Residential Details
    [Documentation]
    ...    Suite Setup for the Residential Details section in applicant_journey_tests.robot.
    ...    Fills personal details with stub data and proceeds to /applicant-residential-details.
    ...    Satisfies: RT-1, RT-5
    Navigate To Personal Details
    Fill Personal Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

Navigate To Employment Type
    [Documentation]
    ...    Suite Setup for employment_tests.robot.
    ...    Traverses through all preceding wizard steps to reach /select-employment.
    ...    Satisfies: RT-1, RT-6
    Navigate To Residential Details
    Fill Residential Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Salaried Employment Details In Session
    [Documentation]
    ...    Test Setup for salaried employment tests within employment_tests.robot.
    ...    Navigates within session to /select-employment, selects Salaried, and proceeds to /applicant-employment-details.
    ...    Satisfies: RT-1, RT-6, TN3
    Go To    ${BASE_URL}${URL_EMPLOYMENT_TYPE}
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${ET_SALARIED_CARD}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active

Navigate To Self Employed Details In Session
    [Documentation]
    ...    Test Setup for self-employed tests within employment_tests.robot.
    ...    Navigates within session to /select-employment, selects Self Employed, and proceeds to /applicant-employment-details.
    ...    Satisfies: RT-1, RT-6, TN3
    Go To    ${BASE_URL}${URL_EMPLOYMENT_TYPE}
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${ET_SELF_EMPLOYED_CARD}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active

Navigate To Confirm Application
    [Documentation]
    ...    Suite Setup for confirm_application_tests.robot.
    ...    Traverses through all wizard steps including salaried employment to reach /confirm-application.
    ...    Satisfies: RT-1, RT-7
    Navigate To Employment Type
    Navigate To Salaried Employment Details In Session
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${APP_EMPLOYER_NAME}
    Fill Text    ${SED_SALARY}    ${APP_MONTHLY_SALARY}
    ${consent_checked}=    Run Keyword And Return Status
    ...    Get Property    ${SED_CONSENT}    checked
    IF    not ${consent_checked}
        Click    ${SED_CONSENT}
    END
    Click    ${SED_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}

# --- Within-session navigation (Test Setup keywords) ---

Navigate To Student Details Within Session
    [Documentation]
    ...    Test Setup for student_details_tests.robot.
    ...    Hard-navigates to /student-details within the active wizard session.
    ...    Requires app_code in localStorage (set by Suite Setup).
    ...    Satisfies: TN1 resolution, T3
    Go To    ${BASE_URL}${URL_STUDENT_DETAILS}
    Wait For Elements State    ${SD_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Student Details With GILE Filled
    [Documentation]
    ...    Test Setup for student_details tests that require the personal details section
    ...    to be visible (first-name, last-name, student-type-radio, class, student-id,
    ...    loan-amount). These fields only appear after GILE dropdowns are filled.
    ...    Navigates to /student-details and fills all four GILE dropdowns.
    ...    Satisfies: TN1 resolution, T3
    Go To    ${BASE_URL}${URL_STUDENT_DETAILS}
    Wait For Elements State    ${SD_TITLE}    visible    timeout=${TIMEOUT}
    Search And Select First Option In React Select    institute-id-react-select    ${APP_INSTITUTE_SEARCH}
    Select First Option In React Select    location-id-react-select
    Select First Option In React Select    board-id-react-select
    Select First Option In React Select    academic-year-id-react-select
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}

Navigate To Student Details With All Fields Filled
    [Documentation]
    ...    Test Setup for TC-5014 — navigates to /student-details and fills all GILE and
    ...    personal detail fields WITHOUT clicking Show Plans.
    ...    Uses Go To + GILE fill. show-plans-button uses 'testidfor' attribute (not
    ...    data-testid) so it is findable after form completion regardless of navigation path.
    ...    Satisfies: TN1 resolution, T3
    Go To    ${BASE_URL}${URL_STUDENT_DETAILS}
    Wait For Elements State    ${SD_TITLE}    visible    timeout=${TIMEOUT}
    Search And Select First Option In React Select    institute-id-react-select    ${APP_INSTITUTE_SEARCH}
    Select First Option In React Select    location-id-react-select
    Select First Option In React Select    board-id-react-select
    Select First Option In React Select    academic-year-id-react-select
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${SD_FIRST_NAME}    ${APP_STUDENT_FIRST_NAME}
    Fill Text    ${SD_LAST_NAME}    ${APP_STUDENT_LAST_NAME}
    Click    ${SD_STUDENT_TYPE_RADIO} >> nth=0
    Sleep    500ms
    Select First Option In React Select    class-id-react-select
    Fill Text    ${SD_LOAN_AMOUNT}    ${APP_LOAN_AMOUNT}

Navigate To Choose Plan Within Session
    [Documentation]
    ...    Test Setup for choose_plan_tests.robot.
    ...    Hard-navigates to /choose-plan within the active wizard session.
    Go To    ${BASE_URL}${URL_CHOOSE_PLAN}
    Wait For Elements State    css=[data-testid='choose-plan-title']    visible    timeout=${TIMEOUT}

Navigate To Select Applicant Within Session
    [Documentation]
    ...    Test Setup for select_applicant_tests.robot.
    ...    Hard-navigates to /select-applicant within the active wizard session.
    Go To    ${BASE_URL}${URL_SELECT_APPLICANT}
    Wait For Elements State    css=[data-testid='select-applicant-title']    visible    timeout=${TIMEOUT}

Navigate To Basic Details Within Session
    [Documentation]
    ...    Test Setup for applicant_journey_tests.robot (basic details section).
    Go To    ${BASE_URL}${URL_BASIC_DETAILS}
    Wait For Elements State    css=[data-testid='applicant-basic-details-title']    visible    timeout=${TIMEOUT}

Navigate To Employment Type Within Session
    [Documentation]
    ...    Test Setup for employment type tests in employment_tests.robot.
    Go To    ${BASE_URL}${URL_EMPLOYMENT_TYPE}
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Confirm Application Within Session
    [Documentation]
    ...    Test Setup for confirm_application_tests.robot.
    ...    Hard-navigates to /confirm-application within the active wizard session.
    Go To    ${BASE_URL}${URL_CONFIRM_APPLICATION}
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}

# --- Traversal stub fill helpers ---

Select First Option In React Select
    [Documentation]
    ...    Traversal helper — clicks a react-select container and selects the first option.
    ...    Uses keyboard navigation (Down + Enter) because react-select renders options in a
    ...    portal outside the container div — scoped CSS selectors cannot target them.
    ...    This is an approved T1 exception for Suite Setup traversal helpers only.
    ...    Satisfies: TN1 (wizard traversal cost), RT-1
    [Arguments]    ${testid}
    Click    css=[data-testid='${testid}']
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Search And Select First Option In React Select
    [Documentation]
    ...    Traversal helper for async/search react-select dropdowns (e.g., institute search).
    ...    Types a search term, waits for options to load from the API, then selects the first.
    ...    Uses ${LONG_TIMEOUT} for the API response wait.
    ...    This is an approved T1 exception for Suite Setup traversal helpers only.
    ...    Satisfies: TN1 (wizard traversal cost), RT-1
    [Arguments]    ${testid}    ${search_term}
    Click    css=[data-testid='${testid}'] input[role='combobox']
    Type Text    css=[data-testid='${testid}'] input[role='combobox']    ${search_term}
    Sleep    2s    # Wait for async API search results to load
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Fill Student Details With Stub Data
    [Documentation]
    ...    Quick-fill the student details wizard step with APP_* stub variables.
    ...    Selects first option in each GILE dropdown and the first radio.
    ...    Calls Show Plans to proceed to /choose-plan.
    ...    Satisfies: RT-1 (traversal infrastructure)
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    # Institute: async search — type search term then select first result
    Search And Select First Option In React Select    institute-id-react-select    ${APP_INSTITUTE_SEARCH}
    # Location, board, academic year become enabled after institute selection
    Select First Option In React Select    location-id-react-select
    Select First Option In React Select    board-id-react-select
    Select First Option In React Select    academic-year-id-react-select
    # Wait for personal details section to appear after GILE selection
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}
    # Student personal details
    Fill Text    ${SD_FIRST_NAME}    ${APP_STUDENT_FIRST_NAME}
    Fill Text    ${SD_LAST_NAME}    ${APP_STUDENT_LAST_NAME}
    Click    ${SD_STUDENT_TYPE_RADIO} >> nth=0
    # Class dropdown (keyboard nav — also uses portal)
    Click    css=[data-testid='class-id-react-select']
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter
    Fill Text    ${SD_STUDENT_ID}    SD12345
    Fill Text    ${SD_LOAN_AMOUNT}    ${APP_LOAN_AMOUNT}
    # Click Show Plans to advance to /choose-plan
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}

Click First Plan In List
    [Documentation]
    ...    Traversal helper — clicks the first available plan in the plan list container.
    ...    The plan list renders items with dynamic testids (index-planId).
    ...    Uses >> nth=0 to select the first child of the list container.
    ...    Satisfies: RT-1 (traversal)
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click    ${CP_PLAN_LIST} >> nth=0

Fill Personal Details With Stub Data
    [Documentation]
    ...    Quick-fill personal details with APP_* stub variables.
    ...    Selects first option for gender, DOB (year/month/day), and marital status.
    ...    Satisfies: RT-1 (traversal)
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}
    Fill Text    ${PD_PAN_INPUT}    ${APP_PAN_NUMBER}
    Sleep    2s    # Wait for PAN lookup to complete
    # Gender react-select
    Select First Option In React Select    gender-react-select
    # Date of birth — year/month/day react-selects
    Select First Option In React Select    year-react-select
    Select First Option In React Select    month-react-select
    Select First Option In React Select    day-react-select
    # Marital status radio
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Text    ${PD_EMAIL_INPUT}    ${APP_EMAIL}
    ${consent_checked}=    Run Keyword And Return Status
    ...    Get Property    ${PD_CONSENT}    checked
    IF    not ${consent_checked}
        Click    ${PD_CONSENT}
    END
    Click    ${PD_PROCEED_BUTTON}

Fill Residential Details With Stub Data
    [Documentation]
    ...    Quick-fill residential details with APP_* stub variables.
    ...    Satisfies: RT-1 (traversal)
    Wait For Elements State    ${RD_ADDR_LINE1}    visible    timeout=${TIMEOUT}
    Fill Text    ${RD_ADDR_LINE1}    ${APP_ADDRESS_LINE1}
    Fill Text    ${RD_ADDR_LINE2}    ${APP_ADDRESS_LINE2}
    Fill Text    ${RD_PINCODE}    ${APP_PINCODE}
    Sleep    2s    # Wait for city/state to auto-populate from pincode
    Click    ${RD_RESIDENCE_TYPE_RADIO} >> nth=0
    Click    ${RD_PROCEED_BUTTON}
