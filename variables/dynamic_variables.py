"""
Dynamic variables generated once per robot execution (Python module cache).

APP_CREATION_MOBILE  — Fresh mobile for the Application Creation Flow wizard.
                       Always generated from the epoch timestamp — no env override.
                       Static reuse would accumulate in-progress applications on the
                       account across runs, causing Playwright strict-mode failures.
                       All wizard suites share this number within one run.
DASHBOARD_NEW_MOBILE — Fresh mobile for new-user dashboard tests (EMI empty
                       state, AD alert, PG empty state, Insurance plan selection).
                       Starts with '8' — new number generated on every run.
LENDER_NR01_MOBILE   — Fresh mobile for bureau rejection test TC-LS-NR01.
LENDER_NR02_MOBILE   — Fresh mobile for bureau rejection test TC-LS-NR02.
LENDER_NR03_MOBILE   — Fresh mobile for bureau rejection test TC-LS-NR03.
LENDER_NR04_MOBILE   — Fresh mobile for bureau rejection test TC-LS-NR04 (plan 5, no banking → manual approval).
LENDER_NR05_MOBILE   — Fresh mobile for bureau rejection test TC-LS-NR05 (plan 4, all bureau ineligible → banking).
BANK_STATEMENT_MOBILE — Fresh mobile for bank_statement_tests.robot suite setup (plan 2 → bank-statement).

Each new robot invocation (new Python process) generates new numbers.
To override DASHBOARD_NEW_MOBILE for a specific suite run:
    DASHBOARD_NEW_MOBILE=8123456789 ./env/bin/robot tests/dashboard_tests.robot
"""

import os
import time

_ts = int(time.time())

# Always generated — env override intentionally not supported to prevent
# static reuse accumulating in-progress applications across runs.
APP_CREATION_MOBILE = '9' + str(_ts)[-9:]

_env_dash = os.environ.get('DASHBOARD_NEW_MOBILE', '').strip()
if _env_dash:
    DASHBOARD_NEW_MOBILE = _env_dash
else:
    # '8' + last 9 digits of epoch timestamp → fresh mobile each run, starts with 8
    DASHBOARD_NEW_MOBILE = '8' + str(_ts)[-9:]

# Unique mobiles for bureau lender rejection tests — each test owns a fresh application.
# Prefix '7' + subprefix 1/2/3 + last 8 digits of timestamp → 10-digit numbers, all unique per run.
LENDER_NR01_MOBILE = '71' + str(_ts)[-8:]
LENDER_NR02_MOBILE = '72' + str(_ts)[-8:]
LENDER_NR03_MOBILE = '73' + str(_ts)[-8:]
LENDER_NR04_MOBILE = '74' + str(_ts)[-8:]
LENDER_NR05_MOBILE = '75' + str(_ts)[-8:]
BANK_STATEMENT_MOBILE = '76' + str(_ts)[-8:]
