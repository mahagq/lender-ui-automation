# Customer Portal UI Automation

Robot Framework end-to-end test suite for the GQ Customer Portal authentication flow.
Covers the mobile number login form and OTP verification flow against the UAT environment.

---

## Project Structure

```
customer_portal_ui_automation/
├── tests/
│   ├── login_tests.robot       # Login form test cases (5 tests)
│   └── otp_tests.robot         # OTP verification test cases (4 tests + 1 slow)
├── resources/
│   ├── LoginPage.robot         # Page object keywords for / (login page)
│   └── OTPPage.robot           # Page object keywords for /verify (OTP page)
├── variables/
│   └── variables.robot         # All test configuration and test data
└── results/                    # Robot Framework output (output.xml, log.html, report.html)
```

---

## Prerequisites

- Python 3.x
- Robot Framework 7.4.2
- Browser (Playwright) library v19.9.0
- Playwright browsers initialised (`rfbrowser init`)

All dependencies live in the shared virtualenv at `../venv/`.

---

## Running Tests

### Default run (all tests, headless, excluding slow)

```bash
/Users/masira/repositories/venv/bin/robot --outputdir results/ --exclude slow tests/
```

### Run with headed browser (visible)

Set `${HEADLESS}` to `False` in `variables/variables.robot`, or override on the command line:

```bash
/Users/masira/repositories/venv/bin/robot --outputdir results/ --exclude slow \
  --variable HEADLESS:False tests/
```

### Run only login tests

```bash
/Users/masira/repositories/venv/bin/robot --outputdir results/ tests/login_tests.robot
```

### Run only OTP tests

```bash
/Users/masira/repositories/venv/bin/robot --outputdir results/ --exclude slow tests/otp_tests.robot
```

### Run the resend OTP test (slow — waits ~3 minutes)

```bash
/Users/masira/repositories/venv/bin/robot --outputdir results/ --include resend tests/otp_tests.robot
```

### Dry run (validate syntax without hitting the browser)

```bash
/Users/masira/repositories/venv/bin/robot --dryrun tests/
```

### Override mobile number via environment variable (CI)

```bash
TEST_MOBILE=9999900000 /Users/masira/repositories/venv/bin/robot --outputdir results/ --exclude slow tests/
```

---

## Test Cases

### Login Tests (`tests/login_tests.robot`)

| Test | Tags | Description |
|------|------|-------------|
| Valid Login With Correct Mobile Number | login, valid, smoke | Valid 10-digit mobile + consent → redirects to /verify |
| Login With Empty Mobile Number | login, validation, negative | No mobile entered → "Please enter your mobile number" |
| Login With Invalid Mobile Number Format | login, validation, negative | Letters in mobile → "Please enter valid mobile number" |
| Login With Short Mobile Number | login, validation, negative | < 10 digits → "Please enter valid mobile number" |
| Login Without Consent | login, validation, negative | No consent checkbox → "Please accept Terms and Conditions" |

### OTP Tests (`tests/otp_tests.robot`)

| Test | Tags | Description |
|------|------|-------------|
| OTP Verification With Empty OTP | otp, validation, negative | No OTP entered → "Please enter 4 digit OTP" |
| OTP Verification With Short OTP | otp, validation, negative | 3-digit OTP → "OTP number must contain 4 digits" |
| Valid OTP Redirects To Dashboard | otp, valid, smoke | OTP 9999 → redirects to /my-applications |
| OTP Verification With Wrong OTP | otp, negative | Wrong OTP → stays on /verify (no redirect) |
| Resend OTP After Timer Expires | otp, slow, resend | After 180s countdown, resend link appears and resets timer |

---

## Configuration

All configuration is in `variables/variables.robot`.

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `https://customer.uat.graydev.in` | Target environment URL |
| `TEST_MOBILE` | `%{TEST_MOBILE=9876543210}` | Mobile for login tests (overridable via env var) |
| `OTP_MOBILE_1..4` | `9876543211..14` | Distinct mobiles for each OTP test (avoids rate limiting) |
| `TEST_OTP` | `9999` | Fixed OTP configured in UAT for all mobile numbers |
| `BROWSER` | `chromium` | Playwright browser (`chromium`, `firefox`, `webkit`) |
| `HEADLESS` | `True` | Run headless (`True`) or with visible browser (`False`) |
| `TIMEOUT` | `10s` | Standard element wait timeout |
| `LONG_TIMEOUT` | `30s` | Extended wait (page navigation, OTP form load) |
| `RESEND_OTP_WAIT` | `185s` | Wait for resend link (180s timer + 5s buffer) |
| `RATE_LIMIT_WAIT` | `45s` | Recovery sleep when UAT checkMobilePost rate limit is hit |

---

## UAT Environment Notes

**Service window:** The UAT server (`customer.uat.graydev.in`) is unavailable **9pm – 7am** daily. All test runs must happen within the 7am–9pm window.

**Fixed OTP:** UAT has OTP `9999` pre-configured for all mobile numbers. No SMS is required.

**IP rate limits:** The UAT backend enforces ~3 `checkMobilePost` calls per ~60 seconds from the same IP. The `Navigate To OTP Page` keyword detects this automatically (page stays on `/` after Send OTP click) and retries after a `RATE_LIMIT_WAIT` sleep. No manual intervention needed.

**Test ordering:** OTP tests are ordered to work within the rate-limit window:
1. Validation tests (Empty, Short OTP) — no `verifyOtpPost` calls
2. Valid OTP — first `verifyOtpPost` call (must succeed before any wrong OTP call)
3. Wrong OTP — last, so a rate-limited `verifyOtpPost` still passes (page stays at /verify either way)

---

## Locator Strategy

All selectors use `data-testid` attributes derived from the React source (`gqcustomer_frontend`).
No CSS class names or XPath. Stable across styling changes.

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
| Resend OTP link | `css=[data-testid='resend-otp-link']` |

---

## Results

After a run, open `results/report.html` in a browser for the full test report, or `results/log.html` for detailed step-by-step logs.
