*** Settings ***
Documentation
...    E2E Application Creation Flow orchestration keywords.
...    Provides Create Full Application — a single keyword that executes the complete
...    Login → Confirm & Submit wizard from end to end using caller-supplied data.
...    Designed for Excel-driven multi-application creation via DataDriver.
...
...    Imports ApplicationCreationFlowPage.robot transitively, which brings in all wizard
...    page resource files (LoginPage, OTPPage, DashboardPage, StudentDetailsPage, etc.).
...
...    New keywords in this file:
...      Resolve Mobile Number              — returns provided mobile or generates random 10-digit
...      Select Option By Text In React Select — selects exact-match option in any react-select
...      Create Full Application            — master orchestration keyword (13 wizard steps)
...
...    T1 exception: Select Option By Text In React Select uses .react-select__option
...    (react-select library class, stable across builds — not CSS Modules). Approved for
...    E2E/traversal use, consistent with existing ApplicationCreationFlowPage.robot exception.

Library     Browser
Resource    ApplicationCreationFlowPage.robot

*** Keywords ***
Resolve Mobile Number
    [Documentation]
    ...    Returns ${mobile} as-is if it is a non-empty string.
    ...    If ${mobile} is blank (empty cell in Excel), generates a random 10-digit
    ...    mobile number starting with 9 — valid for UAT (fixed OTP 9999 applies to all).
    [Arguments]    ${mobile}
    IF    '${mobile}'.strip() == ''
        ${resolved}=    Evaluate    str(random.randint(9000000000, 9999999999))    modules=random
    ELSE
        ${resolved}=    Set Variable    ${mobile}
    END
    RETURN    ${resolved}

Select Option By Text In React Select
    [Documentation]
    ...    Clicks a react-select input (located by data-testid), types ${option_text} to filter,
    ...    waits for the matching option to appear, then clicks it using exact text match.
    ...    T1 exception: uses .react-select__option (stable react-select library class).
    ...    Only one react-select portal is open at a time, so option scoping is unambiguous.
    [Arguments]    ${testid}    ${option_text}
    Click    css=[data-testid='${testid}'] input[role='combobox']
    Type Text    css=[data-testid='${testid}'] input[role='combobox']    ${option_text}    clear=True
    Sleep    500ms
    Wait For Elements State    css=.react-select__option    visible    timeout=${LONG_TIMEOUT}
    Click    css=.react-select__option >> text="${option_text}"

Create Full Application
    [Documentation]
    ...    Master E2E orchestration keyword. Executes all 13 wizard steps:
    ...    Login → Dashboard → Student Details → Choose Plan → Select Applicant →
    ...    Basic Details → Onboarding → Personal Details → Residential Details →
    ...    Employment Type → Employment Details → Confirm Application → Assert Success.
    ...
    ...    Opens a new browser at start. Browser cleanup is handled by Test Teardown
    ...    in the calling test suite (Run Keyword And Ignore Error    Close Browser).
    ...
    ...    Empty ${login_mobile} triggers auto-generation of a random 10-digit mobile.
    ...    ${employment_type} must be 'Salaried' or 'Self-Employed'.
    ...    ${applicant_type} must be 'Student', 'Parent/Guardian', or 'Student+Parent/Guardian'.
    ...    ${referral_code} is optional — leave blank to skip the referral code section.
    [Arguments]
    ...    ${login_mobile}    ${institute_search}    ${location}    ${course}
    ...    ${academic_year}    ${student_first_name}    ${student_last_name}
    ...    ${admission_type}    ${class}    ${student_id}    ${loan_amount}
    ...    ${applicant_type}    ${applicant_first_name}    ${applicant_last_name}
    ...    ${pan_number}    ${gender}    ${dob_year}    ${dob_month}    ${dob_day}
    ...    ${marital_status}    ${email}    ${address_line1}    ${address_line2}
    ...    ${pincode}    ${residence_type}    ${employment_type}
    ...    ${employer_name}    ${monthly_salary}
    ...    ${business_name}    ${annual_income}    ${years_in_business}    ${business_description}
    ...    ${referral_code}

    # ── Resolve mobile ───────────────────────────────────────────────────────────
    ${resolved_mobile}=    Resolve Mobile Number    ${login_mobile}
    Log    Using mobile: ${resolved_mobile}    console=True

    # ── Step 1: Login ────────────────────────────────────────────────────────────
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${resolved_mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Go To    ${BASE_URL}
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${resolved_mobile}
        Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Enter OTP    ${TEST_OTP}
        Click Verify OTP Button
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}

    # ── Step 2: Create new application ──────────────────────────────────────────
    # Handles both: header button (existing account) and empty-state button (new account).
    # Also handles "Before you proceed" in-progress dialog automatically.
    Click Create Application Button And Wait For Student Details

    # ── Step 3: Student Details ──────────────────────────────────────────────────
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    # Institute: async search — type term then select first result
    Search And Select First Option In React Select    institute-id-react-select    ${institute_search}
    # Location, course, academic year: select by exact option text
    Select Option By Text In React Select    location-id-react-select    ${location}
    Select Option By Text In React Select    board-id-react-select    ${course}
    Select Option By Text In React Select    academic-year-id-react-select    ${academic_year}
    # Personal details section appears after GILE dropdowns are filled
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${SD_FIRST_NAME}    ${student_first_name}
    Fill Text    ${SD_LAST_NAME}    ${student_last_name}
    # Admission type: click by visible text ("New Admission" / "Existing Student")
    Click    text=${admission_type}
    Sleep    500ms
    # Class dropdown
    Select Option By Text In React Select    class-id-react-select    ${class}
    Fill Text    ${SD_STUDENT_ID}    ${student_id}
    Fill Text    ${SD_LOAN_AMOUNT}    ${loan_amount}
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

    # ── Step 4: Choose Plan ───────────────────────────────────────────────────────
    Click First Plan In List
    Click Submit Plan Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active

    # ── Step 5: Select Applicant ──────────────────────────────────────────────────
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    IF    '${applicant_type}' == 'Student+Parent/Guardian'
        Select Student Option
        Select Parent Guardian Option
    ELSE IF    '${applicant_type}' == 'Student'
        Select Student Option
        Check Age Eligibility Checkbox
        Check Salary Eligibility Checkbox
    ELSE
        Select Parent Guardian Option
    END
    Click Submit Applicant Type Button
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active

    # ── Step 6: Applicant Basic Details ──────────────────────────────────────────
    Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Basic Details First Name    ${applicant_first_name}
    Fill Basic Details Last Name    ${applicant_last_name}
    Check Basic Details Consent
    Click Submit Basic Details
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Onboarding URL Should Be Active

    # ── Step 7: Onboarding ───────────────────────────────────────────────────────
    Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}
    Click    ${OB_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active

    # ── Step 8: Applicant Personal Details ───────────────────────────────────────
    Wait For Elements State    ${PD_FORM}    visible    timeout=${TIMEOUT}
    Fill Text    ${PD_PAN_INPUT}    ${pan_number}
    Sleep    2s
    Select Option By Text In React Select    gender-react-select    ${gender}
    Select Option By Text In React Select    year-react-select    ${dob_year}
    Select Option By Text In React Select    month-react-select    ${dob_month}
    Select Option By Text In React Select    day-react-select    ${dob_day}
    Click    text=${marital_status}
    Fill Text    ${PD_EMAIL_INPUT}    ${email}
    ${consent_checked}=    Get Property    ${PD_CONSENT}    checked
    IF    not ${consent_checked}
        Click    ${PD_CONSENT}
    END
    Click    ${PD_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

    # ── Step 9: Applicant Residential Details ────────────────────────────────────
    Wait For Elements State    ${RD_ADDR_LINE1}    visible    timeout=${TIMEOUT}
    Fill Text    ${RD_ADDR_LINE1}    ${address_line1}
    Fill Text    ${RD_ADDR_LINE2}    ${address_line2}
    Fill Text    ${RD_PINCODE}    ${pincode}
    Sleep    2s
    Click    text=${residence_type}
    Click    ${RD_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

    # ── Step 10: Select Employment Type ──────────────────────────────────────────
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    IF    '${employment_type}' == 'Salaried'
        Click    ${ET_SALARIED_CARD}
    ELSE
        Click    ${ET_SELF_EMPLOYED_CARD}
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Details URL Should Be Active

    # ── Step 11: Employment Details ───────────────────────────────────────────────
    IF    '${employment_type}' == 'Salaried'
        Fill Employer Name    ${employer_name}
        Fill Monthly Salary    ${monthly_salary}
        Check Salaried Consent
        Click Salaried Proceed
    ELSE
        Fill Business Name    ${business_name}
        Fill Annual Income    ${annual_income}
        Fill Years In Business    ${years_in_business}
        Fill Business Description    ${business_description}
        Click Self Employed Proceed
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active

    # ── Step 12: Confirm Application ─────────────────────────────────────────────
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    IF    '${referral_code}'.strip() != ''
        Fill Text    css=[placeholder='Enter Referral Code']    ${referral_code}
        Click    text=PROCEED
        Sleep    1s
    END
    Check Confirm Application Consent
    Click Confirm Application Proceed

    # ── Step 13: Assert Success ───────────────────────────────────────────────────
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully
