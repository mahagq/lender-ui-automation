# e2e-tests

## Outcome

Automate end-to-end journeys covering the full Customer Portal flow in Robot Framework + Playwright. Five E2E suites live exclusively in `tests/e2e/`: data-driven application creation (Excel), data-driven renewal (Excel), single-fixture smoke test, resume-at-every-page journey, and lender selection with BRE bureau flow. Orchestration lives in `resources/E2EApplicationFlow.robot`; data reading via `libraries/ApplicationDataReader.py`.

**Suites in scope:**
- `tests/e2e/e2e_create_application_tests.robot` — data-driven full E2E: Login → Confirm & Submit (application_data.xlsx)
- `tests/e2e/smoke_e2e_tests.robot` — single fixed Salaried + Parent/Guardian happy path
- `tests/e2e/resume_journey_e2e_tests.robot` — close at each wizard page and resume (9 tests, RESUME_MOBILE)
- `tests/e2e/renewal_flow_e2e_tests.robot` — data-driven renewal E2E: Welcome Back → Verify Details (renewal_application_data.xlsx)
- `tests/e2e/lender_selection_e2e_tests.robot` — 4 E2E lender selection tests (TC-LS-E01–E04; new+renewal × APPROVED+REJECTED; BRE mocked)

---

## Domain Context

**Key resources and data:**

| File | Role |
|------|------|
| `resources/E2EApplicationFlow.robot` | Orchestration: `Create Full Application`, `Create Full Renewal Application` |
| `libraries/ApplicationDataReader.py` | Reads rows from `.xlsx` files; returns dicts for data-driven keywords |
| `data/application_data.xlsx` | Application creation test data (multiple rows = multiple test iterations) |
| `data/renewal_application_data.xlsx` | Renewal test data (multiple rows) |

**Required env vars:**

| Variable | Used by | Notes |
|----------|---------|-------|
| `RESUME_MOBILE` | `resume_journey_e2e_tests.robot` | Pre-existing UAT account; not auto-generated |

---

## Constraints

### Business

#### B1: E2E Tests Must Cover Full Happy Path — No Partial Flows

Every E2E test must exercise the complete journey from Login → Confirm & Submit (application creation) or Welcome Back → Verify Details → Confirm (renewal). Partial flows belong in unit suites under `tests/application_creation_flow/` or `tests/renewal_journey_flow/`.

> **Rationale:** E2E tests validate system integration. A test that stops at the dashboard is a dashboard test, not an E2E test.

#### B2: Data-Driven Suites Driven by Excel

`e2e_create_application_tests.robot` and `renewal_flow_e2e_tests.robot` read test data from `data/application_data.xlsx` and `data/renewal_application_data.xlsx` via `ApplicationDataReader.py`. Adding new scenarios = adding Excel rows, not modifying `.robot` files.

> **Rationale:** Separates test data from test logic. QA can add scenarios without touching Robot Framework code.

#### B3: All E2E Suites Live in tests/e2e/

No E2E test files in `tests/application_creation_flow/`, `tests/renewal_journey_flow/`, or `tests/dashboard/`. E2E logic stays in `tests/e2e/` and `resources/E2EApplicationFlow.robot`.

> **Rationale:** Clear separation between focused unit tests (page-level) and integration tests (full journey). Prevents cross-contamination of session models.

---

### Technical

#### T1: Browser Library (Playwright) — Not SeleniumLibrary

All keywords use `robotframework-browser` APIs.

#### T2: E2E Orchestration in E2EApplicationFlow.robot

`Create Full Application` and `Create Full Renewal Application` keywords handle the complete wizard traversal. Test suites import `E2EApplicationFlow.robot` — no wizard traversal logic inline in test files.

> **Rationale:** Single source of truth for E2E flow. Fixes to traversal (new pages, changed locators) go in one place.

#### T3: ApplicationDataReader.py Reads Excel Data

`libraries/ApplicationDataReader.py` returns structured dicts from `.xlsx` rows. Test suites call it via `Get Application Data` and iterate over rows as test cases or use Robot Framework's data-driven template pattern.

> **Rationale:** Python library provides robust Excel parsing (openpyxl). Avoids brittle CSV parsing in Robot Framework keywords.

#### T4: smoke_e2e_tests.robot Has No Excel Dependency

Smoke test uses fixed static variables from `variables/variables.robot`. One test, one Salaried + Parent/Guardian application. No data file required.

> **Rationale:** Smoke test must run even if Excel files are unavailable (CI data volume issues). Acts as a fast golden-path check independent of data infrastructure.

#### T5: resume_journey_e2e_tests.robot Uses RESUME_MOBILE

9 tests — each closes the browser at a different wizard page and then re-opens and resumes the application from that page. Requires `RESUME_MOBILE` env var pointing to a pre-existing UAT account with an in-progress application (or creates one per test).

> **Rationale:** Resume-journey tests verify that partially completed applications are recoverable. This requires a real account with real application state — cannot be mocked.

---

### User Experience

#### U1: E2E Tests Validate Complete User Journey In Sequence

No page skipping. No direct URL navigation to mid-flow pages. Each E2E test exercises every step the user would take: login → OTP → dashboard → create app → wizard pages → confirm → submit.

#### U2: Data-Driven Tests Cover Multiple Applicant Types and Employment Variants

`application_data.xlsx` rows cover at minimum: Salaried + Parent/Guardian, Salaried + Student, Self-Employed + Parent/Guardian. Renewal data covers: residential edit + employment edit scenarios.

---

### Security

#### S1: Fresh Browser Context Per E2E Suite

Each E2E suite opens a new browser context. No session reuse between suites or test runs.

> **Rationale:** E2E tests must start from a clean slate. Shared sessions could carry auth state or localStorage from a previous test, masking auth failures.

---

### Operational

#### O1: E2E Runs Create Real UAT Records

Each full application creation run produces one UAT application record. Data cleanup awareness required. `APP_CREATION_MOBILE` (auto-generated) is used to avoid accumulation collisions.

#### O2: RESUME_MOBILE Is a Required Env Var

CI pipeline must inject `RESUME_MOBILE` before running `resume_journey_e2e_tests.robot`. Missing var causes Suite Setup to fail explicitly.

---

## Tensions

### TN1: Static Smoke Test vs Data-Driven Coverage

**Type:** trade_off | **Between:** B2 × T4 | **Status:** resolved

B2 requires data-driven coverage. T4 establishes the smoke test as a static, Excel-independent fixture. Running the smoke test when Excel is unavailable (or to validate a specific Salaried + Parent/Guardian path) conflicts with the data-driven principle.

> **Resolution A:** Both co-exist. Smoke test = fast golden path; data-driven test = broad coverage. Smoke test is not a replacement for data-driven tests. CI can run smoke first (fast feedback), then data-driven (full coverage). No conflict — different purposes.

### TN2: RESUME_MOBILE Pre-Existing Account vs CI Reliability

**Type:** hidden_dependency | **Between:** T5 × O2 | **Status:** resolved

Resume tests depend on a specific UAT account. If the account is cleaned up or reset, the tests fail at setup.

> **Resolution A:** Document as suite precondition. Suite Setup validates RESUME_MOBILE is set and the account is accessible. Clear error on failure. CI pipeline injects RESUME_MOBILE as a required env var. Failure is diagnosable without reading test code.

---

## Required Truths

### RT-1: E2EApplicationFlow.robot Exists With Full Orchestration Keywords ⚡ BINDING

`resources/E2EApplicationFlow.robot` exists and provides `Create Full Application` and `Create Full Renewal Application` keywords covering the complete wizard traversal. `libraries/ApplicationDataReader.py` exists and reads `.xlsx` data.

**Why binding:** Both data-driven suites and smoke test import `E2EApplicationFlow.robot`. Without it, no E2E test can execute.

---

### RT-2: Application Creation E2E and Smoke Tests Exist

`tests/e2e/e2e_create_application_tests.robot` exists, reads from `data/application_data.xlsx`, and produces at least 3 test iterations (Salaried + Parent/Guardian, Salaried + Student, Self-Employed + Parent/Guardian).

`tests/e2e/smoke_e2e_tests.robot` exists with exactly 1 fixed test: Salaried + Parent/Guardian full application journey.

Both `data/application_data.xlsx` and `libraries/ApplicationDataReader.py` confirmed on disk.

---

### RT-3: Renewal E2E Tests Exist

`tests/e2e/renewal_flow_e2e_tests.robot` exists and reads from `data/renewal_application_data.xlsx`. Covers Welcome Back → Verify Details → Confirm flow.

`data/renewal_application_data.xlsx` confirmed on disk.

---

### RT-4: Resume Journey Tests Exist

`tests/e2e/resume_journey_e2e_tests.robot` exists with 9 tests. Each test closes the browser at a different wizard page and resumes via RESUME_MOBILE.

---

## Solution Space

### Option A: Separate E2E Files by Journey Type ← Chosen

- `e2e_create_application_tests.robot` — data-driven application creation
- `smoke_e2e_tests.robot` — single static happy path
- `renewal_flow_e2e_tests.robot` — data-driven renewal
- `resume_journey_e2e_tests.robot` — resume-at-every-page
- `lender_selection_e2e_tests.robot` — lender selection BRE bureau flow (new+renewal × APPROVED+REJECTED)
- All in `tests/e2e/`
- Orchestration in `resources/E2EApplicationFlow.robot`
- Data in `libraries/ApplicationDataReader.py` + `data/*.xlsx`
- Satisfies: RT-1 through RT-4, all constraints
- Reversibility: TWO_WAY

---

## Generation

**Option:** A  
**Status:** VERIFIED — all files confirmed on disk

### Artifacts

| Artifact | Type | Satisfies |
|----------|------|-----------|
| `resources/E2EApplicationFlow.robot` ⚡ | code | RT-1, T2 |
| `libraries/ApplicationDataReader.py` ⚡ | code | RT-1, T3 |
| `data/application_data.xlsx` | data | RT-2, B2 |
| `data/renewal_application_data.xlsx` | data | RT-3, B2 |
| `tests/e2e/e2e_create_application_tests.robot` | test | RT-2, B1, B2, U1, U2 |
| `tests/e2e/smoke_e2e_tests.robot` | test | RT-2, B1, T4, U1 |
| `tests/e2e/renewal_flow_e2e_tests.robot` | test | RT-3, B1, B2, U1 |
| `tests/e2e/resume_journey_e2e_tests.robot` | test | RT-4, T5, U1 |
| `tests/e2e/lender_selection_e2e_tests.robot` | test | RT-2, RT-3, B1, B3, U1 |
| `resources/LenderSelectionPage.robot` | code | RT-2, T2 |
| `resources/OKYCPage.robot` | code | RT-2 |
| `resources/BankStatementPage.robot` | code | RT-2 |

⚡ = Binding constraint artifacts

---

## Verification

**Date:** 2026-04-29 | **Result:** CONVERGED

### Verification Matrix

| Constraint | Type | Code | Test | Docs | Status |
|---|---|---|---|---|---|
| B1: Full happy path coverage | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| B2: Data-driven from Excel | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| B3: E2E suites in tests/e2e/ only | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T1: Browser Library (Playwright) | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T2: Orchestration in E2EApplicationFlow.robot | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T3: ApplicationDataReader.py reads Excel | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T4: Smoke test has no Excel dependency | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| T5: RESUME_MOBILE pre-existing account | BOUNDARY | — | ✓ | ✓ | SATISFIED |
| U1: Complete journey in sequence | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| U2: Multiple applicant types covered | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| S1: Fresh browser context per suite | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| O1: Real UAT records — data awareness | INVARIANT | — | ✓ | ✓ | SATISFIED |
| O2: RESUME_MOBILE required env var | BOUNDARY | — | ✓ | ✓ | SATISFIED |

No open gaps.
