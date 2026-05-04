#!/usr/bin/env node
/**
 * Parses a Playwright codegen recording and produces:
 *   1. recordings/<flow>_<timestamp>_flow.md — steps + test plan + test cases
 *
 * Usage: node scripts/generate-flow-docs.js <recording.js> <output.md> [flow-name]
 */

const fs = require('fs');
const path = require('path');

const [,, inputFile, outputFile, flowName] = process.argv;

if (!inputFile || !outputFile) {
  console.error('Usage: node scripts/generate-flow-docs.js <recording.js> <output.md> [flow-name]');
  process.exit(1);
}

if (!fs.existsSync(inputFile)) {
  console.error(`Recording not found: ${inputFile}`);
  process.exit(1);
}

const content = fs.readFileSync(inputFile, 'utf8');
const flow = flowName || path.basename(inputFile, '.js');
const timestamp = new Date().toISOString().replace('T', ' ').slice(0, 19);

// ─── Testid → readable label map (from CLAUDE.md locator table) ─────────────
const TESTID_LABELS = {
  'mobile-number-input':               'Mobile number input',
  'mobile-number-input-error':         'Mobile number error',
  'consent-checkbox':                  'Consent checkbox',
  'consent-checkbox-error':            'Consent error',
  'send-otp-button':                   'Send OTP button',
  'otp-input':                         'OTP input',
  'otp-input-error':                   'OTP input error',
  'verify-otp-button':                 'Verify OTP button',
  'resend-otp-link':                   'Resend OTP link',
  'dashboard-title':                   'Dashboard title',
  'profile-button':                    'Profile button',
  'emi-tab-navigation-button':         'EMI tab',
  'pg-tab-navigation-button':          'PG tab',
  'ins-tab-navigation-button':         'Insurance tab',
  'filter-button':                     'Filter button',
  'proceed-button':                    'Proceed button',
  'addr-line-1-input':                 'Address line 1 input',
  'pincode-input':                     'Pincode input',
  'salaried':                          'Salaried card',
  'self-employed':                     'Self-employed card',
  'employer-name-input':               'Employer name input',
  'net-monthly-salary-input':          'Monthly salary input',
  'business-name-input':               'Business name input',
  'business-annual-income-input':      'Annual income input',
  'years-of-current-business-input':   'Years in business input',
};

// ─── URL → page name map ─────────────────────────────────────────────────────
const URL_LABELS = {
  '/':                               'Login page',
  '/verify':                         'OTP verification page',
  '/my-applications':                'Dashboard page',
  '/student-details':                'Student Details page',
  '/choose-plan':                    'Choose Plan page',
  '/select-applicant':               'Select Applicant page',
  '/applicant-basic-details':        'Applicant Basic Details page',
  '/onboarding':                     'Onboarding page',
  '/applicant-personal-details':     'Personal Details page',
  '/applicant-residential-details':  'Residential Details page',
  '/select-employment':              'Employment Type page',
  '/applicant-employment-details':   'Employment Details page',
  '/confirm-application':            'Confirm Application page',
  '/renewal-confirmation':           'Welcome Back page',
  '/renewal-details':                'Verify Details page',
  '/faq':                            'FAQ page',
  '/instant-eligibility':            'Bypass Auth page',
};

function pageLabel(url) {
  try {
    const u = new URL(url);
    const pathname = u.pathname.replace(/\/$/, '') || '/';
    return URL_LABELS[pathname] || pathname;
  } catch {
    return url;
  }
}

function testidLabel(id) {
  return TESTID_LABELS[id] || id;
}

// ─── Action parser ───────────────────────────────────────────────────────────
function parseActions(src) {
  const lines = src.split('\n');
  const actions = [];

  for (const raw of lines) {
    const line = raw.trim();
    if (!line.startsWith('await ')) continue;

    // Navigation
    let m = line.match(/page\.goto\(['"`]([^'"`]+)['"`]\)/);
    if (m) { actions.push({ type: 'navigate', url: m[1], label: pageLabel(m[1]) }); continue; }

    // getByTestId chained with another getByTestId (nested)
    m = line.match(/getByTestId\(['"`]([^'"`]+)['"`]\)\.getByTestId\(['"`]([^'"`]+)['"`]\)\.(click|fill|check|uncheck)\((['"`]?)([^'"`]*)['"`]?\)/);
    if (m) {
      const [,outer, inner, act,, val] = m;
      const desc = `${testidLabel(outer)} → ${testidLabel(inner)}`;
      actions.push({ type: act, selector: `[data-testid="${outer}"] [data-testid="${inner}"]`, label: desc, value: val || null });
      continue;
    }

    // getByTestId → action
    m = line.match(/getByTestId\(['"`]([^'"`]+)['"`]\)\.(click|fill|check|uncheck|type|press)\((['"`]?)([^'"`]*)['"`]?\)/);
    if (m) {
      const [, id, act,, val] = m;
      actions.push({ type: act, selector: `[data-testid="${id}"]`, label: testidLabel(id), value: val || null });
      continue;
    }

    // getByRole
    m = line.match(/getByRole\(['"`]([^'"`]+)['"`](?:,\s*\{[^}]*name:\s*['"`]([^'"`]+)['"`][^}]*\})?\)\.(click|fill|check)\(/);
    if (m) {
      const [, role, name, act] = m;
      const label = name ? `${role.charAt(0).toUpperCase() + role.slice(1)} "${name}"` : `${role}`;
      actions.push({ type: act, label, selector: name ? `role=${role}[name="${name}"]` : `role=${role}`, value: null });
      continue;
    }

    // getByText
    m = line.match(/getByText\(['"`]([^'"`]+)['"`]\)\.(click|fill)\(/);
    if (m) {
      const [, text, act] = m;
      actions.push({ type: act, label: `Text "${text}"`, selector: `text=${text}`, value: null });
      continue;
    }

    // getByLabel
    m = line.match(/getByLabel\(['"`]([^'"`]+)['"`]\)\.(click|fill|check)\((['"`]?)([^'"`]*)['"`]?\)/);
    if (m) {
      const [, label, act,, val] = m;
      actions.push({ type: act, label: `Label "${label}"`, selector: `label=${label}`, value: val || null });
      continue;
    }

    // expect URL
    m = line.match(/expect\(page\)\.toHaveURL\(['"`]([^'"`]+)['"`]\)/);
    if (m) { actions.push({ type: 'assertUrl', label: pageLabel(m[1]), url: m[1] }); continue; }

    // expect visible
    m = line.match(/expect\(page\.(?:locator|getByTestId|getByRole|getByText)\(['"`]([^'"`]+)['"`]\)\)\.toBeVisible\(\)/);
    if (m) { actions.push({ type: 'assertVisible', label: m[1] }); continue; }
  }

  return actions;
}

// ─── Step renderer ───────────────────────────────────────────────────────────
function actionToStep(a, n) {
  switch (a.type) {
    case 'navigate':
      return `${n}. **Navigate** to ${a.label} (\`${a.url}\`)`;
    case 'click':
      return `${n}. **Click** ${a.label}`;
    case 'fill':
    case 'type':
      return `${n}. **Fill** ${a.label}${a.value ? ` with \`"${a.value}"\`` : ''}`;
    case 'check':
      return `${n}. **Check** ${a.label}`;
    case 'uncheck':
      return `${n}. **Uncheck** ${a.label}`;
    case 'press':
      return `${n}. **Press** \`${a.value}\` on ${a.label}`;
    case 'assertUrl':
      return `${n}. **Verify** current page is ${a.label}`;
    case 'assertVisible':
      return `${n}. **Verify** element \`${a.label}\` is visible`;
    default:
      return `${n}. ${a.type} ${a.label}`;
  }
}

// ─── Detect which pages/elements were touched ────────────────────────────────
function detect(actions) {
  const touched = new Set(actions.map(a => a.label));
  const urls    = actions.filter(a => a.type === 'navigate').map(a => a.url);
  const filled  = actions.filter(a => a.type === 'fill' || a.type === 'type');
  const clicked = actions.filter(a => a.type === 'click');

  return { touched, urls, filled, clicked };
}

// ─── Test case generator ─────────────────────────────────────────────────────
function buildTestCases(actions, flow) {
  const { touched, urls, filled } = detect(actions);
  const rows = [];
  let tcId = 1;

  const pages = [...new Set(urls.map(u => {
    try { return new URL(u).pathname.replace(/\/$/, '') || '/'; } catch { return u; }
  }))];

  // Happy path (always)
  const stepSummary = actions
    .filter(a => ['navigate','click','fill','check'].includes(a.type))
    .slice(0, 6)
    .map(a => {
      switch (a.type) {
        case 'navigate': return pageLabel(a.url);
        case 'click':    return `Click ${a.label}`;
        case 'fill':     return `Fill ${a.label}`;
        case 'check':    return `Check ${a.label}`;
        default:         return a.label;
      }
    }).join(' → ');

  rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Happy path — complete ${flow} flow | ${stepSummary} | User reaches expected page successfully | smoke |`);

  // Field-level negatives for each filled element
  for (const f of filled) {
    rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Empty ${f.label} — show validation error | Leave ${f.label} blank, submit | Validation error displayed under ${f.label} | validation |`);
    if (f.selector && f.selector.includes('mobile')) {
      rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Invalid format in ${f.label} | Enter non-numeric or < 10 digits | "Please enter valid mobile number" error | validation |`);
    }
    if (f.selector && f.selector.includes('otp')) {
      rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Short OTP (< 4 digits) | Enter 1–3 digits in OTP input | "OTP number must contain 4 digits" error | validation |`);
      rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Non-numeric OTP | Enter letters in OTP input | "Only numeric values allowed" error | validation |`);
      rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Wrong OTP — stay on verify page | Enter 1234 (incorrect) | URL stays on /verify; "Incorrect OTP" toast | negative |`);
    }
  }

  // Consent / checkbox
  if (touched.has('Consent checkbox')) {
    rows.push(`| TC-${String(tcId++).padStart(3,'0')} | No consent — block OTP send | Leave consent unchecked, tap Send OTP | "Please accept Terms and Conditions" error | validation |`);
  }

  // Resend OTP — detect via OTP elements (SPA navigation, no goto)
  const hasOtpPage = touched.has('OTP input') || touched.has('Verify OTP button');
  if (hasOtpPage) {
    rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Resend OTP link visible after 180s | Wait for countdown to expire | Resend OTP link appears and is clickable | otp |`);
  }

  // Navigation back/forward
  if (pages.length > 1) {
    rows.push(`| TC-${String(tcId++).padStart(3,'0')} | Back navigation — preserve state | Navigate back from page 2 to page 1 | Previous page loads; entered data retained | navigation |`);
  }

  return rows;
}

// ─── Infer pages from element interactions (for JS-navigated pages) ──────────
// Playwright codegen doesn't emit page.goto for SPA route changes.
// Map known testids to the page they live on.
const ELEMENT_TO_PATH = {
  'otp-input':                         '/verify',
  'otp-input-error':                   '/verify',
  'verify-otp-button':                 '/verify',
  'resend-otp-link':                   '/verify',
  'dashboard-title':                   '/my-applications',
  'profile-button':                    '/my-applications',
  'emi-tab-navigation-button':         '/my-applications',
  'pg-tab-navigation-button':          '/my-applications',
  'ins-tab-navigation-button':         '/my-applications',
  'filter-button':                     '/my-applications',
  'addr-line-1-input':                 '/renewal-details',
  'salaried':                          '/renewal-details',
  'self-employed':                     '/renewal-details',
  'employer-name-input':               '/renewal-details',
  'net-monthly-salary-input':          '/renewal-details',
  'business-name-input':               '/renewal-details',
  'business-annual-income-input':      '/renewal-details',
  'years-of-current-business-input':   '/renewal-details',
};

function inferPagesFromElements(actions) {
  const inferred = new Set();
  for (const a of actions) {
    if (!a.selector) continue;
    const m = a.selector.match(/data-testid="([^"]+)"/);
    if (m && ELEMENT_TO_PATH[m[1]]) inferred.add(ELEMENT_TO_PATH[m[1]]);
  }
  return inferred;
}

// ─── Scope detector ──────────────────────────────────────────────────────────
function buildScope(actions) {
  const gotoPaths = actions.filter(a => a.type === 'navigate').map(a => pageLabel(a.url));
  const inferredPaths = [...inferPagesFromElements(actions)].map(p => URL_LABELS[p] || p);
  const pages = [...new Set([...gotoPaths, ...inferredPaths])];

  const components = [...new Set(
    actions.filter(a => a.type !== 'navigate' && a.type !== 'assertUrl').map(a => a.label)
  )].slice(0, 12);

  return { pages, components };
}

// ─── Main ────────────────────────────────────────────────────────────────────
const actions = parseActions(content);

if (actions.length === 0) {
  console.error('No recognizable actions found in recording. Is this a valid Playwright codegen output?');
  process.exit(1);
}

const { pages, components } = buildScope(actions);
const testCaseRows = buildTestCases(actions, flow);

const stepLines = actions
  .map((a, i) => actionToStep(a, i + 1))
  .join('\n');

// Map pages visited to resource files
const RESOURCE_MAP = {
  '/':                               'resources/LoginPage.robot',
  '/verify':                         'resources/OTPPage.robot',
  '/my-applications':                'resources/DashboardPage.robot',
  '/student-details':                'resources/StudentDetailsPage.robot',
  '/choose-plan':                    'resources/ChoosePlanPage.robot',
  '/select-applicant':               'resources/SelectApplicantPage.robot',
  '/applicant-basic-details':        'resources/ApplicantBasicDetailsPage.robot',
  '/onboarding':                     'resources/OnboardingPage.robot',
  '/applicant-personal-details':     'resources/ApplicantPersonalDetailsPage.robot',
  '/applicant-residential-details':  'resources/ApplicantResidentialDetailsPage.robot',
  '/select-employment':              'resources/EmploymentTypePage.robot',
  '/applicant-employment-details':   'resources/ApplicantEmploymentPage.robot',
  '/confirm-application':            'resources/ConfirmApplicationPage.robot',
  '/renewal-confirmation':           'resources/WelcomeBackPage.robot',
  '/renewal-details':                'resources/VerifyDetailsPage.robot',
};

const gotoPaths = actions.filter(a => a.type === 'navigate').map(a => {
  try { return new URL(a.url).pathname.replace(/\/$/, '') || '/'; } catch { return '/'; }
});
const visitedPaths = [...new Set([...gotoPaths, ...inferPagesFromElements(actions)])];

const resourceFiles = visitedPaths
  .filter(p => RESOURCE_MAP[p])
  .map(p => `- \`${RESOURCE_MAP[p]}\``)
  .join('\n');

const md = `# ${flow.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')} Flow — Documentation

**Generated:** ${timestamp}
**Recording:** \`${path.basename(inputFile)}\`
**Base URL:** \`https://customer.uat.graydev.in\`

---

## Flow Steps

${stepLines}

---

## Pages Visited

${pages.map(p => `- ${p}`).join('\n')}

---

## Test Plan

### Objective
Verify the **${flow}** user journey functions correctly end-to-end, covering all interactive elements, validation rules, and navigation paths recorded.

### Scope

**Pages covered:**
${pages.map(p => `- ${p}`).join('\n')}

**Components exercised:**
${components.map(c => `- ${c}`).join('\n')}

### Test Strategy

| Strategy | Description |
|----------|-------------|
| Happy path | All valid inputs, expected flow from start to end |
| Negative / Validation | Empty required fields, invalid format, wrong values |
| Boundary conditions | Min/max input lengths, edge values |
| Navigation | Back/forward, direct URL access |
| Session | Rate-limiting, OTP expiry, session persistence |

### Prerequisites

- UAT environment accessible (7am–9pm IST)
- Fixed OTP: \`9999\` (works for all UAT mobile numbers)
- Test mobile: any 10-digit number registered on UAT
- Browser: Chromium (Playwright Browser Library)

### Out of Scope

- API-level testing (covered by backend test suite)
- Performance testing
- Mobile responsiveness (Browser library default viewport)

---

## Test Cases

| TC ID | Description | Steps | Expected Result | Tag |
|-------|-------------|-------|-----------------|-----|
${testCaseRows.join('\n')}

---

## Automation Notes

### Resource files to import

${resourceFiles || '- `resources/LoginPage.robot`\n- `resources/OTPPage.robot`'}

### Variables file

- \`variables/variables.robot\` — \`\${BASE_URL}\`, \`\${TIMEOUT}\`, \`\${LONG_TIMEOUT}\`, test mobile numbers

### Session model

- Suite Setup: open browser, navigate to start URL
- Test Setup: hard-navigate to relevant page (reset state without new login where possible)
- Test Teardown: NONE (shared session)
- Suite Teardown: Close Browser

### Key locators used

${[...new Set(actions.filter(a => a.selector).map(a => {
  const sel = a.selector;
  let display;
  if (sel.startsWith('[data-testid=')) {
    display = `css=${sel}`;
  } else if (sel.startsWith('role=')) {
    display = sel;
  } else if (sel.startsWith('text=')) {
    display = sel;
  } else if (sel.startsWith('label=')) {
    display = sel;
  } else {
    display = sel;
  }
  return `- \`${display}\` → ${a.label}`;
}))].join('\n') || '_(derived from recording)_'}

---

> **Next step:** Share this file with Claude Code to generate Robot Framework test suite files.
`;

fs.writeFileSync(outputFile, md, 'utf8');
console.log(`Flow doc: ${outputFile}`);
