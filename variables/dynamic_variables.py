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

Each new robot invocation (new Python process) generates new numbers.
To override DASHBOARD_NEW_MOBILE for a specific suite run:
    DASHBOARD_NEW_MOBILE=8123456789 ./venv/bin/robot tests/dashboard_tests.robot
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
