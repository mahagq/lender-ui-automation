#!/bin/bash
# Record the "app-create" flow via Playwright codegen.
# Covers: login → Create New Application → student-details → choose-plan →
#         select-applicant → applicant wizard pages → confirm-application.
# Close the browser when done — the script is saved to recordings/

RECORDING_DIR="recordings"
FLOW="app-create"
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
echo "Tip: Use APP_CREATION_MOBILE 9876540001 (OTP: 9999)."
echo "     Complete the full wizard: student-details → choose-plan → select-applicant"
echo "     → applicant-basic-details → onboarding → personal-details →"
echo "     → residential-details → select-employment → employment-details → confirm-application."
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
  echo "  MOBILE=9876540001 OTP=9999 LOAN_AMOUNT=100000 node $OUTPUT_FILE"
else
  echo "No recording was saved."
fi
