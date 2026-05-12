# Customer Portal UI Automation

Robot Framework end-to-end test suite for the GQ Customer Portal.
Covers the login left component, mobile number login form, OTP verification flow, bypass authentication, dashboard, full Application Creation Flow wizard (10 pages, TC-5001–TC-13025), E2E journeys (smoke, resume, renewal, lender selection), Renewal Journey Flow (screen-by-screen), and Lender Selection Bureau Flow (BRE mocking, KYC redirect, bank statement upload) — all targeting the UAT environment (`https://customer.uat.graydev.in`).

> **Test Cases:** See [`CP_UI_Automation_Test_Cases.xlsx`](./CP_UI_Automation_Test_Cases.xlsx) for the full test case list with descriptions, steps, and expected results.

---

## Project Structure

```
customer_portal_ui_automation/
├── tests/
│   ├── login_left_component_tests.robot      # Left panel component tests (9 tests, TC-101–109)
│   ├── login_tests.robot                     # Login form tests (23 tests, TC-201, TC-207–228)
│   ├── otp_tests.robot                       # OTP verification tests (18 tests, 3 skipped, TC-301–318)
│   ├── bypass_auth_tests.robot               # Bypass auth tests (4 tests, 3 skipped)
│   ├── dashboard/
│   │   ├── dashboard_tests.robot             # Dashboard — header/create-app/insurance/logout (11 tests, 2 skipped)
│   │   ├── dashboard_emi_tests.robot         # EMI tab tests (5 tests; DASHBOARD_MOBILE)
│   │   ├── dashboard_ad_tests.robot          # Auto Debit tab tests (10 tests; AD_MOBILE)
│   │   ├── dashboard_pg_tests.robot          # Transaction History tab tests (21 tests; PG_MOBILE)
│   │   ├── dashboard_new_user_tests.robot    # New-user empty state tests (4 tests; DASHBOARD_NEW_MOBILE)
│   │   ├── dashboard_ins_tests.robot         # Insurance tab tests (11 tests; INS_MOBILE)
│   │   └── dashboard_ins_new_user_tests.robot # Insurance new-user tests (4 tests; DASHBOARD_NEW_MOBILE)
│   ├── e2e/
│   │   ├── e2e_create_application_tests.robot    # Full E2E flow: Login → Confirm & Submit (data-driven via application_data.xlsx)
│   │   ├── smoke_e2e_tests.robot                 # Single fixed happy-path E2E — Salaried Parent Guardian (1 test)
│   │   ├── resume_journey_e2e_tests.robot        # Close-and-resume at every wizard page (9 tests; RESUME_MOBILE)
│   │   ├── renewal_flow_e2e_tests.robot          # Data-driven renewal E2E: nth application happy path (RENEWAL_MOBILE)
│   │   └── lender_selection_e2e_tests.robot      # Lender selection E2E: new+renewal × APPROVED+REJECTED (4 tests, TC-LS-E01–E04)
│   ├── renewal_journey_flow/
│   │   ├── student_details_tests.robot           # Renewal: /student-details — same UI as ACF (7 tests, TC-R5001–R5007)
│   │   ├── choose_plan_tests.robot               # Renewal: /choose-plan — same UI as ACF (8 tests, TC-R6001–R6008)
│   │   ├── welcome_back_tests.robot              # Renewal: Welcome Back screen (6 tests, TC-WB01–WB06)
│   │   └── verify_details_tests.robot            # Renewal: Verify Details — edit/skip/confirm (25 tests, TC-VD01–VD25)
│   ├── lender_selection/
│   │   ├── bureau_lender_flow_tests.robot           # BRE mocked bureau flow: 4 core scenarios (TC_LENDER_01–04; smoke+partial; robot:skip)
│   │   ├── bureau_lender_approval_tests.robot       # Real BRE approval: Western Capital → KYC (1 test, TC-LS-NA01; lender-approval)
│   │   ├── bureau_lender_rejection_tests.robot      # Real BRE rejection: plan-specific edge cases (5 tests, TC-LS-NR01–05; lender-rejection; isolated sessions)
│   │   ├── bureau_lender_screen_UI_tests.robot      # New app lender selection UI (13 tests, TC-LS-N00–N12; lender-selection-new)
│   │   ├── bureau_lender_flow_renewalapp_tests.robot # Renewal lender selection UI (4 tests, TC-LS-R01–R04; lender-selection-renewal)
│   │   └── bank_statement_tests.robot               # Bank statement journey (6 tests, robot:skip until testids confirmed)
│   └── application_creation_flow/
│       ├── student_details_tests.robot           # /student-details (40 tests, TC-5001–5N-13)
│       ├── choose_plan_tests.robot               # /choose-plan (18 tests, TC-6001–6018)
│       ├── select_applicant_tests.robot          # /select-applicant (19 tests, TC-7001–7020)
│       ├── applicant_basic_details_tests.robot   # /applicant-basic-details (23 tests, TC-8001–8014-S)
│       ├── onboarding_tests.robot                # /onboarding (7 tests, TC-9001–9N-01)
│       ├── personal_details_tests.robot          # /applicant-personal-details (18 tests, TC-10001–10N-10)
│       ├── residential_details_tests.robot       # /applicant-residential-details (12 tests, TC-11001–11N-05)
│       ├── employment_tests.robot                # /select-employment + /applicant-employment-details (46 tests, TC-12001–12N-SE06)
│       └── confirm_application_tests.robot       # /confirm-application (20 tests, TC-13001–13025)
├── resources/
│   ├── LoginLeftComponent.robot              # Page object keywords for left panel
│   ├── LoginPage.robot                       # Page object keywords for / (login page)
│   ├── OTPPage.robot                         # Page object keywords for /verify (OTP page)
│   ├── BypassAuthPage.robot                  # Page object keywords for /instant-eligibility
│   ├── DashboardPage.robot                   # Page object keywords for /my-applications
│   ├── InsuranceDashboardPage.robot          # Page object keywords for /my-applications#ins
│   ├── ApplicationCreationFlowPage.robot     # Wizard navigation infrastructure + traversal helpers (incl. renewal keywords)
│   ├── E2EApplicationFlow.robot              # High-level E2E keywords: Create Full Application, Create Full Renewal Application, lender assignment variants
│   ├── LenderSelectionPage.robot             # Page object keywords for /application-loader/{app_id} (lender selection + BRE mocking)
│   ├── OKYCPage.robot                        # Page object keywords for /okyc/{app_id} (KYC URL assertion)
│   ├── BankStatementPage.robot               # Page object keywords for bank statement journey (stub; PENDING TESTID)
│   ├── StudentDetailsPage.robot              # Page object keywords for /student-details
│   ├── ChoosePlanPage.robot                  # Page object keywords for /choose-plan
│   ├── SelectApplicantPage.robot             # Page object keywords for /select-applicant
│   ├── ApplicantBasicDetailsPage.robot       # Page object keywords for /applicant-basic-details
│   ├── OnboardingPage.robot                  # Page object keywords for /onboarding
│   ├── ApplicantPersonalDetailsPage.robot    # Page object keywords for /applicant-personal-details
│   ├── ApplicantResidentialDetailsPage.robot # Page object keywords for /applicant-residential-details
│   ├── EmploymentTypePage.robot              # Page object keywords for /select-employment
│   ├── ApplicantEmploymentPage.robot         # Page object keywords for /applicant-employment-details
│   ├── ConfirmApplicationPage.robot          # Page object keywords for /confirm-application
│   ├── WelcomeBackPage.robot                 # Page object keywords for Welcome Back screen (renewal)
│   ├── WelcomeBackPage.robot                 # Page object keywords for Welcome Back screen (renewal)
│   └── VerifyDetailsPage.robot               # Page object keywords for Verify Details screen (renewal)
├── variables/
│   └── variables.robot                       # All test configuration, test data, and APP_* wizard variables
├── CP_UI_Automation_Test_Cases.xlsx          # Full test case documentation
└── results/                                  # Robot Framework output (output.xml, log.html, report.html)
```

---

## Prerequisites

- Python 3.x
- Robot Framework 7.4.2
- Browser (Playwright) library v19.9.0
- Playwright browsers initialised (`rfbrowser init`)

All dependencies live in the project virtualenv at `./env/`.

---

## Running Tests

### Run all suites

```bash
./env/bin/robot --outputdir results/ tests/
```

### Run a single suite

```bash
# Auth
./env/bin/robot --outputdir results/ tests/login_left_component_tests.robot
./env/bin/robot --outputdir results/ tests/login_tests.robot
./env/bin/robot --outputdir results/ tests/otp_tests.robot
./env/bin/robot --outputdir results/ tests/bypass_auth_tests.robot

# Dashboard
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_emi_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_ad_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_pg_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_new_user_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_ins_tests.robot
./env/bin/robot --outputdir results/ tests/dashboard/dashboard_ins_new_user_tests.robot

# E2E
./env/bin/robot --outputdir results/ tests/e2e/e2e_create_application_tests.robot
./env/bin/robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot
./env/bin/robot --outputdir results/ tests/e2e/resume_journey_e2e_tests.robot
./env/bin/robot --outputdir results/ tests/e2e/renewal_flow_e2e_tests.robot

# Renewal Journey Flow
./env/bin/robot --outputdir results/ tests/renewal_journey_flow/student_details_tests.robot
./env/bin/robot --outputdir results/ tests/renewal_journey_flow/choose_plan_tests.robot
./env/bin/robot --outputdir results/ tests/renewal_journey_flow/welcome_back_tests.robot
./env/bin/robot --outputdir results/ tests/renewal_journey_flow/verify_details_tests.robot

# Lender Selection
./env/bin/robot --outputdir results/ tests/lender_selection/bureau_lender_flow_tests.robot
./env/bin/robot --outputdir results/ tests/lender_selection/bureau_lender_approval_tests.robot
./env/bin/robot --outputdir results/ tests/lender_selection/bureau_lender_rejection_tests.robot
./env/bin/robot --outputdir results/ tests/lender_selection/bureau_lender_screen_UI_tests.robot
./env/bin/robot --outputdir results/ tests/lender_selection/bureau_lender_flow_renewalapp_tests.robot
./env/bin/robot --outputdir results/ tests/lender_selection/bank_statement_tests.robot
./env/bin/robot --outputdir results/ tests/e2e/lender_selection_e2e_tests.robot

# Application Creation Flow
./env/bin/robot --outputdir results/ tests/application_creation_flow/student_details_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/choose_plan_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/select_applicant_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/applicant_basic_details_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/onboarding_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/personal_details_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/residential_details_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/employment_tests.robot
./env/bin/robot --outputdir results/ tests/application_creation_flow/confirm_application_tests.robot
```

### Run by tag

```bash
./env/bin/robot --include smoke --outputdir results/ tests/
./env/bin/robot --include login --outputdir results/ tests/
./env/bin/robot --include otp --outputdir results/ tests/
./env/bin/robot --include bypass-auth --outputdir results/ tests/
./env/bin/robot --include dashboard --outputdir results/ tests/
./env/bin/robot --include application-creation-flow --outputdir results/ tests/
./env/bin/robot --include negative --outputdir results/ tests/
./env/bin/robot --include salaried --outputdir results/ tests/application_creation_flow/employment_tests.robot
./env/bin/robot --include self-employed --outputdir results/ tests/application_creation_flow/employment_tests.robot
./env/bin/robot --include resend --outputdir results/ tests/otp_tests.robot    # ~3 min
./env/bin/robot --include e2e --outputdir results/ tests/e2e/
./env/bin/robot --include renewal --outputdir results/ tests/
./env/bin/robot --include renewal-journey-flow --outputdir results/ tests/renewal_journey_flow/
./env/bin/robot --include skip-journey --outputdir results/ tests/renewal_journey_flow/verify_details_tests.robot
./env/bin/robot --include edit-residential --outputdir results/ tests/renewal_journey_flow/verify_details_tests.robot
./env/bin/robot --include edit-employment --outputdir results/ tests/renewal_journey_flow/verify_details_tests.robot
./env/bin/robot --include lender-selection --outputdir results/ tests/
./env/bin/robot --include lender-selection-new --outputdir results/ tests/
./env/bin/robot --include lender-selection-renewal --outputdir results/ tests/
./env/bin/robot --include lender-approval --outputdir results/ tests/
./env/bin/robot --include lender-rejection --outputdir results/ tests/
./env/bin/robot --include bank-statement --outputdir results/ tests/
./env/bin/robot --include lender-selection-e2e --outputdir results/ tests/
./env/bin/robot --include partial --outputdir results/ tests/lender_selection/bureau_lender_flow_tests.robot
```

### Dry run (syntax check, no browser)

```bash
./env/bin/robot --dryrun tests/
```

### Override base URL or mobile number

```bash
./env/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999900000 ./env/bin/robot --outputdir results/ tests/
BYPASS_AUTH_MOBILE=<erp_mobile> ./env/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
```

---

## Test Suites Summary

| Suite File | Tests | Page(s) |
|------------|-------|---------|
| login_left_component_tests | 9 | Left panel |
| login_tests | 23 | / (login form) |
| otp_tests | 18 (3 skipped) | /verify |
| bypass_auth_tests | 4 (3 skipped) | /instant-eligibility |
| dashboard/dashboard_tests | 11 (2 skipped) | /my-applications |
| dashboard/dashboard_emi_tests | 5 | /my-applications#emi |
| dashboard/dashboard_ad_tests | 10 | /my-applications#ad |
| dashboard/dashboard_pg_tests | 21 | /my-applications#direct |
| dashboard/dashboard_new_user_tests | 4 | /my-applications (new user) |
| dashboard/dashboard_ins_tests | 11 | /my-applications#ins |
| dashboard/dashboard_ins_new_user_tests | 4 | /my-applications#ins (new user) |
| e2e/e2e_create_application_tests | — (data-driven) | Login → Confirm & Submit |
| e2e/smoke_e2e_tests | 1 | Full wizard — single salaried happy path |
| e2e/resume_journey_e2e_tests | 9 | Close + resume at each wizard page |
| e2e/renewal_flow_e2e_tests | — (data-driven) | Renewal E2E (RENEWAL_MOBILE) |
| renewal_journey_flow/student_details_tests | 7 | /student-details (renewal) |
| renewal_journey_flow/choose_plan_tests | 8 | /choose-plan (renewal) |
| renewal_journey_flow/welcome_back_tests | 6 | Welcome Back screen |
| renewal_journey_flow/verify_details_tests | 25 | Verify Details — edit, skip, confirm |
| lender_selection/bureau_lender_flow_tests | 4 | /application-loader/{app_id} — BRE mocked bureau scenarios (robot:skip) |
| lender_selection/bureau_lender_approval_tests | 1 | /application-loader/{app_id} — real BRE approval → KYC |
| lender_selection/bureau_lender_rejection_tests | 5 | /application-loader/{app_id} — real BRE rejection edge cases (isolated sessions) |
| lender_selection/bureau_lender_screen_UI_tests | 13 | /application-loader/{app_id} — new app lender selection UI |
| lender_selection/bureau_lender_flow_renewalapp_tests | 4 | /application-loader/{app_id} — renewal lender selection UI |
| lender_selection/bank_statement_tests | 6 (all skipped) | /bank-statement/{app_code} |
| e2e/lender_selection_e2e_tests | 4 | Full E2E: new+renewal × APPROVED+REJECTED |
| application_creation_flow/student_details_tests | 40 | /student-details |
| application_creation_flow/choose_plan_tests | 18 | /choose-plan |
| application_creation_flow/select_applicant_tests | 19 | /select-applicant |
| application_creation_flow/applicant_basic_details_tests | 23 | /applicant-basic-details |
| application_creation_flow/onboarding_tests | 7 | /onboarding |
| application_creation_flow/personal_details_tests | 18 | /applicant-personal-details |
| application_creation_flow/residential_details_tests | 12 | /applicant-residential-details |
| application_creation_flow/employment_tests | 46 | /select-employment + /applicant-employment-details |
| application_creation_flow/confirm_application_tests | 20 | /confirm-application |
| **Total** | **409** (+ data-driven rows; 6 skipped bank-statement) | |

---

## Configuration

All configuration is in `variables/variables.robot`.

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://customer.uat.graydev.in` | Target environment URL |
| `TEST_MOBILE` | `%{TEST_MOBILE=9876543210}` | Default login mobile |
| `BYPASS_AUTH_MOBILE` | `%{BYPASS_AUTH_MOBILE=9876543210}` | ERP-whitelisted mobile for TC-401 |
| `TEST_OTP` | `9999` | Fixed UAT OTP |
| `BROWSER` | `chromium` | Playwright browser |
| `HEADLESS` | `True` | Headless mode toggle |
| `TIMEOUT` | `10s` | Standard element wait |
| `LONG_TIMEOUT` | `30s` | Extended wait (navigation, API) |
| `DASHBOARD_MOBILE` | `8108556708` | Dashboard suite — has active EMI applications |
| `AD_MOBILE` | `8763694182` | Auto Debit suite account |
| `PG_MOBILE` | `7757855472` | Transaction History suite account |
| `INS_MOBILE` | `8668768645` | Insurance tab suite account |
| `APP_CREATION_MOBILE` | dynamic (`dynamic_variables.py`) | Dedicated mobile for all wizard suites |
| `APP_FIRST_NAME / LAST_NAME` | `Test / Parent` | Applicant stub name |
| `APP_PAN_NUMBER` | `ABCDE1234F` | Stub PAN |
| `APP_EMAIL` | `testparent@example.com` | Stub email |
| `APP_ADDRESS_LINE1/2` | `123 Test Street / Test Area` | Stub address |
| `APP_PINCODE` | `400001` | Stub pincode |
| `APP_EMPLOYER_NAME` | `Test Company Pvt Ltd` | Salaried stub |
| `APP_MONTHLY_SALARY` | `50000` | Salaried stub |
| `APP_BUSINESS_NAME` | `Test Business` | Self-employed stub |
| `APP_BUSINESS_INCOME` | `600000` | Self-employed stub |
| `APP_BUSINESS_YEARS` | `05` | Self-employed stub |
| `RENEWAL_MOBILE` | `%{RENEWAL_MOBILE=8108556708}` | Existing account for renewal/nth application journey |
| `RESUME_MOBILE` | `%{RESUME_MOBILE=9876543210}` | Account kept in-progress for resume journey tests |

---

## UAT Environment Notes

**Service window:** UAT is unavailable **9pm – 7am** daily.

**Fixed OTP:** UAT has OTP `9999` pre-configured for all mobile numbers. No SMS dependency.

**checkMobilePost rate limit:** ~3 calls per ~60 seconds per IP. `Navigate To OTP Page` auto-detects and retries after `RATE_LIMIT_WAIT` (45s).

**Application Creation Flow session model:** Each wizard suite has its own independent `Suite Setup` that traverses the full wizard from login. `Test Setup` hard-navigates to the target page within the existing session.

**Dashboard session model:** Dashboard tests are split across 7 independent files under `tests/dashboard/`, each with its own browser session and dedicated `Suite Setup` login.

---

## Locator Strategy

All selectors use `data-testid` attributes. No CSS class names or absolute XPath.

| Element | Selector |
|---------|----------|
| Login form | `css=[data-testid='login-form']` |
| Mobile input | `css=[data-testid='mobile-number-input']` |
| Consent checkbox | `css=[data-testid='consent-checkbox']` |
| Send OTP button | `css=[data-testid='send-otp-button']` |
| OTP input | `css=[data-testid='otp-input']` |
| Dashboard title | `css=[data-testid='dashboard-title']` |
| Profile button | `css=[data-testid='profile-button']` |
| EMI tab | `css=[data-testid='emi-tab-navigation-button']` |
| Insurance tab | `css=[data-testid='ins-tab-navigation-button']` |

---

## Results

After a run, open `results/report.html` for the full test report or `results/log.html` for detailed step-by-step logs.
