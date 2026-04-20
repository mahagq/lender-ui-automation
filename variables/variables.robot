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
${HEADLESS}               True

# Timeouts
${TIMEOUT}                10s
${LONG_TIMEOUT}           30s
${RESEND_OTP_WAIT}        185s

# Negative test data — invalid inputs for validation error tests
${INVALID_MOBILE}         12345
${WRONG_FORMAT_MOBILE}    123abc4567
${WRONG_OTP}              1234
${SHORT_OTP}              123
