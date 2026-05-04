*** Settings ***
Documentation
...    Renewal Journey — Verify Details screen.
...    Reached after clicking "CONTINUE WITH THESE DETAILS" on the Welcome Back screen.
...    Shows pre-filled residential and employment details from the previous application.
...    Supports: viewing, editing residential section, editing employment section
...    (type selection → salaried or self-employed sub-form), and confirming to submit.
...
...    Employment edit flow:
...      Edit Details (nth=1) → Employment Type Selection (salaried / self-employed cards)
...        → Click Salaried → Salaried form (employer-name, net-monthly-salary) → SUBMIT / BACK
...        → Click Self-Employed → SE form (business fields) → SUBMIT / BACK
...        → BACK on type selection → Verify Details
...
...    Session model:
...      Suite Setup    → Navigate To Verify Details Via Renewal (login once, create one application, land on /renewal-details)
...      Test Setup     → Navigate To Verify Details Within Session (Go To /renewal-details — same app, no re-login)
...      Suite Teardown → Close Browser
...
...    TC-VD09 runs 2nd-to-last — submits the shared application.
...    TC-VD25 runs LAST with [Setup] Navigate To Verify Details New Application Within Session
...    (creates one fresh application within the existing browser session, no re-login).

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/WelcomeBackPage.robot
Resource    ../../resources/VerifyDetailsPage.robot
Resource    ../../resources/ConfirmApplicationPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Verify Details Via Renewal
Suite Teardown  Close Browser
Test Setup      Navigate To Verify Details Within Session
Test Tags       renewal    verify-details    renewal-journey-flow    allure.label.epic:CP UI Automation    allure.label.feature:Renewal Journey Flow    allure.label.story:Verify Details

*** Test Cases ***
# ── Visibility ──────────────────────────────────────────────────────────────────

TC-VD01 Verify Details Page Is Visible
    [Tags]    smoke
    Verify Details Page Should Be Visible

TC-VD28 Verify Details URL Is Correct
    Verify Details URL Should Be Active

TC-VD02 Residential Section Title And Address Are Visible
    Residential Section Should Be Visible

TC-VD03 Residential Edit Details Button Is Visible
    Residential Edit Button Should Be Visible

TC-VD29 Employment Section Is Visible
    Employment Section Should Be Visible

TC-VD04 Employment Type Selection Has Salaried And Self-Employed Options
    [Documentation]    Opens employment type selection and verifies both options are present.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

TC-VD05 Employment Edit Details Button Is Visible
    Employment Edit Button Should Be Visible

# ── Edit Employment — Type Selection Navigation ──────────────────────────────────

TC-VD07 Select Salaried Then Back Returns To Employment Type Selection
    [Tags]    edit-employment
    [Documentation]    Selects Salaried option then clicks BACK — should return to type selection screen.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Salaried Option
    Salaried Fields Should Be Visible
    Click Back From Edit
    Employment Type Selection Should Be Visible

TC-VD08 Select Self Employed Then Back Returns To Employment Type Selection
    [Tags]    edit-employment
    [Documentation]    Selects Self-Employed option then clicks BACK — should return to type selection screen.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Click Back From Edit
    Employment Type Selection Should Be Visible

# ── Edit Residential ────────────────────────────────────────────────────────────

TC-VD10 Edit Residential Opens Address Fields
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible

TC-VD11 Edit Address Line 1 And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Residence Type Radio In Edit Form
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD12 Edit Residence Type Radio And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Residence Type Radio In Edit Form
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD13 Empty Address Line 1 Shows Error And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${EMPTY}
    Submit Residential Edit
    Verify Details Address Line 1 Error Should Be Visible

TC-VD14 Invalid Pincode In Edit Form Shows Error
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Text    css=[data-testid='pincode-input']    abcdef
    Submit Residential Edit
    Verify Details Pincode Error Should Be Visible

TC-VD26 Select Self Owned Residence Type And Submit Updates Value
    [Tags]    edit-residential
    [Documentation]    Selects Self Owned residence type and submits — residential section should reload.
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Self Owned Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD27 Select Other Residence Type And Submit Updates Value
    [Tags]    edit-residential
    [Documentation]    Selects Other residence type and submits — residential section should reload.
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Other Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD15 Back From Residential Edit Returns To Verify Details
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

# ── Edit Employment — Salaried Sub-form ─────────────────────────────────────────

TC-VD16 Salaried Employment Edit Fill And Submit Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    Opens salaried form, fills employer name + salary, submits — lands back on Verify Details.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    ${APP_MONTHLY_SALARY}
    Submit Employment Edit
    Verify Details Page Should Be Visible

TC-VD18 Salaried Empty Form Shows Employer Name Error
    [Tags]    edit-employment    negative
    [Documentation]    Submits salaried form without filling any fields — employer name error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Submit Employment Edit
    Employer Name Error Should Be Visible In VD

TC-VD19 Alphabets In Monthly Salary Show Salary Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills salary with alphabets — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    abcdef
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD23 Back From Salaried Fields Returns To Employment Type Selection
    [Tags]    edit-employment
    [Documentation]    Opens salaried form then clicks BACK — should return to employment type selection.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Click Back From Edit
    Employment Type Selection Should Be Visible

TC-VD30 Full Back Chain From Salaried Form Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    Salaried form → BACK → type selection → BACK → Verify Details (chained back navigation).
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Salaried Option
    Salaried Fields Should Be Visible
    Click Back From Edit
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

TC-VD33 Salaried Employer Name Filled Empty Salary Shows Salary Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills employer name only, leaves salary empty — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

# ── Edit Employment — Self-Employed Sub-form ─────────────────────────────────────

TC-VD17 Self Employed Employment Edit Fill And Submit Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    Opens SE form, fills all business fields, submits — lands back on Verify Details.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Submit Employment Edit
    Verify Details Page Should Be Visible

TC-VD20 Self Employed Empty Form Shows Business Name Error
    [Tags]    edit-employment    negative
    [Documentation]    Submits SE form without filling any fields — business name error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Submit Employment Edit
    Business Name Error Should Be Visible In VD

TC-VD21 Alphabets In Annual Income Show Income Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills annual income with alphabets — business-annual-income-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name    ${APP_BUSINESS_NAME}
    Fill VD Annual Income    abcdef
    Submit Employment Edit
    Annual Income Error Should Be Visible In VD

TC-VD22 Back From Employment Type Selection Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    Opens employment type selection then clicks BACK — should return to Verify Details.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

TC-VD31 Full Back Chain From Self Employed Form Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    SE form → BACK → type selection → BACK → Verify Details (chained back navigation).
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Click Back From Edit
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

TC-VD32 SE Alphabets In Years Of Business Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills years in business with alphabets — years-of-current-business-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Years In Business       abcdef
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD

# ── Proceed ─────────────────────────────────────────────────────────────────────

TC-VD34 Confirm Application Page Visible After Clicking Confirm And Proceed
    [Documentation]    Clicking CONFIRM AND PROCEED navigates to /confirm-application with consent checkbox visible.
    Click Confirm And Proceed Without Consent
    Confirm Application Page Should Be Visible

TC-VD35 Proceed Button Enabled After Checking Consent On Confirm Application
    [Documentation]    On /confirm-application, checking consent enables the PROCEED button.
    Click Confirm And Proceed Without Consent
    Confirm Application Proceed Button Should Be Enabled With Consent

TC-VD24 Confirm And Proceed Without Consent Proceed Button Is Disabled
    [Tags]    negative
    [Documentation]    Clicks CONFIRM AND PROCEED, lands on /confirm-application, verifies PROCEED is disabled without consent.
    Click Confirm And Proceed Without Consent
    Verify Details Consent Error Should Be Visible

TC-VD09 Confirm And Proceed Without Employment Edit Submits Application
    [Documentation]    Confirms directly without editing employment — verifies successful submission.
    ...    Runs 2nd-to-last: submits the shared application leaving it in a terminal state.
    Click Confirm And Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully

TC-VD25 Confirm And Proceed With Consent Submits Application
    [Setup]    Navigate To Verify Details New Application Within Session
    [Documentation]    Confirms with consent after creating a fresh application within the same session.
    ...    Runs LAST — TC-VD09 submitted the shared app, so this test needs its own fresh application.
    Click Confirm And Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully
