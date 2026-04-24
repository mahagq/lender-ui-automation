#!/bin/bash
# Record the "dashboard" flow via Playwright codegen.
# Covers: login → /my-applications → tab navigation (EMI/AD/PG/Insurance) → profile menu.
# Close the browser when done — the script is saved to recordings/

RECORDING_DIR="recordings"
FLOW="dashboard"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RECORDING_DIR}/${FLOW}_${TIMESTAMP}.js"
START_URL="https://customer.uat.graydev.in/"

mkdir -p "$RECORDING_DIR"

echo "Ensuring Playwright browsers are installed..."
npx --yes playwright install chromium

echo "Starting Playwright recorder..."
echo "Flow:   $FLOW"
echo "Target: $START_URL"
echo "Output: $OUTPUT_FILE"
echo ""
echo "A browser will open. Perform your actions, then close the browser to save."
echo "Tip: Log in as 8108556708 (OTP: 9999) — this account has active EMI applications."
echo "     Navigate the EMI / Auto Debit / Transaction History / Insurance tabs."
echo "---"

npx playwright codegen \
  --target javascript \
  --output "$OUTPUT_FILE" \
  "$START_URL"

if [ -f "$OUTPUT_FILE" ]; then
  echo ""
  echo "Recording saved to: $OUTPUT_FILE"
  echo "To replay headless:  node replay.js $OUTPUT_FILE"
  echo "To replay headed:    node replay-headed.js $OUTPUT_FILE"
  echo ""
  echo "Parameterize with env vars after recording:"
  echo "  MOBILE=8108556708 OTP=9999 node $OUTPUT_FILE"
else
  echo "No recording was saved."
fi
