# Customer Portal UI Automation

Robot Framework end-to-end test suite for the GQ Customer Portal.
Covers the login left component, mobile number login form, OTP verification flow, bypass authentication, dashboard, and the full Application Creation Flow wizard (10 pages, TC-5001–TC-13025) — all targeting the UAT environment (`https://customer.uat.graydev.in`).

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
│   ├── dashboard_tests.robot                 # Dashboard — header/create-app/insurance/logout (11 tests, 2 skipped)
│   ├── dashboard_emi_tests.robot             # EMI tab tests (5 tests; DASHBOARD_MOBILE)
│   ├── dashboard_ad_tests.robot              # Auto Debit tab tests (10 tests; AD_MOBILE)
│   ├── dashboard_pg_tests.robot              # Transaction History tab tests (21 tests; PG_MOBILE)
│   ├── dashboard_new_user_tests.robot        # New-user empty state tests (4 tests; DASHBOARD_NEW_MOBILE)
│   ├── dashboard_ins_tests.robot             # Insurance tab tests (11 tests; INS_MOBILE)
│   ├── dashboard_ins_new_user_tests.robot    # Insurance new-user tests (4 tests; DASHBOARD_NEW_MOBILE)
│   ├── student_details_tests.robot           # /student-details (40 tests, TC-5001–5N-13)
│   ├── choose_plan_tests.robot               # /choose-plan (16 tests, TC-6001–6016)
│   ├── select_applicant_tests.robot          # /select-applicant (10 tests, TC-7001–7011)
│   ├── applicant_journey_tests.robot         # /applicant-basic-details (23 tests, TC-8001–8014-S)
│   ├── onboarding_tests.robot                # /onboarding (7 tests, TC-9001–9N-01)
│   ├── personal_details_tests.robot          # /applicant-personal-details (15 tests, TC-10001–10N-07)
│   ├── residential_details_tests.robot       # /applicant-residential-details (12 tests, TC-11001–11N-05)
│   ├── employment_tests.robot                # /select-employment + /applicant-employment-details (42 tests, TC-12001–12N-SE06)
│   └── confirm_application_tests.robot       # /confirm-application (20 tests, TC-13001–13025)
├── resources/
│   ├── LoginLeftComponent.robot              # Page object keywords for left panel
│   ├── LoginPage.robot                       # Page object keywords for / (login page)
│   ├── OTPPage.robot                         # Page object keywords for /verify (OTP page)
│   ├── BypassAuthPage.robot                  # Page object keywords for /instant-eligibility
│   ├── DashboardPage.robot                   # Page object keywords for /my-applications
│   ├── InsuranceDashboardPage.robot          # Page object keywords for /my-applications#ins
│   ├── ApplicationCreationFlowPage.robot     # Wizard navigation infrastructure + traversal helpers
│   ├── StudentDetailsPage.robot              # Page object keywords for /student-details
│   ├── ChoosePlanPage.robot                  # Page object keywords for /choose-plan
│   ├── SelectApplicantPage.robot             # Page object keywords for /select-applicant
│   ├── ApplicantBasicDetailsPage.robot       # Page object keywords for /applicant-basic-details
│   ├── OnboardingPage.robot                  # Page object keywords for /onboarding
│   ├── ApplicantPersonalDetailsPage.robot    # Page object keywords for /applicant-personal-details
│   ├── ApplicantResidentialDetailsPage.robot # Page object keywords for /applicant-residential-details
│   ├── EmploymentTypePage.robot              # Page object keywords for /select-employment
│   ├── ApplicantEmploymentPage.robot         # Page object keywords for /applicant-employment-details
│   └── ConfirmApplicationPage.robot          # Page object keywords for /confirm-application
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

All dependencies live in the project virtualenv at `./venv/`.

---

## Running Tests

### Run all suites

```bash
./venv/bin/robot --outputdir results/ tests/
```

### Run a single suite

```bash
# Auth
./venv/bin/robot --outputdir results/ tests/login_left_component_tests.robot
./venv/bin/robot --outputdir results/ tests/login_tests.robot
./venv/bin/robot --outputdir results/ tests/otp_tests.robot
./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot

# Dashboard
./venv/bin/robot --outputdir results/ tests/dashboard_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_emi_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ad_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_pg_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_new_user_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ins_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ins_new_user_tests.robot

# Application Creation Flow
./venv/bin/robot --outputdir results/ tests/student_details_tests.robot
./venv/bin/robot --outputdir results/ tests/choose_plan_tests.robot
./venv/bin/robot --outputdir results/ tests/select_applicant_tests.robot
./venv/bin/robot --outputdir results/ tests/applicant_journey_tests.robot
./venv/bin/robot --outputdir results/ tests/onboarding_tests.robot
./venv/bin/robot --outputdir results/ tests/personal_details_tests.robot
./venv/bin/robot --outputdir results/ tests/residential_details_tests.robot
./venv/bin/robot --outputdir results/ tests/employment_tests.robot
./venv/bin/robot --outputdir results/ tests/confirm_application_tests.robot
```

### Run by tag

```bash
./venv/bin/robot --include smoke --outputdir results/ tests/
./venv/bin/robot --include login --outputdir results/ tests/
./venv/bin/robot --include otp --outputdir results/ tests/
./venv/bin/robot --include bypass-auth --outputdir results/ tests/
./venv/bin/robot --include dashboard --outputdir results/ tests/
./venv/bin/robot --include application-creation-flow --outputdir results/ tests/
./venv/bin/robot --include negative --outputdir results/ tests/
./venv/bin/robot --include salaried --outputdir results/ tests/employment_tests.robot
./venv/bin/robot --include self-employed --outputdir results/ tests/employment_tests.robot
./venv/bin/robot --include resend --outputdir results/ tests/otp_tests.robot    # ~3 min
```

### Dry run (syntax check, no browser)

```bash
./venv/bin/robot --dryrun tests/
```

### Override base URL or mobile number

```bash
./venv/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999900000 ./venv/bin/robot --outputdir results/ tests/
BYPASS_AUTH_MOBILE=<erp_mobile> ./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
```

---

## Test Suites Summary

| Suite File | Tests | Wizard Page(s) |
|------------|-------|----------------|
| login_left_component_tests | 9 | Left panel |
| login_tests | 23 | / (login form) |
| otp_tests | 18 (3 skipped) | /verify |
| bypass_auth_tests | 4 (3 skipped) | /instant-eligibility |
| dashboard_tests | 11 (2 skipped) | /my-applications |
| dashboard_emi_tests | 5 | /my-applications#emi |
| dashboard_ad_tests | 10 | /my-applications#ad |
| dashboard_pg_tests | 21 | /my-applications#direct |
| dashboard_new_user_tests | 4 | /my-applications (new user) |
| dashboard_ins_tests | 11 | /my-applications#ins |
| dashboard_ins_new_user_tests | 4 | /my-applications#ins (new user) |
| student_details_tests | 40 | /student-details |
| choose_plan_tests | 16 | /choose-plan |
| select_applicant_tests | 10 | /select-applicant |
| applicant_journey_tests | 23 | /applicant-basic-details |
| onboarding_tests | 7 | /onboarding |
| personal_details_tests | 15 | /applicant-personal-details |
| residential_details_tests | 12 | /applicant-residential-details |
| employment_tests | 42 | /select-employment + /applicant-employment-details |
| confirm_application_tests | 20 | /confirm-application |
| **Total** | **~295** | |

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

---

## UAT Environment Notes

**Service window:** UAT is unavailable **9pm – 7am** daily.

**Fixed OTP:** UAT has OTP `9999` pre-configured for all mobile numbers. No SMS dependency.

**checkMobilePost rate limit:** ~3 calls per ~60 seconds per IP. `Navigate To OTP Page` auto-detects and retries after `RATE_LIMIT_WAIT` (45s).

**Application Creation Flow session model:** Each wizard suite (`applicant_journey_tests`, `onboarding_tests`, `personal_details_tests`, `residential_details_tests`, `employment_tests`, `confirm_application_tests`) has its own independent `Suite Setup` that traverses the full wizard from login. `Test Setup` hard-navigates to the target page within the existing session.

**Dashboard session model:** Dashboard tests are split across 7 independent files, each with its own browser session and dedicated `Suite Setup` login.

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
