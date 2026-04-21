# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Robot Framework UI automation suite for the GQ Customer Portal. Covers the login left component, login form, OTP verification flow, and dashboard — targeting UAT: `https://customer.uat.graydev.in/`. Uses the **Browser library (Playwright)** — not SeleniumLibrary.

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
./venv/bin/robot --outputdir results/ tests/dashboard_tests.robot
```

### Run tests by tag
```bash
./venv/bin/robot --outputdir results/ --include smoke tests/          # smoke tests only
./venv/bin/robot --outputdir results/ --include login tests/          # login tests only
./venv/bin/robot --outputdir results/ --include otp tests/            # OTP tests only
./venv/bin/robot --outputdir results/ --include dashboard tests/      # dashboard tests only
./venv/bin/robot --outputdir results/ --include resend tests/otp_tests.robot  # ~3min resend test
```

### Dry run (syntax check, no browser)
```bash
./venv/bin/robot --dryrun tests/
```

### Override base URL or mobile number
```bash
./venv/bin/robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999999999 ./venv/bin/robot --outputdir results/ tests/
```

## Architecture

```
tests/                     — Test suites (import resources and variables)
  login_left_component_tests.robot  — 9 left panel component tests
  login_tests.robot                 — 15 login form tests
  otp_tests.robot                   — 13 OTP tests (3 skipped)
  dashboard_tests.robot             — 31 dashboard tests (6 skipped)

resources/                 — Page Object keyword libraries (no variable imports)
  LoginLeftComponent.robot  — Keywords + locators for left panel component
  LoginPage.robot           — Keywords + locators for / (login form)
  OTPPage.robot             — Keywords + locators for /verify (OTP form)
  DashboardPage.robot       — Keywords + locators for /my-applications (dashboard)

variables/
  variables.robot           — All variables: BASE_URL, timeouts, test data, browser settings

results/                   — robot output (output.xml, log.html, report.html)
```

**Key pattern:** Test files import resource files and the variables file. Resource files do NOT import variables — Robot Framework shares the variable scope from the suite, so resources access `${TIMEOUT}`, `${BASE_URL}`, etc. directly. No `*** Keywords ***` section in test files — all keywords live in resource files (Page Object Model).

## UAT Constraints

- **Fixed OTP**: UAT uses OTP `9999` for all mobile numbers — no SMS dependency.
- **checkMobilePost rate limit**: ~3 calls per ~60s per IP. `Navigate To OTP Page` auto-detects (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT` (45s). Each OTP/login test uses a distinct mobile number to reduce collisions.
- **verifyOtpPost rate limit**: Also applies per IP. Handled with a three-state page-check after `RATE_LIMIT_WAIT` sleep: (1) on `/my-applications` → OTP succeeded, skip retry; (2) on `/verify` → re-enter OTP; (3) on `/` → rate limit forced logout, re-submit login form then OTP. Applied in `Valid OTP Redirects To Dashboard`, `Login And Navigate To Dashboard`, and `Switch To Account`.
- **Test order**: `Valid OTP Redirects To Dashboard` runs before `Wrong OTP Shows Incorrect OTP Toast` — a prior failed verifyOtpPost can trigger rate limiting that blocks the valid path.
- **UAT availability**: UAT is **down 9pm–7am**. Live tests must run between 7am–9pm.

## Dashboard Session Model

The dashboard suite uses a **single shared browser session** across all 31 tests:
- `Suite Setup` — `Login And Navigate To Dashboard`: opens browser, logs in with `${DASHBOARD_MOBILE}` (8108556708), reaches /my-applications.
- `Test Setup` — `Navigate To Dashboard`: hard-navigates to /my-applications (resets tab/filter/dropdown state). No new login.
- `Test Teardown` — NONE (shared session preserved — no `Close Context`).
- `Suite Teardown` — `Close Browser`.
- **TC-4009 (Logout) MUST remain the last test** — it destroys the shared session.
- **TC-4030** calls `Switch To Account    ${PG_MOBILE}` (~3 min into the suite, rate limits cleared). TC-4031 inherits that session.

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
| Wrong OTP | URL stays on `/verify` (primary); toast `text=Incorrect OTP` (secondary — non-blocking, may be absent if verifyOtpPost rate-limited) |

## Routes

| Page | URL path |
|------|----------|
| Login | `/` |
| OTP verification | `/verify` |
| Dashboard | `/my-applications` |
| FAQ | `/faq` |
