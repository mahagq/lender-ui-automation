#!/bin/bash
# Record a browser session using Playwright codegen against the GQ Customer Portal UAT.
# Open the browser, perform your actions, then close it — the script is saved to recordings/

RECORDING_DIR="recordings"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILE="${RECORDING_DIR}/session_${TIMESTAMP}.js"

mkdir -p "$RECORDING_DIR"

echo "Ensuring Playwright browsers are installed..."
npx --yes playwright install chromium

echo "Starting Playwright recorder..."
echo "Target: https://customer.uat.graydev.in/"
echo "Output: $OUTPUT_FILE"
echo ""
echo "A browser will open. Perform your actions, then close the browser to save."
echo "---"

npx playwright codegen \
  --target javascript \
  --output "$OUTPUT_FILE" \
  "https://customer.uat.graydev.in/"

if [ -f "$OUTPUT_FILE" ]; then
  echo ""
  echo "Recording saved to: $OUTPUT_FILE"
  echo "To replay headless:  node replay.js $OUTPUT_FILE"
  echo "To replay headed:    node replay-headed.js $OUTPUT_FILE"
else
  echo "No recording was saved."
fi
