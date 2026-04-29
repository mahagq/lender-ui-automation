# application-creation-flow

## Outcome

Automate the full Application Creation Flow (10 pages, /student-details through /confirm-application) in Robot Framework + Playwright, ported from the existing Java/Selenium test suite in `gq_customer_ui_automation` and extended to cover new UAT branch changes in `gqcustomer_frontend`. All automation lives in `customer_portal_ui_automation`. No changes to `gqcustomer_frontend` or `gq_customer_ui_automation`.

**Pages in scope:**
- `/student-details` — Student Details
- `/choose-plan` — Choose Plan
- `/select-applicant` — Select Applicant Type
- `/applicant-basic-details` — Applicant Basic Details
- `/onboarding` — Onboarding
- `/applicant-personal-details` — Applicant Personal Details
- `/applicant-residential-details` — Applicant Residential Details
- `/select-employment` — Select Employment Type
- `/applicant-employment-details` — Applicant Employment Details
- `/confirm-application` — Confirm Application

---

## Constraints

### Business

#### B1: All Enabled Java Test Scenarios Must Be Ported

Every `@Test(enabled = true)` scenario in the Java suite covering these 10 pages must have a corresponding Robot Framework test case. Disabled Java tests (`enabled = false`) must be tracked as `robot:skip` with a note.

> **Rationale:** The Java suite defines the agreed test coverage baseline (TC-6001–TC-6011 Choose Plan, TC-7001–TC-7010 Select Applicant, TC-12001–TC-12066+ Employment, TC-13001–TC-13020+ Confirm Application). Dropping any enabled test reduces coverage below baseline.

**Java TC ranges by page:**
- TC-6001–6011: Choose Plan (`SelectPlanTest`, `SelectPlanTestClass2`)
- TC-7001–7010: Select Applicant (`SelectApplicantTest`, `SelectApplicantTestClass2`)
- TC-12001–12026+: Employment Type + Salaried Details (`SelectEmploymentTest`, `SalariedEmploymentTest`, `SalariedEmploymentTestClass2/3`)
- TC-12047–12066+: Self-Employment Details (`SelfEmploymentTest`, `SelfEmploymentTestClass2-5`)
- TC-13001–13020+: Confirm Application (`ConfirmApplicationTest`, `ConfirmApplicationTestClass2/3`)

#### B2: New UAT-Branch Features Must Be Covered

Pages that exist in the UAT branch of `gqcustomer_frontend` but have no Java test coverage (StudentDetails form validation, Onboarding, Personal Details, Residential Details, ApplicantBasicDetails) must be automated at a level equivalent to the Java coverage standard — title visible, required fields, form submission, error states.

> **Rationale:** These pages were updated on the UAT branch. They are untested in the Java suite, creating a coverage gap.

#### B3: No Changes to Source Repos

Zero modifications to `gqcustomer_frontend` and `gq_customer_ui_automation`. All work is confined to `customer_portal_ui_automation`.

> **Rationale:** Explicit user requirement. Those repos are owned by separate teams.

#### B4: All Existing Project Patterns Must Be Maintained

New files must follow POM pattern (resource files in `resources/`, suites in `tests/`, variables in `variables/variables.robot`), Allure listener annotations, tag conventions (`application-creation`, per-page tags), and the established `data-testid` locator contract.

> **Rationale:** Consistency with the existing 81-test suite ensures Jenkins pipeline, Allure report, and dry-run infrastructure work unchanged.

---

### Technical

#### T1: data-testid Locators Exclusively

All selectors must use `css=[data-testid='...']`. CSS class names in `gqcustomer_frontend` use CSS Modules (hashed at build time — unstable across deploys). XPath and class selectors are forbidden.

> **Rationale:** CSS Modules produce hashed class names like `mKL82Y7dAkemlOmrz5p7` (seen in Java page objects) that break after every frontend build. `data-testid` attributes are stable. The existing Java suite already violates this in places — Robot Framework port must correct those usages.

**Known data-testid map (from UAT branch + Java page objects):**

| Page | Key testids |
|------|-------------|
| StudentDetails | `student-details-title`, `first-name-input`, `last-name-input`, `student-type-radio`, `class-id-react-select`, `student-id-input`, `loan-amount-input`, `show-plans-button` |
| ChoosePlan | `choose-plan-title`, `plans-count`, `plan-list-container`, `submit-plan-details-button`, `no-plans-found` |
| SelectApplicant | `select-applicant-title`, `select-applicant-note`, `Parent/Guardian-0`, `Student-1`, `submit-applicant-type-button` |
| ApplicantBasicDetails | `applicant-basic-details-title`, `first-name-input`, `last-name-input`, `consent-checkbox`, `submit-button` |
| Onboarding | `onboarding-title`, `onboarding-info-one`, `onboarding-info-two`, `onboarding-info-three`, `proceed-button` |
| PersonalDetails | `personal-details-title`, `pan-number-input`, `gender-react-select`, `year-react-select`, `month-react-select`, `day-react-select`, `marital-status-radio`, `email-input`, `consent-checkbox`, `proceed-button` |
| ResidentialDetails | `residential-details-title`, `addr-line-1-input`, `addr-line-2-input`, `pincode-input`, `city-input`, `state-react-select`, `type-radio`, `proceed-button` |
| EmploymentType | `select-employment-type-title`, `employment-type-title`, `salaried`, `self-employed` |
| EmploymentDetails (Salaried) | `employment-details-title`, `employer-name-input`, `net-monthly-salary-input`, `consent-checkbox`, `in-words`, `proceed-button` |
| EmploymentDetails (Self-Employed) | `employment-details-title`, `business-name-input`, `business-annual-income-input`, `years-of-current-business-input`, `business-description-input`, `proceed-button` |
| ConfirmApplication | `confirm-application-title`, `confirm-application-form`, `consent-checkbox`, `proceed-button`, section headings and edit buttons per section, value display `data-testid`s |

#### T2: Authenticated Session + New Application Required for All Flow Tests

Every test in the application creation flow requires: (1) a logged-in browser session (OTP verified), (2) a new application created via Dashboard → EMI Tab → Create New Application, (3) a valid `app_code` stored in localStorage. Pages from `/choose-plan` onward redirect to `/my-applications` if `app_code` is missing.

> **Rationale:** The frontend reads `app_code` from localStorage on every flow page. Without it, `navigateTo('/my-applications')` is called immediately. The Suite Setup must navigate the full wizard entry path before any test runs.

#### T3: Wizard Page Order Enforced Server-Side

Pages in the flow cannot be accessed by direct URL navigation without a valid application state. Tests that need to reach a specific page (e.g., Confirm Application) must either navigate sequentially through prior pages or use a pre-seeded application that is already at that stage in the database.

> **Rationale:** Observed in Java suite — every `@BeforeMethod` navigates from login through all prerequisite pages. Direct URL navigation skips tracker API calls that gate the next page.

#### T4: Employment Details Has Two Distinct Form Variants

`/applicant-employment-details` renders different fields depending on whether Salaried or Self-Employed was selected on `/select-employment`. Both variants must be fully automated with separate resource keywords:
- **Salaried**: `employer-name-input`, `net-monthly-salary-input`, `consent-checkbox`, `in-words` text
- **Self-Employed**: `business-name-input`, `business-annual-income-input`, `years-of-current-business-input`, `business-description-input`

> **Rationale:** Java test suite covers both paths across multiple test classes (TC-12017–12046 Salaried, TC-12047–12066+ Self-Employed). Missing either path leaves half the employment scenarios untested.

#### T5: Confirm Application Shows Data Consistent With Prior Steps

The Confirm Application page displays values entered across all previous pages. Test data used in Suite Setup (names, plan, applicant type, PAN, address, employment) must be tracked and asserted consistently on the Confirm Application page.

> **Rationale:** TC-13001–13020 specifically validate that the correct previously-entered values appear in the summary sections. Inconsistent test data causes these assertions to fail.

#### T6: Browser Library (Playwright) — Not SeleniumLibrary

All keywords must use `robotframework-browser` (Playwright) APIs: `Wait For Elements State`, `Fill Text`, `Click`, `Get Text`, `Get Url`, `Select Options By`, `Get Element Count`. SeleniumLibrary keywords (`Input Text`, `Wait Until Element Is Visible`) are not available.

> **Rationale:** This is the existing project's established library. The Java suite uses Selenium — translation to Browser library keywords is required during porting.

#### T7: UAT Rate Limits Apply to Application Creation Setup

The Suite Setup for each test class must log in via the same `Navigate To OTP Page` / `Verify OTP` flow used in the auth suite, subject to the same UAT rate limits (checkMobilePost ~3/60s, verifyOtpPost per-IP). The mobile number used for application creation must be distinct from auth suite numbers to avoid rate limit collisions. Use `${APP_CREATION_MOBILE}` variable.

> **Rationale:** Multiple suite setups running in sequence against UAT can hit the rate limit. The auth suite already handles this — application creation suite must follow the same pattern.

---

### User Experience

#### U1: Form Validation Error data-testids Follow Established Patterns

Input field errors use `<field-name>-input-error` (e.g., `first-name-input-error`). Select/radio errors use `<field-name>-error` or `<field-name>-react-select-error`. Tests must assert these specific elements are visible with appropriate error text when validation fails.

> **Rationale:** Consistent with auth suite pattern (e.g., `mobile-number-input-error`, `otp-input-error`). Error assertions must be precise — checking the wrong testid causes false passes.

#### U2: Proceed/Submit Buttons Follow Outlined→Contained State Pattern

Buttons render as `variant='outlined'` (disabled appearance) when the form is invalid and switch to `variant='contained'` (enabled) only when all required fields are valid. Tests should assert button state changes, not just clickability.

> **Rationale:** The Java tests explicitly check `isProceedBtnEnabled()` (TC-6005, TC-6007, TC-6008, TC-7007, TC-7008). This UX pattern is consistent across all pages. Robot Framework should use `Wait For Elements State ... enabled/disabled` or check the button's class/aria attributes.

#### U3: Page Title Assertion on Every Test

Each test must begin with (or have in Setup) an assertion that the correct page title is visible using the page's `*-title` testid. This confirms the prerequisite navigation succeeded before the test body runs.

> **Rationale:** Silent redirects to `/my-applications` (due to missing app_code) would cause confusing failures on element not found. Title assertion catches these immediately.

#### U4: Back Navigation Returns to Correct Previous Page

Tests covering the Back button (TC-6010, TC-7010, TC-12012) must verify that browser back navigation lands on the expected prior page by asserting the prior page's title testid.

> **Rationale:** The Java suite explicitly validates back-navigation titles. The wizard has meaningful "back" behavior that should be regression-tested.

---

### Security

#### S1: Application Creation Flow Requires Authentication

All flow pages redirect to `/` (login) if the user is not authenticated. Suite Setup must confirm the session is valid before test execution. If Setup fails to authenticate, the suite must abort — not run tests against a logged-out state.

> **Rationale:** An unauthenticated test run would fail silently on every test (redirected to login page) without a clear cause. Explicit auth validation in Suite Setup prevents misleading test results.

#### S2: Test Mobile Numbers Must Be Isolated From Auth Suite Numbers

The mobile number used to create applications (`APP_CREATION_MOBILE`) must be different from the numbers used in `login_tests.robot`, `otp_tests.robot`, `bypass_auth_tests.robot`, and `dashboard_tests.robot` to avoid checkMobilePost rate limit collisions across suites.

> **Rationale:** UAT rate-limits checkMobilePost per IP (~3 calls/60s). If suites share mobile numbers and run concurrently or in quick succession, they block each other.

---

### Operational

#### O1: Suite Creates Real Applications on UAT — Data Cleanup Awareness

Running the application creation suite creates actual application records on UAT under the test mobile number. These accumulate over multiple runs. Tests must be designed to create a new application per suite run (not rely on pre-existing data from a previous run) and the `APP_CREATION_MOBILE` number should be a dedicated test-only number not used by real users.

> **Rationale:** Pre-mortem finding: if a previous run's application is in a different wizard state, the `@BeforeMethod` navigation flow may skip pages (auto-advance) and tests will start on the wrong page.

#### O2: PRECONDITION Comments Required for Data-Dependent Tests

Tests that require specific UAT data (e.g., institution "GQ Academy" existing in UAT, a plan being available for the fee amount, Confirm Application showing real submitted data) must have a `PRECONDITION:` comment explaining the data dependency and what happens if the data is absent.

> **Rationale:** Matches the convention established in `dashboard_tests.robot` (TC-4001, TC-4011, TC-4030). Data-dependent test failures on CI must be diagnosable without re-reading the code.

#### O3: Jenkins Pipeline and Allure Report Integration

New test suite must integrate with the existing Jenkins pipeline. The Allure Behaviors tab must show: Epic: CP UI Automation → Feature: Application Creation Flow → Story per page (StudentDetails, ChoosePlan, SelectApplicant, etc.). Tags must follow the convention: `application-creation` (suite-level) + `student-details`, `choose-plan`, etc. (page-level).

> **Rationale:** Consistent with existing suites in the Allure report. The Jenkins pipeline runs `tests/` with no file filters — new suite file is auto-included.

#### O4: UAT Availability Window

Application creation suite tests must only run between 07:00 and 21:00 IST. UAT is down 21:00–07:00. This is the same constraint as all other suites.

> **Rationale:** Matches UAT constraint documented for the entire test project.

---

## Tensions

### TN1: Wizard Traversal Cost — Auth + App Creation vs Per-Test Navigation

**Type:** hidden_dependency | **Between:** T2 × T3 | **Status:** resolved

T2 requires an authenticated session AND a newly created application (with `app_code` in localStorage) before any flow test can run. T3 enforces wizard page order server-side — there is no shortcut to `/applicant-personal-details` without having navigated through `/student-details` and `/choose-plan` first. Taken together, every test would need a full login → dashboard → create application → wizard traversal cycle from scratch, multiplying setup cost by the total test count (~80+).

> **Resolution B: Suite-level Setup for auth + app creation; Test-level Setup for page navigation.**
> Each suite file (`student_details_tests.robot`, `choose_plan_tests.robot`, etc.) performs ONE Suite Setup that logs in, creates a new application, and navigates to the target wizard page. The shared browser context persists across all tests in the suite. Test Setup navigates back to the page (using `Go To` on a URL that is valid within the current wizard session) without re-authenticating. If Suite Setup fails to authenticate or create an application, Robot Framework aborts the entire suite — tests never run against the login page.
>
> **Propagation:**
> - T7 LOOSENED — rate limit load drops from O(N_tests) logins to O(N_suites) logins (~10x reduction)
> - S1 TIGHTENED — Suite Setup abort-on-failure is now mandatory; `Should Be True    '${APP_URL}' in '${current_url}'` guard required after Setup

### TN2: Rate Limit Load vs Full Java TC Coverage

**Type:** resource_tension | **Between:** B1 × T7 | **Status:** resolved

B1 requires porting all ~80+ enabled Java test scenarios. The Java @BeforeMethod re-runs the full navigation flow (login → app creation → page navigation) before every single test. T7 limits checkMobilePost to ~3 calls per 60s per IP. Naively running all tests with per-test login would trigger rate limit blocks within minutes, making the CI run non-deterministic.

> **Resolution A: One login per suite file — deliberate test grouping by wizard page.**
> Tests for the same wizard page are grouped into the same suite file. Each file's Suite Setup does one login and one `Create New Application`. Within the suite, Test Setup uses `Go To` on the wizard page URL (which resolves correctly because the browser context holds the active session and `app_code`). Total UAT logins across the full test run = number of suite files (capped at ~10), not number of test cases (80+).
>
> **Propagation:**
> - O1 LOOSENED — fewer application records created per CI run
> - B1 TIGHTENED — test grouping must be deliberate: all tests for a page in one file; cross-page grouping would break shared-session assumptions

### TN3: Employment Dual-Variant vs One Resource File Per Page

**Type:** trade_off | **Between:** T4 × B4 | **Status:** resolved

T4 requires both the Salaried and Self-Employed form variants to be fully automated. Both variants share the same URL (`/applicant-employment-details`) but render completely different fields. B4 requires maintaining the established pattern of one resource file per page URL. Creating two separate resource files for the same URL breaks the pattern; cramming both into one file risks coupling.

> **Resolution B: Single `ApplicantEmploymentPage.robot` with clearly separated keyword groups.**
> The resource file contains two named groups: (1) Salaried keywords (`Fill Salaried Employment Details`, `Validate Salaried Field Errors`, etc.) and (2) Self-Employed keywords (`Fill Self Employed Details`, `Validate Business Field Errors`, etc.). Test suites invoke the appropriate group. This is identical to the Dashboard pattern — one `DashboardPage.robot` resource serves all tabs (EMI, Insurance, PG). No B4 violation.
>
> **Propagation:**
> - B4 LOOSENED — the "one resource per URL" pattern is maintained
> - T4 LOOSENED — both variants get explicit keyword coverage with no risk of one being dropped

### TN4: Confirm Application Assertions vs Dynamically Computed UAT Values

**Type:** trade_off | **Between:** T5 × O1 | **Status:** resolved

T5 requires consistent, assertable test data on the Confirm Application page. O1 acknowledges that the suite creates real UAT applications — meaning EMI amounts, interest rates, and total fees are computed server-side based on the institution's current UAT plan configuration. These values are not hardcoded and may change if UAT plan data is updated. Asserting exact values for computed fields would make tests brittle.

> **Resolution A: Exact assertions for user-entered static fields; format/non-empty assertions for API-computed fields.**
> - Static fields (names, email, address, employment type, applicant type) → `Should Be Equal As Strings` with variables from `variables.robot`
> - API-computed fields (EMI amount, interest rate, tenure, total fee) → `Should Not Be Empty` or `Should Match Regexp    ${value}    \\d` (contains digits)
> - PRECONDITION comment on Confirm Application tests documents which fields are exact vs format-only.
>
> **Propagation:**
> - O2 TIGHTENED — PRECONDITION comment on Confirm Application tests is now required (not just recommended)
> - T5 TIGHTENED — all static test data (names, PAN, DOB, email, address) must be declared as variables in `variables.robot` and used consistently across the entire wizard

---

## Required Truths

### RT-1: Wizard Navigation Infrastructure ⚡ BINDING

A shared `ApplicationCreationFlowPage.robot` keyword library exists that provides a single entry point — `Create Application And Navigate To Student Details` — which logs in (handling UAT rate limits), navigates to the Dashboard, creates a new application via the EMI tab, and arrives at `/student-details`. Additionally, a `Navigate To Wizard Page` helper navigates from the current session state to any specific wizard page by sequentially filling preceding pages with minimal stub data (happy-path traversal without assertions). Both keywords use `${APP_CREATION_MOBILE}` (defined in `variables/variables.robot`) — a dedicated mobile number distinct from all auth suite numbers.

**Gap:** Neither keyword exists. No `ApplicationCreationFlowPage.robot` resource file exists. `${APP_CREATION_MOBILE}` is not defined in `variables/variables.robot`. No wizard traversal helper exists.

**Why binding:** Without this infrastructure, no test in RT-2 through RT-7 can execute. Every test in the suite depends on reaching its wizard page via this helper. If this RT is not satisfied, the entire feature is blocked regardless of how perfectly the other resource files are written.

**Dependency chain:** RT-1 → RT-2 → RT-3 → RT-4 → RT-5 → RT-6 → RT-7

---

### RT-2: Student Details Page Automated

`resources/StudentDetailsPage.robot` exists with keywords covering:
- GILE form fields: `institute-id-react-select`, `location-id-react-select`, `board-id-react-select`, `academic-year-id-react-select`
- Student Details form fields: `first-name-input`, `last-name-input`, `student-type-radio`, `class-id-react-select`, `student-id-input`, `loan-amount-input`
- Error testids: `first-name-input-error`, `last-name-input-error`, `student-type-radio-error`, `class-id-react-select-error`, `loan-amount-input-error`
- Submit: `show-plans-button`

`tests/student_details_tests.robot` exists with B2-level coverage (title visible, required field validation, form submission to /choose-plan). No Java TC IDs exist for this page — this is new coverage.

**Gap:** No `StudentDetailsPage.robot`. No `student_details_tests.robot`.

---

### RT-3: Choose Plan Page Automated (TC-6001–6011)

`resources/ChoosePlanPage.robot` exists with keywords for:
- Plan list container: `plan-list-container`, `plans-count`
- Plan selection: selecting plan by index, asserting selected state
- Proceed button state: enabled/disabled via `submit-plan-details-button`
- No-plans state: `no-plans-found`

`tests/choose_plan_tests.robot` exists with all enabled Java TCs ported:
- TC-6001: Verify GILE (institute name) on ChoosePlan page
- TC-6002: Verify plan details (count, EMI amounts)
- TC-6003: Verify plans in sequence
- TC-6004: Verify recommended plan badge
- TC-6005: No plan selected → proceed button disabled
- TC-6006: Multiple plan selection switches (only one active at a time)
- TC-6007: Proceed button disabled when no plan selected
- TC-6008: Proceed button enabled after plan selected
- TC-6009: Facing Issues link opens help panel
- TC-6010: Back navigation returns to student details title
- TC-6011: Close button behavior

**Gap:** No `ChoosePlanPage.robot`. No `choose_plan_tests.robot`.

---

### RT-4: Select Applicant Page Automated (TC-7001–7010)

`resources/SelectApplicantPage.robot` exists with keywords for:
- Title: `select-applicant-title`
- Applicant type options: `Parent/Guardian-0`, `Student-1`
- Student consent checkboxes: age consent (`id=age`), salary consent (`id=salary`)
- Proceed button: `submit-applicant-type-button`

`tests/select_applicant_tests.robot` exists with all enabled Java TCs ported:
- TC-7001: Institute name visible
- TC-7002: Two applicant type options visible
- TC-7003: Parent/Guardian selection
- TC-7004: Student selection
- TC-7005: First consent checkbox after Student selection
- TC-7006: Second consent checkbox after Student selection
- TC-7007: Proceed button disabled without selection
- TC-7008: Proceed button enabled after selection
- TC-7009: Facing Issues link
- TC-7010: Back navigation returns to ChoosePlan

**Gap:** No `SelectApplicantPage.robot`. No `select_applicant_tests.robot`.

---

### RT-5: Four Uncovered Pages Automated (B2 — New Coverage)

Four pages with no Java test coverage are automated at B2 level (title visible, field presence, required field validation, form submission to next page):

1. **`resources/ApplicantBasicDetailsPage.robot`** — keywords for `applicant-basic-details-title`, `first-name-input`, `last-name-input`, `consent-checkbox`, `submit-button`, error testids
2. **`resources/OnboardingPage.robot`** — keywords for `onboarding-title`, `onboarding-info-one/two/three`, `proceed-button`
3. **`resources/ApplicantPersonalDetailsPage.robot`** — keywords for `personal-details-title`, `pan-number-input`, `gender-react-select`, `year/month/day-react-select`, `marital-status-radio`, `email-input`, `consent-checkbox`, `proceed-button`, error testids
4. **`resources/ApplicantResidentialDetailsPage.robot`** — keywords for `residential-details-title`, `addr-line-1-input`, `addr-line-2-input`, `pincode-input`, `city-input`, `state-react-select`, `type-radio`, `proceed-button`, error testids

Four separate suite files cover these pages (one per page, matching the page-per-suite pattern): `tests/application_creation_flow/applicant_basic_details_tests.robot`, `tests/application_creation_flow/onboarding_tests.robot`, `tests/application_creation_flow/personal_details_tests.robot`, `tests/application_creation_flow/residential_details_tests.robot`.

**Gap:** SATISFIED — all four resource files and four test suite files exist on disk.

---

### RT-6: Employment Pages Automated — Both Variants (TC-12001–12066+)

`resources/EmploymentTypePage.robot` exists with keywords for `select-employment-type-title`, `employment-type-title`, `salaried` option, `self-employed` option.

`resources/ApplicantEmploymentPage.robot` exists with **two keyword groups** (TN3 resolution):
- **Salaried group:** `employment-details-title`, `employer-name-input`, `net-monthly-salary-input`, `consent-checkbox`, `in-words`, `proceed-button`, error testids
- **Self-Employed group:** `employment-details-title`, `business-name-input`, `business-annual-income-input`, `years-of-current-business-input`, `business-description-input`, `proceed-button`, error testids

`tests/employment_tests.robot` contains:
- Employment Type section (TC-12001–12003, TC-12010–12016)
- Salaried Employment Details section (TC-12017–12046)
- Self-Employed Employment Details section (TC-12047–12066+)

**Gap:** No `EmploymentTypePage.robot`. No `ApplicantEmploymentPage.robot`. No `employment_tests.robot`.

---

### RT-7: Confirm Application Page Automated (TC-13001–13020+)

`resources/ConfirmApplicationPage.robot` exists with keywords for:
- Page title: `confirm-application-title`
- Form container: `confirm-application-form`
- Section headings and edit buttons (per section: student-details, emi-plan-details, who-is-applying, your-general-details, your-residential-details, your-employment-details)
- Value display testids for all summary fields
- Consent checkbox: `consent-checkbox`, proceed button: `proceed-button`

**Assertion strategy (TN4 resolution):**
- Static user-entered values (names, email, address, employment type) → `Should Be Equal As Strings` with variables from `variables.robot`
- API-computed values (EMI amount, interest rate, tenure) → `Should Not Be Empty` or `Should Match Regexp    ${val}    ^\\d`

`tests/confirm_application_tests.robot` exists with TC-13001–13020+ ported.

**Gap:** No `ConfirmApplicationPage.robot`. No `confirm_application_tests.robot`.

**PRECONDITION:** These tests require a full wizard traversal with consistent test data. Suite Setup navigates through all preceding pages using stub data from `variables.robot`. Exact values asserted in Confirm Application must match what was entered in Suite Setup.

---

### RT-8: Test Data Variables Complete and Consistent

`variables/variables.robot` is extended with all wizard test data variables, all prefixed `APP_` to namespace them from auth suite variables:

```
${APP_CREATION_MOBILE}         — Dedicated test mobile, distinct from all auth suite numbers
${APP_STUDENT_FIRST_NAME}      — e.g., Test
${APP_STUDENT_LAST_NAME}       — e.g., Student
${APP_STUDENT_TYPE}            — e.g., New Admission
${APP_FEE_AMOUNT}              — e.g., 10000
${APP_APPLICANT_TYPE}          — e.g., Parent/Guardian
${APP_APPLICANT_FIRST_NAME}    — e.g., Test
${APP_APPLICANT_LAST_NAME}     — e.g., Applicant
${APP_PAN_NUMBER}              — e.g., ABCDE1234F
${APP_EMAIL}                   — e.g., test@example.com
${APP_ADDR_LINE_1}             — e.g., 123 Test Street
${APP_ADDR_LINE_2}             — e.g., Test Area
${APP_PINCODE}                 — e.g., 400001
${APP_EMPLOYER_NAME}           — e.g., Test Company Pvt Ltd
${APP_MONTHLY_SALARY}          — e.g., 50000
${APP_BUSINESS_NAME}           — e.g., Test Business
${APP_ANNUAL_INCOME}           — e.g., 600000
${APP_YEARS_IN_BUSINESS}       — e.g., 5
```

**Gap:** None of these variables exist in `variables/variables.robot` currently.

---

## Solution Space

### Option A: Monolithic Suite (All pages in one suite file)

Single `tests/application_creation_tests.robot` with one Suite Setup (login + create app). Tests for all 10 pages run sequentially in a single suite — later pages depend on the same application created in Suite Setup.

- **Satisfies:** RT-1 through RT-8
- **Reversibility:** TWO_WAY
- **Complexity:** Low (one file to maintain)
- **Problems:** Test failure on an early page cascades to all subsequent pages. All ~80+ tests share one application — if test state is modified by an earlier test (e.g., a test that navigates away), later tests break. Violates TN2 resolution (tests are not grouped by page with isolated Suite Setups).

### Option B: Page-Per-Suite (One suite file per wizard page) ← Recommended

Separate suite files per page/group: `student_details_tests.robot`, `choose_plan_tests.robot`, `select_applicant_tests.robot`, `applicant_journey_tests.robot`, `employment_tests.robot`, `confirm_application_tests.robot`. Each file has its own Suite Setup that calls `Navigate To Wizard Page <target>`. Resource files: one per page URL, `ApplicantEmploymentPage.robot` with dual-variant keyword groups.

- **Satisfies:** RT-1 through RT-8
- **Reversibility:** TWO_WAY
- **Complexity:** Medium (6 suite files, 10 resource files)
- **Advantages:** Full test isolation per suite. TN1 confirmed (Suite Setup per file). TN2 confirmed (one login per suite file). TN3 confirmed (ApplicantEmploymentPage.robot dual groups). TN4 confirmed (Confirm Application assertion strategy). Suite-level failure contains to that suite only.

### Option C: Grouped Suites (Pages grouped by flow section, ~3-4 files)

Group early-flow pages into fewer suites: (StudentDetails + ChoosePlan), (SelectApplicant + BasicDetails + Onboarding + PersonalDetails + Residential), (Employment), (ConfirmApplication). Fewer total logins (~4 vs 6).

- **Satisfies:** RT-1 through RT-8
- **Reversibility:** TWO_WAY
- **Complexity:** Medium-low (4 suite files, 10 resource files)
- **Problems:** Mixed-page suites require Suite Setup to navigate further to reach later pages. Test setup within the suite is more complex. Harder to isolate failures. Does not cleanly map to Java's per-page test class structure.

**RECOMMENDATION: Option B** — page-per-suite isolation is the cleanest structure. Matches the Java suite's class-per-page pattern. All 4 TN resolutions confirmed. The additional login cost (~6 logins per full run) is mitigated by `${RATE_LIMIT_WAIT}` handling already built into the auth infrastructure. `Navigate To Wizard Page` uses stub data to traverse preceding pages quickly.


---

## Generation (Phase 4)

**Option:** B (Page-Per-Suite)
**Completed:** 2026-04-21
**Dry-run result:** 183 tests pass, 0 failures, 7 pre-existing skips

### Artifacts Generated

| Artifact | Type | Satisfies |
|----------|------|-----------|
| `variables/variables.robot` (updated) | code | RT-8, T5, S2 |
| `resources/ApplicationCreationFlowPage.robot` ⚡ | code | RT-1, T2, T7, S1, O1 |
| `resources/StudentDetailsPage.robot` | code | RT-2, T1, U1 |
| `resources/ChoosePlanPage.robot` | code | RT-3, T1, U2, U3 |
| `resources/SelectApplicantPage.robot` | code | RT-4, T1, U1, U4 |
| `resources/ApplicantBasicDetailsPage.robot` | code | RT-5, T1, U1 |
| `resources/OnboardingPage.robot` | code | RT-5, T1, U1 |
| `resources/ApplicantPersonalDetailsPage.robot` | code | RT-5, T1, U1 |
| `resources/ApplicantResidentialDetailsPage.robot` | code | RT-5, T1, U1 |
| `resources/EmploymentTypePage.robot` | code | RT-6, T1, U1 |
| `resources/ApplicantEmploymentPage.robot` | code | RT-6, T1, T4, U1 |
| `resources/ConfirmApplicationPage.robot` | code | RT-7, T1, T5, U1 |
| `tests/application_creation_flow/student_details_tests.robot` | test | RT-2, B1, B2 |
| `tests/application_creation_flow/choose_plan_tests.robot` | test | RT-3, B1 |
| `tests/application_creation_flow/select_applicant_tests.robot` | test | RT-4, B1 |
| `tests/application_creation_flow/applicant_basic_details_tests.robot` | test | RT-5, B2 |
| `tests/application_creation_flow/onboarding_tests.robot` | test | RT-5, B2 |
| `tests/application_creation_flow/personal_details_tests.robot` | test | RT-5, B2 |
| `tests/application_creation_flow/residential_details_tests.robot` | test | RT-5, B2 |
| `tests/application_creation_flow/employment_tests.robot` | test | RT-6, B1, T4 |
| `tests/application_creation_flow/confirm_application_tests.robot` | test | RT-7, B1, T5 |
| `README.md` (updated) | docs | O3 |
| `CLAUDE.md` (updated) | docs | O3, O4 |
| `jenkins.md` (updated) | docs | O3 |

---

## Verification (Phase 5)

**Date:** 2026-04-22 | **Result:** CONVERGED (1 non-blocking gap open)

### Verification Matrix

| Constraint | Type | Code | Test | Docs | Status |
|---|---|---|---|---|---|
| B1: All Java TCs ported | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| B2: New UAT features covered | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| B3: No source repo changes | INVARIANT | ✓ | — | ✓ | SATISFIED |
| B4: Existing patterns maintained | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T1: data-testid exclusively | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T2: Auth session + new app | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T3: Wizard page order enforced | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| T4: Two employment variants | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T5: Confirm Application data consistency | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| T6: Browser library (Playwright) | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| T7: Rate limits handled | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| U1: Form validation error testids | INVARIANT | ✓ | ✓ | ✓ | SATISFIED (G2 fixed 2026-04-27) |
| U2: Button state assertions | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| U3: Page title on every test | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| U4: Back navigation tests | GOAL | ✓ | ✓ | ✓ | SATISFIED |
| S1: Auth abort-on-fail | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| S2: Isolated mobile numbers | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| O1: Real UAT app data awareness | INVARIANT | ✓ | ✓ | ✓ | SATISFIED |
| O2: PRECONDITION comments | BOUNDARY | ✓ | ✓ | ✓ | SATISFIED |
| O3: Jenkins/Allure integration | GOAL | ✓ | ✓ | ✓ | **FIXED in session** |
| O4: UAT availability window | BOUNDARY | — | — | ✓ | SATISFIED |

### Gaps

**G1 (FIXED):** O3 — All 6 wizard test suites were missing `allure.label.epic`, `allure.label.feature`, `allure.label.story` tags. Fixed by adding Allure label tags to all 6 Test Tags lines in this verify session.

**G2 (FIXED 2026-04-27):** U1 — Added `Gender Error Should Be Visible`, `DOB Error Should Be Visible`, `Marital Status Error Should Be Visible` keywords to `ApplicantPersonalDetailsPage.robot` and TC-10N-08/09/10 to `personal_details_tests.robot`. personal_details suite: 15 → 18 tests. Total: 320 → 323 tests.

⚡ = Binding constraint artifact (generated first)
