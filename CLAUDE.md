# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Robot Framework UI automation suite for the GQ Customer Portal authentication flow (Login + OTP verification). Targets UAT: `https://customer.uat.graydev.in/`. Uses the **Browser library (Playwright)** — not SeleniumLibrary.

## Commands

### Run all tests (default — excludes slow/resend tests)
```bash
robot --outputdir results/ tests/
```

### Run a single test file
```bash
robot --outputdir results/ tests/login_tests.robot
robot --outputdir results/ tests/otp_tests.robot
```

### Run tests by tag
```bash
robot --outputdir results/ --include smoke tests/          # smoke tests only
robot --outputdir results/ --include login tests/          # login tests only
robot --outputdir results/ --include otp tests/            # OTP tests only
robot --outputdir results/ --include resend tests/otp_tests.robot  # ~3min resend test
robot --outputdir results/ --include slow tests/           # all slow tests (nightly)
```

### Dry run (syntax check, no browser)
```bash
robot --dryrun tests/
```

### Override base URL or mobile number
```bash
robot --variable BASE_URL:https://other-env.example.com --outputdir results/ tests/
TEST_MOBILE=9999999999 robot --outputdir results/ tests/
```

## Architecture

```
tests/           — Test suites (import resources and variables)
  login_tests.robot   — 5 login scenarios (valid, empty, invalid format, short, no consent)
  otp_tests.robot     — 5 OTP scenarios (valid, empty, short, wrong, resend-after-timer)

resources/       — Page Object keyword libraries (no variable imports — scope is shared by suite)
  LoginPage.robot     — Keywords + locators for / (login form)
  OTPPage.robot       — Keywords + locators for /verify (OTP form)

variables/
  variables.robot     — All variables: BASE_URL, timeouts, test data, browser settings

results/         — robot output (output.xml, log.html, report.html) — gitignore candidate
```

**Key pattern:** Each test file imports both resource files and the variables file. Resource files do NOT import variables — Robot Framework shares the variable scope from the suite, so resources access `${TIMEOUT}`, `${BASE_URL}`, etc. directly.

## UAT Constraints

- **Fixed OTP**: UAT uses OTP `9999` for all mobile numbers — no SMS dependency.
- **Rate limiting**: UAT allows ~3 `checkMobilePost` calls per ~60s per IP. The `Navigate To OTP Page` keyword in `otp_tests.robot` auto-detects rate limiting (OTP form not visible within `LONG_TIMEOUT`) and retries after `RATE_LIMIT_WAIT` (45s). OTP tests use distinct mobile numbers (`OTP_MOBILE_1`–`OTP_MOBILE_4`) to reduce collision.
- **Test order**: `Valid OTP Redirects To Dashboard` runs before `OTP Verification With Wrong OTP` because a prior failed `verifyOtpPost` call can trigger IP rate limiting that blocks the valid path.
- **UAT availability**: UAT is **down 9pm–9am**. Live tests must run between 7am–9pm.

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
| Wrong OTP | toast notification | assert URL still contains `/verify` (not the error element) |

## Routes

| Page | URL path |
|------|----------|
| Login | `/` |
| OTP verification | `/verify` |
| Dashboard (post-login) | `/my-applications` |
