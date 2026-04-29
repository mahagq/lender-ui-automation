# customer-portal-auth-automation

## Outcome

Build a complete Robot Framework UI automation test suite for the customer portal's authentication flow (Login + OTP verification), derived from actual frontend source selectors. The suite must cover: valid login (mobile number + consent) redirecting to OTP page, login validation errors (empty mobile, invalid mobile format, non-10-digit mobile, consent not accepted), valid OTP redirecting to dashboard, and OTP error states (invalid OTP, empty OTP, resend OTP after timer). Files must follow the existing project's page-object pattern — `LoginPage.robot` and `OTPPage.robot` resource files with keyword libraries, and `login_tests.robot` / `otp_tests.robot` (or combined `auth_tests.robot`) test suites. All locators derived from `data-testid` attributes in `gqcustomer_frontend`. Tests run against UAT: https://customer.uat.graydev.in/. Results captured via `robot --outputdir results/`.

> **CRITICAL NOTE**: The login form collects **mobile number + consent checkbox** — there is no email field and no password field. Original test spec referring to email/password has been revised accordingly.

---

## Discovered Selectors (from gqcustomer_frontend source)

| Element | data-testid | Notes |
|---------|-------------|-------|
| Login form | `login-form` | `data-testid` on `<form>` |
| Mobile number input | `mobile-number-input` | `<input>` element |
| Mobile number error | `mobile-number-input-error` | Shown on validation failure |
| Consent checkbox | `consent-checkbox` | Must be checked before submit |
| Send OTP button | `send-otp-button` | Submits mobile number, triggers SMS |
| OTP form | `verify-otp-form` | `data-testid` on `<form>` |
| OTP input | `otp-input` | `<input>` element |
| OTP input error | `otp-input-error` | Shown on validation failure |
| Verify OTP button | `verify-otp-button` | Submits 4-digit OTP |
| OTP timer | `send-otp-timer` | Counts down 180s |
| Resend OTP link | `resend-otp-link` | Visible ONLY after 180s countdown |

## Routes

| Page | URL |
|------|-----|
| Login | `https://customer.uat.graydev.in/` |
| Verify OTP | `https://customer.uat.graydev.in/verify` |
| Dashboard | `https://customer.uat.graydev.in/my-applications` |

---

## Constraints

### Business

#### B1: Login Form Uses Mobile Number, Not Email/Password

All test cases for the login flow must use the mobile number input field. There is no email or password field in the current frontend. Tests written for email/password will fail with "element not found" errors.

> **Rationale:** Confirmed by reading `LoginForm.jsx` — form collects `mobile_number` + `consent` only. The `checkMobilePost` API call sends an OTP to the provided mobile number.

#### B2: Full Revised Test Coverage

The test suite must cover all revised auth test cases. Current coverage: **21 login test cases** (valid login, 8 validation error scenarios, field behaviour, OTP-redirect flows, button state, UI elements, consent navigation links, query param prefill, mobile footer), **14 OTP test cases** (11 active: field visibility, empty/short/non-numeric/valid/wrong OTP, back-button navigation ×2, mobile display, timer; 3 skipped: SMS-dependent, timing-sensitive, resend slow test tagged `robot:skip`), and **4 bypass auth test cases** (2 active: valid mobile redirect, no-param redirect; 2 skipped: no-account error state requires specific UAT test data).

> **Rationale:** These are the meaningful coverage points derivable from the Yup validation schema and OTP flow. Skipped tests are preserved in the suite with explanatory tags — they are not deleted.

#### B3: UAT Environment Target

All tests must run against `https://customer.uat.graydev.in/`. Base URL must be a variable — never hardcoded inside keyword or test files.

> **Rationale:** User confirmed target is UAT server. Variables file or env var injection allows switching environments.

---

### Technical

#### T1: Locators Must Use data-testid Attributes Exclusively

Every Robot Framework locator must reference the `data-testid` attribute (e.g., `xpath=//*[@data-testid='mobile-number-input']` or `css=[data-testid='mobile-number-input']`). CSS class selectors and absolute XPath are forbidden.

> **Rationale:** CSS classes in this React project use CSS Modules (hashed class names like `LoginForm_InputWrapper__abc12`), which change on rebuild. `data-testid` attributes are stable, semantic locators explicitly added by developers for testing.

#### T2: Browser Library Detection Required

The existing Robot Framework project does not yet have `.robot` files confirming whether SeleniumLibrary or Browser (Playwright) is in use. Library choice must be detected from `requirements.txt`, `robot.yaml`, or existing test files before keyword implementations are written.

> **Rationale:** SeleniumLibrary and Browser library have different keyword syntax. Using the wrong library will cause immediate import failures.

#### T3: OTP Delivery via SMS — Configurable Wait Required

The OTP is a 4-digit code sent via SMS to the test mobile number. UAT SMS delivery may take 5–30 seconds. Tests that require a real OTP must wait up to 30 seconds for SMS delivery and have a fallback strategy if the gateway is unavailable.

> **Rationale:** User confirmed OTP source includes SMS (option 3). The Yup schema confirms OTP is 4 digits, numeric only (`Regex.otp`).

#### T4: Resend OTP Only Appears After 180-Second Timer

The `data-testid='resend-otp-link'` element is rendered conditionally — only when the countdown timer (`totalSeconds=180`) reaches zero. Tests for resend OTP must either wait the full 180 seconds or use a dedicated timer-bypass strategy.

> **Rationale:** Confirmed in `SendOtpTimer.jsx` — the `<span>` with `data-testid='resend-otp-link'` is in the `else` branch of `{time !== 0 ? ... : ...}`.

#### T5: Exact Field Constraints from Yup Schema

Mobile number: 10-digit numeric, enforced by `maxLength={10}` and Yup `.length(10)`. OTP: 4-digit numeric, enforced by `maxLength={4}` and Yup `.length(4, ...)` + `.matches(Regex.otp)`.

> **Rationale:** Validation messages are exact strings from Login.jsx and VerifyOTP.jsx. Tests must assert these exact strings.

---

### User Experience

#### U1: Exact Validation Error Message Assertions

Tests must assert the exact error messages rendered in `data-testid='*-error'` elements. Strings are:
- Empty mobile: `"Please enter your mobile number"`
- Invalid format: `"Please enter valid mobile number"`
- Non-10-digit: `"Mobile number must contain 10 digits"`
- Consent: `"Please accept Terms and Conditions"`
- Empty OTP: `"Please enter 4 digit OTP"`
- Wrong OTP length: `"OTP number must contain 4 digits"`
- Non-numeric OTP: `"Only numeric values allowed"`
- Wrong OTP toast: `"Incorrect OTP"` — **secondary/non-blocking** assertion. Primary assertion is URL stays on `/verify`. If `verifyOtpPost` is rate-limited (429), no toast appears — URL assertion still passes, toast failure is logged as WARN not a test failure.

> **Rationale:** These are the exact strings in the Yup schemas in Login.jsx and VerifyOTP.jsx. Any deviation in assertions will cause false failures. The wrong OTP toast is non-blocking because UAT verifyOtpPost rate limiting can suppress it without affecting the core wrong-OTP behaviour (user stays on /verify either way).

#### U2: Explicit Waits for All React-Rendered Elements

Every interaction keyword must use `Wait Until Element Is Visible` before clicking or typing. `Sleep` statements must not be used.

> **Rationale:** The frontend is a React SPA — elements are dynamically rendered. Immediate interactions without waits will produce intermittent failures.

#### U3: URL-Based Redirect Assertions

After valid login, assert current URL contains `/verify`. After valid OTP, assert current URL contains `/my-applications`.

> **Rationale:** Confirmed in Login.jsx (`navigateTo('/verify', ...)`) and VerifyOTP.jsx (`navigateTo('/my-applications')`). URL assertion is more reliable than element presence for post-redirect states.

---

### Security

#### S1: Test Credentials Must Not Be Hardcoded in Test Files

The test mobile number (a real UAT-registered number) and any OTP values must be stored in a Robot Framework variables file (`variables.robot` or `variables.yaml`) or injected via environment variables (`%{VARIABLE_NAME}`). They must not appear inline in any `.robot` test file.

> **Rationale:** User confirmed credentials strategy as variables file + environment variables (options 1 and 2). Hardcoding real mobile numbers creates a risk if the repo is shared.

#### S2: data-testid Stability Is a Contract

The `data-testid` attributes in `gqcustomer_frontend` function as a test API contract. Any frontend change that removes or renames these attributes will silently break the test suite. This dependency must be documented and communicated to the frontend team.

> **Rationale:** Pre-mortem finding: "selectors broke silently" was selected as the most realistic failure mode.

---

### Operational

#### O1: Dry-Run Must Pass Before Execution

`robot --dryrun tests/` must complete without errors before any live test run is attempted. This validates syntax, keyword resolution, and variable references.

> **Rationale:** Prevents wasted UAT API calls and obscure runtime errors that could be caught statically.

#### O2: Results Output Required

All test runs must use `robot --outputdir results/` to generate `log.html`, `report.html`, and `output.xml`. Console output summary (total / passed / failed) must be captured.

> **Rationale:** User requirement from the original task spec.

#### O3: Selector Failure Diagnosis Protocol (pre-mortem)

When a test fails with "element not found", the first diagnostic step must be to re-read the corresponding source file in `gqcustomer_frontend` and confirm the `data-testid` attribute still exists and matches. This check must happen before any other debugging.

> **Source:** pre-mortem — "selectors broke silently" failure story.
> **Rationale:** This was the #1 voted failure mode. Making the protocol explicit prevents wasted debugging time.

#### O4: SMS OTP Timeout and Fallback Strategy (pre-mortem)

UAT OTP tests must set a configurable SMS wait timeout (minimum 30 seconds). If the SMS gateway is unavailable or the OTP does not arrive within the timeout, the test must be marked as skipped (not failed) with a clear message: `SMS OTP not received within timeout — SMS gateway may be unavailable`.

> **Source:** pre-mortem — "UAT OTP never arrived" failure story.
> **Rationale:** SMS delivery is an external dependency. A gateway outage should not fail the entire suite or block CI.

---

## Tensions

### TN1: Resend OTP Timer (180s) vs Full Test Coverage

**Type:** trade_off | **Between:** T4 × B2 | **Status:** resolved

Testing the resend OTP button (T4) requires waiting the full 180-second countdown before `data-testid='resend-otp-link'` becomes visible. Running this wait in every CI test run adds 3+ minutes and blocks the pipeline.

TRIZ: Technical contradiction (Speed vs Correctness). Applying P15 (Dynamization — make it adaptive via tagging).

**Resolution (Decision A — Tag & Skip in CI):**
Tag the resend OTP test with `slow` and `resend` tags. Exclude from default CI runs via `--exclude slow`. Run on demand (manual trigger or nightly job).

> **Propagation:** B2 (coverage) LOOSENED — tagged test is in the suite, runnable anytime. O2 (results) TIGHTENED — default CI report won't include slow tests; document this in results README.

---

### TN2: SMS OTP Gateway Reliability vs Reliable Test Runs

**Type:** resource_tension | **Between:** T3 × O4 × B2 × O1 | **Status:** resolved

Real OTP delivery via SMS is an external dependency that can fail or time out in CI (pre-mortem story: "UAT OTP never arrived"). This would make all OTP-dependent tests unreliable.

TRIZ: Resource tension (Reliability vs External Availability). Applying P10 (Prior action — pre-configure fixed OTP in UAT).

**Resolution (Decision A — Fixed OTP 9999):**
UAT backend has a fixed OTP `9999` configured for any valid mobile number. No SMS wait is required. `TEST_OTP=9999` goes in the variables file.

Runtime rate limit handling (added 2026-04-21): UAT `verifyOtpPost` is rate-limited per IP in addition to `checkMobilePost`. After OTP submission, the test polls for redirect up to `LONG_TIMEOUT`, then waits `RATE_LIMIT_WAIT` (45s) and checks page state — three branches: (1) already on `/my-applications` → succeeded; (2) OTP form still visible → re-enter OTP; (3) back on `/` login page → rate limit forced logout, re-submit login then OTP. Each OTP test uses a distinct mobile number (`EXT_OTP_MOBILE_*`) to reduce rate limit collisions.

> **Propagation:** T3 (SMS wait) LOOSENED — no SMS dependency. O4 (gateway fallback) LOOSENED — no gateway needed. S1 (no hardcoded creds) TIGHTENED — `9999` must live in `variables.robot`, not inline in tests.

---

### TN3: Unknown Browser Library Blocks Locator Implementation

**Type:** hidden_dependency | **Between:** T2 → T1, T5 | **Status:** resolved

T2 (library unknown) was a blocker: SeleniumLibrary and Browser (Playwright) have different keyword syntax, locator formats, and wait strategies. T1 and T5 cannot be implemented until the library is confirmed.

**Resolution (Browser / Playwright v19.9.0 confirmed):**
Both libraries were found in the project venv. User selected **Browser (Playwright)**. Locator syntax: `css=[data-testid='...']`. Input keyword: `Fill Text`. Submit: `Click`.

> **Propagation:** T1 (locators) LOOSENED — syntax confirmed. T5 (field constraints) LOOSENED — `Fill Text` + DOM maxLength handles this. U2 (explicit waits) LOOSENED — Browser has built-in auto-wait; explicit `Wait Until` only needed for slow API responses.

---

### TN4: No Hardcoded Credentials vs Working UAT Tests

**Type:** trade_off | **Between:** S1 × B3 × O1 | **Status:** resolved

Tests must use real UAT credentials (a registered mobile number and OTP), but S1 forbids hardcoding them anywhere in test files.

TRIZ: Physical contradiction (Privacy vs Usability). Applying P1 (Segmentation — separate config layer from test logic) and P24 (Intermediary — variables file as the config intermediary).

**Resolution (Variables file + env var injection):**
`variables.robot` holds `BASE_URL`, `TEST_MOBILE`, `TEST_OTP=9999`. For CI, `TEST_MOBILE` is injected via `%{TEST_MOBILE}` environment variable. No sensitive value appears inline in any `.robot` file.

> **Propagation:** S1 LOOSENED — credentials in variables file, not in tests. B3 LOOSENED — BASE_URL variable enables environment switching without editing test files.

---

## Required Truths

> **BINDING CONSTRAINT: RT-1** — All other unsatisfied truths depend on or flow from it.

### RT-1: Complete Project File Structure Must Exist ⚠️ BINDING

The Robot Framework automation project must have all five required files before any test can be written, dry-run, or executed.

**Required files:**
- `variables/variables.robot` — BASE_URL, TEST_MOBILE, TEST_OTP
- `resources/LoginPage.robot` — Login page keywords (page object)
- `resources/OTPPage.robot` — OTP verify page keywords (page object)
- `tests/login_tests.robot` — Login test suite
- `tests/otp_tests.robot` — OTP test suite (includes slow-tagged resend test)

**Status:** NOT_SATISFIED
**Gap:** Project currently has only empty `tests/` and `results/` directories. No resource files, no variables file, no test files.

#### RT-1.1: resources/ directory with page object files

`resources/LoginPage.robot` and `resources/OTPPage.robot` must exist with Browser library imports and all keyword definitions derived from confirmed `data-testid` locators.

**Status:** NOT_SATISFIED — directory and files do not exist.

#### RT-1.2: tests/ directory with test suite files

`tests/login_tests.robot` and `tests/otp_tests.robot` must exist, importing the resource files and variables file.

**Status:** NOT_SATISFIED — test directory exists but contains no `.robot` files.

#### RT-1.3: variables/variables.robot with credential variables

```robot
*** Variables ***
${BASE_URL}       https://customer.uat.graydev.in
${TEST_MOBILE}    9876543210
${TEST_OTP}       9999
${BROWSER}        chromium
```

**Status:** NOT_SATISFIED — file does not exist.

---

### RT-2: Confirmed UAT Test Credentials ✓ SATISFIED

Any valid 10-digit mobile number is accepted by UAT (fixed OTP `9999` is configured universally). `TEST_MOBILE=9876543210` and `TEST_OTP=9999` will be used.

**Status:** SATISFIED
**Evidence:** User confirmed UAT accepts any valid 10-digit number with OTP 9999. TN2 resolution confirmed.

#### RT-2.1: Mobile number accepted by checkMobilePost API

Any 10-digit number triggers OTP send and navigates to `/verify`. Wrong-format numbers trigger client-side validation errors before API call.

**Status:** SATISFIED

---

### RT-3: Playwright Runtime Fully Initialized ✓ SATISFIED

`rfbrowser init` has been run. All browsers downloaded: `chromium-1194`, `firefox-1495`, `webkit-2215`. Library: `robotframework-browser==19.9.0`.

**Status:** SATISFIED
**Evidence:** Playwright binary found at `venv/lib/.../Browser/wrapper/node_modules/.bin/playwright`. All browser dirs present.

---

### RT-4: UAT Locators Match Source Selectors (verifiable at runtime)

The `data-testid` attributes derived from `gqcustomer_frontend` source must be present in the UAT-deployed version of the frontend.

**Status:** PARTIAL
**Gap:** UAT deployment version is unknown. Source selectors are confirmed correct for the current codebase, but UAT may run a slightly older build. RT-4 is verified (pass) or corrected (fix selector) on the first actual test run. Per O3, any element-not-found failure triggers immediate source re-inspection.

#### RT-4.1: Login page locators present in UAT

`data-testid='login-form'`, `data-testid='mobile-number-input'`, `data-testid='send-otp-button'`, `data-testid='consent-checkbox'` must be present.

#### RT-4.2: OTP page locators present in UAT

`data-testid='verify-otp-form'`, `data-testid='otp-input'`, `data-testid='verify-otp-button'`, `data-testid='resend-otp-link'` must be present.

---

### RT-5: robot --dryrun Passes Without Errors (specification ready)

`robot --dryrun tests/` must exit 0, confirming correct syntax, valid keyword resolution, and variable references.

**Status:** SPECIFICATION_READY — all information required to satisfy this is known; depends on RT-1 being satisfied first.
**Gap:** None beyond RT-1. Once project files exist and are correctly structured, dry-run will pass.

---

## Solution Space

### Option A — Incremental Build (file by file)

Create files one at a time, dry-run after each. Slowest but easiest to debug.

- Satisfies: RT-1, RT-5 (incrementally)
- Gaps: None (all info known)
- Reversibility: TWO_WAY
- Complexity: Low (but slow)

### Option B — Full Simultaneous Generation ← **Recommended**

Generate all 5 files at once in m4-generate. Dry-run once at the end. Efficient and complete.

- Satisfies: RT-1 (all sub-truths), RT-5
- Gaps: None (all info known — library, locators, validation messages, OTP, mobile number, routes all confirmed)
- Reversibility: TWO_WAY
- Complexity: Medium
- **Why recommended:** All inputs are known. The manifold contains every locator, validation message, route, and credential needed. A single generation pass produces a working suite. Dry-run immediately validates correctness.

### Option C — Variables-First then Generation

Collect variables first as a separate step, then generate remaining files. Only useful if mobile number wasn't known — it is now.

- Satisfies: RT-1, RT-2, RT-5
- Gaps: Redundant now that RT-2 is SATISFIED
- Reversibility: TWO_WAY
- Complexity: Medium (two-step, no benefit over B)

---

## Tension Validation (cross-phase)

| Tension | Decision | Honored by Option B? |
|---------|----------|----------------------|
| TN1: Tag resend slow | `slow`+`resend` tags in otp_tests.robot | CONFIRMED |
| TN2: Fixed OTP 9999 | `TEST_OTP=9999` in variables.robot | CONFIRMED |
| TN3: Browser/Playwright | `Library    Browser` in all resource files | CONFIRMED |
| TN4: Variables file | All credentials in variables.robot only | CONFIRMED |

---

## Draft Required Truths (seeds for /m3-anchor)

> These are drafts only — NOT commitments. m3-anchor will validate, refine, or discard each one.

- **DRT-1**: A test mobile number registered in the UAT backend must exist and be known before valid-login tests can be written *(seeds from B1, B3)*
- **DRT-2**: The UAT SMS gateway must deliver OTPs within 30s, or a fixed-OTP bypass must exist in the UAT environment *(seeds from T3, O4)*
- **DRT-3**: The `data-testid` attribute contract in `gqcustomer_frontend` must remain stable — any rename is a breaking change *(seeds from T1, O3)*
- **DRT-4**: The Robot Framework browser library must be confirmed before keyword implementations can be written *(seeds from T2)*
