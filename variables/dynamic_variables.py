"""
Dynamic variables generated once per robot execution (Python module cache).

APP_CREATION_MOBILE  — Fresh mobile for the Application Creation Flow wizard.
                       All wizard suites share this number within one run.
DASHBOARD_NEW_MOBILE — Fresh mobile for new-user dashboard tests (EMI empty
                       state, AD alert, PG empty state, Insurance plan selection).
                       Starts with '6' — new number generated on every run.

Each new robot invocation (new Python process) generates new numbers.
To override for a specific suite run:
    APP_CREATION_MOBILE=9876540001 ./venv/bin/robot tests/student_details_tests.robot
    DASHBOARD_NEW_MOBILE=8123456789 ./venv/bin/robot tests/dashboard_tests.robot
"""

import os
import time

_ts = int(time.time())

_env = os.environ.get('APP_CREATION_MOBILE', '').strip()
if _env:
    APP_CREATION_MOBILE = _env
else:
    # '9' + last 9 digits of epoch timestamp → valid 10-digit Indian mobile number
    APP_CREATION_MOBILE = '9' + str(_ts)[-9:]

_env_dash = os.environ.get('DASHBOARD_NEW_MOBILE', '').strip()
if _env_dash:
    DASHBOARD_NEW_MOBILE = _env_dash
else:
    # '8' + last 9 digits of epoch timestamp → fresh mobile each run, starts with 8
    DASHBOARD_NEW_MOBILE = '8' + str(_ts)[-9:]
