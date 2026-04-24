"""
Dynamic variables for the Application Creation Flow wizard suites.

APP_CREATION_MOBILE is generated once per robot execution using the current
timestamp, so every run gets a fresh mobile number with no existing applications.

Because Python caches imported modules, all wizard suites within a single
robot invocation share the same generated number (module is loaded once).
Each new robot invocation (new Python process) generates a new number.

To override (e.g. when running a single suite manually to resume a journey):
    APP_CREATION_MOBILE=9876540001 ./venv/bin/robot tests/student_details_tests.robot
"""

import os
import time

_env = os.environ.get('APP_CREATION_MOBILE', '').strip()
if _env:
    APP_CREATION_MOBILE = _env
else:
    # '9' + last 9 digits of epoch timestamp → valid 10-digit Indian mobile number
    APP_CREATION_MOBILE = '9' + str(int(time.time()))[-9:]
