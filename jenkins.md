# Jenkins Pipeline — cp_ui_automation

## Overview

Jenkins pipeline for the GQ Customer Portal UI Automation suite.
Runs Robot Framework + Playwright tests against UAT across **17 suite files** (~250 tests),
generates an Allure report, uploads it to S3, and preserves history for trend graphs across builds.

| Suite File | Tests | Account |
|------------|-------|---------|
| login_left_component_tests | 9 | TEST_MOBILE |
| login_tests | 23 | OTP_MOBILE_* / EXT_* |
| otp_tests | 18 (3 skipped) | OTP_MOBILE_* / EXT_* |
| bypass_auth_tests | 4 (3 skipped) | TEST_MOBILE |
| dashboard_tests | 11 (2 skipped) | DASHBOARD_MOBILE → NEW_USER_MOBILE |
| dashboard_emi_tests | 5 | DASHBOARD_MOBILE |
| dashboard_ad_tests | 10 | AD_MOBILE |
| dashboard_pg_tests | 21 | PG_MOBILE |
| dashboard_new_user_tests | 4 | DASHBOARD_NEW_MOBILE |
| dashboard_ins_tests | 11 | INS_MOBILE |
| dashboard_ins_new_user_tests | 4 | DASHBOARD_NEW_MOBILE |
| student_details_tests | 35 | APP_CREATION_MOBILE |
| choose_plan_tests | 16 | APP_CREATION_MOBILE |
| select_applicant_tests | 10 | APP_CREATION_MOBILE |
| applicant_journey_tests | 27 | APP_CREATION_MOBILE |
| employment_tests | 30 | APP_CREATION_MOBILE |
| confirm_application_tests | 12 | APP_CREATION_MOBILE |

---

## How it works — Step by Step

```
Developer pushes code to GitHub (master branch)
            │
            ▼
   Jenkins triggered manually
   (Build with Parameters)
            │
            ▼
┌─────────────────────────────┐
│  Select Parameters          │
│  ┌──────────┐ ┌──────────┐  │
│  │   ENV    │ │ HEADLESS │  │
│  │──────────│ │──────────│  │
│  │  UAT     │ │ true     │  │
│  └──────────┘ └──────────┘  │
└─────────────────────────────┘
            │
            ▼
   Runs tests/ (excludes slow/resend)
```

---

## Stage 1 — Workspace Cleanup
```
- Removes old results/ folder from previous run
- Creates fresh results/allure-results/ directory
- Sets permissions (chmod 777) so Docker can write to them
```

## Stage 2 — Checkout SCM
```
- Pulls latest code from GitHub
- Branch: master
- Repo: grayquest-finance/customer_portal_ui_automation
- Credentials: Jenkins 'github' credential
```

## Stage 3 — Restore Allure History
```
- Downloads previous build history from S3:
  s3://gq-qa-reports/allure-history/cp_ui_automation/UAT/
- Placed into results/allure-results/history/
- Powers the TREND graph in Allure (pass/fail trend across builds)
```

## Stage 4 — Build Docker Image
```
- Image name: cp-ui-automation:playwright
- If image already exists → skips build
- If not found → builds from Dockerfile
- Image contains: Python, Node.js, uv, Robot Framework, Playwright, Allure CLI
```

## Stage 5 — Run Tests [CP UI] [UAT]
```
Step 5a — Write Allure config files (on Jenkins host, before Docker):
  ├── results/allure-results/categories.json   → Product Defects / Infra Defects / Skipped
  ├── results/allure-results/allure.properties → enables behaviors, suites, packages, graph plugins
  ├── results/allure-results/executor.json     → records build name, number, Jenkins URL
  └── results/allure-results/environment.properties → static fallback env widget values

Step 5b — Run Docker container (workspace volume-mounted as /app):
  ├── uv sync --group dev          → installs Python deps (robotframework, allure-robotframework)
  ├── rfbrowser init --with-deps   → installs Playwright + Chromium
  ├── uv run robot                 → executes test suite
  │     --variable HEADLESS:True/False
  │     --name 'CP UI Automation [UAT]'
  │     --exclude slow              → skips resend/slow tests
  │     --listener allure_robotframework         → captures results as allure JSON
  │     --listener allure_env_listener.py        → writes environment.properties dynamically
  │     -d results
  │     tests/
  │
  └── allure generate              → converts allure JSON → full HTML report
        results/allure-results → results/allure-report
```

## Stage 6 — Upload & Save History
```
- Uploads full report to S3:
  s3://gq-qa-reports/automation-reports/cp_ui_automation/UAT/{date}/build-{N}_{time}/allure-report/

  Example:
  automation-reports/cp_ui_automation/UAT/2026-04-20/build-5_14-30-00/allure-report/

- Each build gets its own folder → historical reports never overwritten

- Saves history back to S3 for next build's trend graph:
  s3://gq-qa-reports/allure-history/cp_ui_automation/UAT/
```

## Finally — Google Chat Notification
```
- Sends build status to Google Chat webhook
- Message includes: Status, Job name, Build number, Env, Console URL
- Fires on both SUCCESS and FAILURE
- Credential: 'webhook-qa-test-env'
```

---

## Full Flow Diagram

```
[Jenkins — Build with Parameters]
        │
        ├─ ENV=UAT
        └─ HEADLESS=true
                │
    ┌───────────┴────────────────────────────────────┐
    │  Stage 1: Cleanup workspace                    │
    │  Stage 2: Git checkout master branch           │
    │  Stage 3: Restore history from S3              │
    │  Stage 4: Docker image check/build             │
    │  Stage 5: Docker run                           │
    │    ├── uv sync + rfbrowser init                │
    │    ├── robot (tests/ --exclude slow)           │
    │    │     └── allure listener → JSON results    │
    │    │     └── env listener   → env.properties   │
    │    └── allure generate → HTML report           │
    │  Stage 6: Upload report → S3                  │
    │           Save history  → S3                  │
    └───────────────────────────────────────────────┘
                │
                ▼
    S3 Report URL:
    s3://gq-qa-reports/automation-reports/
      cp_ui_automation/UAT/
      2026-04-20/build-5_14-30-00/allure-report/
                │
                ▼
    Google Chat → "SUCCESS: customer_portal_ui_automation [UAT] #5"
```

---

## S3 Bucket Structure

```
gq-qa-reports/
│
├── automation-reports/
│    └── cp_ui_automation/
│         └── UAT/
│              └── 2026-04-20/
│                   └── build-5_14-30-00/
│                        └── allure-report/
│
└── allure-history/
     └── cp_ui_automation/
          └── UAT/
               ├── history.json
               ├── categories-trend.json
               ├── duration-trend.json
               ├── history-trend.json
               └── retry-trend.json
```

---

## Allure Report Structure

| Tab | Content |
|-----|---------|
| **Overview** | Summary stats, trend graph, suite pass/fail blocks |
| **Behaviors** | Epic: CP UI Automation → Feature: Authentication → Story: Login Left Component / Login / OTP Verification / Bypass Authentication; Feature: Dashboard → Story: Dashboard / Auto Debit / Payment Gateway / New User Empty States / Insurance Tab; Feature: Application Creation Flow → Story: Student Details / Choose Plan / Select Applicant / Applicant Journey / Employment / Confirm Application |
| **Suites** | CP UI Automation [UAT] → Login Left Component Tests / Login Tests / Otp Tests / Bypass Auth Tests / Dashboard Tests / Dashboard Emi Tests / Dashboard Ad Tests / Dashboard Pg Tests / Dashboard New User Tests / Dashboard Ins Tests / Dashboard Ins New User Tests / Student Details Tests / Choose Plan Tests / Select Applicant Tests / Applicant Journey Tests / Employment Tests / Confirm Application Tests |
| **Categories** | Product Defects / Test Infrastructure Defects / Skipped Tests |
| **Timeline** | Tests plotted by execution time |

**Environment widget (top-right on Overview):**
```
Environment        = UAT
Application        = GrayQuest Customer Portal
Build.Number       = 5
Branch             = master
Target.URL         = https://customer.uat.graydev.in
Test.Run.Timestamp = 20-Apr-2026 14:30:00 IST
```

---

## Running Tests Locally with Allure

### Prerequisites
```bash
pip install allure-robotframework
# Allure CLI: https://allurereport.org/docs/install/
```

### Run + Generate Report
```bash
robot \
  --variable HEADLESS:False \
  --name 'CP UI Automation [UAT]' \
  --exclude slow \
  --listener 'allure_robotframework:./results/allure-results' \
  --listener 'resources/allure_env_listener.py' \
  -d results \
  tests/

allure generate results/allure-results --clean -o results/allure-report
allure open results/allure-report
```

---

## Jenkins Prerequisites

| Requirement | Detail |
|-------------|--------|
| Jenkins Node | `GQ_QA_Automation_Node` must be online |
| Credential | `github` — GitHub personal access token |
| Credential | `uat-ssh-key` — SSH key for node access |
| Credential | `webhook-qa-test-env` — Google Chat webhook URL |
| AWS CLI | Installed on node with S3 write access to `gq-qa-reports` |
| Docker | Installed on node, ubuntu user in docker group |
| Allure CLI | Inside Docker image `cp-ui-automation:playwright` |
| Env Var | `BYPASS_AUTH_MOBILE` — UAT mobile registered for ERP bypass auth (bypassAuthPost). TC-401 is currently tagged `robot:skip` — general OTP test accounts are not ERP-whitelisted. To enable: set this var to an ERP-whitelisted UAT mobile and remove `robot:skip`. |
| Env Var | `APP_INSTITUTE_SEARCH` — search term used to trigger the async GILE institute dropdown API in Application Creation Flow suite setups. Defaults to `Sch`. Override if UAT data changes and `Sch` returns no results. |
