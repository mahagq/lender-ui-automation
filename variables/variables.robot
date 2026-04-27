*** Variables ***
# Satisfies: B3 (UAT environment), S1 (no hardcoded credentials in test files), TN4 resolution

# Base URL — change this to switch environments without editing test files
${BASE_URL}               https://customer.uat.graydev.in

# Test mobile number — reads from TEST_MOBILE env var in CI, falls back to local default
# Any valid 10-digit number works in UAT (fixed OTP 9999 applies to all)
${TEST_MOBILE}            %{TEST_MOBILE=9876543210}

# Bypass auth mobile — must be registered for ERP bypass auth on UAT (bypassAuthPost).
# This is different from TEST_MOBILE: /instant-eligibility?m=<mobile> only redirects away
# if the mobile has been whitelisted for ERP tokenised access. Set BYPASS_AUTH_MOBILE env
# var in CI to the correct UAT ERP-registered mobile.
# PRECONDITION (TC-401): ${BYPASS_AUTH_MOBILE} must be a mobile registered for bypass auth
# on UAT. Using a general OTP test mobile will cause bypassAuthPost to fail and the page to
# stay on /instant-eligibility (no redirect) — making TC-401 fail.
${BYPASS_AUTH_MOBILE}     %{BYPASS_AUTH_MOBILE=9876543210}

# Per-test mobile numbers for OTP tests — each test uses a distinct number
${OTP_MOBILE_1}           9876543211
${OTP_MOBILE_2}           9876543212
${OTP_MOBILE_3}           9876543213
${OTP_MOBILE_4}           9876543214

# Rate limit recovery wait — UAT allows ~3 checkMobilePost calls per ~60s from the same IP.
# When the 4th call is rate-limited, the page stays on / with no error shown.
# Navigate To OTP Page detects this and sleeps before retrying.
${RATE_LIMIT_WAIT}        45s

# Fixed OTP configured in UAT for all mobile numbers (TN2 resolution)
${TEST_OTP}               9999

# Browser settings
${BROWSER}                chromium
${HEADLESS}               False

# Timeouts
${TIMEOUT}                10s
${LONG_TIMEOUT}           30s
${RESEND_OTP_WAIT}        185s

# Negative test data — invalid inputs for validation error tests
${INVALID_MOBILE}         12345
${WRONG_FORMAT_MOBILE}    123abc4567
${WRONG_OTP}              1234
${SHORT_OTP}              123

# Extended login test data (TC-208 to TC-213)
${SPACES_MOBILE}          ${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}${SPACE}
${ALPHA_MOBILE}           abcdefghij
${ALPHANUMERIC_MOBILE}    abc1234567
${SPECIAL_CHAR_MOBILE}    @#$%^&*()!
${LONG_MOBILE}            12345678901234

# Extended login test mobiles — for tests that navigate to OTP page
${EXT_LOGIN_MOBILE_1}     9876543215
${EXT_LOGIN_MOBILE_2}     9876543216

# Extended OTP test mobiles — one per test to avoid rate limiting
${EXT_OTP_MOBILE_1}       9876543217
${EXT_OTP_MOBILE_2}       9876543218
${EXT_OTP_MOBILE_3}       9876543219
${EXT_OTP_MOBILE_4}       9876543220
${EXT_OTP_MOBILE_5}       9876543221
${EXT_OTP_MOBILE_6}       9876543222
${EXT_OTP_MOBILE_7}       9876543223
${EXT_OTP_MOBILE_8}       9876543224
${EXT_OTP_MOBILE_9}       9876543225

# Dashboard suite mobile — used for Suite Setup login (TC-4001/TC-4011 EMI data).
# 8108556708 has active EMI applications so TC-4001 and TC-4011 pass without account switching.
# Distinct from all OTP_MOBILE_* and EXT_* numbers.
${DASHBOARD_MOBILE}       8108556708

# Insurance tab mobile — for dashboard_ins_tests.robot suite.
# 8668768645 has active insurance policies (Status: Issued + Status: Applied).
${INS_MOBILE}             8668768645

# Auto Payments tab mobile — Suite Setup account for dashboard_ad_tests.robot (independent suite).
# 8763694182 has multiple AD cards with active/pending repayment statuses and schedule data.
${AD_MOBILE}              8763694182

# PG account mobile — Suite Setup account for dashboard_pg_tests.robot (independent suite).
# 7757855472 has transaction records so TC-4030/TC-4031 (download buttons) pass.
${PG_MOBILE}              7757855472

# Create-application button scenario mobiles (TC-4034/TC-4035 in dashboard_tests.robot)
# TC-4034: runs under the already-logged-in DASHBOARD_MOBILE session — no Switch To Account.
# TC-4035: switches to NEW_USER_MOBILE which has no applications → empty-state button visible.
${EXISTING_USER_MOBILE}   8108556708
${NEW_USER_MOBILE}        9938383856

# Extended login test mobiles (TC-221+)
${EXT_LOGIN_MOBILE_3}     9876543227

# Extended OTP test mobiles (TC-314+)
${EXT_OTP_MOBILE_10}      9876543226

# Negative test data (TC-314)
${NON_NUMERIC_OTP}        abcd

# Application Creation Flow test data (RT-8, TN4 resolution)
# APP_CREATION_MOBILE is generated dynamically per run in variables/dynamic_variables.py.
# Wizard suites import that file via `Variables` to get a fresh mobile each execution.
# Existing application journey tests use ${EXISTING_USER_MOBILE}.

# Renewal Journey suite mobile — UAT account that already has at least one completed application.
# Used by all tests/renewal_journey_flow/ suites and renewal E2E.
${RENEWAL_MOBILE}         %{RENEWAL_MOBILE=8108556708}

# Resume Journey suite mobile — UAT account kept perpetually in-progress (application never submitted).
# Used by tests/e2e/resume_journey_e2e_tests.robot.
${RESUME_MOBILE}          %{RESUME_MOBILE=9876543210}

# Student details stub data (used by traversal helpers in Suite Setups)
${APP_STUDENT_FIRST_NAME}     Test
${APP_STUDENT_LAST_NAME}      Student
${APP_LOAN_AMOUNT}            100000
# Institute search term for async GILE institute dropdown (types this to trigger API search).
# Use a term that returns at least one result on UAT. Override via APP_INSTITUTE_SEARCH env var.
${APP_INSTITUTE_SEARCH}       %{APP_INSTITUTE_SEARCH=Sch}

# Applicant (parent/guardian) details
${APP_FIRST_NAME}             Test
${APP_LAST_NAME}              Parent
${APP_PAN_NUMBER}             DDDPD1621M
${APP_EMAIL}                  testparent@example.com

# Residential details
${APP_ADDRESS_LINE1}          123 Test Street
${APP_ADDRESS_LINE2}          Test Area
${APP_PINCODE}                400001

# Salaried employment details
${APP_EMPLOYER_NAME}          Test Company Pvt Ltd
${APP_MONTHLY_SALARY}         50000

# Self-employed details
${APP_BUSINESS_NAME}          Test Business
${APP_BUSINESS_INCOME}        600000
${APP_BUSINESS_YEARS}         05
${APP_BUSINESS_DESC}          Software consulting and services
