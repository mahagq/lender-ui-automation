# renewal-journey-flow

## Outcome

Automate the Renewal Journey Flow for returning GQ customers — Welcome Back pre-fill screen (`/renewal-confirmation`) and Verify Details review screen (`/renewal-details`) — in Robot Framework + Playwright. Renewal-specific Student Details (`/student-details` via RENEWAL_MOBILE) and Choose Plan (`/choose-plan`) tests run under `tests/renewal_journey_flow/` using a pre-existing UAT account. Resources `WelcomeBackPage.robot` and `VerifyDetailsPage.robot` are net-new; `StudentDetailsPage.robot` and `ChoosePlanPage.robot` are reused from the application creation flow.

**Pages in scope:**
- `/student-details` (renewal entry) — Student Details
- `/choose-plan` (renewal) — Choose Plan
- `/renewal-confirmation` — Welcome Back pre-fill screen
- `/renewal-details` — Verify Details review screen

---

## Domain Context

**Confirmed locators:**

| Element | Locator |
|---------|---------|
| Welcome Back continue button | `text=CONTINUE WITH THESE DETAILS` |
| Welcome Back change applicant button | `text=CHANGE APPLICANT DETAILS` |
| Verify Details address title | `xpath=//h3[normalize-space()='Residential details']` |
| Verify Details addr line 1 input | `css=[data-testid='addr-line-1-input']` |
| Verify Details skip button | `css=[data-testid='skip-button']` |
| Verify Details confirm button | `text=CONFIRM AND PROCEED` |
| Verify Details business name | `css=[data-testid='business-name-input']` |
| Verify Details annual income | `css=[data-testid='business-annual-income-input']` |
| Verify Details years in business | `css=[data-testid='years-of-current-business-input']` |
| Verify Details consent checkbox error | `css=[data-testid='consent-checkbox-error']` |
| Verify Details addr line 1 error | `css=[data-testid='addr-line-1-input-error']` |
| Verify Details pincode error | `css=[data-testid='pincode-input-error']` |
| Verify Details business name error | `css=[data-testid='business-name-input-error']` |
| Verify Details annual income error | `css=[data-testid='business-annual-income-input-error']` |

**Test scope (46 tests across 4 suite files):**

| File | Mobile | TCs | Count |
|------|--------|-----|-------|
| `tests/renewal_journey_flow/student_details_tests.robot` | RENEWAL_MOBILE | TC-R5001–R5007 | 7 |
| `tests/renewal_journey_flow/choose_plan_tests.robot` | RENEWAL_MOBILE | TC-R6001–R6008 | 8 |
| `tests/renewal_journey_flow/welcome_back_tests.robot` | RENEWAL_MOBILE | TC-WB01–WB06 | 6 |
| `tests/renewal_journey_flow/verify_details_tests.robot` | RENEWAL_MOBILE | TC-VD01–VD25 | 25 |

---

## Constraints

### Business

#### B1: Renewal Flow Covers Existing Customers — Welcome Back + Verify Details Required

Welcome Back pre-fill screen and Verify Details review screen are the core renewal-specific pages. Both must be fully automated. Scenarios: pre-fill accuracy, continue/change-applicant navigation, skip employment, edit residential, edit employment, validation errors, and final CONFIRM AND PROCEED.

> **Rationale:** These are the two new pages added for the renewal journey. Without them, the renewal automation coverage is incomplete.

#### B2: Student Details and Choose Plan Are Shared Pages — Use RENEWAL_MOBILE

`/student-details` and `/choose-plan` are shared with the application creation flow but the renewal journey tests must use `RENEWAL_MOBILE` (a pre-existing account) not `APP_CREATION_MOBILE`. The two test directories are independent — no cross-directory session sharing.

> **Rationale:** Renewal tests navigate from a returning-customer login context. Creating a new application (as in the application creation flow) would make the user a new applicant, which changes the page behaviour for Welcome Back and Verify Details.

#### B3: No Changes to Application Creation Flow Resource Files

`WelcomeBackPage.robot` and `VerifyDetailsPage.robot` are additive. No edits to `StudentDetailsPage.robot`, `ChoosePlanPage.robot`, `ApplicationCreationFlowPage.robot`, or any pre-existing resource file.

> **Rationale:** The application creation flow suite is stable and verified. Touching its resource files introduces regression risk with no benefit.

---

### Technical

#### T1: Browser Library (Playwright) — Not SeleniumLibrary

All keywords use `robotframework-browser` APIs. No SeleniumLibrary keywords.

#### T2: data-testid Locators — text= Permitted Where data-testid Absent

Welcome Back continue/change-applicant buttons have no `data-testid` — `text=CONTINUE WITH THESE DETAILS` and `text=CHANGE APPLICANT DETAILS` are permitted for these two elements only.

> **Rationale:** The frontend renders these as text-content buttons without `data-testid`. This is a documented exception — all other renewal locators use `data-testid`.

#### T3: Single Shared Session Per Suite — Go To for Test Setup

Each renewal suite opens one browser session. Suite Setup logs in once and navigates to the target page. Test Setup uses `Go To ${BASE_URL}/renewal-confirmation` or `Go To ${BASE_URL}/renewal-details` (no re-login). Suite Teardown closes the browser.

> **Rationale:** Mirrors the application creation flow session model. Avoids rate-limit collisions from per-test logins.

#### T4: verify_details_tests.robot Shares One Application — TC-VD09 Submits It, TC-VD25 Gets a Fresh One

The suite's Suite Setup creates one shared renewal application and navigates to `/renewal-details`. TC-VD01–VD08 use Test Setup Go To to reset state. TC-VD09 (2nd-to-last) uses `[Setup] NONE` and submits the shared application. TC-VD25 (last) creates a fresh application within the session before running.

> **Rationale:** Submitting the application is a one-way action — the shared application cannot be reused after TC-VD09. TC-VD25 requires a clean application state so it must create its own.

#### T5: RENEWAL_MOBILE Must Be a Pre-Existing UAT Account

`RENEWAL_MOBILE` must be registered on UAT with at least one prior application in history. It cannot be auto-generated (unlike `APP_CREATION_MOBILE`). Must be set as env var before running renewal suites.

> **Rationale:** Welcome Back and Verify Details screens only appear for returning customers. A fresh account would redirect to the standard new-application flow instead.

---

### User Experience

#### U1: Verify Details Tests Cover Skip, Edit Residential, Edit Employment, Validations, and Proceed

`verify_details_tests.robot` must cover: skip journey (tagged `skip-journey`), edit residential fields (tagged `edit-residential`), edit employment fields (tagged `edit-employment`), validation error states (empty/invalid inputs), and the final CONFIRM AND PROCEED path.

> **Rationale:** These are the five distinct user paths on the Verify Details screen. Missing any path leaves a critical renewal flow untested.

#### U2: Welcome Back Tests Assert Pre-Fill and Both Navigation Paths

`welcome_back_tests.robot` must assert: pre-filled student name/course/institution visibility and both CTA paths (continue with existing details → `/renewal-details` navigation, change applicant details → applicant form navigation).

> **Rationale:** The primary value of Welcome Back is pre-fill accuracy. Both CTAs must be tested to confirm navigation is wired correctly.

#### U3: Renewal Student Details and Choose Plan Cover Same Functional Scope

Renewal variants of Student Details (TC-R5001–R5007) and Choose Plan (TC-R6001–R6008) test the same field visibility, validation, and submission behaviour as the application creation counterparts, using RENEWAL_MOBILE context.

---

### Security

#### S1: Suite Setup Abort-on-Auth-Failure

If Suite Setup login or renewal navigation fails, the suite must abort — tests must not silently run against an unexpected page.

---

### Operational

#### O1: RENEWAL_MOBILE Is a Required Env Var

Must be injected by the CI pipeline before running any renewal suite. No auto-generation. Missing var causes Suite Setup to fail with a clear error.

#### O2: All Renewal Tests Tagged 'renewal' + Suite-Specific Tag

All renewal tests carry `renewal` tag for filtered runs. Suite-specific tags: `renewal-journey-flow`, `welcome-back`, `verify-details`, `skip-journey`, `edit-residential`, `edit-employment`.

---

## Tensions

### TN1: Shared Application Lifecycle in verify_details_tests.robot

**Type:** hidden_dependency | **Between:** T3 × T4 | **Status:** resolved

The shared browser session (T3) means the single application created in Suite Setup is the only available application. Once TC-VD09 submits it, the application is closed and cannot be reset by a Go To. TC-VD25 cannot reuse the submitted application.

> **Resolution A:** TC-VD09 uses `[Setup] NONE` (no Go To reset) and runs 2nd-to-last. TC-VD25 runs last and creates a fresh application via `Create Renewal Application And Navigate To Verify Details` before executing. This preserves the shared session while allowing TC-VD25 to run against a clean application.
>
> **Propagation:** T4 TIGHTENED — TC-VD09 must remain 2nd-to-last and TC-VD25 must remain last. Test file order is load-bearing.

### TN2: RENEWAL_MOBILE Pre-Existing Account vs CI Reliability

**Type:** resource_tension | **Between:** B2 × T5 | **Status:** resolved

Using a pre-existing account (T5) means the test depends on account history in UAT. If the account data is reset, renewed, or altered, Suite Setup navigation may fail or land on the wrong page.

> **Resolution A:** Accept the data dependency and document it as a suite precondition. RENEWAL_MOBILE is documented in CLAUDE.md as a fixed UAT account number. CI pipeline must inject it. Failure to reach `/renewal-confirmation` after login causes Suite Setup to abort with a clear error — diagnosable without re-reading test code.
>
> **Propagation:** O1 TIGHTENED — CI pipeline RENEWAL_MOBILE injection is mandatory, not optional.

---

## Required Truths

### RT-1: WelcomeBackPage.robot and VerifyDetailsPage.robot Exist ⚡ BINDING

Both resource files exist with keywords covering all renewal-specific locators. `WelcomeBackPage.robot` provides Suite Setup keyword `Navigate To Welcome Back Page` and Test Setup keyword. `VerifyDetailsPage.robot` provides Suite Setup keyword, skip, edit residential, edit employment, confirm, and validation keywords.

**Why binding:** Without these two files, no Welcome Back or Verify Details test can execute. Student Details and Choose Plan tests use existing resource files and are unblocked.

---

### RT-2: Welcome Back Tests Exist (TC-WB01–WB06)

`tests/renewal_journey_flow/welcome_back_tests.robot` exists with 6 tests covering:
- Pre-fill visibility (student name, course, institution)
- Continue with these details → navigates to `/renewal-details`
- Change applicant details → navigates to applicant form
- Consent checkbox and validation
- Page title assertion

---

### RT-3: Verify Details Tests Exist (TC-VD01–VD25)

`tests/renewal_journey_flow/verify_details_tests.robot` exists with 25 tests covering:
- Skip journey (TC-VD01–VD03, tagged `skip-journey`)
- Edit residential fields (TC-VD04–VD09, tagged `edit-residential`)
- Edit employment fields (TC-VD10–VD15, tagged `edit-employment`)
- Validation errors: empty addr line 1, invalid pincode, empty business name, invalid annual income (TC-VD16–VD22)
- CONFIRM AND PROCEED final submission (TC-VD23–VD25)
- TC-VD09 submits shared app (2nd-to-last, `[Setup] NONE`)
- TC-VD25 creates fresh app (last, `[Setup] NONE`)

---

### RT-4: Renewal Student Details and Choose Plan Tests Exist

`tests/renewal_journey_flow/student_details_tests.robot` (TC-R5001–R5007) and `tests/renewal_journey_flow/choose_plan_tests.robot` (TC-R6001–R6008) exist. Both use `RENEWAL_MOBILE` and reuse `StudentDetailsPage.robot` and `ChoosePlanPage.robot` resource files.

---

## Solution Space

### Option A: Separate Suite Files per Renewal Page ← Chosen

- `welcome_back_tests.robot` + `verify_details_tests.robot` + `student_details_tests.robot` + `choose_plan_tests.robot` in `tests/renewal_journey_flow/`
- `resources/WelcomeBackPage.robot` + `resources/VerifyDetailsPage.robot` (new)
- Reuses existing `StudentDetailsPage.robot`, `ChoosePlanPage.robot`
- Each suite: 1 login, Go To for Test Setup
- Mirrors application creation flow session model exactly
- Satisfies: RT-1 through RT-4, all constraints
- Reversibility: TWO_WAY

---

## Generation

**Option:** A  
**Status:** VERIFIED — all files confirmed on disk

### Artifacts

| Artifact | Type | Satisfies |
|----------|------|-----------|
| `resources/WelcomeBackPage.robot` ⚡ | code | RT-1, T1, T2 |
| `resources/VerifyDetailsPage.robot` ⚡ | code | RT-1, T1, T2, U1 |
| `tests/renewal_journey_flow/welcome_back_tests.robot` | test | RT-2, B1, U2 |
| `tests/renewal_journey_flow/verify_details_tests.robot` | test | RT-3, B1, U1, T4 |
| `tests/renewal_journey_flow/student_details_tests.robot` | test | RT-4, B2, U3 |
| `tests/renewal_journey_flow/choose_plan_tests.robot` | test | RT-4, B2, U3 |

⚡ = Binding constraint artifacts (required before any Welcome Back or Verify Details test)

---

## Verification

**Date:** 2026-04-29 | **Result:** CONVERGED

### Verification Matrix

| Constraint | Type | Code | Test | Docs | Status |
|---|---|---|---|---|---|
| B1: Welcome Back + Verify Details automated | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| B2: Renewal Student Details + Choose Plan | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| B3: No changes to application creation flow | INVARIANT | ✓ | — | ✓ | SATISFIED |
| T1: Browser Library (Playwright) | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T2: data-testid locators (text= exception documented) | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T3: Single shared session per suite | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T4: TC-VD09 submits shared app, TC-VD25 fresh | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| T5: RENEWAL_MOBILE pre-existing account | BOUNDARY | — | ✓ | ✓ | SATISFIED |
| U1: Verify Details covers all 5 user paths | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| U2: Welcome Back pre-fill + both CTAs | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| U3: Renewal SD + CP functional scope | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| S1: Suite Setup abort-on-auth-failure | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| O1: RENEWAL_MOBILE required env var | INVARIANT | — | ✓ | ✓ | SATISFIED |
| O2: Renewal tags on all tests | GOAL | ✓ | ✓ | ✓ | SATISFIED |

No open gaps.
