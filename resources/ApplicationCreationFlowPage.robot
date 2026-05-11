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
...    NOTE: react-select traversal uses role=option (ARIA role, stable across builds and
...    react-select versions — works with both v4 class-based and v5 Emotion CSS naming).
...    This is an approved exception to the data-testid-only rule (T1) for traversal helpers ONLY.
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
Resource    WelcomeBackPage.robot
Resource    VerifyDetailsPage.robot
Resource    LenderSelectionPage.robot
Resource    OKYCPage.robot
Resource    BankStatementPage.robot

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
${SED_PROCEED_BUTTON}           role=button[name=Proceed]

# Self-Employed Details locators (traversal use)
${SE_BUSINESS_NAME}             css=[data-testid='business-name-input']
${SE_ANNUAL_INCOME}             css=[data-testid='business-annual-income-input']
${SE_YEARS}                     css=[data-testid='years-of-current-business-input']
${SE_DESCRIPTION}               css=[data-testid='business-description-input']
${SE_PROCEED_BUTTON}            role=button[name=Proceed]

# Confirm Application locators (traversal use)
${CA_FORM}                      css=[data-testid='confirm-application-form']
${CA_TITLE}                     css=[data-testid='confirm-application-title']

*** Keywords ***
Login And Create Application
    [Arguments]    ${mobile}=${APP_CREATION_MOBILE}
    [Documentation]
    ...    Shared login step for all application-creation suite setups.
    ...    Opens browser, logs in with ${mobile} (defaults to ${APP_CREATION_MOBILE}), handles
    ...    checkMobilePost and verifyOtpPost rate limits (same pattern as Login And Navigate To Dashboard).
    ...    Leaves browser on /my-applications (dashboard) after completion.
    ...    Satisfies: RT-1, T7, S2, TN2 resolution
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit in App Creation Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${mobile}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit in App Creation Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        ${url_after}=    Get Url
        IF    '/my-applications' in '${url_after}'
            No Operation    # already on dashboard — OTP succeeded during sleep
        ELSE IF    '/verify' in '${url_after}'
            Enter OTP    ${TEST_OTP}
            Click Verify OTP Button
        ELSE
            Submit Login Form    ${mobile}
            Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
            Submit OTP Form    ${TEST_OTP}
        END
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
    ...    If the wizard skips /select-applicant (applicant type already set on the account),
    ...    falls back to a direct URL navigation.
    ...    Satisfies: RT-1, RT-4
    Navigate To Choose Plan
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click First Plan In List
    Wait For Elements State    ${CP_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CP_SUBMIT_BUTTON}
    ${on_select_applicant}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    10s    500ms    Select Applicant URL Should Be Active
    IF    not ${on_select_applicant}
        Log    Wizard skipped /select-applicant — falling back to direct navigation.    console=True
        Navigate To Select Applicant Within Session
    END

Navigate To Applicant Basic Details
    [Documentation]
    ...    Suite Setup for applicant_basic_details_tests.robot.
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
    ...    Suite Setup for onboarding_tests.robot.
    ...    Fills basic details and proceeds to /onboarding.
    ...    Satisfies: RT-1, RT-5
    Navigate To Applicant Basic Details
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${APP_FIRST_NAME}
    Fill Text    ${BD_LAST_NAME}    ${APP_LAST_NAME}
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    not ${checked}
        Click    ${BD_CONSENT}
    END
    Click    ${BD_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}

Navigate To Personal Details
    [Documentation]
    ...    Suite Setup for personal_details_tests.robot.
    ...    Clicks Proceed on Onboarding to reach /applicant-personal-details.
    ...    Satisfies: RT-1, RT-5
    Navigate To Onboarding
    Click    ${OB_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}

Navigate To Residential Details
    [Documentation]
    ...    Suite Setup for residential_details_tests.robot.
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
    ...    Test Setup for applicant_basic_details_tests.robot.
    Go To    ${BASE_URL}${URL_BASIC_DETAILS}
    Wait For Elements State    css=[data-testid='applicant-basic-details-title']    visible    timeout=${TIMEOUT}

Navigate To Personal Details Within Session
    [Documentation]
    ...    Test Setup for personal_details_tests.robot.
    ...    Hard-navigates to /applicant-personal-details within the active wizard session.
    Go To    ${BASE_URL}${URL_PERSONAL_DETAILS}
    Wait For Elements State    css=[data-testid='personal-details-title']    visible    timeout=${TIMEOUT}

Navigate To Residential Details Within Session
    [Documentation]
    ...    Test Setup for residential_details_tests.robot.
    ...    Hard-navigates to /applicant-residential-details within the active wizard session.
    Go To    ${BASE_URL}${URL_RESIDENTIAL_DETAILS}
    Wait For Elements State    css=[data-testid='residential-details-title']    visible    timeout=${TIMEOUT}

Navigate To Employment Type Within Session
    [Documentation]
    ...    Test Setup for employment type tests in employment_tests.robot.
    Go To    ${BASE_URL}${URL_EMPLOYMENT_TYPE}
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Confirm Application Within Session
    [Documentation]
    ...    Test Setup for confirm_application_tests.robot.
    ...    Hard-navigates to /confirm-application and auto-dismisses the referral code popup
    ...    if present, so it does not block confirm-application test execution.
    Go To    ${BASE_URL}${URL_CONFIRM_APPLICATION}
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    Handle Referral Code Popup If Present

Navigate To Confirm Application Without Popup Handling
    [Documentation]
    ...    Test Setup for referral code test cases in confirm_application_tests.robot.
    ...    Hard-navigates to /confirm-application WITHOUT dismissing the referral popup.
    ...    Use this setup for tests that explicitly test the referral code popup behaviour.
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
    Wait For Elements State    role=option >> nth=0    visible    timeout=${LONG_TIMEOUT}
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Select Specific Option In React Select
    [Documentation]
    ...    Traversal helper — types a value into a react-select to filter options, then selects it.
    ...    Used for DOB (year/month/day) where a pinned value is required.
    ...    This is an approved T1 exception for Suite Setup traversal helpers only.
    ...    Satisfies: TN1 (wizard traversal cost), RT-1
    [Arguments]    ${testid}    ${value}
    Click    css=[data-testid='${testid}'] input[role='combobox']
    Type Text    css=[data-testid='${testid}'] input[role='combobox']    ${value}
    Sleep    300ms
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
    ...    Uses > div:first-child to explicitly target the first plan card inside the container.
    ...    Satisfies: RT-1 (traversal)
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='plan-list-container'] > div:first-child

Click Plan In List By Index
    [Arguments]    ${plan_index}=1
    Wait For Elements State    ${CP_PLAN_LIST}    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='plan-list-container'] > div:nth-child(${plan_index})

Fill Personal Details With Stub Data
    [Documentation]
    ...    Quick-fill personal details with APP_* stub variables.
    ...    Selects first option for gender, DOB (year/month/day), and marital status.
    ...    Satisfies: RT-1 (traversal)
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}
    Fill Text    ${PD_PAN_INPUT}    ${APP_PAN_NUMBER}
    Sleep    2s    # Wait for PAN lookup to complete
    # Gender — click Male radio button (value='MALE') to avoid strict mode on gender-react-select
    Select Gender Male
    # Date of birth — year/month/day react-selects (pinned to APP_DOB_* variables)
    Select Specific Option In React Select    year-react-select    ${APP_DOB_YEAR}
    Select Specific Option In React Select    month-react-select    ${APP_DOB_MONTH}
    Select Specific Option In React Select    day-react-select    ${APP_DOB_DAY}
    # Marital status radio
    Click    css=[data-testid='marital-status-radio'] >> nth=0
    Fill Text    ${PD_EMAIL_INPUT}    ${APP_EMAIL}
    ${consent_checked}=    Get Property    ${PD_CONSENT}    checked
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
    Click    ${RD_PROCEED_BUTTON}
    Wait For Elements State    ${RD_RESIDENCE_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${RD_RESIDENCE_TYPE_RADIO} >> nth=0
    Wait For Elements State    css=[data-testid='type-radio'][data-state='checked']    visible    timeout=${TIMEOUT}
    Click    role=button[name=Proceed]

# ════════════════════════════════════════════════════════════════════════════════
# Renewal Journey traversal keywords
# Uses ${RENEWAL_MOBILE} — an existing account that already has prior applications.
# Entry is always via the header "Create new application" button (no empty-state fallback).
# Pages: Student Details and Choose Plan are identical to the first-application flow.
# After Choose Plan: Welcome Back screen → Verify Details screen (renewal-specific).
# ════════════════════════════════════════════════════════════════════════════════

Login And Create Renewal Application
    [Documentation]
    ...    Logs in with ${mobile} (defaults to ${RENEWAL_MOBILE}) — existing account with prior applications.
    ...    Clicks the header "Create new application" button.
    ...    If "Before you proceed" dialog appears, clicks CREATE NEW APPLICATION.
    ...    Leaves browser on /student-details ready for renewal suite traversal.
    [Arguments]    ${mobile}=${RENEWAL_MOBILE}
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    Rate limit detected — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Go To    ${BASE_URL}
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${mobile}
        Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Sleep    ${RATE_LIMIT_WAIT}
        ${url_after}=    Get Url
        IF    '/my-applications' in '${url_after}'
            No Operation    # already on dashboard — OTP succeeded during sleep
        ELSE IF    '/verify' in '${url_after}'
            Enter OTP    ${TEST_OTP}
            Click Verify OTP Button
        ELSE
            Submit Login Form    ${mobile}
            Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
            Submit OTP Form    ${TEST_OTP}
        END
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click Create Application Button And Wait For Student Details

Navigate To Student Details Via Renewal
    [Documentation]
    ...    Suite Setup for renewal_journey_flow/student_details_tests.robot.
    ...    Logs in with ${RENEWAL_MOBILE} and lands on /student-details.
    Login And Create Renewal Application

Navigate To Choose Plan Via Renewal
    [Documentation]
    ...    Suite Setup for renewal_journey_flow/choose_plan_tests.robot.
    ...    Traverses student details with stub data then proceeds to /choose-plan.
    Login And Create Renewal Application
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

Navigate To Welcome Back Via Renewal
    [Documentation]
    ...    Suite Setup for renewal_journey_flow/welcome_back_tests.robot.
    ...    Traverses student details + selects plan, then lands on the Welcome Back screen.
    Login And Create Renewal Application
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click First Plan In List
    Click Submit Plan Button
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}

Navigate To Verify Details Via Renewal
    [Documentation]
    ...    Suite Setup for renewal_journey_flow/verify_details_tests.robot.
    ...    Traverses through Welcome Back → clicks "CONTINUE WITH THESE DETAILS" → Verify Details.
    Navigate To Welcome Back Via Renewal
    Click    text=CONTINUE WITH THESE DETAILS
    Wait For Elements State    xpath=//h3[normalize-space()='Residential details']    visible    timeout=${LONG_TIMEOUT}

Navigate To Welcome Back Within Session
    [Documentation]
    ...    Test Setup for renewal_journey_flow/welcome_back_tests.robot.
    ...    Reuses the active browser session and SAME application — no new login, no new application.
    Go To    ${BASE_URL}/renewal-confirmation
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}

Navigate To Verify Details Within Session
    [Documentation]
    ...    Test Setup for renewal_journey_flow/verify_details_tests.robot.
    ...    Reuses the active browser session and SAME application — no new login, no new application.
    Go To    ${BASE_URL}/renewal-details
    Wait For Elements State    xpath=//h3[normalize-space()='Residential details']    visible    timeout=${LONG_TIMEOUT}

Navigate To Verify Details New Application Within Session
    [Documentation]
    ...    Special Test Setup for TC-VD62 only.
    ...    TC-VD61 navigates shared application to /confirm-application; this creates a fresh renewal application
    ...    within the existing browser session (no re-login) and traverses to /renewal-details.
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click Create Application Button And Wait For Student Details
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click First Plan In List
    Click Submit Plan Button
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}
    Click    text=CONTINUE WITH THESE DETAILS
    Wait For Elements State    xpath=//h3[normalize-space()='Residential details']    visible    timeout=${LONG_TIMEOUT}

Resume In Progress Application
    [Documentation]
    ...    Clicks the header "Create new application" button on the dashboard.
    ...    When a "Before you proceed" dialog appears (in-progress application exists),
    ...    clicks "CONTINUE EXISTING APPLICATION" to resume from where the user left off.
    ...    Use this in resume journey tests AFTER re-logging in with ${RESUME_MOBILE}.
    Wait For Elements State    ${EMI_TAB}    visible    timeout=${TIMEOUT}
    Click    ${EMI_TAB}
    Sleep    1s
    Wait For Elements State    ${CREATE_APP_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CREATE_APP_BUTTON}
    Wait For Elements State    css=[role='dialog']    visible    timeout=${LONG_TIMEOUT}
    Click    css=[role='dialog'] >> text=CONTINUE EXISTING APPLICATION

Resume In Progress Application Via EMI Card
    [Documentation]
    ...    Resumes an in-progress application by clicking the "Verify Now" (emi-card-action-button)
    ...    on the EMI tab card. Use this AFTER clicking Close on a wizard page (which redirects
    ...    to dashboard). Does NOT use the "Before you proceed" dialog.
    ...    Uses nth=-1 (last matching button) to target the most recently created application
    ...    when multiple emi-card-action-buttons are present (e.g. RENEWAL_MOBILE accounts).
    Wait For Elements State    ${EMI_TAB}    visible    timeout=${TIMEOUT}
    Click    ${EMI_TAB}
    Wait For Elements State    css=[data-testid='emi-card-action-button'] >> nth=0    visible    timeout=${LONG_TIMEOUT}
    Click    css=[data-testid='emi-card-action-button'] >> nth=0

Click Wizard Close Button
    [Documentation]
    ...    Generic close button for any wizard page — clicks data-testid='close-button' and
    ...    waits for dashboard URL. Use in resume journey tests to avoid keyword name conflicts
    ...    when multiple page resources define their own Click Close Button keywords.
    Click    css=[data-testid='close-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Create Application For Resume Tests
    [Documentation]
    ...    Suite Setup for resume_journey_e2e_tests.robot.
    ...    Logs in with ${APP_CREATION_MOBILE} (fresh account each run), creates a new application,
    ...    and lands on /student-details ready for TC-RE01.
    Login And Create Application
    Click Create Application Button And Wait For Student Details

Create Application For Renewal Resume Tests
    [Documentation]
    ...    Suite Setup for resume_journey_renewal_e2e_tests.robot.
    ...    Logs in with ${RENEWAL_MOBILE} (existing account with prior applications — required for
    ...    renewal path), creates a new renewal application, and lands on /student-details ready for TC-RER01.
    Login And Create Renewal Application

Create Application For SE Resume Tests
    [Documentation]
    ...    Suite Setup for resume_journey_se_e2e_tests.robot.
    ...    Logs in with ${APP_CREATION_MOBILE} (fresh account each run), creates a new application,
    ...    and traverses all wizard steps to land on /select-employment ready for SE resume tests.
    Navigate To Employment Type

Fill Student Details Data
    [Documentation]
    ...    Fills all student details fields (GILE dropdowns + personal info + loan amount)
    ...    WITHOUT clicking Show Plans. Use this when the test needs to close the wizard
    ...    at /student-details (TC-RE01).
    ...    Contrast with Fill Student Details With Stub Data which also clicks Show Plans.
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Search And Select First Option In React Select    institute-id-react-select    ${APP_INSTITUTE_SEARCH}
    Select First Option In React Select    location-id-react-select
    Select First Option In React Select    board-id-react-select
    Select First Option In React Select    academic-year-id-react-select
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${SD_FIRST_NAME}    ${APP_STUDENT_FIRST_NAME}
    Fill Text    ${SD_LAST_NAME}    ${APP_STUDENT_LAST_NAME}
    Click    ${SD_STUDENT_TYPE_RADIO} >> nth=0
    Click    css=[data-testid='class-id-react-select']
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter
    Fill Text    ${SD_STUDENT_ID}    SD12345
    Fill Text    ${SD_LOAN_AMOUNT}    ${APP_LOAN_AMOUNT}

Select Plan And Wait For Basic Details
    [Documentation]
    ...    Clicks the first plan, submits, and waits for the next wizard step.
    ...    Fresh accounts skip /select-applicant and land on /applicant-basic-details directly.
    ...    Handles both outcomes: /select-applicant (if shown) → submits parent option → basic-details,
    ...    or /applicant-basic-details directly.
    Click First Plan In List
    Click    ${CP_SUBMIT_BUTTON}
    ${on_sa}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    10s    500ms    Select Applicant URL Should Be Active
    IF    ${on_sa}
        Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
        Click    ${SA_PARENT_OPTION}
        Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
        Click    ${SA_SUBMIT_BUTTON}
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

Select Salaried And Wait For Employment Details
    [Documentation]
    ...    Clicks the Salaried card on /select-employment and waits for /applicant-employment-details.
    ...    Used in resume journey TC-RE08 to reach employment details without filling data.
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${ET_SALARIED_CARD}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active

Select Self Employed And Wait For Employment Details
    [Documentation]
    ...    Clicks the Self-Employed card on /select-employment and waits for /applicant-employment-details.
    ...    Used in SE resume journey tests to reach employment details without filling data.
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${ET_SELF_EMPLOYED_CARD}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active

Fill SE Employment Data And Proceed
    [Documentation]
    ...    Fills business name, annual income, years in business, business description on
    ...    /applicant-employment-details (SE form) and proceeds to /confirm-application.
    ...    Starts from /applicant-employment-details with SE form loaded.
    ...    Dismisses referral code popup if present after landing on /confirm-application.
    Wait For Elements State    ${SE_BUSINESS_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SE_BUSINESS_NAME}    ${APP_BUSINESS_NAME}
    Fill Text    ${SE_ANNUAL_INCOME}    ${APP_BUSINESS_INCOME}
    Fill Text    ${SE_YEARS}    ${APP_BUSINESS_YEARS}
    Fill Text    ${SE_DESCRIPTION}    ${APP_BUSINESS_DESC}
    Click    ${SE_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Handle Referral Code Popup If Present

Fill Salaried Employment Data And Proceed
    [Documentation]
    ...    Fills employer name, monthly salary on /applicant-employment-details and proceeds
    ...    — navigates to /confirm-application. Starts from /applicant-employment-details.
    ...    Consent checkbox only appears when salary < 25000; checked conditionally if visible.
    ...    Used in resume journey TC-RE09.
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${APP_EMPLOYER_NAME}
    Fill Text    ${SED_SALARY}    ${APP_MONTHLY_SALARY}
    ${consent_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${SED_CONSENT}    visible    timeout=3s
    IF    ${consent_visible}
        ${checked}=    Get Property    ${SED_CONSENT}    checked
        IF    not ${checked}
            Click    ${SED_CONSENT}
        END
    END
    Click    ${SED_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Handle Referral Code Popup If Present

Select Parent Guardian And Submit
    [Documentation]
    ...    Selects the Parent/Guardian applicant option and submits — navigates to /applicant-basic-details.
    ...    Used in resume journey TC-RE04 to advance from /select-applicant.
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_PARENT_OPTION}
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

Fill And Submit Basic Details
    [Documentation]
    ...    Fills applicant basic details (first name, last name, consent) and submits
    ...    — navigates to /onboarding. Used in resume journey TC-RE05.
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${APP_FIRST_NAME}
    Fill Text    ${BD_LAST_NAME}    ${APP_LAST_NAME}
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    not ${checked}
        Click    ${BD_CONSENT}
    END
    Click    ${BD_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

Fill And Submit Salaried Employment
    [Documentation]
    ...    Selects Salaried employment type, fills employer name + monthly salary, and proceeds
    ...    — navigates to /confirm-application. Consent checkbox only appears when salary < 25000.
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${ET_SALARIED_CARD}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${APP_EMPLOYER_NAME}
    Fill Text    ${SED_SALARY}    ${APP_MONTHLY_SALARY}
    ${consent_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${SED_CONSENT}    visible    timeout=3s
    IF    ${consent_visible}
        ${checked}=    Get Property    ${SED_CONSENT}    checked
        IF    not ${checked}
            Click    ${SED_CONSENT}
        END
    END
    Click    ${SED_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active

# ════════════════════════════════════════════════════════════════════════════════
# Lender Selection Suite Setup keywords
# These keywords create a fresh application, submit it, wait for the lender
# selection page, and capture the dynamic app_id / app_code as suite variables.
# ════════════════════════════════════════════════════════════════════════════════

Navigate To Lender Selection New App
    [Documentation]
    ...    Suite Setup for lender selection new-application suites.
    ...    Logs in with APP_CREATION_MOBILE, creates application, fills wizard with stub data,
    ...    submits on confirm page, waits for /application-loader/{id}, and captures
    ...    LENDER_APP_ID as a suite variable.
    Navigate To Confirm Application
    Handle Referral Code Popup If Present
    ${consent_checked}=    Get Property    css=[data-testid='consent-checkbox']    checked
    IF    not ${consent_checked}
        Click    css=[data-testid='consent-checkbox']
    END
    Click    css=[data-testid='proceed-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ${app_id}=    Extract App ID From Current URL
    Set Suite Variable    ${LENDER_APP_ID}    ${app_id}
    Lender Selection Page Should Be Visible

Navigate To Lender Selection New App Within Session
    [Arguments]    ${plan_index}=1
    [Documentation]
    ...    Creates a fresh new application within the existing browser session (no re-login).
    ...    Accepts plan_index (default 1) to select a specific plan from the plan list.
    ...    Overwrites LENDER_APP_ID suite variable with the new application's id.
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click Create Application Button And Wait For Student Details
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click Plan In List By Index    ${plan_index}
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_PARENT_OPTION}
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${APP_FIRST_NAME}
    Fill Text    ${BD_LAST_NAME}    ${APP_LAST_NAME}
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    not ${checked}
        Click    ${BD_CONSENT}
    END
    Click    ${BD_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}
    Click    ${OB_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Fill Personal Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active
    Fill Residential Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
    Navigate To Salaried Employment Details In Session
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${APP_EMPLOYER_NAME}
    Fill Text    ${SED_SALARY}    ${APP_MONTHLY_SALARY}
    Click    ${SED_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    Handle Referral Code Popup If Present
    ${consent_checked}=    Get Property    css=[data-testid='consent-checkbox']    checked
    IF    not ${consent_checked}
        Click    css=[data-testid='consent-checkbox']
    END
    Click    css=[data-testid='proceed-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ${app_id}=    Extract App ID From Current URL
    Set Suite Variable    ${LENDER_APP_ID}    ${app_id}
    Lender Selection Page Should Be Visible

Login And Navigate To Lender Selection New App
    [Arguments]    ${plan_index}=1    ${mobile}=${APP_CREATION_MOBILE}
    [Documentation]
    ...    Opens a fresh browser, logs in, creates a new application with the given plan index,
    ...    and navigates to the lender selection page. Use as [Setup] for isolated browser-per-test runs.
    Login And Create Application    ${mobile}
    Navigate To Lender Selection New App Within Session    ${plan_index}

Login And Submit New App
    [Arguments]    ${plan_index}=1    ${mobile}=${APP_CREATION_MOBILE}
    [Documentation]
    ...    Opens a fresh browser, logs in, fills the wizard with the given plan index,
    ...    and clicks proceed on confirm-application. Does NOT wait for lender selection.
    ...    Use as [Setup] when the expected post-submit destination is not lender selection
    ...    (e.g., plan_index=4 → all bureau lenders ineligible → direct /bank-statement/ redirect).
    Login And Create Application    ${mobile}
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click Create Application Button And Wait For Student Details
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click Plan In List By Index    ${plan_index}
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_PARENT_OPTION}
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${BD_FIRST_NAME}    ${APP_FIRST_NAME}
    Fill Text    ${BD_LAST_NAME}    ${APP_LAST_NAME}
    ${checked}=    Get Property    ${BD_CONSENT}    checked
    IF    not ${checked}
        Click    ${BD_CONSENT}
    END
    Click    ${BD_SUBMIT_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}
    Click    ${OB_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    Fill Personal Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active
    Fill Residential Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
    Navigate To Salaried Employment Details In Session
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${APP_EMPLOYER_NAME}
    Fill Text    ${SED_SALARY}    ${APP_MONTHLY_SALARY}
    Click    ${SED_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    Handle Referral Code Popup If Present
    ${consent_checked}=    Get Property    css=[data-testid='consent-checkbox']    checked
    IF    not ${consent_checked}
        Click    css=[data-testid='consent-checkbox']
    END
    Click    css=[data-testid='proceed-button']

Navigate To Lender Selection Renewal App
    [Documentation]
    ...    Suite Setup for lender selection renewal-application suites.
    ...    Logs in with RENEWAL_MOBILE, creates renewal application, fills student details,
    ...    selects plan, confirms via Welcome Back, submits on Verify Details confirm page,
    ...    waits for /application-loader/{id}, and captures LENDER_RENEWAL_APP_ID.
    Login And Create Renewal Application
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click First Plan In List
    Click Submit Plan Button
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}
    Click    text=CONTINUE WITH THESE DETAILS
    Wait For Elements State    xpath=//h3[normalize-space()='Residential details']    visible    timeout=${LONG_TIMEOUT}
    ${has_skip}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[data-testid='skip-button']    visible    timeout=4s
    IF    ${has_skip}
        Click    css=[data-testid='skip-button']
    END
    Click    text=CONFIRM AND PROCEED
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    Handle Referral Code Popup If Present
    Check Confirm Application Consent
    Click Confirm Application Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ${app_id}=    Extract App ID From Current URL
    Set Suite Variable    ${LENDER_RENEWAL_APP_ID}    ${app_id}
    Lender Selection Page Should Be Visible

Navigate To Lender Selection Renewal App Within Session
    [Documentation]
    ...    Creates a fresh renewal application within the existing browser session (no re-login).
    ...    Used by TC-LS-R06 Setup to get a clean lender selection state for the approval test.
    ...    Overwrites LENDER_RENEWAL_APP_ID suite variable with the new application's id.
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click Create Application Button And Wait For Student Details
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Fill Student Details With Stub Data
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active
    Click First Plan In List
    Click Submit Plan Button
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}
    Click    text=CONTINUE WITH THESE DETAILS
    Wait For Elements State    xpath=//h3[normalize-space()='Residential details']    visible    timeout=${LONG_TIMEOUT}
    ${has_skip}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[data-testid='skip-button']    visible    timeout=4s
    IF    ${has_skip}
        Click    css=[data-testid='skip-button']
    END
    Click    text=CONFIRM AND PROCEED
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    Handle Referral Code Popup If Present
    Check Confirm Application Consent
    Click Confirm Application Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ${app_id}=    Extract App ID From Current URL
    Set Suite Variable    ${LENDER_RENEWAL_APP_ID}    ${app_id}
    Lender Selection Page Should Be Visible

Navigate To Bank Statement Via BRE Rejection
    [Documentation]
    ...    Suite Setup for bank_statement_tests.robot.
    ...    Creates a fresh new application, submits it, mocks BRE REJECTED, triggers lender
    ...    assignment, waits for redirect to /bank-statement/{code}, captures BS_APP_CODE.
    Navigate To Confirm Application
    Handle Referral Code Popup If Present
    ${consent_checked}=    Get Property    css=[data-testid='consent-checkbox']    checked
    IF    not ${consent_checked}
        Click    css=[data-testid='consent-checkbox']
    END
    Click    css=[data-testid='proceed-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    # Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    IF    not ${on_bank}
        Click View Available Financing
        Check KFS Consent If Present
        Click First Available Continue Button
        Wait For Bureau Decision
        ${url}=    Get Url
    END
    Should Contain    ${url}    /bank-statement/
    ${app_code}=    Extract App Code From Bank Statement URL
    Set Suite Variable    ${BS_APP_CODE}    ${app_code}
    # Unroute BRE Mock

Navigate To Bank Statement Via Plan Two
    [Documentation]
    ...    Suite Setup for bank_statement_tests.robot (plan 2 path — no mock).
    ...    Creates fresh app with plan 2 (BANK_STATEMENT_MOBILE), navigates to lender selection,
    ...    selects first available lender. Real BRE with plan 2 redirects directly to /bank-statement/.
    ...    Captures BS_APP_CODE from the redirect URL.
    Login And Create Application    ${BANK_STATEMENT_MOBILE}
    Navigate To Lender Selection New App Within Session    2
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Bank Statement URL Should Be Active
    ${app_code}=    Extract App Code From Bank Statement URL
    Set Suite Variable    ${BS_APP_CODE}    ${app_code}
