"""
Allure Environment Listener - GQ Customer Portal UI Automation
Module-style Robot Framework listener (no class wrapper).
Writes environment.properties dynamically on first suite start.
Environment is always UAT for this project.
"""
import os
from datetime import datetime

ROBOT_LISTENER_API_VERSION = 2

_written = False


def start_suite(name, attrs):
    global _written
    if _written:
        return
    _written = True

    now = datetime.now()
    exec_date = now.strftime('%Y-%m-%d')
    timestamp = now.strftime('%d-%b-%Y %H:%M:%S') + ' IST'
    build_number = os.environ.get('BUILD_NUMBER', 'local')
    branch = os.environ.get('GIT_BRANCH', os.environ.get('BRANCH_NAME', 'master'))
    branch = branch.replace('origin/', '')

    allure_results_dir = 'results/allure-results'
    content = (
        f'Environment=UAT\n'
        f'Application=GrayQuest Customer Portal\n'
        f'Build.Number={build_number}\n'
        f'Branch={branch}\n'
        f'Execution.Date={exec_date}\n'
        f'Test.Run.Timestamp={timestamp}\n'
        f'Test.Framework=Robot Framework\n'
        f'Browser=Chromium (Playwright)\n'
        f'Operating.System=Linux\n'
        f'Target.URL=https://customer.uat.graydev.in\n'
    )

    os.makedirs(allure_results_dir, exist_ok=True)
    env_file = os.path.join(allure_results_dir, 'environment.properties')
    with open(env_file, 'w') as f:
        f.write(content)
    print(f'\n[AllureEnvListener] Environment=UAT | {timestamp} → {env_file}')


def end_suite(name, attrs):
    pass


def start_test(name, attrs):
    pass


def end_test(name, attrs):
    pass


def log_message(message):
    pass
