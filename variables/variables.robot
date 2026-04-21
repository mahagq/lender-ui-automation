*** Variables ***
# Satisfies: B3 (UAT environment), S1 (no hardcoded credentials in test files), TN4 resolution

# Base URL — change this to switch environments without editing test files
${BASE_URL}               https://customer.uat.graydev.in

# Test mobile number — reads from TEST_MOBILE env var in CI, falls back to local default
# Any valid 10-digit number works in UAT (fixed OTP 9999 applies to all)
${TEST_MOBILE}            %{TEST_MOBILE=9876543210}

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

# PG account mobile — for TC-4030/TC-4031 which need transaction records.
# Switch To Account is called in TC-4030 body (runs ~3 min after Suite Setup,
# so rate limits are cleared before the second authentication attempt).
${PG_MOBILE}              7757855472
