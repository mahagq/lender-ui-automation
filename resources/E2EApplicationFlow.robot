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
Renewal Details URL Should Be Visible
    ${url}=    Get Url
    Should Contain    ${url}    /renewal-details

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
    ...    Opens a react-select dropdown and selects an option.
    ...    If option_text is non-empty: types to filter (searchable selects), then clicks first
    ...    option whose text contains option_text (Playwright text= does substring match).
    ...    Handles both exact values and partial/malformed values (e.g. '-2023' matches '2022-2023').
    ...    If option_text is empty: opens dropdown then ArrowDown+Enter → first available option.
    ...    Scrolls element into view first to avoid out-of-viewport click failures.
    ...    Waits for combobox enabled — dependent dropdowns are disabled while upstream API is in flight.
    [Arguments]    ${testid}    ${option_text}
    Wait For Elements State    css=[data-testid='${testid}'] input[role='combobox']    enabled    timeout=${LONG_TIMEOUT}
    Evaluate JavaScript    css=[data-testid='${testid}']    (el) => el.scrollIntoView({block: 'center', behavior: 'instant'})
    Sleep    300ms
    Click    css=[data-testid='${testid}']
    Wait For Elements State    role=option >> nth=0    visible    timeout=${LONG_TIMEOUT}
    IF    '${option_text}' != ''
        Click    role=option >> text=${option_text}
    ELSE
        Keyboard Key    press    ArrowDown
        Keyboard Key    press    Enter
    END

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
        ${url_after}=    Get Url
        IF    '/my-applications' in '${url_after}'
            No Operation    # already on dashboard — OTP succeeded during sleep
        ELSE IF    '/verify' in '${url_after}'
            # Still on OTP page — re-enter and submit
            Enter OTP    ${TEST_OTP}
            Click Verify OTP Button
        ELSE
            # Forced logout to / — re-login then OTP
            Submit Login Form    ${resolved_mobile}
            Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
            Submit OTP Form    ${TEST_OTP}
        END
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
    Select Option By Text In React Select    class-id-react-select    ${class}
    Fill Text    ${SD_STUDENT_ID}    ${student_id}
    Fill Text    ${SD_LOAN_AMOUNT}    ${loan_amount}
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

    # ── Step 4: Choose Plan ───────────────────────────────────────────────────────
    Click First Plan In List
    Click Submit Plan Button
    # Existing accounts with prior applications land on /renewal-confirmation (Welcome Back).
    # Clicking CHANGE APPLICANT DETAILS returns to /select-applicant (standard ACF flow).
    ${on_welcome_back}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=CHANGE APPLICANT DETAILS    visible    timeout=5s
    IF    ${on_welcome_back}
        Click    text=CHANGE APPLICANT DETAILS
    END
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
    # Gender is radio buttons (button[value='MALE'] / button[value='FEMALE']), not a react-select
    ${gender_value}=    Evaluate    '${gender}'.upper()
    Wait For Elements State    css=button[value='${gender_value}']    visible    timeout=${TIMEOUT}
    Click    css=button[value='${gender_value}']
    Select Specific Option In React Select    year-react-select    ${dob_year}
    Select Specific Option In React Select    month-react-select    ${dob_month}
    Select Specific Option In React Select    day-react-select    ${dob_day}
    Click    text=${marital_status}
    Fill Text    ${PD_EMAIL_INPUT}    ${email}
    ${consent_checked}=    Get Property    ${PD_CONSENT}    checked
    IF    not ${consent_checked}
        Click    ${PD_CONSENT}
    END
    Wait For Elements State    ${PD_PROCEED_BUTTON}    enabled    timeout=${LONG_TIMEOUT}
    Click    ${PD_PROCEED_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Residential Details URL Should Be Active

    # ── Step 9: Applicant Residential Details ────────────────────────────────────
    # Two-step page: (1) fill address → first proceed; (2) select residence type → second proceed
    Wait For Elements State    ${RD_ADDR_LINE1}    visible    timeout=${TIMEOUT}
    Fill Text    ${RD_ADDR_LINE1}    ${address_line1}
    Fill Text    ${RD_ADDR_LINE2}    ${address_line2}
    Fill Text    ${RD_PINCODE}    ${pincode}
    Sleep    2s
    Click    ${RD_PROCEED_BUTTON}
    Wait For Elements State    ${RD_RESIDENCE_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    text=${residence_type}
    Wait For Elements State    css=[data-testid='type-radio'][data-state='checked']    visible    timeout=${TIMEOUT}
    Click    role=button[name=Proceed]
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
    # Referral code popup always appears on first visit — must be handled before consent is accessible
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${RC_SKIP_BUTTON}    visible    timeout=5s
    IF    ${popup_visible}
        IF    '${referral_code}'.strip() != ''
            Fill Text    css=[placeholder='Enter Referral Code']    ${referral_code}
            Click    ${RC_PROCEED_BUTTON}
            Sleep    1s
        ELSE
            Click    ${RC_SKIP_BUTTON}
        END
    END
    Check Confirm Application Consent
    Click Confirm Application Proceed

    # ── Step 13: Assert Success ───────────────────────────────────────────────────
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Confirm Application Submitted Successfully

Create Full Renewal Application
    [Documentation]
    ...    Master E2E orchestration keyword for renewal (nth application) flow.
    ...    Uses ${RENEWAL_MOBILE} (existing account with prior applications).
    ...    After Choose Plan: Welcome Back screen → "CONTINUE WITH THESE DETAILS" → Verify Details → Submit.
    ...    Simpler argument set than Create Full Application — no personal/employment data needed
    ...    (pre-filled from previous application and confirmed as-is).
    [Arguments]
    ...    ${institute_search}    ${location}    ${course}    ${academic_year}
    ...    ${student_first_name}    ${student_last_name}    ${admission_type}
    ...    ${class}    ${student_id}    ${loan_amount}    ${referral_code}
    ...    ${mobile}=${EMPTY}

    # ── Step 1: Login ────────────────────────────────────────────────────────────
    ${resolved_mobile}=    Set Variable If    '${mobile}'.strip() != ''    ${mobile}    ${RENEWAL_MOBILE}
    Login And Create Renewal Application    ${resolved_mobile}

    # ── Step 2: Student Details ──────────────────────────────────────────────────
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}
    Search And Select First Option In React Select    institute-id-react-select    ${institute_search}
    Select Option By Text In React Select    location-id-react-select    ${location}
    Select Option By Text In React Select    board-id-react-select    ${course}
    Select Option By Text In React Select    academic-year-id-react-select    ${academic_year}
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${SD_FIRST_NAME}    ${student_first_name}
    Fill Text    ${SD_LAST_NAME}    ${student_last_name}
    Click    text=${admission_type}
    Sleep    500ms
    Select Option By Text In React Select    class-id-react-select    ${class}
    Fill Text    ${SD_STUDENT_ID}    ${student_id}
    Fill Text    ${SD_LOAN_AMOUNT}    ${loan_amount}
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

    # ── Step 3: Choose Plan ───────────────────────────────────────────────────────
    Click First Plan In List
    Click Submit Plan Button

    # ── Step 4: Welcome Back screen ──────────────────────────────────────────────
    Wait For Elements State    text=CONTINUE WITH THESE DETAILS    visible    timeout=${LONG_TIMEOUT}
    Click    text=CONTINUE WITH THESE DETAILS
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Renewal Details URL Should Be Visible

    # ── Step 5: Verify Details — confirm ─────────────────────────────────────────
    Wait For Elements State    text=CONFIRM AND PROCEED    visible    timeout=${LONG_TIMEOUT}
    Click    text=CONFIRM AND PROCEED
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active

    # ── Step 6: Confirm Application ──────────────────────────────────────────────
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${RC_SKIP_BUTTON}    visible    timeout=5s
    IF    ${popup_visible}
        IF    '${referral_code}'.strip() != ''
            Fill Text    css=[placeholder='Enter Referral Code']    ${referral_code}
            Click    ${RC_PROCEED_BUTTON}
            Sleep    1s
        ELSE
            Click    ${RC_SKIP_BUTTON}
        END
    END
    Check Confirm Application Consent
    Click Confirm Application Proceed

    # ── Step 7: Assert Success ────────────────────────────────────────────────────
    Wait Until Keyword Succeeds    60s    500ms    Confirm Application Submitted Successfully

Create Full Application With Lender Assignment
    [Documentation]
    ...    Full E2E: Login → 13-step wizard → confirm submit → lender selection → BRE decision → KYC or Bank Statement.
    ...    Uses APP_* stub data for all wizard fields.
    ...    ${plan_index}: reserved — always selects Plan 1 (first available). Pass plan_index=2 for future use when Create Full Application supports plan selection by index.
    ...    ${lender_decision}: APPROVED → asserts /okyc/; REJECTED → asserts /bank-statement/.
    ...    Teardown: caller test must call Run Keyword And Ignore Error    Close Browser.
    [Arguments]
    ...    ${student_first_name}    ${student_last_name}    ${loan_amount}
    ...    ${applicant_first_name}    ${applicant_last_name}    ${pan_number}
    ...    ${dob_year}    ${dob_month}    ${dob_day}
    ...    ${email}    ${address_line1}    ${address_line2}    ${pincode}
    ...    ${employer_name}    ${monthly_salary}
    ...    ${plan_index}=1    ${lender_decision}=APPROVED
    Log    plan_index=${plan_index} (reserved — Plan 1 always selected; extend Create Full Application to support plan_index when needed)    level=DEBUG
    Create Full Application
    ...    ${EMPTY}    ${APP_INSTITUTE_SEARCH}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    ${student_first_name}    ${student_last_name}    New Admission    ${EMPTY}    SD12345
    ...    ${loan_amount}    Parent/Guardian    ${applicant_first_name}    ${applicant_last_name}
    ...    ${pan_number}    Male    ${dob_year}    ${dob_month}    ${dob_day}
    ...    Unmarried    ${email}    ${address_line1}    ${address_line2}    ${pincode}
    ...    Rented    Salaried    ${employer_name}    ${monthly_salary}
    ...    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    Mock BRE Assign Lender    ${lender_decision}
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Unroute BRE Mock

Create Full Renewal Application With Lender Assignment
    [Documentation]
    ...    Full E2E renewal: Login (RENEWAL_MOBILE) → renewal wizard → confirm → lender selection → BRE decision.
    ...    ${plan_index}: reserved — always selects Plan 1. Extend Create Full Renewal Application to support plan selection by index when needed.
    ...    ${lender_decision}: APPROVED → asserts /okyc/; REJECTED → asserts /bank-statement/.
    ...    Teardown: caller test must call Run Keyword And Ignore Error    Close Browser.
    [Arguments]    ${plan_index}=1    ${lender_decision}=APPROVED
    Log    plan_index=${plan_index} (reserved — Plan 1 always selected)    level=DEBUG
    Create Full Renewal Application
    ...    ${APP_INSTITUTE_SEARCH}    ${EMPTY}    ${EMPTY}    ${EMPTY}
    ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    New Admission
    ...    ${EMPTY}    SD12345    ${APP_LOAN_AMOUNT}    ${EMPTY}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    Mock BRE Assign Lender    ${lender_decision}
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    Click First Available Continue Button
    Wait For Bureau Decision
    Unroute BRE Mock
