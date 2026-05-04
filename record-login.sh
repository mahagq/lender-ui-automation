#!/bin/bash
# Record the "login" flow via Playwright codegen.
# Covers: login form (mobile number + consent) → Send OTP → OTP entry → dashboard.
# Close the browser when done — the script is saved to recordings/

RECORDING_DIR="recordings"
FLOW="login"
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
echo "Tip: Use mobile number 9876543210 (OTP: 9999) for a clean UAT login."
echo "---"

npx playwright codegen \
  --target javascript \
  --output "$OUTPUT_FILE" \
  "$START_URL"

if [ -f "$OUTPUT_FILE" ]; then
  echo ""
  echo "Recording saved to: $OUTPUT_FILE"

  DOCS_FILE="${RECORDING_DIR}/${FLOW}_${TIMESTAMP}_flow.md"
  echo "Generating flow documentation..."
  node scripts/generate-flow-docs.js "$OUTPUT_FILE" "$DOCS_FILE" "$FLOW"

  if [ -f "$DOCS_FILE" ]; then
    echo ""
    echo "───────────────────────────────────────────────────"
    echo "  Flow doc:  $DOCS_FILE"
    echo "  Recording: $OUTPUT_FILE"
    echo "───────────────────────────────────────────────────"
    echo ""
    echo "Next steps:"
    echo "  1. Review the flow doc: open $DOCS_FILE"
    echo "  2. Share the doc path with Claude to generate RF automation"
    echo "  3. Replay headless: node replay.js $OUTPUT_FILE"
    echo "  4. Replay headed:   node replay-headed.js $OUTPUT_FILE"
  else
    echo "Warning: doc generation failed — check scripts/generate-flow-docs.js"
    echo "To replay: node replay.js $OUTPUT_FILE"
  fi
else
  echo "No recording was saved."
fi
