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
Library     Collections
Library     slack_notifier.py
Resource    ApplicationCreationFlowPage.robot
Resource    EsignPage.robot
Resource    DownPaymentPage.robot

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
    ...    2026 UI rewrite replaced react-select with a custom Select (cmdk-based) component —
    ...    no data-testid, trigger is a button[role='combobox'] whose accessible name is its
    ...    floating label text, options render as role='option' (cmdk CommandItem default).
    ...    ${testid} is the LEGACY react-select testid naming (kept for call-site compatibility)
    ...    — mapped below to the new field's label-text substring.
    ...    If option_text is non-empty: clicks first option whose text contains option_text.
    ...    If option_text is empty: opens dropdown then ArrowDown+Enter → first available option.
    [Arguments]    ${testid}    ${option_text}
    ${label_map}=    Create Dictionary
    ...    institute-id-react-select=School / College / University
    ...    location-id-react-select=Location
    ...    board-id-react-select=Board / Class / Stream
    ...    academic-year-id-react-select=Academic Year
    ...    class-id-react-select=Class
    ...    year-react-select=Year
    ...    month-react-select=Month
    ...    day-react-select=Date
    ${label}=    Get From Dictionary    ${label_map}    ${testid}
    # Exact text match (Playwright :text-is()), not substring — confirmed by the official
    # gqcustomer_frontend_e2e repo (student-details.page.ts): substring filtering collides,
    # e.g. "Class" is contained in "Board / Class / Stream".
    ${combobox}=    Set Variable    css=button[role='combobox']:has(:text-is("${label}"))
    Wait For Elements State    ${combobox}    enabled    timeout=${LONG_TIMEOUT}
    Evaluate JavaScript    ${combobox}    (el) => el.scrollIntoView({block: 'center', behavior: 'instant'})
    Click    ${combobox}
    Wait For Elements State    role=option >> nth=0    visible    timeout=${LONG_TIMEOUT}
    IF    '${option_text}' != ''
        Click    role=option >> text=${option_text} >> nth=0
    ELSE
        # ArrowDown+Enter keyboard nav is unreliable with the new cmdk-based Select —
        # click the first rendered option directly instead.
        Click    role=option >> nth=0
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
    ...    ${referral_code}    ${plan_identifier}=${EMPTY}

    # ── Resolve mobile ───────────────────────────────────────────────────────────
    ${resolved_mobile}=    Resolve Mobile Number    ${login_mobile}
    Log    Using mobile: ${resolved_mobile}    console=True
    Set Suite Variable    ${LAST_USED_MOBILE}    ${resolved_mobile}

    # ── Step 1: Login ────────────────────────────────────────────────────────────
    New Browser    ${BROWSER}    headless=${HEADLESS}    args=['--start-maximized']
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
        IF    '/applications' in '${url_after}'
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
    # DASHBOARD_TITLE testid is stale post-revamp (dashboard-shell.tsx has no such testid) —
    # URL assertion above is sufficient confirmation we landed on /applications.

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
    Select Option By Text In React Select    class-id-react-select    ${class}
    Fill Text    ${SD_STUDENT_ID}    ${student_id}
    Type Text    ${SD_LOAN_AMOUNT}    ${loan_amount}
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Choose Plan URL Should Be Active

    # ── Step 4: Choose Plan ───────────────────────────────────────────────────────
    # If a specific plan identifier is supplied (e.g. Ratnaafin's RCPL-dlg-prod-4),
    # select that plan; otherwise fall back to the first available plan.
    IF    '${plan_identifier}'.startswith('#')
        ${plan_idx}=    Evaluate    '${plan_identifier}'[1:]
        Click Plan In List By Index    ${plan_idx}
    ELSE IF    '${plan_identifier}' != ''
        Select Plan By Identifier    ${plan_identifier}
    ELSE
        Click First Plan In List
    END
    Click Submit Plan Button
    # /upload-address-proof/ can surface right here for some accounts (observed live) —
    # check and DB-bypass it before assuming the usual wizard order continues.
    ${_url_now}=    Get Url
    ${_app_id_now}=    Evaluate    next((p.split('#')[0] for p in '${_url_now}'.rstrip('/').split('/') if p.split('#')[0].isdigit()), '')
    IF    '${_app_id_now}' != ''
        Handle Address Proof Page If Present    ${_app_id_now}
    END
    # Existing accounts with prior applications land on /renewal-confirmation (Welcome Back).
    # Clicking CHANGE APPLICANT DETAILS returns to /who-is-applying (standard ACF flow).
    ${on_welcome_back}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=CHANGE APPLICANT DETAILS    visible    timeout=5s
    IF    ${on_welcome_back}
        Click    text=CHANGE APPLICANT DETAILS
    END
    # Some GILE configs skip /who-is-applying and land directly on /applicant-name.
    # Returning applicants (PAN already has basic details on file) can skip straight to /get-started.
    ${on_select}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    10s    500ms    Select Applicant URL Should Be Active
    ${on_onboarding}=    Set Variable    ${False}
    IF    not ${on_select}
        ${cur_url}=    Get Url
        ${on_onboarding}=    Evaluate    '/get-started' in '''${cur_url}'''
        IF    not ${on_onboarding}
            Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Basic Details URL Should Be Active
        ELSE
            Log    Returning applicant — basic details already on file, landed directly on /get-started    console=True
        END
    END

    # ── Step 5: Select Applicant (skipped when GILE pre-configures applicant type) ──
    IF    ${on_select}
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
    END

    # ── Step 6: Applicant Basic Details (skipped if already on /get-started) ────────
    IF    not ${on_onboarding}
        Wait For Elements State    ${BD_FIRST_NAME}    visible    timeout=${TIMEOUT}
        Fill Basic Details First Name    ${applicant_first_name}
        Fill Basic Details Last Name    ${applicant_last_name}
        # Newly added required field (pushed live) — "<Name>'s father's first name (as per
        # PAN card)". Label uses a curly apostrophe (U+2019) generated dynamically per
        # applicant name — match on "father" alone, which is unique to this field and
        # apostrophe-independent.
        ${father_field_present}=    Run Keyword And Return Status
        ...    Wait For Elements State    css=input[placeholder*="father"]    visible    timeout=3s
        IF    ${father_field_present}
            Fill Text    css=input[placeholder*="father"]    MK
        END
        Check Basic Details Consent
        Submit Basic Details Until Onboarding
    END

    # ── Step 7: Onboarding (app sometimes auto-skips straight to Personal Details) ──
    ${cur_url}=    Get Url
    ${on_personal_details}=    Evaluate    '/applicant-personal-details' in '''${cur_url}'''
    IF    not ${on_personal_details}
        Wait For Elements State    ${OB_INFO_ONE}    visible    timeout=${TIMEOUT}
        Click    ${OB_PROCEED_BUTTON}
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Personal Details URL Should Be Active
    ELSE
        Log    Onboarding auto-skipped — already on /applicant-personal-details    console=True
    END

    # ── Step 8: Applicant Personal Details ───────────────────────────────────────
    Wait For Elements State    ${PD_FORM}    visible    timeout=${LONG_TIMEOUT}
    Fill Text    ${PD_PAN_INPUT}    ${pan_number}
    Sleep    8s    # Wait for PAN lookup to complete before gender/DOB fields activate
    # Gender is radio buttons (button[value='MALE'] / button[value='FEMALE']), not a react-select
    ${gender_value}=    Evaluate    '${gender}'.upper()
    Wait Until Keyword Succeeds    45s    3s    Click Gender Button    ${gender_value}
    Select Specific Option In React Select    year-react-select    ${dob_year}
    Select Specific Option In React Select    month-react-select    ${dob_month}
    Select Specific Option In React Select    day-react-select    ${dob_day}
    Click    text=${marital_status}
    Fill Text    ${PD_EMAIL_INPUT}    ${email}
    ${consent_checked}=    Get Attribute    ${PD_CONSENT}    aria-checked
    IF    '${consent_checked}' != 'true'
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
    Wait For Elements State    ${RD_CITY_STATE}    visible    timeout=${LONG_TIMEOUT}
    Click    ${RD_PROCEED_BUTTON}
    Wait For Elements State    ${RD_RESIDENCE_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    text=${residence_type}
    Wait For Elements State    role=radio[checked]    visible    timeout=${TIMEOUT}
    Click    role=button[name=Proceed]
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active

    # ── Step 10-11: Employment Type + Details (2026 UI: one merged page, no URL change) ──
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}
    IF    '${employment_type}' == 'Salaried'
        Click    ${ET_SALARIED_CARD}
    ELSE
        Click    ${ET_SELF_EMPLOYED_CARD}
    END
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
            Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}
        ELSE
            Click    ${RC_SKIP_BUTTON}
        END
    END
    Check Confirm Application Consent
    IF    ${MANUAL_SUBMIT}
        Log    ⏸ MANUAL_SUBMIT=True — pausing at Confirm & Submit. Complete submission manually in the browser.    console=True
        Wait Until Keyword Succeeds    ${MANUAL_SUBMIT_TIMEOUT}    5s    Confirm Application Submitted Successfully
    ELSE
        Click Confirm Application Proceed
        # ── Step 13: Assert Success ───────────────────────────────────────────────────
        Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Confirm Application Submitted Successfully
    END

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
    Select Option By Text In React Select    class-id-react-select    ${class}
    Fill Text    ${SD_STUDENT_ID}    ${student_id}
    Type Text    ${SD_LOAN_AMOUNT}    ${loan_amount}
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
            Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}
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
    ...    Full E2E: Login → wizard → confirm submit → lender selection → real BRE decision → KYC or Bank Statement.
    ...    ${plan_index}=1 → uses Create Full Application (plan 1 via Click First Plan In List).
    ...    ${plan_index}=2 → uses Login And Navigate To Lender Selection New App plan_index=2.
    ...    ${lender_name}: if set, clicks that lender's continue button; else clicks first available.
    ...    Teardown: caller test must call Run Keyword And Ignore Error    Close Browser.
    [Arguments]
    ...    ${student_first_name}    ${student_last_name}    ${loan_amount}
    ...    ${applicant_first_name}    ${applicant_last_name}    ${pan_number}
    ...    ${dob_year}    ${dob_month}    ${dob_day}
    ...    ${email}    ${address_line1}    ${address_line2}    ${pincode}
    ...    ${employer_name}    ${monthly_salary}
    ...    ${plan_index}=1    ${lender_name}=${EMPTY}    ${institute_search}=${APP_INSTITUTE_SEARCH}
    ...    ${location}=${EMPTY}    ${board}=${EMPTY}    ${academic_year}=${EMPTY}    ${plan_identifier}=${EMPTY}
    IF    ${plan_index} == 1
        Create Full Application
        ...    ${EMPTY}    ${institute_search}    ${location}    ${board}    ${academic_year}
        ...    ${student_first_name}    ${student_last_name}    New Admission    Sr. Kg    SD12345
        ...    ${loan_amount}    Parent/Guardian    ${applicant_first_name}    ${applicant_last_name}
        ...    ${pan_number}    Male    ${dob_year}    ${dob_month}    ${dob_day}
        ...    Married    ${email}    ${address_line1}    ${address_line2}    ${pincode}
        ...    Self Owned    Salaried    ${employer_name}    ${monthly_salary}
        ...    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${EMPTY}    ${plan_identifier}
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ELSE
        Login And Navigate To Lender Selection New App    plan_index=${plan_index}
    END
    # Check if BRE already auto-assigned and moved past lender selection
    Sleep    2s
    ${cur_url}=    Get Url
    ${already_past}=    Evaluate    '/application-status/' in '${cur_url}' or '/upload-bank-statements/' in '${cur_url}' or '/kyc/' in '${cur_url}'
    IF    not ${already_past}
        Lender Selection Page Should Be Visible
        Check KFS Consent If Present
        IF    '${lender_name}' != '${EMPTY}'
            Click Lender Continue Button By Name    ${lender_name}
        ELSE
            Click First Available Continue Button
        END
        Wait For Bureau Decision
    ELSE
        Log    BRE auto-assigned — already on ${cur_url}, skipping lender selection    console=True
    END

Create Full Renewal Application With Lender Assignment
    [Documentation]
    ...    Full E2E renewal: Login (RENEWAL_MOBILE) → renewal wizard → confirm → lender selection → real BRE decision.
    ...    ${plan_index}=1 → uses Create Full Renewal Application (plan 1 via Click First Plan In List).
    ...    ${plan_index}=2 → uses Navigate To Lender Selection Renewal App plan_index=2.
    ...    ${lender_name}: if set, clicks that lender's continue button; else clicks first available.
    ...    Teardown: caller test must call Run Keyword And Ignore Error    Close Browser.
    [Arguments]    ${plan_index}=1    ${lender_name}=${EMPTY}
    IF    ${plan_index} == 1
        Create Full Renewal Application
        ...    ${APP_INSTITUTE_SEARCH}    ${EMPTY}    ${EMPTY}    ${EMPTY}
        ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    New Admission
        ...    ${EMPTY}    SD12345    ${APP_LOAN_AMOUNT}    ${EMPTY}
        Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Lender Selection URL Should Be Active
    ELSE
        Navigate To Lender Selection Renewal App    plan_index=${plan_index}
    END
    Lender Selection Page Should Be Visible
    Check KFS Consent If Present
    IF    '${lender_name}' != '${EMPTY}'
        Click Lender Continue Button By Name    ${lender_name}
    ELSE
        Click First Available Continue Button
    END
    Wait For Bureau Decision

Perform KYC Bypass Journey
    [Documentation]
    ...    Unified new/renewal E2E flow with DB-based KYC bypass.
    ...    journey_type='new'     — full 13-step wizard (dynamic fresh mobile), plan 1, Western Capital.
    ...    journey_type='renewal' — renewal flow (${RENEWAL_MOBILE} or override via mobile arg), plan 1, Western Capital.
    ...    On landing at /kyc/{app_id}: runs Bypass KYC Via Database, reloads page, asserts /sign-agreement/{app_id}.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, KycBypassDb library.
    [Arguments]    ${journey_type}=new    ${mobile}=${EMPTY}    ${lender_name}=Western Capital

    IF    '${journey_type}' == 'new'
        # Ratnaafin requires a specific GILE institute set + plan; all other lenders use defaults.
        ${is_ratnaafin}=    Evaluate    'ratnaafin' in '''${lender_name}'''.lower()
        ${is_mirae}=        Evaluate    'mirae' in '''${lender_name}'''.lower()
        ${is_csb}=          Evaluate    'csb' in '''${lender_name}'''.lower()
        ${is_tcl}=          Evaluate    'tata' in '''${lender_name}'''.lower() or 'tcl' in '''${lender_name}'''.lower()
        ${is_axis}=         Evaluate    'axis' in '''${lender_name}'''.lower() or 'afl' in '''${lender_name}'''.lower()
        IF    ${is_ratnaafin}
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH_RATNAAFIN}
            ${loc}=      Set Variable    ${APP_LOCATION_RATNAAFIN}
            ${brd}=      Set Variable    ${APP_BOARD_RATNAAFIN}
            ${yr}=       Set Variable    ${APP_ACADEMIC_YEAR_RATNAAFIN}
            ${plan}=     Set Variable    ${APP_PLAN_ID_RATNAAFIN}
        ELSE IF    ${is_mirae}
            # Mirae: Oaksmith institute set (same school dropdown CSB uses) + a specific plan tag.
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH_RATNAAFIN}
            ${loc}=      Set Variable    ${APP_LOCATION_RATNAAFIN}
            ${brd}=      Set Variable    ${APP_BOARD_RATNAAFIN}
            ${yr}=       Set Variable    ${APP_ACADEMIC_YEAR_RATNAAFIN}
            ${plan}=     Set Variable    ${APP_PLAN_ID_MIRAE}
        ELSE IF    ${is_csb}
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH_RATNAAFIN}
            ${loc}=      Set Variable    ${APP_LOCATION_RATNAAFIN}
            ${brd}=      Set Variable    ${APP_BOARD_RATNAAFIN}
            ${yr}=       Set Variable    ${APP_ACADEMIC_YEAR_RATNAAFIN}
            ${plan}=     Set Variable    ${APP_PLAN_ID_CSB}
        ELSE IF    ${is_tcl}
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH_RATNAAFIN}
            ${loc}=      Set Variable    ${APP_LOCATION_RATNAAFIN}
            ${brd}=      Set Variable    ${APP_BOARD_RATNAAFIN}
            ${yr}=       Set Variable    ${APP_ACADEMIC_YEAR_RATNAAFIN}
            ${plan}=     Set Variable    ${APP_PLAN_ID_TCL}
        ELSE IF    ${is_axis}
            # Axis Finance Ltd. / AFL: default institute (Masira Darvesh), plan matched by
            # the "AxisML" tag — the second plan in the list, per user confirmation.
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH}
            ${loc}=      Set Variable    ${EMPTY}
            ${brd}=      Set Variable    ${EMPTY}
            ${yr}=       Set Variable    ${EMPTY}
            ${plan}=     Set Variable    AxisML
        ELSE
            ${inst}=     Set Variable    ${APP_INSTITUTE_SEARCH}
            ${loc}=      Set Variable    ${EMPTY}
            ${brd}=      Set Variable    ${EMPTY}
            ${yr}=       Set Variable    ${EMPTY}
            ${plan}=     Set Variable    ${EMPTY}
        END
        Create Full Application With Lender Assignment
        ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    ${APP_LOAN_AMOUNT}
        ...    ${APP_FIRST_NAME}    ${APP_LAST_NAME}    ${APP_PAN_NUMBER}
        ...    ${APP_DOB_YEAR}    ${APP_DOB_MONTH}    ${APP_DOB_DAY}
        ...    ${APP_EMAIL}    ${APP_ADDRESS_LINE1}    ${APP_ADDRESS_LINE2}    ${APP_PINCODE}
        ...    ${APP_EMPLOYER_NAME}    ${APP_MONTHLY_SALARY}
        ...    plan_index=1    lender_name=${lender_name}
        ...    institute_search=${inst}    location=${loc}    board=${brd}
        ...    academic_year=${yr}    plan_identifier=${plan}
        ${active_mobile}=    Set Variable    ${LAST_USED_MOBILE}
    ELSE
        ${active_mobile}=    Set Variable If    '${mobile}'.strip() != ''    ${mobile}    ${RENEWAL_MOBILE}
        Create Full Renewal Application With Lender Assignment    plan_index=1    lender_name=${lender_name}
    END
    # Track journey context for the end-of-run summary (visible even if a later step fails).
    Set Test Variable    ${JOURNEY_MOBILE}    ${active_mobile}
    Set Test Variable    ${JOURNEY_LENDER}    ${lender_name}
    Set Test Variable    ${JOURNEY_STAGE}    Application Created & Lender Assigned
    Successful Lender Assignment Should Be Visible
    Set Test Variable    ${JOURNEY_STAGE}    Lender Approved (application-status)
    # Extract app ID from URL now (covers /kyc/, /application-status/, /upload-bank-statements/ all contain the ID)
    ${_post_bre_url}=    Get Url
    ${_early_app_id}=    Evaluate    next((p.split('#')[0] for p in '${_post_bre_url}'.rstrip('/').split('/') if p.split('#')[0].isdigit()), '')
    IF    '${_early_app_id}' != ''
        Set Test Variable    ${JOURNEY_APP_ID}    ${_early_app_id}
    END
    Click Proceed To KYC
    OKYC URL Should Be Active
    ${app_id}=    Extract App ID From OKYC URL
    Set Test Variable    ${JOURNEY_APP_ID}    ${app_id}
    Set Test Variable    ${JOURNEY_STAGE}    OKYC
    # KYC: by default the DB bypass inserts the KYC records directly (the live Digio SDK flow
    # hangs in automation). Set MANUAL_KYC=True to instead pause here so the operator completes
    # KYC by hand in the browser (Digilocker/OKYC), then the run resumes once it reaches /sign-agreement/.
    IF    ${MANUAL_KYC}
        Set Test Variable    ${JOURNEY_STAGE}    Awaiting Manual KYC
        Log    Manual KYC on app ${app_id} — complete Digilocker/OKYC in the browser. The run will resume automatically once the page reaches /sign-agreement/ (waiting up to ${MANUAL_KYC_TIMEOUT}).    console=True
        Wait Until Keyword Succeeds    ${MANUAL_KYC_TIMEOUT}    2s    Esign URL Should Be Active    ${app_id}
        Set Test Variable    ${JOURNEY_STAGE}    Manual KYC Done
    ELSE
        Bypass KYC Via Database    ${active_mobile}    ${app_id}    lender_name=${lender_name}
        Set Test Variable    ${JOURNEY_STAGE}    KYC Bypassed
        Reload
        Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Esign URL Should Be Active    ${app_id}
    END
    Set Test Variable    ${JOURNEY_STAGE}    eSign Page
    # eSign: tick the single consent checkbox and click Accept Terms & Conditions to sign.
    Complete Esign Step
    Set Test Variable    ${JOURNEY_STAGE}    eSign Signed
    # Down payment: proceed-to-pay → online payment → Razorpay UPI (test) → down-payment-status.
    Complete Down Payment Step    ${app_id}
    Set Test Variable    ${JOURNEY_STAGE}    Down Payment Paid (down-payment-status)
    # Final steps: enter the eNACH/selfie flow from the down-payment-status page.
    ${final_url}=    Enter Final Steps If Present    ${app_id}
    Set Test Variable    ${JOURNEY_STAGE}    Entered Final Steps (${final_url})
    # eNACH (Debit Card → Digio → NPCI Accept) then selfie DB bypass.
    Complete Nach And Selfie Step    ${app_id}
    Set Test Variable    ${JOURNEY_STAGE}    eNACH Done + Selfie Bypassed
    # Final step: alternate mobile + email verification (both OTP 9999) -> Start Fee Disbursal.
    Complete Additional Details Step    ${app_id}
    Set Test Variable    ${JOURNEY_STAGE}    Fee Disbursal Started
    RETURN    ${app_id}

Submit Basic Details Until Onboarding
    [Documentation]
    ...    Clicks Submit on the applicant-basic-details page and confirms the page advances to
    ...    /get-started. UAT intermittently no-ops the first submit (URL stays on
    ...    /applicant-name), so this re-clicks up to 4 times before failing.
    Wait Until Keyword Succeeds    4x    1s    Click Basic Details Submit And Confirm Onboarding

Click Basic Details Submit And Confirm Onboarding
    [Documentation]    One submit attempt — clicks Submit, then waits up to 10s for /get-started.
    Click Submit Basic Details
    Wait Until Keyword Succeeds    10s    500ms    Onboarding URL Should Be Active

Print Journey Summary
    [Documentation]
    ...    Prints a summary block of the journey context. Designed to run from Test Teardown
    ...    so it appears on every run — pass or fail — reporting the furthest stage reached.
    ...    Reads test variables set during Perform KYC Bypass Journey, with safe fallbacks.
    ...    Also sends a Slack notification if SLACK_WEBHOOK_URL is set.
    ${app_id}=     Get Variable Value    ${JOURNEY_APP_ID}    ${EMPTY}
    # Fallback: extract app ID from current URL if not yet set
    IF    '${app_id}' == '${EMPTY}'
        ${_cur_url}=    Run Keyword And Return Status    Get Url
        ${_url}=        Run Keyword And Ignore Error    Get Url
        ${_url_val}=    Set Variable If    ${_cur_url}    ${_url[1]}    ${EMPTY}
        ${app_id}=      Evaluate
        ...    next((p for p in '${_url_val}'.rstrip('/').split('/') if p.isdigit()), '(not reached)')
    END
    ${lender}=     Get Variable Value    ${JOURNEY_LENDER}    ${LENDER_NAME}
    ${mobile}=     Get Variable Value    ${JOURNEY_MOBILE}    (not reached)
    ${stage}=      Get Variable Value    ${JOURNEY_STAGE}     Login / Start
    # Test status + failure message are exposed by Robot in teardown. Collapse the error to one line.
    ${status}=     Get Variable Value    ${TEST_STATUS}      (running)
    ${msg}=        Get Variable Value    ${TEST_MESSAGE}     ${EMPTY}
    ${error}=      Evaluate    $msg.splitlines()[0] if $msg else 'none'
    Log    ==================================================    console=True
    Log    JOURNEY SUMMARY    console=True
    Log    APP ID: ${app_id}    console=True
    Log    LENDER: ${lender}    console=True
    Log    MOBILE: ${mobile}    console=True
    Log    STAGE: ${stage}    console=True
    Log    RESULT: ${status}    console=True
    Log    ERROR: ${error}    console=True
    Log    ==================================================    console=True
    # Send Slack notification
    Run Keyword And Ignore Error
    ...    Send Slack Notification
    ...    app_id=${app_id}
    ...    pan=${APP_PAN_NUMBER}
    ...    mobile=${mobile}
    ...    lender=${lender}
    ...    stage=${stage}
    ...    status=${status}
    ...    error=${error}
    # Send Email notification
    Run Keyword And Ignore Error
    ...    Send Email Notification
    ...    app_id=${app_id}
    ...    pan=${APP_PAN_NUMBER}
    ...    mobile=${mobile}
    ...    lender=${lender}
    ...    stage=${stage}
    ...    status=${status}
    ...    error=${error}

Navigate To Esign New App
    [Documentation]
    ...    Suite Setup for agreement/sign-agreement tests — new application journey.
    ...    Calls Perform KYC Bypass Journey (journey_type=new, plan 1, Western Capital),
    ...    then extracts and stores the esign app ID as ${ESIGN_APP_ID} suite variable.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, KycBypassDb library.
    Perform KYC Bypass Journey    journey_type=new
    ${app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${ESIGN_APP_ID}    ${app_id}

Navigate To Down Payment New App
    [Documentation]
    ...    Suite Setup for downpayment tests — new application journey.
    ...    Full path: login (fresh dynamic mobile) → wizard (plan 1) → Western Capital (real BRE)
    ...    → KYC DB bypass → /kyc/ → reload to /sign-agreement/ → sign agreement → /down-payment/{app_id}.
    ...    Extracts and stores app ID as ${DP_APP_ID} suite variable.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, EsignPage.robot,
    ...    DownPaymentPage.robot, KycBypassDb library.
    Perform KYC Bypass Journey    journey_type=new
    ${esign_app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${ESIGN_APP_ID}    ${esign_app_id}
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Down Payment URL Should Be Active    ${ESIGN_APP_ID}
    ${dp_app_id}=    Extract App ID From Down Payment URL
    Set Suite Variable    ${DP_APP_ID}    ${dp_app_id}

Navigate To Esign Renewal App
    [Documentation]
    ...    Suite Setup for agreement/sign-agreement tests — renewal application journey.
    ...    Uses ${RENEWAL_MOBILE}. Calls Perform KYC Bypass Journey (journey_type=renewal),
    ...    then extracts and stores the esign app ID as ${ESIGN_APP_ID} suite variable.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, KycBypassDb library.
    Perform KYC Bypass Journey    journey_type=renewal
    ${app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${ESIGN_APP_ID}    ${app_id}

Navigate To Down Payment Change Plan App
    [Documentation]
    ...    Suite Setup for change plan tests — Thakkar International Academy (EMI_PLAN_CHANGE=true).
    ...    Full path: login (fresh dynamic mobile) → wizard → Western Capital (real BRE)
    ...    → KYC DB bypass → /kyc/ → reload to /sign-agreement/ → sign → /down-payment/{app_id}.
    ...    Sets ${DP_CHANGE_APP_ID} suite variable. Change plan card is visible on landing.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, EsignPage.robot,
    ...    DownPaymentPage.robot, KycBypassDb library.
    Create Full Application With Lender Assignment
    ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    ${APP_LOAN_AMOUNT}
    ...    ${APP_FIRST_NAME}    ${APP_LAST_NAME}    ${APP_PAN_NUMBER}
    ...    ${APP_DOB_YEAR}    ${APP_DOB_MONTH}    ${APP_DOB_DAY}
    ...    ${APP_EMAIL}    ${APP_ADDRESS_LINE1}    ${APP_ADDRESS_LINE2}    ${APP_PINCODE}
    ...    ${APP_EMPLOYER_NAME}    ${APP_MONTHLY_SALARY}
    ...    plan_index=1    lender_name=Western Capital    institute_search=Thakkar International Academy
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active
    ${app_id}=    Extract App ID From OKYC URL
    Bypass KYC Via Database    ${LAST_USED_MOBILE}    ${app_id}
    Reload
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Esign URL Should Be Active    ${app_id}
    ${esign_app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${ESIGN_APP_ID}    ${esign_app_id}
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Down Payment URL Should Be Active    ${ESIGN_APP_ID}
    ${dp_change_app_id}=    Extract App ID From Down Payment URL
    Set Suite Variable    ${DP_CHANGE_APP_ID}    ${dp_change_app_id}

Navigate To Down Payment Lower EMI App
    [Documentation]
    ...    Suite Setup for lower EMI change plan tests — Ashvini Varhade (EMI_PLAN_CHANGE=true, plans with DP).
    ...    Full path: login (fresh dynamic mobile) → wizard → Western Capital (real BRE)
    ...    → KYC DB bypass → /kyc/ → reload to /sign-agreement/ → sign → /down-payment/{app_id}.
    ...    Sets ${DP_LOWER_EMI_APP_ID} suite variable. Lower EMI change plan card visible on landing.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, EsignPage.robot,
    ...    DownPaymentPage.robot, KycBypassDb library.
    Create Full Application With Lender Assignment
    ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    ${APP_LOAN_AMOUNT}
    ...    ${APP_FIRST_NAME}    ${APP_LAST_NAME}    ${APP_PAN_NUMBER}
    ...    ${APP_DOB_YEAR}    ${APP_DOB_MONTH}    ${APP_DOB_DAY}
    ...    ${APP_EMAIL}    ${APP_ADDRESS_LINE1}    ${APP_ADDRESS_LINE2}    ${APP_PINCODE}
    ...    ${APP_EMPLOYER_NAME}    ${APP_MONTHLY_SALARY}
    ...    plan_index=1    lender_name=Western Capital    institute_search=Ashvini Varhade
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active
    ${app_id}=    Extract App ID From OKYC URL
    Bypass KYC Via Database    ${LAST_USED_MOBILE}    ${app_id}
    Reload
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Esign URL Should Be Active    ${app_id}
    ${esign_app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${ESIGN_APP_ID}    ${esign_app_id}
    Accept Terms And Sign Agreement
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Down Payment URL Should Be Active    ${ESIGN_APP_ID}
    ${dp_lower_emi_app_id}=    Extract App ID From Down Payment URL
    Set Suite Variable    ${DP_LOWER_EMI_APP_ID}    ${dp_lower_emi_app_id}

Navigate To Esign New App With Plan
    [Documentation]
    ...    Per-test Setup keyword — opens a fresh browser, creates a new application with the given
    ...    plan_index, selects Western Capital, bypasses KYC via DB, and lands on /sign-agreement/{app_id}.
    ...    Stores the esign app ID as ${NACH_APP_ID} suite variable (named for plan 6 NACH use-case).
    ...    plan_index=1 → /down-payment after esign; plan_index=6 → /mandate after esign.
    ...    Calling suite MUST import: LenderSelectionPage.robot, OKYCPage.robot, KycBypassDb library.
    [Arguments]    ${plan_index}=6
    Login And Navigate To Lender Selection New App    plan_index=${plan_index}
    Check KFS Consent If Present
    Click Lender Continue Button By Name    Western Capital
    Wait For Bureau Decision
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active
    ${app_id}=    Extract App ID From OKYC URL
    Bypass KYC Via Database    ${APP_CREATION_MOBILE}    ${app_id}
    Reload
    Wait Until Keyword Succeeds    ${SUBMISSION_TIMEOUT}    500ms    Esign URL Should Be Active    ${app_id}
    ${esign_app_id}=    Extract App ID From Esign URL
    Set Suite Variable    ${NACH_APP_ID}    ${esign_app_id}
