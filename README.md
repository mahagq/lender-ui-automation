# Customer Portal UI Automation

Robot Framework end-to-end test suite for the GQ Customer Portal.
Covers the login left component, mobile number login form, OTP verification flow, bypass authentication, dashboard, and the full Application Creation Flow wizard (10 pages, TC-5001–TC-13025) — all targeting the UAT environment (`https://customer.uat.graydev.in`).

---

## Project Structure

```
customer_portal_ui_automation/
├── tests/
│   ├── login_left_component_tests.robot      # Left panel component tests (9 tests, TC-101–109)
│   ├── login_tests.robot                     # Login form tests (23 tests, TC-201, TC-207–228)
│   ├── otp_tests.robot                       # OTP verification tests (18 tests, 3 skipped, TC-301–318)
│   ├── bypass_auth_tests.robot               # Bypass auth tests (4 tests, 3 skipped)
│   ├── dashboard_tests.robot                 # Dashboard — header/general/create-app/insurance/logout (11 tests, 2 skipped)
│   ├── dashboard_emi_tests.robot             # EMI tab tests (5 tests, TC-4001, TC-4011, TC-4044–4046; DASHBOARD_MOBILE)
│   ├── dashboard_ad_tests.robot              # Auto Debit tab tests (10 tests, TC-4002, TC-4012, TC-4036–4043; AD_MOBILE)
│   ├── dashboard_pg_tests.robot              # Transaction History tab tests (21 tests, TC-4003, TC-4013–4031, TC-4051; PG_MOBILE)
│   ├── dashboard_new_user_tests.robot        # New-user empty state tests (4 tests, TC-4047–4050; DASHBOARD_NEW_MOBILE)
│   ├── dashboard_ins_tests.robot             # Insurance tab tests (11 tests, TC-4101–4111; INS_MOBILE)
│   ├── dashboard_ins_new_user_tests.robot    # Insurance new-user tests (4 tests, TC-4112–4115; DASHBOARD_NEW_MOBILE)
│   ├── student_details_tests.robot           # /student-details tests (35 tests, TC-5001–5027, TC-5N-01–5N-08)
│   ├── choose_plan_tests.robot               # /choose-plan tests (16 tests, TC-6001–6016)
│   ├── select_applicant_tests.robot          # /select-applicant tests (10 tests, TC-7001–7011)
│   ├── applicant_journey_tests.robot         # Basic+Onboarding+Personal+Residential (27 tests, TC-8001–11007)
│   ├── employment_tests.robot                # /select-employment + /applicant-employment-details (30 tests, TC-12001–12094)
│   └── confirm_application_tests.robot       # /confirm-application tests (12 tests, TC-13001–13025)
├── resources/
│   ├── LoginLeftComponent.robot              # Page object keywords for left panel
│   ├── LoginPage.robot                       # Page object keywords for / (login page)
│   ├── OTPPage.robot                         # Page object keywords for /verify (OTP page)
│   ├── BypassAuthPage.robot                  # Page object keywords for /instant-eligibility
│   ├── DashboardPage.robot                   # Page object keywords for /my-applications
│   ├── InsuranceDashboardPage.robot          # Page object keywords for /my-applications#ins (Insurance tab)
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

### Run all suites (headless)

```bash
./venv/bin/robot --outputdir results/ tests/
```

### Run a single suite

```bash
./venv/bin/robot --outputdir results/ tests/login_left_component_tests.robot
./venv/bin/robot --outputdir results/ tests/login_tests.robot
./venv/bin/robot --outputdir results/ tests/otp_tests.robot
./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_emi_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ad_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_pg_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_new_user_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ins_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_ins_new_user_tests.robot
./venv/bin/robot --outputdir results/ tests/student_details_tests.robot
./venv/bin/robot --outputdir results/ tests/choose_plan_tests.robot
./venv/bin/robot --outputdir results/ tests/select_applicant_tests.robot
./venv/bin/robot --outputdir results/ tests/applicant_journey_tests.robot
./venv/bin/robot --outputdir results/ tests/employment_tests.robot
./venv/bin/robot --outputdir results/ tests/confirm_application_tests.robot
```

### Run with visible browser

```bash
./venv/bin/robot --variable HEADLESS:False --outputdir results/ tests/
```

### Run by tag

```bash
./venv/bin/robot --include smoke --outputdir results/ tests/                                   # smoke tests only
./venv/bin/robot --include login --outputdir results/ tests/                                   # login tests only
./venv/bin/robot --include otp --outputdir results/ tests/                                     # OTP tests only
./venv/bin/robot --include bypass-auth --outputdir results/ tests/                             # bypass auth tests only
./venv/bin/robot --include dashboard --outputdir results/ tests/                               # dashboard tests only
./venv/bin/robot --include insurance --outputdir results/ tests/dashboard_ins_tests.robot    # insurance tab tests only
./venv/bin/robot --include resend --outputdir results/ tests/otp_tests.robot                   # slow resend test (~3 min)
./venv/bin/robot --include application-creation-flow --outputdir results/ tests/              # all wizard tests
./venv/bin/robot --include salaried --outputdir results/ tests/employment_tests.robot         # salaried only
./venv/bin/robot --include self-employed --outputdir results/ tests/employment_tests.robot    # self-employed only
```

### Dry run (syntax check, no browser)

```bash
./venv/bin/robot --dryrun tests/
```

### Override base URL or mobile number

```bash
./venv/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999900000 ./venv/bin/robot --outputdir results/ tests/
# TC-401 requires an ERP-registered mobile for bypass auth redirect:
BYPASS_AUTH_MOBILE=<erp_mobile> ./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
```

---

## Test Suites

### Login Left Component Tests (`tests/login_left_component_tests.robot`) — 9 tests (TC-101–TC-109)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-101 | GQ Logo Is Displayed In Left Section | ui, smoke | SVG logo visible in left panel |
| TC-102 | Register For EMI Plans Heading Text Is Correct | ui, content | Main heading text assertion |
| TC-103 | Subheading Paragraph Text Is Correct | ui, content | Info paragraph text assertion |
| TC-104 | Trusted By Image Is Visible | ui, smoke | "Trusted by 5M+ Parents" image visible |
| TC-105 | About Us Link Opens About Us Page | ui, navigation | About Us link navigates correctly |
| TC-106 | Privacy Policy Link Opens Privacy Policy Page | ui, navigation | Privacy Policy link navigates correctly |
| TC-107 | Terms And Conditions Link Opens Terms And Conditions Page | ui, navigation | T&C link navigates correctly |
| TC-108 | Contact Us Link Opens Contact Us Page | ui, navigation | Contact Us link navigates correctly |
| TC-109 | Copyright Footer Text Is Correct | ui, content | Copyright notice text assertion |

### Login Tests (`tests/login_tests.robot`) — 23 tests (TC-201, TC-207–TC-228)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-201 | Login Page URL And Title Match | login, smoke, url | URL = `${BASE_URL}/` and tab title contains "GrayQuest Education Finance" |
| TC-207 | Valid Login With Correct Mobile Number | login, valid, smoke | Valid 10-digit mobile + consent → redirects to /verify |
| TC-208 | Mobile Number Input Field Is Visible And Editable | login, ui, field | Input is visible and accepts input |
| TC-209 | Login With Empty Mobile Number | login, validation, negative | No mobile → "Please enter your mobile number" |
| TC-210 | Login With Spaces In Mobile Number | login, validation, negative | Spaces only → "Please enter your mobile number" |
| TC-211 | Login With Alphabets In Mobile Number | login, validation, negative | Letters only → "Please enter valid mobile number" |
| TC-212 | Login With Invalid Mobile Number Format | login, validation, negative | Letters mixed in → "Please enter valid mobile number" |
| TC-213 | Login With Alphanumeric Mobile Number | login, validation, negative | Alphanumeric → "Please enter valid mobile number" |
| TC-214 | Login With Special Characters In Mobile Number | login, validation, negative | Special chars → "Please enter valid mobile number" |
| TC-215 | Login With Short Mobile Number | login, validation, negative | < 10 digits → "Please enter valid mobile number" |
| TC-216 | Mobile Number Field Enforces 10 Digit Max Length | login, validation, field | 14-digit input truncated to 10 digits |
| TC-217 | Valid Mobile Starting With 6 To 9 Navigates To OTP Page | login, valid, otp-redirect | Valid mobile → OTP page title "Enter 4 Digit OTP" |
| TC-218 | Login Without Consent | login, validation, negative | No consent checkbox → "Please accept Terms and Conditions" |
| TC-219 | Send OTP With Consent Checked Navigates To OTP Page | login, valid, otp-redirect | Mobile + consent → OTP page |
| TC-220 | Send OTP Button Is Enabled With Mobile And Consent | login, validation, button-state | Button enabled only with valid mobile + consent |
| TC-221 | Login Form Title Is Visible | login, ui, title | Form title = "What is your Mobile Number?" |
| TC-222 | Mobile Input Note Text Is Visible | login, ui, note | Note below mobile input contains banking guidance text |
| TC-223 | Terms Of Service Link In Consent Opens New Tab | login, ui, consent, navigation | T&C link opens T&C page in new tab |
| TC-224 | Privacy Policy Link In Consent Opens New Tab | login, ui, consent, navigation | Privacy Policy link opens in new tab |
| TC-225 | Mobile Number Prefill Via Query Param Navigates To OTP Page | login, valid, query-param | `/?m=<mobile>` auto-submits and redirects to /verify |
| TC-226 | Mobile Footer Is Present On Login Page | login, ui, mobile-footer | `mobile-footer-container` present in DOM (attached state) |
| TC-227 | Consent Label Text Contains Sign In Agreement | login, ui, consent | Consent label contains "By signing in, I agree to the" |
| TC-228 | Consent Checkbox Label Click Checks Consent Checkbox | login, ui, consent | Clicking consent label checks the checkbox input |

### OTP Tests (`tests/otp_tests.robot`) — 18 tests (15 active, 3 skipped, TC-301–TC-318)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-301 | OTP Input Field Is Visible And Editable | otp, ui, field | OTP input is visible and enabled |
| TC-302 | OTP Verification With Empty OTP | otp, validation, negative | No OTP → "Please enter 4 digit OTP" |
| TC-303 | OTP Verification With Short OTP | otp, validation, negative | 3-digit OTP → "OTP number must contain 4 digits" |
| TC-304 | Verify OTP Button Is Enabled After OTP Entry | otp, ui, button-state | Button enabled after entering OTP |
| TC-305 | Valid OTP Redirects To Dashboard With Greeting | otp, valid, smoke, dashboard | OTP 9999 → /my-applications with "Hello," greeting |
| TC-306 | Wrong OTP Shows Incorrect OTP Toast | otp, negative, toast | Wrong OTP → stays on /verify; toast shown (best-effort) |
| TC-307 | Back Button Returns To Login Page | otp, navigation, back-button | Back → login form with "What is your Mobile Number?" |
| TC-308 | Back Button Clears Mobile Number Input | otp, navigation, back-button | Back → mobile input field is empty |
| TC-309 | Entered Mobile Number Is Displayed On OTP Page | otp, ui, mobile-display | Submitted mobile shown on OTP page |
| TC-310 | OTP Countdown Timer Shows Resend Text | otp, ui, timer | Timer container shows "Resend in..." text |
| TC-311 | OTP Not Received *(skipped)* | otp, manual | Requires SMS gateway — not automatable |
| TC-312 | OTP Timer Disabled State *(skipped)* | otp, manual | Timing-sensitive — not reliably automatable |
| TC-313 | Resend OTP After Timer Expires *(skipped)* | otp, slow, resend | ~3 min wait; run with `--include resend` |
| TC-314 | OTP With Non-Numeric Characters Shows Error | otp, validation, negative | Non-numeric OTP → "Only numeric values allowed" |
| TC-315 | OTP Page Heading Is Enter 4 Digit OTP | otp, ui, heading | Page heading = "Enter 4 Digit OTP" |
| TC-316 | Back Button Then Re-Login Navigates To OTP Page | otp, navigation, back-button | OTP page → back → re-login → /verify |
| TC-317 | Existing Customer OTP Verification Lands On Dashboard With Applications | otp, valid, existing-customer, dashboard | Existing user OTP → /my-applications with EMI tab + app cards |
| TC-318 | New Customer OTP Verification Lands On Dashboard With Create Application Prompt | otp, valid, new-customer, dashboard | New user OTP → /my-applications with empty state |

### Bypass Authentication Tests (`tests/bypass_auth_tests.robot`) — 4 tests (2 skipped)

Tests the `/instant-eligibility` page used for tokenised ERP access without OTP. The page authenticates via `bypassAuthPost` using a mobile number in the `?m=` query parameter.

| Test | Tags | Description |
|------|------|-------------|
| Bypass Auth With Valid Mobile Redirects Away From Instant Eligibility *(skipped)* | bypass-auth, smoke, redirect | `?m=${BYPASS_AUTH_MOBILE}` → bypassAuthPost → redirect away from /instant-eligibility. Skipped — requires an ERP-whitelisted UAT mobile. Set `BYPASS_AUTH_MOBILE` env var and remove `robot:skip` to enable. |
| Bypass Auth Without Query Param Redirects To Login Page | bypass-auth, redirect, negative | No `?m=` → useEffect redirects to / (login form visible) |
| Bypass Auth No Account Error State Is Visible *(skipped)* | bypass-auth, negative | bypassAuthPost failure → no-account error state (needs specific UAT mobile) |
| Sign In Button On No Account State Navigates To Login *(skipped)* | bypass-auth, negative, navigation | Sign In on no-account state → / (depends on TC-403 precondition) |

### Dashboard Tests — Overview

Dashboard tests are split across **7 independent files**, each with its own browser session and dedicated `Suite Setup` login. No cross-file `Switch To Account` calls.

| File | Suite Setup account | Tests | TCs |
|------|---------------------|-------|-----|
| `dashboard_tests.robot` | DASHBOARD_MOBILE → NEW_USER_MOBILE | 11 (2 skipped) | TC-4004–4010, TC-4034, TC-4032–4033, TC-4035, TC-4009 |
| `dashboard_emi_tests.robot` | DASHBOARD_MOBILE | 5 | TC-4001, TC-4011, TC-4044–4046 |
| `dashboard_ad_tests.robot` | AD_MOBILE (8763694182) | 10 | TC-4002, TC-4012, TC-4036–4043 |
| `dashboard_pg_tests.robot` | PG_MOBILE (7757855472) | 21 | TC-4003, TC-4013–4029, TC-4051, TC-4030–4031 |
| `dashboard_new_user_tests.robot` | DASHBOARD_NEW_MOBILE | 4 | TC-4047–4050 |
| `dashboard_ins_tests.robot` | INS_MOBILE (8668768645) | 11 | TC-4101–4111 |
| `dashboard_ins_new_user_tests.robot` | DASHBOARD_NEW_MOBILE | 4 | TC-4112–4115 |

#### `dashboard_tests.robot` — 11 tests (2 skipped): Header / General / Insurance Tab Nav / Create App / Logout

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4004 | Stages And CTA Of Stages *(skipped)* | stages | No data-testid for stage elements |
| TC-4005 | Back Button Is Not Present On Dashboard *(skipped)* | navigation | No back button on dashboard |
| TC-4006 | GrayQuest Logo Is Visible On Dashboard | dashboard, logo, ui, smoke | GQ logo + "Hello," title + "Autopay subscriptions" subtitle |
| TC-4007 | Profile Icon Shows FAQ And Logout Options | dashboard, profile, ui | Profile dropdown shows FAQ and Logout |
| TC-4008 | FAQ Link Navigates To FAQ Page | dashboard, profile, navigation | FAQ click → URL contains /faq |
| TC-4010 | Create New Application Button Has Visible Effect | dashboard, application, smoke | Button click → modal or URL change |
| TC-4034 | Create New Application Button Visible And Clickable In Header (Existing User) | dashboard, application, smoke | Header button visible + click → dialog or URL change |
| TC-4032 | Insurance Tab Button Is Visible On Dashboard | dashboard, insurance, tab-navigation | Insurance tab button visible |
| TC-4033 | Insurance Tab Click Updates URL Hash | dashboard, insurance, tab-navigation | Insurance tab click → URL hash `#ins` |
| TC-4035 | Create New Application Button Visible And Clickable In Empty State (New User) | dashboard, application, smoke | Empty-state button visible + click → navigates away (switches to NEW_USER_MOBILE) |
| TC-4009 | Logout Returns To Login Page | dashboard, profile, logout, session | Logout → redirects to login page *(runs last — destroys shared session)* |

#### `dashboard_emi_tests.robot` — 5 tests: EMI Tab

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4001 | EMI Applications Are Visible On Dashboard | dashboard, emi, smoke | At least one EMI card visible after login |
| TC-4011 | EMI Tab Click Shows EMI Content | dashboard, emi, tab-navigation | EMI tab click → URL hash #emi + EMI cards visible |
| TC-4044 | EMI Card Shows Application ID Label | dashboard, emi, ui | "Application ID:" label visible on EMI card |
| TC-4045 | EMI Card App Copy Button Is Visible | dashboard, emi, ui | `app-id-copy-button` visible on first EMI card |
| TC-4046 | EMI Load More Button Is Visible | dashboard, emi, ui, pagination | `load-more-button` visible when multiple EMI apps exist |

#### `dashboard_ad_tests.robot` — 10 tests: Auto Debit Tab

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4002 | Auto Debit Applications On Dashboard | dashboard, auto-debit, tab-navigation | Auto Payments (AD) tab button visible |
| TC-4012 | Auto Payments Tab Click | dashboard, auto-payments, tab-navigation | Auto Payments tab click → URL hash `#ad` |
| TC-4036 | AD Tab App Code Label Is Visible | dashboard, auto-payments, smoke | "App. Code:" label visible on AD card |
| TC-4037 | AD Tab Copy Button Is Visible | dashboard, auto-payments, ui | Copy button visible on first AD card |
| TC-4038 | AD Tab Repayment Active Status Is Visible | dashboard, auto-payments, ui, status | "Your repayment is active" visible |
| TC-4039 | AD Tab Repayment Pending Status Is Visible | dashboard, auto-payments, ui, status | "Your repayment is pending" visible |
| TC-4040 | AD Tab Action Button Is Visible | dashboard, auto-payments, ui | `auto-debit-action-button` visible on first AD card |
| TC-4041 | AD Action Button Opens Detail Modal | dashboard, auto-payments, modal | Action button → modal with Summary, Repayment Complete, Student Details |
| TC-4042 | AD Detail Modal Close Button Dismisses Modal | dashboard, auto-payments, modal | Close button → modal hidden |
| TC-4043 | AD Schedule Section Is Visible | dashboard, auto-payments, ui | "Auto payments schedule" heading visible |

#### `dashboard_pg_tests.robot` — 21 tests: Transaction History / PG Tab

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4003 | Payment Gateway Applications Are Visible | dashboard, pg, smoke | Transaction History tab + Online/Offline sub-tabs visible |
| TC-4013 | Transaction History Tab Click | dashboard, pg, tab-navigation, smoke | PG tab click → URL hash #direct + sub-tabs visible |
| TC-4014 | Offline Payments Sub-tab Is Accessible | dashboard, pg, sub-tab | Offline sub-tab visible and clickable |
| TC-4015 | Online Payments Sub-tab Is Accessible | dashboard, pg, sub-tab | Online sub-tab visible and clickable |
| TC-4016 | Filter Panel Is Visible For Online Payments | dashboard, pg, filter, online | Filter button → all time and status filters visible |
| TC-4017 | Filter By All Months For Online Payments | dashboard, pg, filter, online, time-filter | "All Months" filter selectable |
| TC-4018 | Filter By This Month For Online Payments | dashboard, pg, filter, online, time-filter | "This Month" filter selectable |
| TC-4019 | Filter By This Year For Online Payments | dashboard, pg, filter, online, time-filter | "This Year" filter selectable |
| TC-4020 | Filter By Last Year For Online Payments | dashboard, pg, filter, online, time-filter | "Last Year" filter selectable |
| TC-4021 | Filter By Status Paid For Online Payments | dashboard, pg, filter, online, status-filter | "Paid" status filter selectable |
| TC-4022 | Filter By Status Failed For Online Payments | dashboard, pg, filter, online, status-filter | "Failed" status filter selectable |
| TC-4023 | Filter Panel Is Visible For Offline Payments | dashboard, pg, filter, offline | Filter button → time filters visible (no status filters) |
| TC-4024 | Filter By All Months For Offline Payments | dashboard, pg, filter, offline, time-filter | "All Months" filter selectable on Offline tab |
| TC-4025 | Filter By This Month For Offline Payments | dashboard, pg, filter, offline, time-filter | "This Month" filter selectable on Offline tab |
| TC-4026 | Filter By This Year For Offline Payments | dashboard, pg, filter, offline, time-filter | "This Year" filter selectable on Offline tab |
| TC-4027 | Filter By Last Year For Offline Payments | dashboard, pg, filter, offline, time-filter | "Last Year" filter selectable on Offline tab |
| TC-4028 | Clear Filter Button Works | dashboard, pg, filter, clear-filter | Clear button resets filter selection |
| TC-4029 | Apply Filter Button Works | dashboard, pg, filter, apply-filter | Apply button applies selected filter |
| TC-4051 | PG Filter Applied Shows Inline Clear | dashboard, pg, filter, inline-clear | Apply filter → inline Clear chip visible and clickable |
| TC-4030 | Download Icon Is Visible For Offline Payment | dashboard, pg, download, offline | Download button visible on first Offline row |
| TC-4031 | Download Icon Is Visible For Online Payment | dashboard, pg, download, online | Download button visible on first Online row |

#### `dashboard_new_user_tests.robot` — 4 tests: New User Empty States

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4047 | EMI Tab Shows No Applications For New User | dashboard, emi, empty-state, smoke | New user → "No Data Found" empty state |
| TC-4048 | AD Tab Shows No Data Alert For New User | dashboard, auto-payments, empty-state | New user → ARIA alert on AD tab |
| TC-4049 | PG Online Sub-tab Shows No Transactions For New User | dashboard, pg, empty-state | New user → "Online transactions not found" |
| TC-4050 | PG Offline Sub-tab Shows No Data For New User | dashboard, pg, empty-state | New user → "No Data Found" + "You have not done any" |

---

### Insurance Dashboard Tests — 15 tests (TC-4101–TC-4115)

Tests the Insurance tab (`/my-applications#ins`), split across two independent files.

#### `dashboard_ins_tests.robot` — 11 tests: Insurance Tab (INS_MOBILE)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4101 | Insurance Tab Click Updates URL Hash | dashboard, insurance, navigation, smoke | Insurance tab click → URL hash `#ins` |
| TC-4102 | Education Banner Image Is Visible | dashboard, insurance, ui, banner | "Education costs illustration" image visible |
| TC-4103 | Education Banner Heading Is Correct | dashboard, insurance, ui, banner | Heading "Education costs are rising" visible |
| TC-4104 | Education Banner Subtext Is Visible | dashboard, insurance, ui, banner | Subtext "Education inflation is real." visible |
| TC-4105 | Guardian One Logo Is Visible | dashboard, insurance, ui, banner | Guardian One insurance provider logo visible |
| TC-4106 | Your Policies Heading Is Visible | dashboard, insurance, ui, policies | "Your Policies" section heading visible |
| TC-4107 | Policy App ID Copy Button Is Visible | dashboard, insurance, ui, policies | `app-id-copy-button` visible on first policy card |
| TC-4108 | Policy Status Issued Badge Is Visible | dashboard, insurance, ui, policies | "Status: Issued" badge visible |
| TC-4109 | Policy Status Applied Badge Is Visible | dashboard, insurance, ui, policies | "Status: Applied" badge visible |
| TC-4110 | Policy Download Button Is Visible And Enabled | dashboard, insurance, ui, policies | Download button visible and enabled on first policy card |
| TC-4111 | Calculate Now Button Opens New Tab | dashboard, insurance, navigation, calculator | "CALCULATE NOW" CTA opens insurance calculator in new tab |

#### `dashboard_ins_new_user_tests.robot` — 4 tests: Insurance New User (DASHBOARD_NEW_MOBILE)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4112 | Insurance Plan Heading Is Visible For New User | dashboard, insurance, ui, new-user, smoke | New user → "Choose your Insurance Plan" heading visible |
| TC-4113 | Education Coverage Plan Is Visible For New User | dashboard, insurance, ui, new-user | New user → "Education Coverage" plan card visible |
| TC-4114 | Recommended Plan Badge Is Visible For New User | dashboard, insurance, ui, new-user | New user → "Recommended" badge visible on plan card |
| TC-4115 | Complete Life Plan Is Visible For New User | dashboard, insurance, ui, new-user | New user → "Complete Life" plan card visible |

### Student Details Tests (`tests/student_details_tests.robot`) — 35 tests

Tests the `/student-details` wizard step. TC-5014 (Show Plans button) runs last — it advances the wizard to `/choose-plan`. The page has a **Close button** (`data-testid='close-button'`) instead of a back button.

| TC | Description | Tags |
|----|-------------|------|
| TC-5001 | Page title visible | smoke |
| TC-5002–5005 | GILE dropdowns visible (institute/location/board/academic year) | |
| TC-5006–5007 | Admission type and annual fee titles visible | |
| TC-5008 | URL contains /student-details | |
| TC-5009–5013 | Name inputs, student type radio, student ID, loan amount visible/accept input | |
| TC-5014 | Show Plans button visible + advances to /choose-plan *(runs last)* | slow |
| TC-5015 | Page subtitle visible ("Enter the Student Details to...") | ui |
| TC-5016 | Student Details section title visible (`student-details-title`) | ui |
| TC-5017 | Facing Issue link visible | ui |
| TC-5018 | Support modal shows Contact Number and Support Email | ui |
| TC-5019 | Existing Student radio option visible | ui |
| TC-5020 | New Admission radio option visible | ui |
| TC-5021 | Show Plans validation errors visible when form incomplete | validation, negative |
| TC-5022 | GILE Institute dropdown accepts search and selects first option | |
| TC-5023 | GILE Location dropdown is selectable after institute selection | |
| TC-5024 | GILE Board dropdown is selectable after institute and location | |
| TC-5025 | Personal Details section appears after all GILE dropdowns filled | |
| TC-5026 | Class dropdown is visible and selectable after GILE filled | |
| TC-5027 | Close button navigates to /my-applications | navigation |
| TC-5N-01 | Personal Details section hidden before GILE is filled | negative |
| TC-5N-02 | Show Plans button hidden before GILE is filled | negative |
| TC-5N-03 | Show Plans with only First Name shows three errors | negative |
| TC-5N-04 | Show Plans with only Last Name shows three errors | negative |
| TC-5N-05 | Show Plans with Name fields filled but no Class or Loan shows two errors | negative |
| TC-5N-06 | Show Plans with Name and Class filled but no Loan shows Loan error | negative |
| TC-5N-07 | Show Plans with only Loan Amount filled shows three errors | negative |
| TC-5N-08 | Show Plans with Loan Amount zero shows Loan error | negative |

### Choose Plan Tests (`tests/choose_plan_tests.robot`) — 16 tests (TC-6001–TC-6016)

Tests the `/choose-plan` wizard step. TC-6008 (select plan + proceed) runs last — advances to `/select-applicant`.

| TC | Description | Tags |
|----|-------------|------|
| TC-6001 | Title + plans count visible | smoke |
| TC-6002–6004 | Plans available, count matches list, title text | smoke |
| TC-6005–6006 | Plan selection, switching plans | |
| TC-6007 | Submit disabled before selection | |
| TC-6009 | URL contains /choose-plan | |
| TC-6010 | "Fee paying to" text visible | |
| TC-6011 | Page accessible after navigation | |
| TC-6012 | "Most Popular" badge visible in plan detail view | |
| TC-6013 | EMI card action button visible on first plan card | |
| TC-6014 | Plan detail shows "Interest per month" and "Payable Today" | |
| TC-6015 | Submit without plan selection shows "Please select plan" error | validation, negative |
| TC-6016 | Back button returns to /student-details | navigation |
| TC-6008 | Select plan → submit enabled → advances to /select-applicant *(runs last)* | |

### Select Applicant Tests (`tests/select_applicant_tests.robot`) — 10 tests

Tests the `/select-applicant` wizard step. TC-7008 (select Parent/Guardian + proceed) runs last — advances to `/applicant-basic-details`.

| TC | Description | Tags |
|----|-------------|------|
| TC-7001 | Title + note visible | smoke |
| TC-7002 | Both applicant options visible | smoke |
| TC-7003–7004 | Parent/Guardian and Student options selectable | |
| TC-7005–7006 | Age + salary consent checkboxes appear after Student selection | |
| TC-7007 | Submit disabled before selection | |
| TC-7009 | URL contains /select-applicant | |
| TC-7011 | Page loads after navigation | |
| TC-7008 | Select Parent/Guardian → submit enabled → advances to /applicant-basic-details *(runs last)* | |

### Applicant Journey Tests (`tests/applicant_journey_tests.robot`) — 27 tests (sequential)

Covers 4 pages sequentially in wizard order. Runs with `[Setup] NONE` after the first page's wizard-advancing test — strict test ordering required.

| Page | TCs | Description |
|------|-----|-------------|
| /applicant-basic-details | TC-8001–8008 | Title, form elements, URL, name inputs, submit state, proceeds to /onboarding |
| /onboarding | TC-9001–9003 | Info sections, proceed button, proceeds to /applicant-personal-details |
| /applicant-personal-details | TC-10001–10008 | Title, PAN/gender/DOB/marital/email fields, URL, proceeds to /applicant-residential-details |
| /applicant-residential-details | TC-11001–11007 | Title, address fields, residence type radio, URL, proceeds to /select-employment |

### Employment Tests (`tests/employment_tests.robot`) — 30 tests

Covers `/select-employment` (7 tests) and `/applicant-employment-details` in two variants: Salaried (13 tests, TC-12014–12045) and Self-Employed (10 tests, TC-12047–12092).

| Section | Tags | Notable TCs |
|---------|------|-------------|
| Select Employment Type | employment | TC-12001–12013: title, URL, cards visible/selectable, switching |
| Salaried Employment Details | employment, salaried | TC-12014–12045: employer name, salary, consent, proceed (last: advances to /confirm-application) |
| Self-Employed Employment Details | employment, self-employed | TC-12047–12092: business name, income, years, description, proceed (last: advances to /confirm-application) |

### Confirm Application Tests (`tests/confirm_application_tests.robot`) — 12 tests

Tests the `/confirm-application` wizard step. TC-13023 (consent + proceed = submit application) runs last.

| TC | Description | Tags |
|----|-------------|------|
| TC-13001 | Title + form visible | smoke |
| TC-13002 | All 6 section edit buttons visible | smoke |
| TC-13003 | Student Details edit navigates to /student-details | |
| TC-13004 | EMI Plan edit button visible | |
| TC-13007 | Who Is Applying edit button visible | |
| TC-13010 | General Details edit button visible | |
| TC-13011 | Proceed button visible | |
| TC-13013 | Residential Details edit button visible | |
| TC-13016 | Employment Details edit button visible | |
| TC-13019 | Consent checkbox visible | |
| TC-13020 | Consent checkbox can be checked | |
| TC-13021 | URL contains /confirm-application | |
| TC-13022 | Proceed disabled without consent | |
| TC-13024 | Back navigation via Student Details edit | |
| TC-13023 | Consent + proceed submits application + navigates past /confirm-application *(runs last)* | |

---

## Configuration

All configuration is in `variables/variables.robot`.

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://customer.uat.graydev.in` | Target environment URL |
| `TEST_MOBILE` | `%{TEST_MOBILE=9876543210}` | Default login mobile (overridable via env var) |
| `BYPASS_AUTH_MOBILE` | `%{BYPASS_AUTH_MOBILE=9876543210}` | Mobile for TC-401 bypass auth redirect test — **must be an ERP-registered mobile** on UAT (bypassAuthPost must succeed). Set via `BYPASS_AUTH_MOBILE` env var. A general OTP test mobile will fail this test. |
| `OTP_MOBILE_1..4` | `9876543211..14` | Distinct mobiles for core OTP tests |
| `EXT_LOGIN_MOBILE_1..2` | `9876543215..16` | Mobiles for login OTP-redirect tests |
| `EXT_OTP_MOBILE_1..10` | `9876543217..26` | Distinct mobiles for extended OTP tests |
| `EXT_LOGIN_MOBILE_3` | `9876543227` | Mobile for query-param prefill login test (TC-225) |
| `NON_NUMERIC_OTP` | `abcd` | Non-numeric OTP string for validation test (TC-314) |
| `DASHBOARD_MOBILE` | `8108556708` | Dashboard suite login — account has active EMI applications |
| `PG_MOBILE` | `7757855472` | PG account — used for TC-4030/TC-4031 (has transaction records) |
| `AD_MOBILE` | `8763694182` | AD account — used for TC-4036–TC-4043 (has active AD applications) |
| `INS_MOBILE` | `8668768645` | Insurance account — used for TC-4101–TC-4111 (has active insurance policies) |
| `TEST_OTP` | `9999` | Fixed OTP configured in UAT for all mobile numbers |
| `BROWSER` | `chromium` | Playwright browser (`chromium`, `firefox`, `webkit`) |
| `HEADLESS` | `True` | Run headless (`True`) or with visible browser (`False`) |
| `TIMEOUT` | `10s` | Standard element wait timeout |
| `LONG_TIMEOUT` | `30s` | Extended wait (page navigation, OTP form load) |
| `RATE_LIMIT_WAIT` | `45s` | Recovery sleep when UAT rate limit is hit |
| `RESEND_OTP_WAIT` | `185s` | Wait for resend OTP link (180s timer + 5s buffer) |
| `APP_CREATION_MOBILE` | `9876540001` | Dedicated mobile for Application Creation Flow suites |
| `APP_STUDENT_FIRST_NAME` | `Test` | Stub first name for student details traversal |
| `APP_STUDENT_LAST_NAME` | `Student` | Stub last name for student details traversal |
| `APP_LOAN_AMOUNT` | `100000` | Stub loan amount for student details traversal |
| `APP_FIRST_NAME` | `Test` | Applicant (parent/guardian) first name |
| `APP_LAST_NAME` | `Parent` | Applicant last name |
| `APP_PAN_NUMBER` | `ABCDE1234F` | Stub PAN number for personal details traversal |
| `APP_EMAIL` | `testparent@example.com` | Stub email for personal details traversal |
| `APP_ADDRESS_LINE1` | `123 Test Street` | Stub address line 1 |
| `APP_ADDRESS_LINE2` | `Test Area` | Stub address line 2 |
| `APP_PINCODE` | `400001` | Stub pincode (triggers city/state auto-populate) |
| `APP_EMPLOYER_NAME` | `Test Company Pvt Ltd` | Stub employer name (salaried) |
| `APP_MONTHLY_SALARY` | `50000` | Stub monthly salary (salaried) |
| `APP_BUSINESS_NAME` | `Test Business` | Stub business name (self-employed) |
| `APP_BUSINESS_INCOME` | `600000` | Stub annual business income (self-employed) |
| `APP_BUSINESS_YEARS` | `05` | Stub years in business (self-employed) |
| `APP_BUSINESS_DESC` | `Software consulting and services` | Stub business description (self-employed) |

---

## UAT Environment Notes

**Service window:** UAT (`customer.uat.graydev.in`) is unavailable **9pm – 7am** daily. All runs must happen within the 7am–9pm window.

**Fixed OTP:** UAT has OTP `9999` pre-configured for all mobile numbers. No SMS dependency.

**checkMobilePost rate limit:** ~3 calls per ~60 seconds per IP. The `Navigate To OTP Page` keyword auto-detects this (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT`. Each OTP test uses a distinct mobile number to reduce collisions.

**verifyOtpPost rate limit:** Also applies per IP. The `Valid OTP Redirects To Dashboard` and `Switch To Account` keywords handle this with a three-state page-check after `RATE_LIMIT_WAIT`:
- On `/my-applications` → OTP succeeded (slow redirect), continue
- On `/verify` (OTP form visible) → re-enter OTP and click Verify
- On `/` (login page) → rate limit forced full logout, re-submit login form then OTP

**Dashboard session model:** Dashboard tests are split across **7 independent files**, each with its own browser session and `Suite Setup` login. This eliminates session contamination and avoids mid-suite rate-limit failures from `Switch To Account` calls:

| File | `Suite Setup` account | Notes |
|------|-----------------------|-------|
| `dashboard_tests.robot` | DASHBOARD_MOBILE → NEW_USER_MOBILE | TC-4035 switches to NEW_USER_MOBILE; TC-4009 (logout) runs last |
| `dashboard_emi_tests.robot` | DASHBOARD_MOBILE | Independent |
| `dashboard_ad_tests.robot` | AD_MOBILE (8763694182) | `Login And Navigate To Dashboard As ${AD_MOBILE}` |
| `dashboard_pg_tests.robot` | PG_MOBILE (7757855472) | `Login And Navigate To Dashboard As ${PG_MOBILE}` |
| `dashboard_new_user_tests.robot` | DASHBOARD_NEW_MOBILE | `Login And Navigate To Dashboard As ${DASHBOARD_NEW_MOBILE}` |
| `dashboard_ins_tests.robot` | INS_MOBILE (8668768645) | `Login And Navigate To Insurance Tab` |
| `dashboard_ins_new_user_tests.robot` | DASHBOARD_NEW_MOBILE | `Login And Navigate To Dashboard As ${DASHBOARD_NEW_MOBILE}` |

All files share the same pattern: `Test Setup` → `Navigate To Dashboard` (hard navigation to reset state), `Test Teardown` → NONE, `Suite Teardown` → `Close Browser`.

---

## Locator Strategy

All selectors use `data-testid` attributes derived from the React source (`gqcustomer_frontend`). No CSS class names or absolute XPath. Stable across styling changes.

Key selectors:

| Element | Selector |
|---------|----------|
| Login form | `css=[data-testid='login-form']` |
| Mobile input | `css=[data-testid='mobile-number-input']` |
| Consent checkbox | `css=[data-testid='consent-checkbox']` |
| Send OTP button | `css=[data-testid='send-otp-button']` |
| OTP form | `css=[data-testid='verify-otp-form']` |
| OTP input | `css=[data-testid='otp-input']` |
| Verify OTP button | `css=[data-testid='verify-otp-button']` |
| Resend OTP link | `css=[data-testid='resend-otp-link']` *(visible only after 180s)* |
| Dashboard title | `css=[data-testid='dashboard-title']` |
| Profile button | `css=[data-testid='profile-button']` |
| EMI tab | `css=[data-testid='emi-tab-navigation-button']` |
| PG tab | `css=[data-testid='pg-tab-navigation-button']` |
| Filter button | `css=[data-testid='filter-button']` |
| Insurance tab | `css=[data-testid='ins-tab-navigation-button']` |

---

## Results

After a run, open `results/report.html` for the full test report or `results/log.html` for detailed step-by-step logs with screenshots.
