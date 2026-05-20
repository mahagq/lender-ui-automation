# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Custom Agents

Project-level agents live in `.claude/agents/`. Use via `Agent` tool with `subagent_type`.

| Agent | `subagent_type` | When to use |
|-------|----------------|-------------|
| UI Comprehensive Tester | `ui-comprehensive-tester` | After UI implementation — validates flows, forms, edge cases using Playwright/Puppeteer/Mobile MCP |
| Ultrathink Debugger | `ultrathink-debugger` | Deep root-cause analysis for bugs, intermittent failures, env-specific issues (runs on Opus) |

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

Robot Framework UI automation suite for the GQ Customer Portal. Covers the login left component, login form, OTP verification flow, bypass authentication, dashboard, the full Application Creation Flow wizard (10 pages: `/student-details` → `/confirm-application`), Renewal Journey Flow (Welcome Back + Verify Details), Lender Selection Bureau Flow (lender assignment, BRE mocking, KYC redirect, bank statement upload), Agreement/Esign Flow (`/esign/{app_id}` → `/down-payment/{app_id}` or `/nach/{app_id}`), and Downpayment Flow (`/down-payment/{app_id}` Steps 1/5/6 + `/down-payment-status/{app_id}`) — targeting UAT: `https://customer.uat.graydev.in/`. Uses the **Browser library (Playwright)** — not SeleniumLibrary.

## Commands

### Run all tests (default — excludes slow/resend tests)
```bash
./env/bin/robot --outputdir results/ tests/
```

### Run a single test file
Pattern: `./env/bin/robot --outputdir results/ tests/<folder>/<file>.robot`

### Run tests by tag
```bash
# Pattern: ./env/bin/robot --outputdir results/ --include <tag> tests/
./env/bin/robot --outputdir results/ --include smoke tests/
./env/bin/robot --outputdir results/ --include login tests/
./env/bin/robot --outputdir results/ --include resend tests/login/otp_tests.robot    # ~3min resend test
./env/bin/robot --outputdir results/ --include salaried tests/application_creation_flow/employment_tests.robot
```

Tags: `smoke`, `login`, `otp`, `bypass-auth`, `dashboard`, `resend`, `application-details`, `repayment-schedule`, `view-applicant-details`, `upload-documents`, `application-creation-flow`, `salaried`, `self-employed`, `renewal`, `renewal-journey-flow`, `skip-journey`, `edit-residential`, `edit-employment`, `lender-selection`, `lender-selection-new`, `lender-selection-renewal`, `lender-approval`, `lender-rejection`, `bank-statement`, `lender-selection-e2e`, `kyc-bypass`, `partial`, `agreement`, `esign-redirect`, `down-payment`, `change-plan`

### Run downpayment tests
```bash
# All flows (A+B+C+E+F shared session)
./env/bin/robot --outputdir results/ tests/downpayment/down_payment_tests.robot

# By flow tag
./env/bin/robot --outputdir results/ --include down-payment tests/downpayment/

# Flow D only (change plan — requires GILE-configured app)
./env/bin/robot --outputdir results/ --include change-plan tests/downpayment/down_payment_change_plan_tests.robot
```

### Dry run (syntax check, no browser)
```bash
./env/bin/robot --dryrun tests/
```

### KYC bypass DB credentials setup
```bash
cp .env.db.template .env.db
# Fill in .env.db:
# DB_HOST=sandbox-app-uat-mysql8.ctumc26e6kyn.ap-south-1.rds.amazonaws.com
# DB_USER=...
# DB_PASSWORD=...
# DB_NAME=gq_migrate
```
In CI/CD (Jenkins): inject `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` as environment variables via `withCredentials`. `db_config.py` checks `.env.db` first; falls back to env vars if file absent.

### Override base URL or mobile number
```bash
./env/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999999999 ./env/bin/robot --outputdir results/ tests/
# TC-401 bypass auth redirect test — requires an ERP-registered mobile (see Bypass Auth section):
BYPASS_AUTH_MOBILE=<erp_mobile> ./env/bin/robot --outputdir results/ tests/login/bypass_auth_tests.robot
```

## Architecture

```
tests/                     — Test suites (import resources and variables)
  e2e/
    e2e_create_application_tests.robot     — Data-driven full E2E application creation (Login → Confirm & Submit; driven by data/application_data.xlsx)
    smoke_e2e_tests.robot                  — Single fixed happy-path E2E (Salaried + Parent/Guardian)
    resume_journey_e2e_tests.robot         — Resume-at-every-page: closes at each wizard page and resumes (RESUME_MOBILE)
    resume_journey_renewal_e2e_tests.robot — Renewal resume: closes/resumes at each renewal step (RENEWAL_MOBILE)
    resume_journey_se_e2e_tests.robot      — SE resume: self-employed employment variant (RESUME_MOBILE)
    renewal_flow_e2e_tests.robot           — Data-driven renewal E2E (existing account; Welcome Back → Verify Details; driven by renewal_application_data.xlsx)
    lender_selection_e2e_tests.robot       — E2E lender selection (plan 1 + Western Capital → KYC; plan 2 → Bank Statement; real BRE)
    kyc_bypass_e2e_tests.robot             — KYC DB bypass E2E (new app + renewal; kyc-bypass tag)
    esign_e2e_tests.robot                  — Agreement/Esign E2E (new + renewal; login → KYC bypass → /esign/)
  login/
    login_left_component_tests.robot  — Left panel component tests
    login_tests.robot                 — Login form tests
    otp_tests.robot                   — OTP tests (includes skipped resend test)
    bypass_auth_tests.robot           — Bypass auth tests (3 skipped — TC-401, TC-403, TC-404)
  application_details/
    repayment_schedule_tests.robot    — Repayment schedule tests (APP_DETAILS_MOBILE)
    view_applicant_details_tests.robot — View application details tests (APP_DETAILS_MOBILE)
    upload_documents_tests.robot      — Upload documents tests (APP_DETAILS_MOBILE)
  dashboard/
    dashboard_tests.robot             — Header, create-app, insurance tab nav, logout (TC-4009 logout MUST be last)
    dashboard_new_user_tests.robot    — New-user empty state tests (DASHBOARD_NEW_MOBILE)
    dashboard_emi_tests.robot         — EMI tab tests (DASHBOARD_MOBILE)
    dashboard_ad_tests.robot          — AD tab tests (AD_MOBILE 8763694182)
    dashboard_pg_tests.robot          — PG/Transaction History tests (PG_MOBILE 7757855472)
    dashboard_ins_tests.robot         — Insurance tab tests (INS_MOBILE 8668768645)
    dashboard_ins_new_user_tests.robot — Insurance new-user tests (DASHBOARD_NEW_MOBILE)
  renewal_journey_flow/
    student_details_tests.robot       — Renewal: Student Details (RENEWAL_MOBILE)
    choose_plan_tests.robot           — Renewal: Choose Plan (RENEWAL_MOBILE)
    welcome_back_tests.robot          — Renewal: Welcome Back pre-fill screen (Test Setup uses Go To /renewal-confirmation)
    verify_details_tests.robot        — Renewal: Verify Details — edit residential (Rented/Self Owned/Other), edit employment (salaried/SE), validations, proceed (Test Setup uses Go To /renewal-details; TC-VD61 navigates shared app to /confirm-application without submitting; TC-VD62 creates fresh app within session and submits; consent is on /confirm-application not /renewal-details)
  lender_selection/
    bureau_lender_flow_tests.robot              — Core BRE mocked bureau flow tests (smoke+regression+partial; BRE mocked via JS)
    bureau_lender_approval_tests.robot          — Real BRE approval test (Western Capital → KYC)
    bureau_lender_rejection_tests.robot         — Real BRE rejection tests (each test owns fresh browser + app; plan-specific edge cases)
    bureau_lender_screen_UI_tests.robot         — UI tests for new app lender selection (lender-selection-new; shared session)
    bureau_lender_flow_renewalapp_tests.robot   — UI tests for renewal app lender selection (lender-selection-renewal; shared session)
    bank_statement_tests.robot                  — Bank statement journey tests
  agreement/
    agreement_tests.robot                  — Agreement/Esign page tests (35 TCs; plan 1 suite setup; TC-AG-DP-001 plan 1 → /down-payment; TC-AG-NACH-001 plan 6 → /nach)
  downpayment/
    down_payment_tests.robot               — Downpayment Flows A+B+C+E+F (51 TCs shared session; Razorpay test mode; Flow E+F run LAST; sets ${DP_APP_ID})
    down_payment_change_plan_tests.robot   — Downpayment Flow D: Change Plan Steps 2→3→4 (34 TCs; own browser session; Thakkar International Academy — GILE EMI_PLAN_CHANGE=true)
  application_creation_flow/
    student_details_tests.robot            — Student Details page tests
    choose_plan_tests.robot                — Choose Plan page tests
    select_applicant_tests.robot           — Select Applicant page tests
    applicant_basic_details_tests.robot    — Applicant Basic Details page tests (independent)
    onboarding_tests.robot                 — Onboarding page tests (independent)
    personal_details_tests.robot           — Personal Details page tests (independent)
    residential_details_tests.robot        — Residential Details page tests (independent)
    employment_tests.robot                 — Employment tests: salaried + SE variants (robot:skip on TC-12045; session conflict, run in isolation)
    confirm_application_tests.robot        — Confirm Application page tests

resources/                 — Page Object keyword libraries (no variable imports)
  RepaymentSchedulePage.robot        — Keywords + locators for /repayment/{app_id}
  ViewApplicantDetailsPage.robot     — Keywords + locators for /application-details/{app_id}
  UploadDocumentsPage.robot          — Keywords + locators for /dms/{app_id}
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
  E2EApplicationFlow.robot           — E2E orchestration: Create Full Application (sets ${LAST_USED_MOBILE} suite var) + Create Full Renewal Application + Create Full Application With Lender Assignment (optional institute_search arg, default ${APP_INSTITUTE_SEARCH}) + Create Full Renewal Application With Lender Assignment + Perform KYC Bypass Journey (journey_type=new|renewal; plan 1, Western Capital; runs Bypass KYC Via Database on /okyc/, reloads to /esign/) + Navigate To Esign New App (Suite Setup for agreement tests; sets ${ESIGN_APP_ID}) + Navigate To Esign Renewal App + Navigate To Esign New App With Plan (per-test setup; plan_index arg; sets ${NACH_APP_ID}) + Navigate To Down Payment New App (Suite Setup for downpayment tests; full journey login→wizard→BRE→KYC bypass→esign→sign→/down-payment/; sets ${ESIGN_APP_ID} and ${DP_APP_ID}) + Navigate To Down Payment Change Plan App (Suite Setup for change plan tests; uses Thakkar International Academy; sets ${ESIGN_APP_ID} and ${DP_CHANGE_APP_ID}); all lender assignment keywords use real BRE — no mock
  LenderSelectionPage.robot          — Keywords + locators for /application-loader/{app_id} (lender selection + BRE mocking)
  OKYCPage.robot                     — Keywords for /okyc/{app_id}: URL assertion, Extract App ID From OKYC URL, Esign URL Should Be Active
  EsignPage.robot                    — Keywords + locators for /esign/{app_id} (agreement summary, consent, modal, signing); URL helpers for /down-payment/ and /nach/; Extract App ID From Down Payment URL
  DownPaymentPage.robot              — Keywords + locators for /down-payment/{app_id} (Steps 1/5/6) and /down-payment-status/{app_id}; variables: ${DP_ONLINE_PAYMENT} (data-testid='online_payment'), ${DP_STATUS_TITLE} (css=div[data-testid='title'] — scoped to success div, not next-step span); Razorpay iframe selectors (DP_RZ_*) confirmed from recording; Navigate To Step 6 Via Bank Transfer; Complete Razorpay Payment Via UPI; Close Razorpay Modal
  BankStatementPage.robot            — Keywords for bank statement journey (stub; PENDING TESTID)

variables/
  variables.robot           — All variables: BASE_URL, timeouts, test data, browser settings, APP_* wizard data

libraries/                 — Python keyword libraries
  ApplicationDataReader.py  — Reads application_data.xlsx for data-driven E2E tests
  db_config.py              — Loads DB creds from .env.db (local) or env vars (CI); validates all required vars
  kyc_bypass_db.py          — Robot keyword library: Bypass KYC Via Database — inserts mock KYC records into 4 tables

.env.db.template           — Template for DB credentials (copy to .env.db, fill in, never commit)
.env.db                    — Local DB credentials (gitignored via .env.*)

results/                   — robot output (output.xml, log.html, report.html)
```

**Key pattern:** Test files import resource files and the variables file (`variables/variables.robot`). Lender selection test files additionally import `variables/dynamic_variables.py` directly (required for dynamic app ID generation). Resource files do NOT import variables — Robot Framework shares the variable scope from the suite, so resources access `${TIMEOUT}`, `${BASE_URL}`, etc. directly. No `*** Keywords ***` section in test files — all keywords live in resource files (Page Object Model).

**ApplicationCreationFlowPage.robot exception:** This orchestrator file imports all wizard page resource files so its `Navigate To *` traversal keywords can call any page's URL helpers and locators. Test suites that import `ApplicationCreationFlowPage.robot` and a specific page file get deduplicated imports automatically.

## UAT Constraints

- **Fixed OTP**: UAT uses OTP `9999` for all mobile numbers — no SMS dependency.
- **Bypass Auth (TC-401, TC-403, TC-404 — all skipped)**: `/instant-eligibility?m=<mobile>` only redirects if the mobile is ERP-whitelisted (`bypassAuthPost` succeeds). Confirmed: neither `9876543210` nor `8108556708` works — `bypassAuthPost` rejects general OTP test accounts. TC-401 is tagged `robot:skip`. To enable: identify a UAT ERP-whitelisted mobile, set `BYPASS_AUTH_MOBILE` env var, and remove `robot:skip` from TC-401.
- **checkMobilePost rate limit**: ~3 calls per ~60s per IP. `Navigate To OTP Page` auto-detects (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT` (45s). Each OTP/login test uses a distinct mobile number to reduce collisions.
- **verifyOtpPost rate limit**: Also applies per IP. Handled with a three-state page-check after `RATE_LIMIT_WAIT` sleep: (1) on `/my-applications` → OTP succeeded, skip retry; (2) on `/verify` → re-enter OTP; (3) on `/` → rate limit forced logout, re-submit login form then OTP. Applied in `Valid OTP Redirects To Dashboard`, `Login And Navigate To Dashboard`, `Switch To Account`, and `Wait For Dashboard` (auto-retries OTP once if still on `/verify` after `LONG_TIMEOUT`).
- **Test order**: `Valid OTP Redirects To Dashboard` runs before `Wrong OTP Shows Incorrect OTP Toast` — a prior failed verifyOtpPost can trigger rate limiting that blocks the valid path.
- **UAT availability**: UAT is **down 9pm–7am**. Live tests must run between 7am–9pm.

## Session Models

**Common pattern (all suites):**
- `Suite Setup` — opens browser, logs in, navigates to starting page, captures any dynamic IDs via `Set Suite Variable`
- `Test Setup` — hard-navigates (`Go To`) to target URL. No re-login
- `Test Teardown` — NONE (shared session preserved)
- `Suite Teardown` — `Close Browser`

Deviations per area documented below.

## Application Details Session Model

All three application details suites share one browser session with `${APP_DETAILS_MOBILE}` (9812345678). Suite Setup clicks `emi-card-option-button` → navigates to target page → `Extract App ID From *URL` → `Set Suite Variable ${APP_ID}`.

| File | Page |
|------|------|
| `repayment_schedule_tests.robot` | `/repayment/{app_id}` |
| `view_applicant_details_tests.robot` | `/application-details/{app_id}` |
| `upload_documents_tests.robot` | `/dms/{app_id}` |

TC-AD-RS-001/002, TC-AD-VA-001/002/008, and TC-AD-UD-001/002 use `[Setup] Navigate To Dashboard` to test entry navigation from the EMI card menu.

---

## Dashboard Session Model

6 independent files, each with its own browser session:

| File | Suite Setup account |
|------|---------------------|
| `dashboard_tests.robot` | DASHBOARD_MOBILE → NEW_USER_MOBILE |
| `dashboard_new_user_tests.robot` | DASHBOARD_NEW_MOBILE |
| `dashboard_emi_tests.robot` | DASHBOARD_MOBILE |
| `dashboard_ad_tests.robot` | AD_MOBILE (8763694182) |
| `dashboard_pg_tests.robot` | PG_MOBILE (7757855472) |
| `dashboard_ins_tests.robot` | INS_MOBILE (8668768645) |
| `dashboard_ins_new_user_tests.robot` | DASHBOARD_NEW_MOBILE (dynamic) |

**`dashboard_tests.robot` specific:**
- **TC-4009 (Logout) MUST remain the last test** — it destroys the shared session.
- TC-4035 switches to `${NEW_USER_MOBILE}`; TC-4009 inherits.

**`dashboard_ins_tests.robot`:** Suite Setup calls `Login And Navigate To Insurance Tab`. Test Setup navigates to `/my-applications` then clicks Insurance tab. TC-4112 uses `[Setup] Navigate To Insurance Tab New User` → `Switch To Account ${DASHBOARD_NEW_MOBILE}`; TC-4113–TC-4115 inherit that session.

## Application Creation Flow Session Model

Each wizard suite uses `${APP_CREATION_MOBILE}` (generated fresh per run by `variables/dynamic_variables.py` — never a static value). Suite Setup traverses all preceding wizard steps with stub data. Wizard-advancing tests (proceed/submit) run **LAST** with `[Setup] NONE`.

**Traversal stub data** uses `APP_*` variables from `variables.robot`:
- react-select dropdowns: `Select First Option In React Select` helper (approved T1 exception for traversal only)
- PAN lookup and pincode city/state API calls require `Sleep 2s` during traversal

**`applicant_basic_details_tests.robot`:** TC-8014 uses `[Setup] NONE` (sequential after TC-8013); TC-8014-S is a standalone close+resume test.

**`employment_tests.robot`:** Per-test `[Setup]` navigates back to `/select-employment` and selects the desired variant.

**`onboarding_tests.robot`**, **`personal_details_tests.robot`**, **`residential_details_tests.robot`** — fully independent suites, no cross-file ordering dependencies.

**E2E tests** live exclusively in `tests/e2e/`. Data-driven via `data/application_data.xlsx`, use `resources/E2EApplicationFlow.robot` and `libraries/ApplicationDataReader.py`.

## Lender Selection Session Model

| File | Suite Setup | Session model | Key variable |
|------|-------------|---------------|-------------|
| `bureau_lender_flow_tests.robot` | `Navigate To Lender Selection New App` | Shared; state-advancing tests run last | `${LENDER_APP_ID}` |
| `bureau_lender_approval_tests.robot` | `Navigate To Lender Selection New App` | Shared; 1 test (real BRE) | `${LENDER_APP_ID}` |
| `bureau_lender_rejection_tests.robot` | None (per-test `[Setup]`) | Each test owns fresh browser + app | `${LENDER_NR0N_MOBILE}` per test |
| `bureau_lender_screen_UI_tests.robot` | `Navigate To Lender Selection New App` | Shared; Test Setup resets to lender page | `${LENDER_APP_ID}` |
| `bureau_lender_flow_renewalapp_tests.robot` | `Navigate To Lender Selection Renewal App` | Shared; Test Setup resets to lender page | `${LENDER_RENEWAL_APP_ID}` |
| `bank_statement_tests.robot` | `Navigate To Bank Statement Via BRE Rejection` | Shared | `${BS_APP_CODE}` |

**bureau_lender_rejection_tests.robot** — isolated model: each test uses its own `[Setup] Login And Navigate To Lender Selection New App` with unique `${LENDER_NR0N_MOBILE}` and plan index; each test uses `[Teardown] Close Browser`. TC-LS-NR05 uses `Login And Submit New App` (plan 4 — all bureau lenders ineligible).

**State-advancing tests in bureau_lender_flow_tests.robot run LAST:**
- TC_LENDER_01: Suite Setup app, mock APPROVED → KYC.
- TC_LENDER_02: `[Setup] Navigate To Lender Selection Within Session` — reset, mock REJECTED then APPROVED.
- TC_LENDER_03, TC_LENDER_04: `[Teardown] Run Keywords    Unroute BRE Mock    AND    Run Keyword And Ignore Error    Close Browser` (partial tests).

## Agreement / Esign Session Model

| File | Suite Setup | Session model | Key variable |
|------|-------------|---------------|-------------|
| `agreement_tests.robot` | `Navigate To Esign New App` | Shared (plan 1, fresh mobile); state-advancing tests run last | `${ESIGN_APP_ID}` |

**TC-AG-030 and TC-AG-031 run LAST in shared session** — TC-AG-030 signs the agreement (navigates away from /esign/); TC-AG-031 uses `[Setup] NONE` and asserts the post-sign redirect URL.

**TC-AG-033, TC-AG-DP-001 own browser sessions** — `[Setup] Navigate To Esign New App` opens a new browser; `[Teardown] Close Browser` closes it.

**TC-AG-NACH-001** — `[Setup] Navigate To Esign New App With Plan    plan_index=6`; `[Teardown] Close Browser`. Uses plan 6 (no downpayment → /nach/ after esign). Sets `${NACH_APP_ID}`.

**Post-esign URL logic:**
- Plan 1 (has downpayment) → signing redirects to `/down-payment/{app_id}`
- Plan 6 (no downpayment) → signing redirects to `/nach/{app_id}`

## Down Payment Session Model

| File | Suite Setup | Session model | Key variable |
|------|-------------|---------------|-------------|
| `down_payment_tests.robot` | `Navigate To Down Payment New App` | Shared (plan 1, fresh mobile); Flows A+B+C share default Test Setup; Flow E+F run LAST | `${DP_APP_ID}` |
| `down_payment_change_plan_tests.robot` | `Navigate To Down Payment Change Plan App` | Own browser session; Flow D only | `${DP_CHANGE_APP_ID}` |

**Flow ordering in `down_payment_tests.robot`:**
- Flow A (TC-DP-001–009): Step 1 SelectedPlan UI. Default Test Setup: `Go To /down-payment/${DP_APP_ID}` + `Down Payment Page Should Be Visible`.
- Flow B (TC-DP-011–020): Step 5 DownPaymentMethod UI. Test Setup: `Go To /down-payment/${DP_APP_ID}#5` + `Down Payment Step 5 Should Be Visible`.
- Flow C (TC-DP-031–040): Step 6 VirtualAccountBankDetails. Test Setup: `Navigate To Step 6 Via Bank Transfer` (navigates through Step 5 → selects Bank Transfer → submits → waits for Step 6).
- Flow E (TC-DP-RZ-001–005): Razorpay test mode via UPI `success@razorpay`. Runs **LAST** — creates real DB entries in `razorpay_order_details`, `gq_internal_payment_transaction_logs`, `customer_tracker`. TC-DP-RZ-001 opens modal (`[Setup] Go To #5 + Step5 Visible`), RZ-002/003/004/005 all use `[Setup: NONE]` — modal stays open through the chain. RZ-004 completes payment; iframe auto-closes after redirect to /down-payment-status/.
- Flow F (TC-DP-STATUS-001–014): `/down-payment-status/{app_id}` page. `[Setup] NONE` — inherits browser state from Flow E redirect. **Must run together with Flow E** (use `--include down-payment-razorpay --include down-payment-status`).

**Razorpay iframe selectors:** All `DP_RZ_*` selectors confirmed from Playwright recording `login_20260518_174915.js`. UPI tab: `iframe >>> [data-testid='upi']`; input: `iframe >>> [placeholder='example@okhdfcbank']`; submit: `iframe >>> [data-testid='vpa-submit']`; fee confirm: `iframe >>> [data-testid='fee-bearer-cta']`; payment status: `iframe >>> [data-testid='payment-status-heading']`.

**Step 6 navigation:** Step 6 requires `location.state.smartCollectSelected=true` (React Router state). Direct URL navigation to `#6` will render empty. Always use `Navigate To Step 6 Via Bank Transfer` keyword which goes through Step 5 programmatically.

**Flow D (Change Plan):** Institute: **Thakkar International Academy** (GILE `EMI_PLAN_CHANGE=true`). Suite Setup: `Navigate To Down Payment Change Plan App` — fresh login → full wizard → Western Capital → KYC bypass → esign → sign → `/down-payment/` → sets `${DP_CHANGE_APP_ID}`. Test Setup: `Go To /down-payment/${DP_CHANGE_APP_ID}` + `Down Payment Page Should Be Visible`. Covers Step 1 (change plan card visible), Step 2 (NewPlanList — `new-plan-list-title`, `css=[data-testid^='0-']` first plan, `proceed-button`), Step 3 (ConfirmNewPlan — `confirm-new-plan-title`, `view-agreement-button`, `agreement-preview-proceed-button`, `consent-checkbox`, `confirm-new-plan-button`), Step 4 (ConfirmNewPlanSuccess — `plan-details-title`, `emi-amount-value`, `emi-count-value`, `total-loan-amount`, `apr-value`, `proceed-to-next-button`, `close-button`). Step 4 tests state-advancing — TC-DP-D-025 changes plan in DB; TC-DP-D-026–034 use `[Setup: NONE]`.

---

**BRE API mocking:** `Mock BRE Assign Lender    APPROVED|REJECTED` in `LenderSelectionPage.robot` uses `Evaluate JavaScript` to override `window.fetch`, intercepting `/v2/credit-engine/assign-lender` and `/v2/credit-engine/assign-lender/fetch` calls. `Switch BRE Mock To    APPROVED|REJECTED` swaps the mock mid-test. Always call `Unroute BRE Mock` in teardown to restore original `window.fetch`. Used only by `bureau_lender_flow_tests.robot` — `lender_selection_e2e_tests.robot` uses real BRE (no mock).

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

* **CLAUDE.md** — update architecture, commands, session model, or any section that reflects the changed area
* **README.md** — update if the change affects setup, usage, or feature coverage
* **jenkins.md** — update if the change affects CI/CD pipeline configuration or test execution
* **`projectreview.md`** — update the relevant section(s) whenever any file, folder, keyword, test, variable, resource, or CI config changes; this file is the complete per-file reference for the project
* **`.manifold/` files** — update any manifold constraint or artifact files that relate to the changed feature or flow
* **Test case files** (`tests/` and subdirectories) — update existing test cases or add new ones to cover the changed functionality; ensure TC IDs, tags, and assertions stay consistent with the change

Do NOT complete a task and stop without checking whether each of these files needs updating. Even small changes (e.g., a new test tag, a renamed keyword, a new mobile number) must be reflected in the relevant documentation and test files in the same response.
