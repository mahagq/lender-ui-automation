# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Robot Framework UI automation suite for the GQ Customer Portal. Covers the login left component, login form, OTP verification flow, bypass authentication, dashboard, and the full Application Creation Flow wizard (10 pages: `/student-details` → `/confirm-application`) — targeting UAT: `https://customer.uat.graydev.in/`. Uses the **Browser library (Playwright)** — not SeleniumLibrary.

## Commands

### Run all tests (default — excludes slow/resend tests)
```bash
./venv/bin/robot --outputdir results/ tests/
```

### Run a single test file
```bash
./venv/bin/robot --outputdir results/ tests/login_left_component_tests.robot
./venv/bin/robot --outputdir results/ tests/login_tests.robot
./venv/bin/robot --outputdir results/ tests/otp_tests.robot
./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard_tests.robot
# Application Creation Flow suites (each requires UAT + APP_CREATION_MOBILE registered):
./venv/bin/robot --outputdir results/ tests/student_details_tests.robot
./venv/bin/robot --outputdir results/ tests/choose_plan_tests.robot
./venv/bin/robot --outputdir results/ tests/select_applicant_tests.robot
./venv/bin/robot --outputdir results/ tests/applicant_journey_tests.robot
./venv/bin/robot --outputdir results/ tests/employment_tests.robot
./venv/bin/robot --outputdir results/ tests/confirm_application_tests.robot
```

### Run tests by tag
```bash
./venv/bin/robot --outputdir results/ --include smoke tests/                    # smoke tests only
./venv/bin/robot --outputdir results/ --include login tests/                    # login tests only
./venv/bin/robot --outputdir results/ --include otp tests/                      # OTP tests only
./venv/bin/robot --outputdir results/ --include bypass-auth tests/              # bypass auth tests only
./venv/bin/robot --outputdir results/ --include dashboard tests/                # dashboard tests only
./venv/bin/robot --outputdir results/ --include resend tests/otp_tests.robot    # ~3min resend test
./venv/bin/robot --outputdir results/ --include application-creation-flow tests/  # all wizard tests
./venv/bin/robot --outputdir results/ --include salaried tests/employment_tests.robot    # salaried only
./venv/bin/robot --outputdir results/ --include self-employed tests/employment_tests.robot  # SE only
```

### Dry run (syntax check, no browser)
```bash
./venv/bin/robot --dryrun tests/
```

### Override base URL or mobile number
```bash
./venv/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999999999 ./venv/bin/robot --outputdir results/ tests/
# TC-401 bypass auth redirect test — requires an ERP-registered mobile (see Bypass Auth section):
BYPASS_AUTH_MOBILE=<erp_mobile> ./venv/bin/robot --outputdir results/ tests/bypass_auth_tests.robot
```

## Architecture

```
tests/                     — Test suites (import resources and variables)
  login_left_component_tests.robot  — 9 left panel component tests (TC-101–TC-109)
  login_tests.robot                 — 23 login form tests (TC-201, TC-207–TC-228)
  otp_tests.robot                   — 18 OTP tests: 15 active, 3 skipped (TC-301–TC-318)
  bypass_auth_tests.robot           — 4 bypass auth tests (2 skipped)
  dashboard_tests.robot             — 33 dashboard tests (2 skipped — TC-4004, TC-4005)
  dashboard_ins_tests.robot         — 15 insurance tab tests (TC-4101–TC-4115; ${INS_MOBILE} 8668768645 for existing-policy tests, ${DASHBOARD_NEW_MOBILE} for new-user tests)
  student_details_tests.robot       — 21 student details tests (TC-5001–TC-5021)
  choose_plan_tests.robot           — 16 choose plan tests (TC-6001–TC-6016)
  select_applicant_tests.robot      — 10 select applicant tests (TC-7001–TC-7011)
  applicant_journey_tests.robot     — 27 sequential wizard tests (TC-8001–TC-11007)
  employment_tests.robot            — 30 employment tests: 7 type + 13 salaried + 10 SE (TC-12001–TC-12094)
  confirm_application_tests.robot   — 12 confirm application tests (TC-13001–TC-13025)

resources/                 — Page Object keyword libraries (no variable imports)
  LoginLeftComponent.robot           — Keywords + locators for left panel component
  LoginPage.robot                    — Keywords + locators for / (login form)
  OTPPage.robot                      — Keywords + locators for /verify (OTP form)
  BypassAuthPage.robot               — Keywords + locators for /instant-eligibility (bypass auth)
  DashboardPage.robot                — Keywords + locators for /my-applications (dashboard)
  InsuranceDashboardPage.robot       — Keywords + locators for /my-applications#ins (Insurance tab)
  ApplicationCreationFlowPage.robot  — Wizard navigation infrastructure + traversal helpers (imports all wizard pages)
  StudentDetailsPage.robot           — Keywords + locators for /student-details
  ChoosePlanPage.robot               — Keywords + locators for /choose-plan
  SelectApplicantPage.robot          — Keywords + locators for /select-applicant
  ApplicantBasicDetailsPage.robot    — Keywords + locators for /applicant-basic-details
  OnboardingPage.robot               — Keywords + locators for /onboarding
  ApplicantPersonalDetailsPage.robot — Keywords + locators for /applicant-personal-details
  ApplicantResidentialDetailsPage.robot — Keywords + locators for /applicant-residential-details
  EmploymentTypePage.robot           — Keywords + locators for /select-employment
  ApplicantEmploymentPage.robot      — Keywords + locators for /applicant-employment-details (salaried + SE)
  ConfirmApplicationPage.robot       — Keywords + locators for /confirm-application

variables/
  variables.robot           — All variables: BASE_URL, timeouts, test data, browser settings, APP_* wizard data

results/                   — robot output (output.xml, log.html, report.html)
```

**Key pattern:** Test files import resource files and the variables file. Resource files do NOT import variables — Robot Framework shares the variable scope from the suite, so resources access `${TIMEOUT}`, `${BASE_URL}`, etc. directly. No `*** Keywords ***` section in test files — all keywords live in resource files (Page Object Model).

**ApplicationCreationFlowPage.robot exception:** This orchestrator file imports all wizard page resource files so its `Navigate To *` traversal keywords can call any page's URL helpers and locators. Test suites that import `ApplicationCreationFlowPage.robot` and a specific page file get deduplicated imports automatically.

## UAT Constraints

- **Fixed OTP**: UAT uses OTP `9999` for all mobile numbers — no SMS dependency.
- **Bypass Auth (TC-401, TC-403, TC-404 — all skipped)**: `/instant-eligibility?m=<mobile>` only redirects if the mobile is ERP-whitelisted (`bypassAuthPost` succeeds). Confirmed: neither `9876543210` nor `8108556708` works — `bypassAuthPost` rejects general OTP test accounts. TC-401 is tagged `robot:skip`. To enable: identify a UAT ERP-whitelisted mobile, set `BYPASS_AUTH_MOBILE` env var, and remove `robot:skip` from TC-401.
- **checkMobilePost rate limit**: ~3 calls per ~60s per IP. `Navigate To OTP Page` auto-detects (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT` (45s). Each OTP/login test uses a distinct mobile number to reduce collisions.
- **verifyOtpPost rate limit**: Also applies per IP. Handled with a three-state page-check after `RATE_LIMIT_WAIT` sleep: (1) on `/my-applications` → OTP succeeded, skip retry; (2) on `/verify` → re-enter OTP; (3) on `/` → rate limit forced logout, re-submit login form then OTP. Applied in `Valid OTP Redirects To Dashboard`, `Login And Navigate To Dashboard`, and `Switch To Account`.
- **Test order**: `Valid OTP Redirects To Dashboard` runs before `Wrong OTP Shows Incorrect OTP Toast` — a prior failed verifyOtpPost can trigger rate limiting that blocks the valid path.
- **UAT availability**: UAT is **down 9pm–7am**. Live tests must run between 7am–9pm.

## Dashboard Session Model

The dashboard suite uses a **single shared browser session** across all 33 tests (31 active, 2 skipped — TC-4004 and TC-4005):
- `Suite Setup` — `Login And Navigate To Dashboard`: opens browser, logs in with `${DASHBOARD_MOBILE}` (8108556708), reaches /my-applications.
- `Test Setup` — `Navigate To Dashboard`: hard-navigates to /my-applications (resets tab/filter/dropdown state). No new login.
- `Test Teardown` — NONE (shared session preserved — no `Close Context`).
- `Suite Teardown` — `Close Browser`.
- **TC-4009 (Logout) MUST remain the last test** — it destroys the shared session.
- **TC-4030** calls `Switch To Account    ${PG_MOBILE}` (~3 min into the suite, rate limits cleared). TC-4031 inherits that session.

## Insurance Dashboard Session Model

`dashboard_ins_tests.robot` uses a **single shared browser session** with `${INS_MOBILE}` (8668768645):
- `Suite Setup` — `Login And Navigate To Insurance Tab`: logs in once, clicks Insurance tab, lands on `/my-applications#ins`.
- `Test Setup` — `Navigate To Insurance Tab`: hard-navigates to `/my-applications` then clicks the Insurance tab.
- `Test Teardown` — NONE (shared session preserved).
- `Suite Teardown` — `Close Browser`.
- **TC-4112** uses `[Setup] Navigate To Insurance Tab New User` which calls `Switch To Account ${DASHBOARD_NEW_MOBILE}`. TC-4113–TC-4115 inherit that session via the suite-level Test Setup.

## Application Creation Flow Session Model

Each wizard test suite uses a **single shared browser session** using `${APP_CREATION_MOBILE}` (9876540001):
- `Suite Setup` — `Navigate To <Page>`: logs in once, creates new application, traverses all preceding wizard steps with stub data.
- `Test Setup` — `Navigate To <Page> Within Session`: hard-navigates (`Go To`) to the target URL. No new login.
- `Test Teardown` — NONE (shared session preserved).
- `Suite Teardown` — `Close Browser`.
- **Wizard-advancing tests (proceed/submit) run LAST** in each suite with `[Setup] NONE` to avoid resetting position.

**Traversal stub data** uses `APP_*` variables from `variables.robot`:
- `APP_CREATION_MOBILE=9876540001` — dedicated mobile distinct from all auth suite numbers
- react-select dropdowns: `Select First Option In React Select` helper (approved T1 exception for traversal only)
- PAN lookup and pincode city/state API calls require `Sleep 2s` during traversal

**`applicant_journey_tests.robot`** runs 4 pages (basic-details, onboarding, personal-details, residential-details) **sequentially** with `[Setup] NONE` after the first section advances the wizard. Strict test ordering is required.

**`employment_tests.robot`** covers both Salaried and Self-Employed variants in one file. Per-test `[Setup]` navigates back to `/select-employment` and selects the desired variant.

## Locators

All locators use `data-testid` CSS selectors exclusively — CSS class names use CSS Modules (hashed, unstable). Never use CSS class selectors or absolute XPath.

| Element | Locator |
|---------|---------|
| Login form | `css=[data-testid='login-form']` |
| Mobile input | `css=[data-testid='mobile-number-input']` |
| Consent checkbox | `css=[data-testid='consent-checkbox']` |
| Send OTP button | `css=[data-testid='send-otp-button']` |
| OTP form | `css=[data-testid='verify-otp-form']` |
| OTP input | `css=[data-testid='otp-input']` |
| Verify OTP button | `css=[data-testid='verify-otp-button']` |
| Resend OTP link | `css=[data-testid='resend-otp-link']` (visible only after 180s countdown) |
| Dashboard title | `css=[data-testid='dashboard-title']` |
| Profile button | `css=[data-testid='profile-button']` |
| EMI tab | `css=[data-testid='emi-tab-navigation-button']` |
| PG tab | `css=[data-testid='pg-tab-navigation-button']` |
| Filter button | `css=[data-testid='filter-button']` |
| Insurance tab | `css=[data-testid='ins-tab-navigation-button']` |

## Exact Validation Error Strings

Tests assert these exact strings — do not paraphrase:

| Scenario | Error element | Message |
|----------|--------------|---------|
| Empty mobile | `mobile-number-input-error` | `Please enter your mobile number` |
| Invalid mobile format | `mobile-number-input-error` | `Please enter valid mobile number` |
| Short mobile (< 10 digits) | `mobile-number-input-error` | `Please enter valid mobile number` (regex fires before length) |
| No consent | `consent-checkbox-error` | `Please accept Terms and Conditions` |
| Empty OTP | `otp-input-error` | `Please enter 4 digit OTP` |
| Short OTP (< 4 digits) | `otp-input-error` | `OTP number must contain 4 digits` |
| Non-numeric OTP | `otp-input-error` | `Only numeric values allowed` |
| Wrong OTP | URL stays on `/verify` (primary); toast `text=Incorrect OTP` (secondary — non-blocking, may be absent if verifyOtpPost rate-limited) |

## Claude Working Rules (VERY IMPORTANT)

Follow these rules strictly to minimize token usage and maintain framework consistency:

### Repository Reading Rules

* Do NOT scan the full repository unless explicitly asked
* Do NOT re-read files already explained in this CLAUDE.md
* Only inspect files directly relevant to the current task
* Always prefer using existing project patterns over generating new structures
* Avoid unnecessary re-analysis of stable files
* Never rewrite existing working keywords unless required

### Framework Rules

* This project uses Robot Framework + Browser Library (Playwright), NOT SeleniumLibrary
* Follow the existing Page Object Model structure strictly
* Test files must NOT contain custom keywords
* All reusable logic must stay inside resource files only
* Do NOT create duplicate keywords
* Reuse existing locators, variables, and utilities first
* Maintain existing naming conventions exactly

### Locator Rules

Priority order for locators:

1. data-testid (highest priority)
2. role-based selectors
3. labels/placeholders
4. visible text hierarchy
5. XPath only as last resort

* Never use unstable CSS classes
* Never use absolute XPath
* Avoid strict mode violations in Playwright
* Prefer exact and unique locators only

### Automation Generation Rules

Whenever a new feature is given:

1. Understand the functional flow
2. Prepare QA test cases first
3. Identify automation scope
4. Check if existing keywords already support the flow
5. Fetch accurate locators using Playwright Inspector logic
6. Generate Robot Framework code only after analysis
7. Suggest reusable keywords only if truly needed

### Output Rules

* Keep responses concise
* Avoid unnecessary explanations
* Prefer production-ready code directly
* Do not generate theoretical examples
* Focus on executable automation code only

## Routes

| Page | URL path |
|------|----------|
| Login | `/` |
| OTP verification | `/verify` |
| Dashboard | `/my-applications` |
| FAQ | `/faq` |
| Bypass Auth | `/instant-eligibility` (with `?m=<mobile>` for tokenised ERP access) |
| Student Details | `/student-details` |
| Choose Plan | `/choose-plan` |
| Select Applicant | `/select-applicant` |
| Applicant Basic Details | `/applicant-basic-details` |
| Onboarding | `/onboarding` |
| Applicant Personal Details | `/applicant-personal-details` |
| Applicant Residential Details | `/applicant-residential-details` |
| Select Employment Type | `/select-employment` |
| Applicant Employment Details | `/applicant-employment-details` (shared URL; form variant = salaried or self-employed) |
| Confirm Application | `/confirm-application` |
