# dashboard-tests

## Outcome

Port all dashboard-related test cases from the Java/Selenium automation suite (`gq_customer_ui_automation`) into the current Robot Framework project (`customer_portal_ui_automation`), using the UAT branch of `gqcustomer_frontend` as the source of truth for UI structure and `data-testid` locators. The resulting Robot Framework suite must cover all enabled, implemented dashboard scenarios — dashboard header, tab navigation, profile menu, EMI tab, and transaction history filters — using Browser (Playwright) library patterns consistent with the existing auth suite.

---

## Domain Context (codebase lookup)

Sources: `gqcustomer_frontend` UAT branch + `gq_customer_ui_automation` Java test classes.

**Confirmed `data-testid` locators (UAT branch):**

| Element | Locator |
|---------|---------|
| Dashboard title | `css=[data-testid='dashboard-title']` |
| Dashboard subtitle | `css=[data-testid='dashboard-subtitle']` |
| Create new application button | `css=[data-testid='create-new-application-button']` |
| EMI tab button | `css=[data-testid='emi-tab-navigation-button']` |
| Insurance tab button | `css=[data-testid='ins-tab-navigation-button']` |
| Auto Payments tab button | `css=[data-testid='ad-tab-navigation-button']` |
| Transaction History tab button | `css=[data-testid='pg-tab-navigation-button']` |
| GQ Logo (desktop) | `css=[data-testid='desktop-view-gq-logo']` |
| Profile button | `css=[data-testid='profile-button']` |
| Profile options container | `css=[data-testid='profile-options-container']` |
| FAQ option | `css=[data-testid='faq']` |
| Logout option | `css=[data-testid='logout']` |
| EMI cards (list) | `css=[data-testid*='emi-card']` |
| EMI card 3-dot button | `css=[data-testid='emi-card-option-button']` |
| Load more button | `css=[data-testid='load-more-button']` |
| PG transaction rows | `css=[data-testid*='table-row-']` |
| Filter button | `css=[data-testid='filter-button']` |
| Online sub-tab | `css=li[data-testid='Online']` |
| Offline sub-tab | `css=li[data-testid=' Offline']` |
| Filter: All Months | `css=[data-testid='All Months']` |
| Filter: This Month | `css=[data-testid='This Month']` |
| Filter: This Year | `css=[data-testid='This Year']` |
| Filter: Last Year | `css=[data-testid='Last Year']` |
| Filter: Paid | `css=[data-testid='Paid']` |
| Filter: Failed | `css=[data-testid='Failed']` |
| Clear filter button | `css=[data-testid='clear-filter-button']` |
| Apply filter button | `css=[data-testid='apply-filter-button']` |
| Download button (row N) | `css=[data-testid='table-row-N-download-button']` |

**Test scope (33 test cases — TC-4001 to TC-4033):**

| TC | Description | Status |
|----|-------------|--------|
| TC-4001 | EMI applications visible on dashboard | enabled |
| TC-4002 | Auto Debit applications on Dashboard | enabled — AD tab button visible on UAT |
| TC-4003 | Payment Gateway applications visible | enabled |
| TC-4004 | Stages and CTA of stages | enabled (empty body) |
| TC-4005 | Back button | enabled (empty body — no back button on dashboard) |
| TC-4006 | GrayQuest Logo visible | enabled |
| TC-4007 | Profile icon — FAQ + Logout options visible | enabled |
| TC-4008 | FAQ link navigates to FAQ page | enabled |
| TC-4009 | Logout returns to login page | enabled |
| TC-4010 | Create new application button — modal or redirect | enabled |
| TC-4011 | EMI tab click and content | enabled |
| TC-4012 | Auto Payments tab click | enabled — AD tab click → URL hash #ad |
| TC-4013 | Transaction History tab click | enabled |
| TC-4014 | Offline Payments sub-tab | enabled |
| TC-4015 | Online Payments sub-tab | enabled |
| TC-4016 | Filter for Online Payments visible | enabled |
| TC-4017 | Filter by Time — All Months (Online) | enabled |
| TC-4018 | Filter by Time — This Month (Online) | enabled |
| TC-4019 | Filter by Time — This Year (Online) | enabled |
| TC-4020 | Filter by Time — Last Year (Online) | enabled |
| TC-4021 | Filter by Status — Paid | enabled |
| TC-4022 | Filter by Status — Failed | enabled |
| TC-4023 | Filter for Offline Payments visible | enabled |
| TC-4024 | Filter by Time — All Months (Offline) | enabled |
| TC-4025 | Filter by Time — This Month (Offline) | enabled — same filter UI as Online |
| TC-4026 | Filter by Time — This Year (Offline) | enabled — same filter UI as Online |
| TC-4027 | Filter by Time — Last Year (Offline) | enabled |
| TC-4028 | Clear filter button | enabled |
| TC-4029 | Apply filter button | enabled |
| TC-4030 | Download icon — offline payment | enabled |
| TC-4031 | Download icon — online payment | enabled (Class3) / **disabled** (Class4 duplicate) |
| TC-4032 | Insurance tab button visible | enabled — UAT branch addition |
| TC-4033 | Insurance tab click updates URL hash to #ins | enabled — UAT branch addition |

---

## Constraints

### Business

#### B1: All Enabled+Implemented Java Tests Must Be Ported

All dashboard test cases that are `enabled=true` AND have implemented test bodies in the Java suite must be ported to Robot Framework. Tests with `enabled=false` must be marked `robot:skip` with a comment explaining why. Tests with empty bodies (TC-4004, TC-4005) must be marked `robot:skip` with explanation.

> **Rationale:** Ensures feature parity with the Java automation suite. The RF suite must be a complete replacement, not a partial port.

#### B2: Disabled Java Tests Must Be Skipped, Not Deleted

Tests that were `enabled=false` in Java but confirmed active on UAT have been promoted to active tests: TC-4002 (AD tab visible), TC-4012 (AD tab click → #ad), TC-4025 (Offline This Month filter), TC-4026 (Offline This Year filter). Tests with genuinely absent content (TC-4004, TC-4005 — empty bodies, no data-testid) remain `robot:skip`.

> **Rationale:** Preserves traceability. Truly untestable scenarios remain skipped with explanation; UAT-confirmed features are promoted to active.

#### B3: TC-4031 Duplicate Resolution

TC-4031 appears in both DashboardTestClass3 (`enabled=true`) and DashboardTestClass4 (`enabled=false`). Port it once as enabled.

> **Rationale:** Single source of truth. The Class3 version (enabled) is the canonical one.

---

### Technical

#### T1: data-testid Locators Exclusively

All locators must use `data-testid` CSS selectors. No CSS class selectors (CSS Modules hashes are unstable) and no absolute XPath. Where `data-testid` is absent (e.g., EMI card container uses dynamic `emi-card-{id}`) use partial attribute match (`css=[data-testid*='emi-card']`).

> **Rationale:** CLAUDE.md mandate. CSS class names are hashed by CSS Modules and change between builds.

#### T2: Authenticated Session Required

All dashboard tests require the user to be logged in. Login must be performed in `Suite Setup` using `TEST_MOBILE` + `TEST_OTP` (9999, UAT fixed). After login the browser session is shared across all tests in the suite — no per-test re-login.

> **Rationale:** Dashboard URL `/my-applications` redirects unauthenticated users back to `/`. Per-test login would also exhaust the UAT `checkMobilePost` rate limit.

#### T3: UAT Rate Limit on checkMobilePost

UAT allows ~3 `checkMobilePost` calls per ~60s per IP. Because dashboard tests share a single session (T2), the rate limit is only hit once at suite setup. If rate limiting occurs during setup, the suite must wait `RATE_LIMIT_WAIT` (45s) and retry.

> **Rationale:** Existing `Navigate To OTP Page` already handles this; suite setup must mirror the same pattern.

#### T4: EMI Tab Tests Require Existing Application Data

TC-4001 (EMI cards visible) asserts that at least one EMI card exists in the account. If the UAT test account has no applications, this test will fail. The test should use `Should Be True` on the count rather than fail ungracefully.

> **Rationale:** UAT test account data may be reset. Test must be resilient — log a clear message if no cards found.

#### T5: PG Tab Filter Tests Require Transaction Data

TC-4013 through TC-4031 (transaction history and filters) require at least one transaction record in the UAT test account. Without transaction data, filter results will be empty and assertions on row visibility will fail.

> **Rationale:** Same data-dependency risk as T4. Tests should assert tab/filter UI elements load correctly, not necessarily that data rows exist.

---

### User Experience

#### U1: Exact Text Assertions for Static Labels

Dashboard title must assert `Hello,` (confirmed from frontend source). Dashboard subtitle must assert the exact string: `Find all your EMI applications, Autopay subscriptions and transaction history here.`

> **Rationale:** These are static strings in the JSX source. Exact match catches unintended copy changes.

#### U2: Tab Navigation Updates URL Hash

Clicking a tab button should result in the URL containing the corresponding hash: `#emi`, `#ins`, `#ad`, `#direct`. Assert URL contains the hash after clicking each tab.

> **Rationale:** Tab state is driven by URL hash in the React app. Hash assertion confirms navigation without depending on tab content loading.

#### U3: Profile Dropdown Visibility Sequence

After clicking `profile-button`, the `profile-options-container` must be visible before asserting `faq` and `logout` option visibility.

> **Rationale:** The dropdown renders conditionally on click. Asserting children before the container is visible causes flaky failures.

---

### Security

#### S1: Dashboard Accessible Only After Authentication

The dashboard URL `/my-applications` must redirect to the login page if accessed without authentication. Suite setup confirms authentication by asserting the URL contains `/my-applications` after OTP verification.

> **Rationale:** Regression guard — confirms auth middleware is working on the UAT environment.

---

### Operational

#### O1: Single Browser Session Shared Across Suite

`Suite Setup` opens the browser, logs in, and lands on the dashboard. `Test Teardown` must NOT call `Close Context` (unlike the auth test suites). The shared session persists until `Suite Teardown` closes the browser.

> **Rationale:** Per-test context open/close would require re-login for every test, exhausting the UAT rate limit and multiplying test runtime. Dashboard tests are read-mostly (no destructive actions) so session sharing is safe.

#### O2: TC-4010 Create New Application — Data-Dependent Branching

TC-4010 behavior depends on account state: accounts with existing applications show the `Create New Application` button + a modal; accounts without applications show a different flow. The test must handle both branches without failing due to account state.

> **Rationale:** UAT test account state varies. The test should assert the button click triggers a visible response (modal or redirect) without hardcoding the expected destination.

---

## Tensions

### TN1: Logout Test Destroys Shared Session

**Type:** hidden_dependency | **Between:** B1, O1 | **Status:** resolved

TC-4009 (logout) calls `logoutPost`, clears `localStorage`/`sessionStorage`, and navigates to `/`. After it executes, the shared browser session (required by O1) is destroyed. Any test that runs after TC-4009 will find itself on the login page, not the dashboard — all subsequent assertions fail.

**TRIZ:** Technical contradiction — P10 (Prior action): pre-arrange test order so logout executes last. P11 (Beforehand cushioning): no recovery needed if logout is the final test.

**Resolution (A — chosen):** TC-4009 must be the last test in the suite. Robot Framework executes tests in file order; `Logout Returns To Login Page` is placed at the end of `dashboard_tests.robot`. Suite Teardown closes the browser immediately after. No re-login is needed.

**Propagation:** O1 TIGHTENED — test ordering becomes load-bearing. The file order of test cases is a functional constraint, not just a style choice.

---

### TN2: EMI and PG Tests Fail on Clean UAT Account

**Type:** trade_off | **Between:** B1, T4, T5 | **Status:** resolved

TC-4001 asserts EMI cards are visible; TC-4013 through TC-4031 assert PG transaction rows and filter results. Both depend on the UAT test account having pre-existing data. If the account is freshly created or reset, these tests fail even when the UI is fully functional.

**TRIZ:** Flexibility vs. Consistency — P15 (Dynamization): make assertions conditional on data state. P3 (Local quality): different assertion strategy for data-dependent vs. UI-structural elements.

**Resolution (B — chosen):** Accept the data dependency and document it as a suite precondition rather than coding around it. Tests assert tab activation and UI elements (filter panel, sub-tabs) unconditionally. Data row assertions remain as-is — a failure with "no EMI cards found" is a correct signal that the test account needs seeding, not a test defect. A `PRECONDITION` comment in the test file documents this.

**Propagation:** T4 LOOSENED — the boundary is now a documented precondition rather than a hidden blocker. T5 same.

---

### TN3: FAQ Page Title Has No data-testid

**Type:** trade_off | **Between:** T1, B1 | **Status:** resolved

TC-4008 (FAQ link click) must assert the FAQ page loaded. The Java test asserts `h1[contains(.,'Frequently Asked Questions')]` via XPath. In the UAT frontend, `Faq.jsx` renders `<FormTitle title='Frequently Asked Questions' />` without passing `testIdFor` — the `h1` has no `data-testid`. Using text= selector or XPath would violate T1 (data-testid only — INVARIANT).

**TRIZ:** Standardization vs. Flexibility — P1 (Segmentation): separate the navigation assertion from the content assertion. Navigation is confirmed via URL; content can be confirmed via browser title. Neither requires a DOM element query.

**Resolution (A — chosen):** Assert (1) URL contains `/faq` — confirms navigation succeeded; and (2) `Get Title` (browser tab title) contains `"FAQ"`. Both are framework-level assertions with zero DOM queries — T1 is fully satisfied. The `testIdFor` gap in `FormTitle` is noted as a frontend improvement opportunity but not a test blocker.

**Propagation:** T1 LOOSENED in scope — URL + browser title assertions count as compliant alternatives to data-testid DOM queries.

---

### TN4: Tab and Filter State Leaks Between Tests

**Type:** resource_tension | **Between:** O1, B1 | **Status:** resolved

The shared session (O1) means UI state accumulated by one test is visible to the next. Tab clicks leave the active tab in a non-default state (e.g., after TC-4013 clicks PG tab, TC-4014 may find the PG sub-tab UI in an unexpected state). Filter panel open/closed state, profile dropdown visibility, and scroll position all persist across tests in the same session.

**TRIZ:** P13 (The other way round): instead of cleaning up after each test, reset before each test starts. P10 (Prior action): navigate to `/my-applications` at the top of each test as the state-reset mechanism.

**Resolution (A — chosen):** Each test that requires a specific starting state uses `[Setup] Go To    ${BASE_URL}/my-applications` as its first action. A hard navigation resets: active tab to `#emi` (the URL hash default), filter panel (closed), profile dropdown (closed), and scroll position. This is lighter than `Close Context` (which would break session sharing) and deterministic.

**Propagation:** O1 TIGHTENED — each test must include a navigation reset in its setup or as its first keyword.

---

### TN5: Create New Application Button — Non-Deterministic Outcome

**Type:** trade_off | **Between:** O2, B1 | **Status:** resolved

TC-4010 clicks the Create New Application button. The frontend branches on account state: accounts with existing applications show a `CreateNewApplicationModal` (CSS class selector — no data-testid); accounts in a clean state may redirect directly to the new application flow. Neither branch has a stable data-testid for assertion. The Java test uses unstable CSS class selectors (`div[contains(@class, 'CreateNewApplicationModal')]`).

**TRIZ:** P15 (Dynamization): adaptive assertion that accepts either branch outcome. P11 (Beforehand cushioning): define a timeout-bounded "did anything happen" check as the fallback.

**Resolution (A — chosen):** Click the button and assert that within `TIMEOUT`, either:
- A modal element is visible (using `Run Keyword And Return Status    Wait For Elements State    css=.modal-dialog    visible`), OR
- The URL has changed from `/my-applications`.
At least one must be true. This covers both account states without depending on which branch was taken. The assertion is "the button had a visible effect" — which is the actual test intent.

**Propagation:** O2 LOOSENED — dual-branch assertion replaces single-destination hardcoding. B1 SATISFIED for TC-4010 without class-selector violations.

---

### TN6: Subtitle Exact Text vs. Copy Drift

**Type:** trade_off | **Between:** U1, B1 | **Status:** resolved

U1 requires exact text assertions (INVARIANT). The dashboard subtitle — `"Find all your EMI applications, Autopay subscriptions and transaction history here."` — is marketing copy that product teams may adjust (punctuation, wording, adding new tab names). An exact match on the full subtitle will cause spurious test failures on any copy update.

**TRIZ:** P3 (Local quality): apply different assertion strategies to different parts of the same page based on their change frequency. P1 (Segmentation): separate structural identity strings from descriptive copy.

**Resolution (A — chosen):** Scope U1 by element stability:
- `dashboard-title` ("Hello,") → `Should Be Equal` (6 characters; design identity, never changes)
- `dashboard-subtitle` → `Should Contain    Autopay subscriptions` (stable product term unlikely to change without a feature change)

This satisfies U1's intent (catch unintended regressions) while avoiding false failures from minor copy edits. The chosen substring `Autopay subscriptions` is product-terminology, not filler copy.

**Propagation:** U1 TIGHTENED in precision — exact match is now explicitly scoped to title only; subtitle becomes a contains-check with documented rationale.

---

## Required Truths

> **PRECONDITION** (TN2 resolution B): TC-4001 and TC-4013–TC-4031 require the UAT test account to have at least one active EMI application and at least one transaction record respectively. These are documented suite preconditions, not test gates. A failure with "no cards found" signals that the test account needs seeding, not a test defect.

### RT-1: Authenticated Browser Session at Suite Startup

**Statement:** A single browser session, authenticated as the UAT test user, must be open and positioned at `/my-applications` before any test case runs.

**Gap:** No `Suite Setup` keyword exists for the dashboard. The existing `Navigate To OTP Page` keyword (OTPPage.robot) opens a context, submits the login form, and lands on `/verify`. A new `Login And Navigate To Dashboard` keyword must be added to `DashboardPage.robot` that continues from OTP entry to dashboard landing — reusing `Submit OTP Form` and `Dashboard URL Should Be Visible` from OTPPage.robot.

#### RT-1.1: Suite Setup Opens Browser Once (No Per-Test Browser/Context)

`Suite Setup` must call `New Browser` exactly once. `Test Teardown` must NOT call `Close Context` (unlike auth suites). `Suite Teardown` must call `Close Browser`.

**Gap:** NOT_SATISFIED — test suite file does not exist yet.

#### RT-1.2: OTP Login Flow Reusable from Existing Keywords

`Navigate To OTP Page` + `Submit OTP Form` + `Dashboard URL Should Be Visible` already exist in OTPPage.robot and can be composed in the Suite Setup keyword.

**Gap:** SPECIFICATION_READY — implementation is a keyword composition; no new login logic needed.

---

### RT-2: Per-Test Navigation Reset to Dashboard Root

**Statement:** Each test case must begin with a hard navigation to `${BASE_URL}/my-applications`. This resets: active tab (defaults to `#emi`), filter panel (closed), profile dropdown (closed), scroll position. Implemented as `Test Setup    Go To    ${BASE_URL}/my-applications` at the suite level.

**Gap:** NOT_SATISFIED — no dashboard suite file. Once created, this is a one-line `Test Setup` in `*** Settings ***`.

---

### RT-3: TC-4009 (Logout) Is the Last Test in the Suite File

**Statement:** `Logout Returns To Login Page` must be the final `*** Test Cases ***` entry in `dashboard_tests.robot`. Robot Framework executes tests in file order. Any test after the logout test will find the session destroyed and fail.

**Gap:** SPECIFICATION_READY — this is a file-ordering constraint, not a code constraint. Must be enforced during authoring and code review.

---

### RT-4: DashboardPage.robot Resource File With All Required Keywords

**Statement:** A `resources/DashboardPage.robot` file must exist providing locators and keywords for all 25 enabled dashboard test cases. This is the binding constraint — all other RTs depend on keywords in this file.

**Gap:** NOT_SATISFIED — file does not exist. Must be created before the test suite can be written.

#### RT-4.1: Header/Branding Keywords

Keywords for: `dashboard-title` text assertion, `dashboard-subtitle` contains assertion, `desktop-view-gq-logo` visibility. Locators confirmed in manifold domain context table.

**Gap:** NOT_SATISFIED — requires implementation.

#### RT-4.2: Profile Dropdown Keywords

Keywords for: click `profile-button`, wait for `profile-options-container` visible (U3 sequence), assert `faq` and `logout` options visible, click FAQ (navigate + assert URL `/faq` + title contains "FAQ" per TN3), click logout (assert URL returns to `/`).

**Gap:** NOT_SATISFIED — requires implementation.

#### RT-4.3: Tab Navigation + Filter Keywords

Keywords for: click each tab button, assert URL hash (`#emi`, `#ins`, `#ad`, `#direct`). Click `pg-tab-navigation-button`, click Online/Offline sub-tabs. Click `filter-button`, select time/status filter options, click `clear-filter-button`, click `apply-filter-button`. Assert `emi-card` partial match (T4 precondition). Click `create-new-application-button` with dual-branch assertion (TN5). Click download buttons by row index.

**Gap:** NOT_SATISFIED — requires implementation.

---

### RT-5: Dashboard-Dedicated Variable for Suite Setup Mobile

**Statement:** `variables/variables.robot` must contain `${DASHBOARD_MOBILE}` — a mobile number used exclusively for the dashboard suite's `Suite Setup` login. Using `${TEST_MOBILE}` risks collision with other suites running concurrently (or sequentially in CI) that also use `TEST_MOBILE` for checkMobilePost, which could trigger the rate limit during dashboard suite setup.

**Gap:** PARTIAL — `variables.robot` exists but `${DASHBOARD_MOBILE}` is not defined. Must add one new entry (e.g., `9876543230`) distinct from all existing `OTP_MOBILE_*` and `EXT_*` numbers.

---

### RT-6: URL Hash Values Confirmed for Tab Assertions

**Statement:** The URL hash produced by clicking each tab button is: EMI → `#emi`, Insurance → `#ins`, Auto Debit → `#ad`, Transaction History (PG) → `#direct`. These must be asserted with `Should Contain    ${url}    #emi` (etc.) after each tab click.

**Gap:** SPECIFICATION_READY — confirmed from UAT frontend source during m1-constrain. Implementation is straightforward URL string checks.

---

### RT-7: FAQ Navigation Asserted via URL + Browser Title (No DOM Query)

**Statement:** TC-4008 (FAQ link click) must assert: (1) URL contains `/faq`, (2) `Get Title` result contains `"FAQ"`. No DOM element query — complies with T1 (no data-testid on FAQ page h1, per TN3 resolution).

**Gap:** SPECIFICATION_READY — TN3 resolution already specifies the exact assertion strategy. Implementation is two lines in `DashboardPage.robot`.

---

### RT-8: TC-4010 Create New Application — Dual-Branch Assertion

**Statement:** After clicking `create-new-application-button`, the test must assert that EITHER a modal becomes visible OR the URL has changed from `/my-applications`. Uses `Run Keyword And Return Status` for the modal check, then `OR` logic. Neither branch must hard-fail the test.

**Gap:** SPECIFICATION_READY — TN5 resolution specifies the exact assertion strategy.

---

### RT-9: Title/Subtitle Assertion Strategy

**Statement:** `dashboard-title` text is asserted with `Should Be Equal    ${text}    Hello,`. `dashboard-subtitle` text is asserted with `Should Contain    ${text}    Autopay subscriptions`. Exact full-text match on subtitle is avoided per TN6 resolution.

**Gap:** SPECIFICATION_READY — TN6 resolution specifies both assertion calls.

---

## Solution Space

### Option A: Inline Keywords in Test Suite File
- All locators and keywords defined inside `dashboard_tests.robot` with no separate resource
- Satisfies: RT-1, RT-2, RT-3, RT-4 (partially), RT-5, RT-6, RT-7, RT-8, RT-9
- Gaps: Keywords not reusable; violates existing project architecture pattern
- Complexity: Low
- Reversibility: TWO_WAY (can extract to resource later)

### Option B: Resource File + Suite File (matches existing project architecture) ← Recommended
- `resources/DashboardPage.robot` — all locators and page object keywords
- `tests/dashboard_tests.robot` — test cases only, imports resource and variables
- `variables/variables.robot` — add `${DASHBOARD_MOBILE}` entry
- Exactly mirrors LoginPage.robot + LoginLeftComponent.robot + OTPPage.robot pattern
- Satisfies: RT-1, RT-2, RT-3, RT-4, RT-5, RT-6, RT-7, RT-8, RT-9 (all)
- Gaps: None
- Complexity: Medium
- Reversibility: TWO_WAY

### Option C: Resource + Separate Locators File
- `resources/DashboardLocators.robot` (variables only) + `resources/DashboardPage.robot` (keywords) + `tests/dashboard_tests.robot`
- Satisfies: all RTs
- Gaps: Over-engineered for a single suite; existing auth resources combine locators + keywords
- Complexity: Medium-High
- Reversibility: TWO_WAY

**BINDING CONSTRAINT: RT-4 (DashboardPage.robot resource file)**
All test cases, the Suite Setup keyword, and the per-test navigation reset depend on keywords in this file. It must be generated first in m4.
