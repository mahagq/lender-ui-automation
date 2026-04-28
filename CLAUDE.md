# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## MCP Tools: code-review-graph

**ALWAYS use code-review-graph tools BEFORE Grep/Glob/Read.** The graph is pre-indexed, token-efficient, and provides structural context (callers, dependents, test coverage) that file scanning cannot.

### When to use graph tools FIRST

| Task | Graph tool | Do NOT use |
|------|-----------|------------|
| Find a keyword/function | `semantic_search_nodes` | Grep across all `.robot` files |
| Understand impact of a change | `get_impact_radius` | Manually trace imports |
| Code review | `detect_changes` + `get_review_context` | Reading entire resource files |
| Find callers of a keyword | `query_graph` (callers_of) | Grep for keyword name |
| Architecture questions | `get_architecture_overview` | Reading directory trees |
| Find test coverage | `query_graph` (tests_for) | Scanning test files |

Fall back to Grep/Glob/Read **only** when the graph returns no result.

### Graph-first workflow for this project

1. **New task** → `semantic_search_nodes` to locate relevant keywords/resources
2. **Before editing a resource file** → `get_impact_radius` to see which test suites are affected
3. **Code review** → `detect_changes` first, then `get_review_context` for snippets only
4. **Adding keywords** → `query_graph` (callers_of) to verify nothing already does the job

## Overview

Robot Framework UI automation suite for the GQ Customer Portal. Covers the login left component, login form, OTP verification flow, bypass authentication, dashboard, the full Application Creation Flow wizard (10 pages: `/student-details` → `/confirm-application`), and Renewal Journey Flow (Welcome Back + Verify Details) — targeting UAT: `https://customer.uat.graydev.in/`. Uses the **Browser library (Playwright)** — not SeleniumLibrary.

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
# Dashboard suites:
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_emi_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_ad_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_pg_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_ins_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_ins_new_user_tests.robot
./venv/bin/robot --outputdir results/ tests/dashboard/dashboard_new_user_tests.robot
# E2E:
./venv/bin/robot --outputdir results/ tests/e2e/e2e_create_application_tests.robot
./venv/bin/robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot
./venv/bin/robot --outputdir results/ tests/e2e/resume_journey_e2e_tests.robot
./venv/bin/robot --outputdir results/ tests/e2e/renewal_flow_e2e_tests.robot
# Renewal Journey Flow (requires RENEWAL_MOBILE + RESUME_MOBILE registered on UAT):
./venv/bin/robot --outputdir results/ tests/renewal_journey_flow/student_details_tests.robot
./venv/bin/robot --outputdir results/ tests/renewal_journey_flow/choose_plan_tests.robot
./venv/bin/robot --outputdir results/ tests/renewal_journey_flow/welcome_back_tests.robot
./venv/bin/robot --outputdir results/ tests/renewal_journey_flow/verify_details_tests.robot
# Application Creation Flow suites (APP_CREATION_MOBILE auto-generated fresh each run — do NOT set via env var):
./venv/bin/robot --outputdir results/ tests/application_creation_flow/student_details_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/choose_plan_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/select_applicant_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/applicant_basic_details_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/onboarding_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/personal_details_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/residential_details_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/employment_tests.robot
./venv/bin/robot --outputdir results/ tests/application_creation_flow/confirm_application_tests.robot
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
./venv/bin/robot --outputdir results/ --include salaried tests/application_creation_flow/employment_tests.robot    # salaried only
./venv/bin/robot --outputdir results/ --include self-employed tests/application_creation_flow/employment_tests.robot  # SE only
./venv/bin/robot --outputdir results/ --include renewal tests/                                                     # all renewal tests
./venv/bin/robot --outputdir results/ --include renewal-journey-flow tests/renewal_journey_flow/                   # renewal journey flow only
./venv/bin/robot --outputdir results/ --include skip-journey tests/renewal_journey_flow/verify_details_tests.robot    # skip employment tests
./venv/bin/robot --outputdir results/ --include edit-residential tests/renewal_journey_flow/verify_details_tests.robot # edit residential tests
./venv/bin/robot --outputdir results/ --include edit-employment tests/renewal_journey_flow/verify_details_tests.robot  # edit employment tests
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
  dashboard/
    dashboard_tests.robot             — 11 dashboard tests (2 skipped — TC-4004, TC-4005): header, create-app, insurance tab nav, logout
    dashboard_new_user_tests.robot    — 4 new-user empty state tests (TC-4047–TC-4050; DASHBOARD_NEW_MOBILE, independent)
    dashboard_emi_tests.robot         — 5 EMI tab tests (TC-4001, TC-4011, TC-4044–TC-4046; DASHBOARD_MOBILE, independent)
    dashboard_ad_tests.robot          — 10 AD tab tests (TC-4002, TC-4012, TC-4036–TC-4043; AD_MOBILE 8763694182, independent)
    dashboard_pg_tests.robot          — 21 PG/Transaction History tests (TC-4003, TC-4013–TC-4029, TC-4051, TC-4030–TC-4031; PG_MOBILE 7757855472, independent)
    dashboard_ins_tests.robot         — 11 insurance tab tests (TC-4101–TC-4111; INS_MOBILE 8668768645, independent)
    dashboard_ins_new_user_tests.robot — 4 insurance new-user tests (TC-4112–TC-4115; DASHBOARD_NEW_MOBILE, independent)
  e2e/
    e2e_create_application_tests.robot     — Data-driven full E2E application creation (Login → Confirm & Submit; driven by data/application_data.xlsx)
    smoke_e2e_tests.robot                  — Single fixed happy-path E2E (Salaried + Parent/Guardian; 1 test)
    resume_journey_e2e_tests.robot         — Resume-at-every-page: 9 tests closing at each wizard page and resuming (RESUME_MOBILE)
    renewal_flow_e2e_tests.robot           — Data-driven renewal E2E (existing account; Welcome Back → Verify Details; driven by renewal_application_data.xlsx)
  renewal_journey_flow/
    student_details_tests.robot            — Renewal: Student Details (7 tests, TC-R5001–TC-R5007; RENEWAL_MOBILE)
    choose_plan_tests.robot                — Renewal: Choose Plan (8 tests, TC-R6001–TC-R6008; RENEWAL_MOBILE)
    welcome_back_tests.robot               — Renewal: Welcome Back pre-fill screen (6 tests; TC-WB01–WB06)
    verify_details_tests.robot             — Renewal: Verify Details — skip, edit residential, edit employment, validations, proceed (25 tests; TC-VD01–VD25)
  application_creation_flow/
    student_details_tests.robot            — 40 student details tests (TC-5001–TC-5027, TC-5N-01–TC-5N-13)
    choose_plan_tests.robot                — 18 choose plan tests (TC-6001–TC-6018)
    select_applicant_tests.robot           — 19 select applicant tests (TC-7001–TC-7020)
    applicant_basic_details_tests.robot    — 23 applicant basic details tests (TC-8001–TC-8014-S, independent)
    onboarding_tests.robot                 — 7 onboarding tests (TC-9001–TC-9N-01, independent)
    personal_details_tests.robot           — 18 personal details tests (TC-10001–TC-10N-10, independent)
    residential_details_tests.robot        — 12 residential details tests (TC-11001–TC-11N-05, independent)
    employment_tests.robot                 — 46 employment tests: 7 type + 13 salaried + 10 SE + 12 validation + misc (TC-12001–TC-12N-SE06)
    confirm_application_tests.robot        — 20 confirm application tests (TC-13001–TC-13025)

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
  WelcomeBackPage.robot              — Keywords + locators for renewal Welcome Back pre-fill screen
  VerifyDetailsPage.robot            — Keywords + locators for renewal Verify Details review screen
  E2EApplicationFlow.robot           — E2E orchestration: Create Full Application + Create Full Renewal Application

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

Dashboard tests are split across **6 independent files**, each with its own browser session:

| File | Suite Setup account | Tests |
|------|---------------------|-------|
| `dashboard_tests.robot` | DASHBOARD_MOBILE → NEW_USER_MOBILE | TC-4004–4010, TC-4034, TC-4032–4033, TC-4035, TC-4009 |
| `dashboard_new_user_tests.robot` | DASHBOARD_NEW_MOBILE | TC-4047–4050 |
| `dashboard_emi_tests.robot` | DASHBOARD_MOBILE | TC-4001, TC-4011, TC-4044–4046 |
| `dashboard_ad_tests.robot` | AD_MOBILE (8763694182) | TC-4002, TC-4012, TC-4036–4043 |
| `dashboard_pg_tests.robot` | PG_MOBILE (7757855472) | TC-4003, TC-4013–4029, TC-4051, TC-4030–4031 |
| `dashboard_ins_tests.robot` | INS_MOBILE (8668768645) | TC-4101–4111 |
| `dashboard_ins_new_user_tests.robot` | DASHBOARD_NEW_MOBILE (dynamic) | TC-4112–4115 |

**Common session model (all dashboard files):**
- `Suite Setup` — opens browser, logs in with the file's account, reaches /my-applications.
- `Test Setup` — `Navigate To Dashboard`: hard-navigates to /my-applications (resets state). No new login.
- `Test Teardown` — NONE (shared session preserved).
- `Suite Teardown` — `Close Browser`.

**`dashboard_tests.robot` specific:**
- **TC-4009 (Logout) MUST remain the last test** — it destroys the shared session.
- TC-4035 switches to `${NEW_USER_MOBILE}`; TC-4009 inherits.
- TC-4032–TC-4033 (Insurance tab nav) run under DASHBOARD_MOBILE — no account switch needed.

**AD/PG files:** Use `Login And Navigate To Dashboard As ${mobile}` (parameterized keyword in `DashboardPage.robot`) — no `Switch To Account` calls anywhere in these files.

## Insurance Dashboard Session Model

`dashboard_ins_tests.robot` uses a **single shared browser session** with `${INS_MOBILE}` (8668768645):
- `Suite Setup` — `Login And Navigate To Insurance Tab`: logs in once, clicks Insurance tab, lands on `/my-applications#ins`.
- `Test Setup` — `Navigate To Insurance Tab`: hard-navigates to `/my-applications` then clicks the Insurance tab.
- `Test Teardown` — NONE (shared session preserved).
- `Suite Teardown` — `Close Browser`.
- **TC-4112** uses `[Setup] Navigate To Insurance Tab New User` which calls `Switch To Account ${DASHBOARD_NEW_MOBILE}`. TC-4113–TC-4115 inherit that session via the suite-level Test Setup.

## Application Creation Flow Session Model

Each wizard test suite uses a **single shared browser session** using `${APP_CREATION_MOBILE}` (generated fresh per run by `variables/dynamic_variables.py` — never a static value):
- `Suite Setup` — `Navigate To <Page>`: logs in once, creates new application, traverses all preceding wizard steps with stub data.
- `Test Setup` — `Navigate To <Page> Within Session`: hard-navigates (`Go To`) to the target URL. No new login.
- `Test Teardown` — NONE (shared session preserved).
- `Suite Teardown` — `Close Browser`.
- **Wizard-advancing tests (proceed/submit) run LAST** in each suite with `[Setup] NONE` to avoid resetting position.

**Traversal stub data** uses `APP_*` variables from `variables.robot`:
- `APP_CREATION_MOBILE` — always dynamic (timestamp-based, generated by `dynamic_variables.py`); env var override intentionally removed to prevent in-progress application accumulation across runs
- react-select dropdowns: `Select First Option In React Select` helper (approved T1 exception for traversal only)
- PAN lookup and pincode city/state API calls require `Sleep 2s` during traversal

**E2E tests** live exclusively in `tests/e2e/`. All new end-to-end journey test files must be placed there. E2E suites are data-driven (Excel via `data/application_data.xlsx`) and cover full flows from Login → Confirm & Submit. They use `resources/E2EApplicationFlow.robot` and `libraries/ApplicationDataReader.py`.

**`applicant_basic_details_tests.robot`** covers `/applicant-basic-details` only (TC-8001–TC-8014-S). Each test uses `[Setup] Navigate To Basic Details Within Session` except TC-8014 (`[Setup] NONE`, sequential after TC-8013) and TC-8014-S (standalone close+resume test).

**`onboarding_tests.robot`**, **`personal_details_tests.robot`**, **`residential_details_tests.robot`** are each fully independent suites with their own Suite Setup traversal — no cross-file ordering dependencies.

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
| Welcome Back continue button | `text=CONTINUE WITH THESE DETAILS` |
| Welcome Back change applicant | `text=CHANGE APPLICANT DETAILS` |
| Verify Details address title | `css=[data-testid='current-address-title']` |
| Verify Details addr line 1 | `css=[data-testid='addr-line-1-input']` |
| Verify Details skip button | `css=[data-testid='skip-button']` |
| Verify Details confirm button | `text=CONFIRM AND PROCEED` |
| Verify Details business name | `css=[data-testid='business-name-input']` |
| Verify Details annual income | `css=[data-testid='business-annual-income-input']` |
| Verify Details years in business | `css=[data-testid='years-of-current-business-input']` |

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
| Verify Details no consent | `consent-checkbox-error` | `Please accept Terms and Conditions` (Verify Details screen) |
| Verify Details empty addr line 1 | `addr-line-1-input-error` | shown in residential edit form |
| Verify Details invalid pincode | `pincode-input-error` | shown in residential edit form |
| Verify Details empty business name | `business-name-input-error` | shown in employment edit form |
| Verify Details invalid annual income | `business-annual-income-input-error` | shown in employment edit form |

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

### File Update Rules (VERY IMPORTANT)

Whenever any change is made to the project — new test cases, new keywords, new resources, new variables, structural changes, or bug fixes — **always update ALL relevant project files in the same session**:

* **CLAUDE.md** — update architecture, commands, session model, locator tables, or any section that reflects the changed area
* **README.md** — update if the change affects setup, usage, or feature coverage
* **jenkins.md** — update if the change affects CI/CD pipeline configuration or test execution
* **`.manifold/` files** — update any manifold constraint or artifact files that relate to the changed feature or flow
* **Test case files** (`tests/` and subdirectories) — update existing test cases or add new ones to cover the changed functionality; ensure TC IDs, tags, and assertions stay consistent with the change

Do NOT complete a task and stop without checking whether each of these files needs updating. Even small changes (e.g., a new test tag, a renamed keyword, a new mobile number) must be reflected in the relevant documentation and test files in the same response.

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
| Verify Details (renewal) | `/verify-details` |
