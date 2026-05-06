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

TC-VD02 Verify Details URL Is Correct
    Verify Details URL Should Be Active

TC-VD03 Residential Section Title And Address Are Visible
    Residential Section Should Be Visible

TC-VD04 Verify Details Info Banner About Current Address Is Visible With Correct Text
    Verify Residential Info Banner Text

TC-VD05 Residential Edit Details Button Is Visible
    Residential Edit Button Should Be Visible

TC-VD06 Employment Section Is Visible
    Employment Section Should Be Visible

TC-VD07 Employment Edit Details Button Is Visible
    Employment Edit Button Should Be Visible  

TC-VD08 Verify Details Info Banner About Current Employment Details Is Visible With Correct Text
    Verify Employment Info Banner Text      

# ── Edit Residential ────────────────────────────────────────────────────────────

TC-VD09 Edit Residential Button is Clickable
    [Tags]    edit-residential
    Click Edit Residential Details

TC-VD10 Edit Residential Button Click Shows Edit Form With Title
    [Tags]    edit-residential
    Click Edit Residential Details
    Current Address Title Should Be Visible

TC-VD11 Edit Residential Button Click Shows Edit Form With Residence Type Title
    [Tags]    edit-residential
    Click Edit Residential Details
    Residence Type Title Should Be Visible

TC-VD12 Edit Address Line 1 And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Residence Type Radio In Edit Form
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD13 Edit Address Line 2 And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 2    ${APP_ADDRESS_LINE2}
    Click Residence Type Radio In Edit Form
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD14 Edit pincode And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Text    css=[data-testid='pincode-input']    400029
    Click Residence Type Radio In Edit Form
    Submit Residential Edit
    Residential Section Should Be Visible   

TC-VD15 Edit Residence Type Radio And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Self Owned Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD16 Empty Address Line 1 Shows Error And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${EMPTY}
    Submit Residential Edit
    Verify Details Address Line 1 Error Should Be Visible

TC-VD17 Empty Address Line 2 Shows Error And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 2    ${EMPTY}
    Submit Residential Edit
    Verify Details Address Line 2 Error Should Be Visible    

TC-VD18 Invalid Pincode In Edit Form Shows Error
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Text    css=[data-testid='pincode-input']    abcdef
    Submit Residential Edit
    Verify Details Pincode Error Should Be Visible

TC-VD19 Empty Pincode Shows Error And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Text    css=[data-testid='pincode-input']    ${EMPTY}
    Submit Residential Edit
    Verify Details Pincode Error Should Be Visible

TC-VD20 All Empty Fields Show Errors And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${EMPTY}
    Fill Verify Details Address Line 2    ${EMPTY}
    Fill Text    css=[data-testid='pincode-input']    ${EMPTY}
    Submit Residential Edit
    Verify Details Address Line 1 Error Should Be Visible
    Verify Details Address Line 2 Error Should Be Visible
    Verify Details Pincode Error Should Be Visible

TC-VD21 Select Self Owned Residence Type And Submit Updates Value
    [Tags]    edit-residential
    [Documentation]    Selects Self Owned residence type and submits — residential section should reload.
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Self Owned Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD22 Select Other Residence Type And Submit Updates Value
    [Tags]    edit-residential
    [Documentation]    Selects Other residence type and submits — residential section should reload.
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Other Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible

TC-VD23 Back From Residential Edit Returns To Verify Details
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

TC-VD24 Edit Residential Then Back Then Edit Again Returns To Edit Form
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible
    Click Edit Residential Details
    Residential Edit Form Should Be Visible

TC-VD25 Edit All Residential Fields and Submit Then Edit Again Shows Updated Values
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ESSAR HOUSE NO-11 K K MARG MAHALAXMI
    Fill Verify Details Address Line 2    MAHALAXMI
    Fill Text    css=[data-testid='pincode-input']    400034
    Click Self Owned Residence Type
    Submit Residential Edit
    Residential Section Should Be Visible
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Address Line 1 Field Should Have Value    ESSAR HOUSE NO-11 K K MARG MAHALAXMI
    Address Line 2 Field Should Have Value    MAHALAXMI
    Pincode Field Should Have Value           400034

# ── Edit Employment — Type Selection Navigation ──────────────────────────────────

TC-VD26 Edit Employment Button is Clickable
    [Tags]    edit-employment
    Click Edit Employment Details

TC-VD27 Edit Employment type button title visible
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Title Should Be Visible

TC-VD28 Edit Employment Button Click Shows Employment Type Selection
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible

TC-VD29 Employment Type Selection Shows Previously Selected Option
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Previously Selected Employment Type Should Be Indicated    

TC-VD30 Employment Type Selection Shows Both Salaried And Self-Employed Options
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Wait For Elements State    ${VD_SALARIED_CARD}       visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VD_SELF_EMPLOYED_CARD}  visible    timeout=${TIMEOUT}

TC-VD31 Click Back From Employment Type Selection Returns To Verify Details
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible    

TC-VD32 Click Back From Employment Type Selection Then Edit Again Returns To Type Selection
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible
    Click Edit Employment Details
    Employment Type Selection Should Be Visible    

TC-VD33 Select Salaried Then Back Returns To Employment Details Section
    [Tags]    edit-employment
    [Documentation]    Selects Salaried option then clicks BACK — should return to type selection screen.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Salaried Option
    Salaried Fields Should Be Visible
    Click Back From Edit
    Employment Section Should Be Visible

TC-VD34 Select Self Employed Then Back Returns To Employment Details Section
    [Tags]    edit-employment
    [Documentation]    Selects Self-Employed option then clicks BACK — should return to type selection screen.
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Click Back From Edit
    Employment Section Should Be Visible

# ── Edit Employment — Salaried Sub-form ─────────────────────────────────────────

TC-VD35 Salaried Employment Edit Fill And Submit Returns To Verify Details
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

TC-VD36 Salaried Empty Form Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Submits salaried form without filling any fields — employer name error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${EMPTY}
    Fill VD Monthly Salary    ${EMPTY}
    Submit Employment Edit
    Employer Name Error Should Be Visible In VD
    Monthly Salary Error Should Be Visible In VD

TC-VD37 Alphabets In Monthly Salary Show Salary Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills salary with alphabets — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    abcdef
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD38 Salaried Employer Name Filled Empty Salary Shows Salary Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills employer name only, leaves salary empty — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    ${EMPTY}
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD39 Zero Monthly Salary Shows Salary Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills salary with 0 — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    0
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD40 Negative Salary Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills salary with a negative number — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    -50000
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD41 Decimal Salary Validation
    [Tags]    edit-employment    negative
    [Documentation]    Fills salary with a decimal number — net-monthly-salary-input-error expected.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    ${APP_EMPLOYER_NAME}
    Fill VD Monthly Salary    50000.50
    Submit Employment Edit
    Monthly Salary Error Should Be Visible In VD

TC-VD42 Edit all Salaried Fields and Submit Then Edit Again Shows Updated Values
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Salaried Option
    Salaried Fields Should Be Visible
    Fill VD Employer Name    New Employer Pvt Ltd
    Fill VD Monthly Salary    120000
    Submit Employment Edit
    Verify Details Page Should Be Visible
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Employer Name Field Should Have Value    New Employer Pvt Ltd
    Monthly Salary Field Should Have Value   120000

TC-VD43 Full Back Chain From Salaried Form Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    Opens salaried form then clicks BACK — should return to Verify Details.
    Click Edit Employment Details
    Click Salaried Option
    Salaried Fields Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

# ── Edit Employment — Self-Employed Sub-form ─────────────────────────────────────

TC-VD44 Self Employed Employment Edit Fill And Submit Returns To Verify Details
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

TC-VD45 Self Employed Empty Form Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Submits SE form without filling any fields — business name error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${EMPTY}
    Fill VD Annual Income           ${EMPTY}
    Fill VD Years In Business       ${EMPTY}
    Fill VD Business Description    ${EMPTY}
    Submit Employment Edit
    Business Name Error Should Be Visible In VD

TC-VD46 Alphabets In Annual Income Show Income Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills annual income with alphabets — business-annual-income-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Annual Income    abcdef
    Submit Employment Edit
    Annual Income Error Should Be Visible In VD

TC-VD47 Alphabets In Years In Business Show Years Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills years in business with alphabets — years-in-business-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Years In Business   abcdef
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD

TC-VD48 Zero Years In Business Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills years in business with 0 — years-in-business-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Years In Business   0
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD

TC-VD49 Negative Years In Business Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills years in business with a negative number — years-in-business-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Years In Business   -5
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD

TC-VD50 Decimal Years In Business Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills years in business with a decimal number — years-in-business-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Years In Business   5.5
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD

TC-VD51 Zero Annual Income Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills annual income with 0 — business-annual-income-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Annual Income   0
    Submit Employment Edit
    Annual Income Error Should Be Visible In VD

TC-VD52 Negative Annual Income Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills annual income with a negative number — business-annual-income-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Annual Income   -50000
    Submit Employment Edit
    Annual Income Error Should Be Visible In VD

TC-VD53 Decimal Annual Income Shows Error
    [Tags]    edit-employment    negative
    [Documentation]    Fills annual income with a decimal number — business-annual-income-input-error expected.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Annual Income   50000.50
    Submit Employment Edit
    Annual Income Error Should Be Visible In VD

TC-VD54 Only Business Name Filled Shows Remaining Errors
    [Tags]    edit-employment    negative
    [Documentation]    Fills only the business name — other fields should show errors.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           ${APP_BUSINESS_NAME}
    Fill VD Annual Income           ${EMPTY}
    Fill VD Years In Business       ${EMPTY}
    Fill VD Business Description    ${EMPTY}
    Submit Employment Edit
    Years In Business Error Should Be Visible In VD
    Annual Income Error Should Be Visible In VD
    Business Description Error Should Be Visible In VD

TC-VD55 Only Annual Income Filled Shows Remaining Errors
    [Tags]    edit-employment    negative
    [Documentation]    Fills only the annual income — other fields should show errors.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Annual Income           ${APP_BUSINESS_INCOME}
    Fill VD Business Name           ${EMPTY}
    Fill VD Years In Business       ${EMPTY}
    Fill VD Business Description    ${EMPTY}
    Submit Employment Edit
    Business Name Error Should Be Visible In VD
    Years In Business Error Should Be Visible In VD
    Business Description Error Should Be Visible In VD

TC-VD56 Only Years In Business Filled Shows Remaining Errors
    [Tags]    edit-employment    negative
    [Documentation]    Fills only the years in business — other fields should show errors.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Years In Business       ${APP_BUSINESS_YEARS}
    Fill VD Annual Income           ${EMPTY}
    Fill VD Business Name           ${EMPTY}
    Fill VD Business Description    ${EMPTY}
    Submit Employment Edit
    Business Name Error Should Be Visible In VD
    Annual Income Error Should Be Visible In VD
    Business Description Error Should Be Visible In VD

TC-VD57 Only Business Description Filled Shows Remaining Errors
    [Tags]    edit-employment    negative
    [Documentation]    Fills only the business description — other fields should show errors.
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Description    ${APP_BUSINESS_DESC}
    Fill VD Annual Income           ${EMPTY}
    Fill VD Years In Business       ${EMPTY}
    Fill VD Business Name           ${EMPTY}
    Submit Employment Edit
    Business Name Error Should Be Visible In VD
    Annual Income Error Should Be Visible In VD
    Years In Business Error Should Be Visible In VD

TC-VD58 Edit all Self-Employed Fields and Submit Returns To Verify Details
    [Tags]    edit-employment
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

TC-VD59 Edit all Self-Employed Fields and Submit Then Edit Again Shows Updated Values
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Fill VD Business Name           New Business
    Fill VD Annual Income           8000000
    Fill VD Years In Business       10
    Fill VD Business Description    New business description
    Submit Employment Edit
    Verify Details Page Should Be Visible
    Click Edit Employment Details
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Business Name Field Should Have Value       New Business
    Annual Income Field Should Have Value       8000000
    Years In Business Field Should Have Value   10
    Business Description Field Should Have Value     New business description


TC-VD60 Full Back Chain From Self Employed Form Returns To Verify Details
    [Tags]    edit-employment
    [Documentation]    SE form → type selection → BACK → Verify Details (chained back navigation).
    Click Edit Employment Details
    Employment Type Selection Should Be Visible
    Click Self Employed Option
    Self Employed Fields Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

# ── Proceed ─────────────────────────────────────────────────────────────────────

TC-VD61 Confirm Application Page Visible After Clicking Confirm And Proceed
    [Documentation]    Clicking CONFIRM AND PROCEED navigates to /confirm-application with consent checkbox visible.
    Click Confirm And Proceed Without Consent
    Skip Referral Code Popup
    Confirm Application Page Should Be Visible

TC-VD62 Confirm And Proceed With Consent Submits Application
    [Setup]    Navigate To Verify Details New Application Within Session
    [Documentation]    Confirms with consent after creating a fresh application within the same session.
    ...    Runs LAST — TC-VD61 submitted the shared app, so this test needs its own fresh application.
    Click Confirm And Proceed Without Consent
    Skip Referral Code Popup
    Check Confirm Application Consent
    Proceed Button Should Be Enabled With Consent
    Click Confirm Application Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully
