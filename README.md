# Customer Portal UI Automation

Robot Framework end-to-end test suite for the GQ Customer Portal.
Covers the login left component, mobile number login form, OTP verification flow, bypass authentication, and dashboard — all targeting the UAT environment (`https://customer.uat.graydev.in`).

---

## Project Structure

```
customer_portal_ui_automation/
├── tests/
│   ├── login_left_component_tests.robot   # Left panel component tests (9 tests)
│   ├── login_tests.robot                  # Login form tests (21 tests)
│   ├── otp_tests.robot                    # OTP verification tests (14 tests, 3 skipped)
│   ├── bypass_auth_tests.robot            # Bypass auth tests (4 tests, 2 skipped)
│   └── dashboard_tests.robot              # Dashboard tests (33 tests, 6 skipped)
├── resources/
│   ├── LoginPage.robot                    # Page object keywords for / (login page)
│   ├── OTPPage.robot                      # Page object keywords for /verify (OTP page)
│   ├── BypassAuthPage.robot               # Page object keywords for /instant-eligibility
│   └── DashboardPage.robot                # Page object keywords for /my-applications
├── variables/
│   └── variables.robot                    # All test configuration and test data
└── results/                               # Robot Framework output (output.xml, log.html, report.html)
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
```

### Run with visible browser

```bash
./venv/bin/robot --variable HEADLESS:False --outputdir results/ tests/
```

### Run by tag

```bash
./venv/bin/robot --include smoke --outputdir results/ tests/                      # smoke tests only
./venv/bin/robot --include login --outputdir results/ tests/                      # login tests only
./venv/bin/robot --include otp --outputdir results/ tests/                        # OTP tests only
./venv/bin/robot --include bypass-auth --outputdir results/ tests/                # bypass auth tests only
./venv/bin/robot --include dashboard --outputdir results/ tests/                  # dashboard tests only
./venv/bin/robot --include resend --outputdir results/ tests/otp_tests.robot      # slow resend test (~3 min)
```

### Dry run (syntax check, no browser)

```bash
./venv/bin/robot --dryrun tests/
```

### Override base URL or mobile number

```bash
./venv/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999900000 ./venv/bin/robot --outputdir results/ tests/
```

---

## Test Suites

### Login Left Component Tests (`tests/login_left_component_tests.robot`) — 9 tests

| Test | Tags | Description |
|------|------|-------------|
| GQ Logo Is Displayed In Left Section | ui, smoke | SVG logo visible in left panel |
| Register For EMI Plans Heading Text Is Correct | ui, content | Main heading text assertion |
| Subheading Paragraph Text Is Correct | ui, content | Info paragraph text assertion |
| Trusted By Image Is Visible | ui, smoke | "Trusted by 5M+ Parents" image visible |
| About Us Link Opens About Us Page | ui, navigation | About Us link navigates correctly |
| Privacy Policy Link Opens Privacy Policy Page | ui, navigation | Privacy Policy link navigates correctly |
| Terms And Conditions Link Opens Terms And Conditions Page | ui, navigation | T&C link navigates correctly |
| Contact Us Link Opens Contact Us Page | ui, navigation | Contact Us link navigates correctly |
| Copyright Footer Text Is Correct | ui, content | Copyright notice text assertion |

### Login Tests (`tests/login_tests.robot`) — 21 tests

| Test | Tags | Description |
|------|------|-------------|
| Login Page URL And Title Match | login, smoke, url | URL = `${BASE_URL}/` and tab title contains "GrayQuest Education Finance" |
| Valid Login With Correct Mobile Number | login, valid, smoke | Valid 10-digit mobile + consent → redirects to /verify |
| Mobile Number Input Field Is Visible And Editable | login, ui, field | Input is visible and accepts input |
| Login With Empty Mobile Number | login, validation, negative | No mobile → "Please enter your mobile number" |
| Login With Spaces In Mobile Number | login, validation, negative | Spaces only → "Please enter your mobile number" |
| Login With Alphabets In Mobile Number | login, validation, negative | Letters only → "Please enter valid mobile number" |
| Login With Invalid Mobile Number Format | login, validation, negative | Letters mixed in → "Please enter valid mobile number" |
| Login With Alphanumeric Mobile Number | login, validation, negative | Alphanumeric → "Please enter valid mobile number" |
| Login With Special Characters In Mobile Number | login, validation, negative | Special chars → "Please enter valid mobile number" |
| Login With Short Mobile Number | login, validation, negative | < 10 digits → "Please enter valid mobile number" |
| Mobile Number Field Enforces 10 Digit Max Length | login, validation, field | 14-digit input truncated to 10 digits |
| Valid Mobile Starting With 6 To 9 Navigates To OTP Page | login, valid, otp-redirect | Valid mobile → OTP page title "Enter 4 Digit OTP" |
| Login Without Consent | login, validation, negative | No consent checkbox → "Please accept Terms and Conditions" |
| Send OTP With Consent Checked Navigates To OTP Page | login, valid, otp-redirect | Mobile + consent → OTP page |
| Send OTP Button Is Enabled With Mobile And Consent | login, validation, button-state | Button enabled only with valid mobile + consent |
| Login Form Title Is Visible | login, ui, title | Form title = "What is your Mobile Number?" |
| Mobile Input Note Text Is Visible | login, ui, note | Note below mobile input contains banking guidance text |
| Terms Of Service Link In Consent Opens New Tab | login, ui, consent, navigation | T&C link opens T&C page in new tab |
| Privacy Policy Link In Consent Opens New Tab | login, ui, consent, navigation | Privacy Policy link opens in new tab |
| Mobile Number Prefill Via Query Param Navigates To OTP Page | login, valid, query-param | `/?m=<mobile>` auto-submits and redirects to /verify |
| Mobile Footer Is Present On Login Page | login, ui, mobile-footer | `mobile-footer-container` present in DOM (attached state) |

### OTP Tests (`tests/otp_tests.robot`) — 14 tests (3 skipped)

| Test | Tags | Description |
|------|------|-------------|
| OTP Input Field Is Visible And Editable | otp, ui, field | OTP input is visible and enabled |
| OTP Verification With Empty OTP | otp, validation, negative | No OTP → "Please enter 4 digit OTP" |
| OTP Verification With Short OTP | otp, validation, negative | 3-digit OTP → "OTP number must contain 4 digits" |
| Verify OTP Button Is Enabled After OTP Entry | otp, ui, button-state | Button enabled after entering OTP |
| Valid OTP Redirects To Dashboard With Greeting | otp, valid, smoke, dashboard | OTP 9999 → /my-applications with "Hello," greeting |
| Wrong OTP Shows Incorrect OTP Toast | otp, negative, toast | Wrong OTP → stays on /verify; toast shown (best-effort) |
| Back Button Returns To Login Page | otp, navigation, back-button | Back → login form with "What is your Mobile Number?" |
| Back Button Clears Mobile Number Input | otp, navigation, back-button | Back → mobile input field is empty |
| Entered Mobile Number Is Displayed On OTP Page | otp, ui, mobile-display | Submitted mobile shown on OTP page |
| OTP Countdown Timer Shows Resend Text | otp, ui, timer | Timer container shows "Resend in..." text |
| OTP With Non-Numeric Characters Shows Error | otp, validation, negative | Non-numeric OTP → "Only numeric values allowed" |
| OTP Not Received *(skipped)* | otp, manual | Requires SMS gateway — not automatable |
| OTP Timer Disabled State *(skipped)* | otp, manual | Timing-sensitive — not reliably automatable |
| Resend OTP After Timer Expires *(skipped)* | otp, slow, resend | ~3 min wait; run with `--include resend` |

### Bypass Authentication Tests (`tests/bypass_auth_tests.robot`) — 4 tests (2 skipped)

Tests the `/instant-eligibility` page used for tokenised ERP access without OTP. The page authenticates via `bypassAuthPost` using a mobile number in the `?m=` query parameter.

| Test | Tags | Description |
|------|------|-------------|
| Bypass Auth With Valid Mobile Redirects Away From Instant Eligibility | bypass-auth, smoke, redirect | `?m=<valid_mobile>` → bypassAuthPost → redirect away from /instant-eligibility |
| Bypass Auth Without Query Param Redirects To Login Page | bypass-auth, redirect, negative | No `?m=` → useEffect redirects to / (login form visible) |
| Bypass Auth No Account Error State Is Visible *(skipped)* | bypass-auth, negative | bypassAuthPost failure → no-account error state (needs specific UAT mobile) |
| Sign In Button On No Account State Navigates To Login *(skipped)* | bypass-auth, negative, navigation | Sign In on no-account state → / (depends on TC-403 precondition) |

### Dashboard Tests (`tests/dashboard_tests.robot`) — 33 tests (2 skipped)

| TC | Test | Tags | Description |
|----|------|------|-------------|
| TC-4001 | EMI Applications Are Visible On Dashboard | dashboard, emi, smoke | At least one EMI card visible after login |
| TC-4002 | Auto Debit Applications On Dashboard | dashboard, auto-debit, tab-navigation | Auto Payments (AD) tab button visible |
| TC-4003 | Payment Gateway Applications Are Visible | dashboard, pg, smoke | Transaction History tab + Online/Offline sub-tabs visible |
| TC-4004 | Stages And CTA Of Stages *(skipped)* | stages | No data-testid for stage elements |
| TC-4005 | Back Button Is Not Present On Dashboard *(skipped)* | navigation | No back button on dashboard |
| TC-4006 | GrayQuest Logo Is Visible On Dashboard | dashboard, logo, ui, smoke | GQ logo + "Hello," title + "Autopay subscriptions" subtitle |
| TC-4007 | Profile Icon Shows FAQ And Logout Options | dashboard, profile, ui | Profile dropdown shows FAQ and Logout |
| TC-4008 | FAQ Link Navigates To FAQ Page | dashboard, profile, navigation | FAQ click → URL contains /faq |
| TC-4010 | Create New Application Button Has Visible Effect | dashboard, application, smoke | Button click → modal or URL change |
| TC-4011 | EMI Tab Click Shows EMI Content | dashboard, emi, tab-navigation | EMI tab click → URL hash #emi + EMI cards visible |
| TC-4012 | Auto Payments Tab Click | dashboard, auto-payments, tab-navigation | Auto Payments tab click → URL hash `#ad` |
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
| TC-4030 | Download Icon Is Visible For Offline Payment | dashboard, pg, download, offline | Download button visible on first Offline row (switches to PG account) |
| TC-4031 | Download Icon Is Visible For Online Payment | dashboard, pg, download, online | Download button visible on first Online row |
| TC-4032 | Insurance Tab Button Is Visible On Dashboard | dashboard, insurance, tab-navigation | Insurance tab button (`ins-tab-navigation-button`) visible |
| TC-4033 | Insurance Tab Click Updates URL Hash | dashboard, insurance, tab-navigation | Insurance tab click → URL hash `#ins` |
| TC-4009 | Logout Returns To Login Page | dashboard, profile, logout, session | Logout → redirects to login page *(runs last)* |

---

## Configuration

All configuration is in `variables/variables.robot`.

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://customer.uat.graydev.in` | Target environment URL |
| `TEST_MOBILE` | `%{TEST_MOBILE=9876543210}` | Default login mobile (overridable via env var) |
| `OTP_MOBILE_1..4` | `9876543211..14` | Distinct mobiles for core OTP tests |
| `EXT_LOGIN_MOBILE_1..2` | `9876543215..16` | Mobiles for login OTP-redirect tests |
| `EXT_OTP_MOBILE_1..10` | `9876543217..26` | Distinct mobiles for extended OTP tests |
| `EXT_LOGIN_MOBILE_3` | `9876543227` | Mobile for query-param prefill login test (TC-225) |
| `NON_NUMERIC_OTP` | `abcd` | Non-numeric OTP string for validation test (TC-314) |
| `DASHBOARD_MOBILE` | `8108556708` | Dashboard suite login — account has active EMI applications |
| `PG_MOBILE` | `7757855472` | PG account — used for TC-4030/TC-4031 (has transaction records) |
| `TEST_OTP` | `9999` | Fixed OTP configured in UAT for all mobile numbers |
| `BROWSER` | `chromium` | Playwright browser (`chromium`, `firefox`, `webkit`) |
| `HEADLESS` | `True` | Run headless (`True`) or with visible browser (`False`) |
| `TIMEOUT` | `10s` | Standard element wait timeout |
| `LONG_TIMEOUT` | `30s` | Extended wait (page navigation, OTP form load) |
| `RATE_LIMIT_WAIT` | `45s` | Recovery sleep when UAT rate limit is hit |
| `RESEND_OTP_WAIT` | `185s` | Wait for resend OTP link (180s timer + 5s buffer) |

---

## UAT Environment Notes

**Service window:** UAT (`customer.uat.graydev.in`) is unavailable **9pm – 7am** daily. All runs must happen within the 7am–9pm window.

**Fixed OTP:** UAT has OTP `9999` pre-configured for all mobile numbers. No SMS dependency.

**checkMobilePost rate limit:** ~3 calls per ~60 seconds per IP. The `Navigate To OTP Page` keyword auto-detects this (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT`. Each OTP test uses a distinct mobile number to reduce collisions.

**verifyOtpPost rate limit:** Also applies per IP. The `Valid OTP Redirects To Dashboard` and `Switch To Account` keywords handle this with a three-state page-check after `RATE_LIMIT_WAIT`:
- On `/my-applications` → OTP succeeded (slow redirect), continue
- On `/verify` (OTP form visible) → re-enter OTP and click Verify
- On `/` (login page) → rate limit forced full logout, re-submit login form then OTP

**Dashboard session model:** The dashboard suite uses a **single shared browser session** across all tests:
- `Suite Setup` — logs in once with `DASHBOARD_MOBILE` (8108556708), lands on /my-applications
- `Test Setup` — navigates to /my-applications (resets tab/filter state, no new login)
- `Test Teardown` — none (shared session preserved between tests)
- `Suite Teardown` — closes browser
- TC-4009 (Logout) **must remain the last test** — it destroys the shared session

**Account switching (TC-4030):** TC-4030 calls `Switch To Account` to log in as `PG_MOBILE` (7757855472) which has transaction records. This logout-then-login happens within the same browser context (~3 minutes after Suite Setup, so rate limits are cleared). TC-4031 inherits the PG_MOBILE session.

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

---

## Results

After a run, open `results/report.html` for the full test report or `results/log.html` for detailed step-by-step logs with screenshots.
