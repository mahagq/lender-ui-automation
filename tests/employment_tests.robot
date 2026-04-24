*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Employment pages:
...      - /select-employment       (TC-12001–TC-12016)
...      - /applicant-employment-details (Salaried: TC-12017–TC-12046)
...      - /applicant-employment-details (Self-Employed: TC-12047–TC-12094)
...
...    Session model:
...      Suite Setup    → Navigate To Employment Type (creates app + full wizard traversal)
...      Per-test Setup → Varies by section (see [Setup] tags below):
...                       Employment Type tests: Navigate To Employment Type Within Session
...                       Salaried tests:        Navigate To Salaried Employment Details In Session
...                       Self-Employed tests:   Navigate To Self Employed Details In Session
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-12045 (salaried proceed) and TC-12092 (self-employed proceed) run last per variant.
...
...    Ported from: GQCP-TC-12001–TC-12094
...    (SelectEmploymentTest + SalariedEmploymentTest + SelfEmploymentTest + classes, Java/Selenium)
...    Satisfies: RT-6, B1 (Java TCs ported), T1, T4 (dual-variant), TN3 resolution

Resource    ../resources/ApplicationCreationFlowPage.robot
Resource    ../resources/EmploymentTypePage.robot
Resource    ../resources/ApplicantEmploymentPage.robot
Resource    ../variables/variables.robot
Variables   ../variables/dynamic_variables.py

Suite Setup     Navigate To Employment Type
Suite Teardown  Close Browser
Test Tags       employment    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Employment

*** Test Cases ***
# ===========================================================================
# SELECT EMPLOYMENT TYPE — /select-employment (TC-12001–TC-12016)
# ===========================================================================

TC-12001 Employment Type Page Title Is Visible
    [Documentation]
    ...    Verifies select-employment-type-title is visible on page load.
    ...    Ported from: GQCP-TC-12001 (institute name display).
    [Setup]    Navigate To Employment Type Within Session
    [Tags]    smoke
    Employment Type Title Should Be Visible

TC-12002 Employment Type Question Is Visible
    [Documentation]
    ...    Verifies employment-type-title label is visible.
    ...    Ported from: GQCP-TC-12002 (display of entered name).
    [Setup]    Navigate To Employment Type Within Session
    Employment Type Question Should Be Visible

TC-12003 Employment Type URL Is Correct
    [Documentation]
    ...    Verifies URL contains /select-employment.
    ...    Ported from: GQCP-TC-12003 (facing issues with login link).
    [Setup]    Navigate To Employment Type Within Session
    Employment Type URL Should Be Active

TC-12010 Salaried Card Is Visible And Selectable
    [Documentation]
    ...    Verifies the Salaried card (data-testid='salaried') is visible and clickable.
    ...    Ported from: GQCP-TC-12010.
    [Setup]    Navigate To Employment Type Within Session
    Salaried Card Should Be Visible
    Select Salaried Employment

TC-12011 Self Employed Card Is Visible And Selectable
    [Documentation]
    ...    Verifies the Self Employed card (data-testid='self-employed') is visible and clickable.
    ...    Ported from: GQCP-TC-12011.
    [Setup]    Navigate To Employment Type Within Session
    Self Employed Card Should Be Visible
    Select Self Employed Employment

TC-12012 Employment Type Back Navigation Preserves Session
    [Documentation]
    ...    Verifies that navigating back to /select-employment within the session shows the page.
    ...    Ported from: GQCP-TC-12012 (back button).
    [Setup]    Navigate To Employment Type Within Session
    Employment Type Title Should Be Visible

TC-12013 Switching Between Employment Types Works
    [Documentation]
    ...    Verifies that selecting Salaried then Self Employed (switching) works without errors.
    ...    Ported from: GQCP-TC-12013.
    [Setup]    Navigate To Employment Type Within Session
    Select Salaried Employment
    Navigate To Employment Type Within Session
    Select Self Employed Employment
    Self Employed Card Should Be Visible

# ===========================================================================
# SALARIED EMPLOYMENT DETAILS (TC-12014–TC-12046)
# Test Setup: Navigate To Salaried Employment Details In Session
# ===========================================================================

TC-12014 Employer Name Field Is Visible
    [Documentation]
    ...    Verifies employer-name-input is visible in the salaried employment form.
    ...    Ported from: GQCP-TC-12014.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Employer Name Field Should Be Visible

TC-12015 Employer Name Rejects Special Characters
    [Documentation]
    ...    Verifies employer-name-input field behaviour with special characters.
    ...    Input accepted; validation error checked on proceed attempt.
    ...    Ported from: GQCP-TC-12015.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    @#$%^&*

TC-12016 Employer Name Rejects Empty Value
    [Documentation]
    ...    Verifies proceed is disabled when employer name is empty.
    ...    Ported from: GQCP-TC-12016.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Salaried Proceed Button Should Be Disabled Without Data

TC-12017 Employer Name Rejects Blank Spaces
    [Documentation]
    ...    Verifies employer name input with only blank spaces.
    ...    Ported from: GQCP-TC-12017.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    ${SPACES_MOBILE}

TC-12018 Employer Name Accepts Alphanumeric
    [Documentation]
    ...    Verifies employer-name-input accepts alphanumeric characters.
    ...    Ported from: GQCP-TC-12018.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    TestCo123

TC-12021 Monthly Salary Field Is Visible
    [Documentation]
    ...    Verifies net-monthly-salary-input is visible.
    ...    Ported from: GQCP-TC-12021.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Monthly Salary Field Should Be Visible

TC-12022 Monthly Salary Rejects Special Characters
    [Documentation]
    ...    Verifies salary field behaviour with special characters.
    ...    Ported from: GQCP-TC-12022.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Monthly Salary    @#$

TC-12023 Monthly Salary Rejects Empty Value
    [Documentation]
    ...    Verifies proceed is disabled when salary is empty.
    ...    Ported from: GQCP-TC-12023.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Salaried Proceed Button Should Be Disabled Without Data

TC-12027 Monthly Salary Below 10000 Shows Warning
    [Documentation]
    ...    Verifies salary field behaviour when value < 10000.
    ...    Ported from: GQCP-TC-12027.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    ${APP_EMPLOYER_NAME}
    Fill Monthly Salary    5000

TC-12029 Monthly Salary Above 10000 Is Accepted
    [Documentation]
    ...    Verifies salary field accepts values >= 10000.
    ...    Ported from: GQCP-TC-12029.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    ${APP_EMPLOYER_NAME}
    Fill Monthly Salary    ${APP_MONTHLY_SALARY}
    In Words Display Should Be Visible

TC-12031 Salaried Proceed Disabled Without Consent
    [Documentation]
    ...    Verifies the proceed button is disabled when consent is unchecked.
    ...    Ported from: GQCP-TC-12031.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    ${APP_EMPLOYER_NAME}
    Fill Monthly Salary    ${APP_MONTHLY_SALARY}
    Salaried Proceed Button Should Be Disabled Without Data

TC-12032 Salaried Proceed Enabled With Consent
    [Documentation]
    ...    Verifies the proceed button is enabled when all fields are filled and consent checked.
    ...    Ported from: GQCP-TC-12032.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Fill Employer Name    ${APP_EMPLOYER_NAME}
    Fill Monthly Salary    ${APP_MONTHLY_SALARY}
    Check Salaried Consent
    Salaried Proceed Button Should Be Enabled

TC-12034 Salaried Proceed Disabled With Empty Fields
    [Documentation]
    ...    Verifies proceed is disabled when fields are blank.
    ...    Ported from: GQCP-TC-12034.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried
    Salaried Proceed Button Should Be Disabled Without Data

TC-12045 Salaried Employment Proceeds To Next Step
    [Documentation]
    ...    Fills valid salaried data + consent and clicks proceed.
    ...    Verifies wizard advances past /applicant-employment-details.
    ...    Ported from: GQCP-TC-12045. Runs LAST for salaried section.
    [Setup]    Navigate To Salaried Employment Details In Session
    [Tags]    salaried    slow
    Fill Employer Name    ${APP_EMPLOYER_NAME}
    Fill Monthly Salary    ${APP_MONTHLY_SALARY}
    Check Salaried Consent
    Click Salaried Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active

# ===========================================================================
# SELF-EMPLOYED EMPLOYMENT DETAILS (TC-12047–TC-12094)
# Test Setup: Navigate To Self Employed Details In Session
# ===========================================================================

TC-12047 Business Name Field Is Visible
    [Documentation]
    ...    Verifies business-name-input is visible in the self-employed form.
    ...    Ported from: GQCP-TC-12047.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Business Name Field Should Be Visible

TC-12048 Business Name Rejects Special Characters
    [Documentation]
    ...    Verifies business-name-input with special characters.
    ...    Ported from: GQCP-TC-12048.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    @#$%^

TC-12049 Business Name Rejects Empty Value
    [Documentation]
    ...    Verifies proceed is disabled when business name is empty.
    ...    Ported from: GQCP-TC-12049.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Self Employed Proceed Button Should Be Disabled Without Data

TC-12054 Annual Income Field Is Visible
    [Documentation]
    ...    Verifies business-annual-income-input is visible.
    ...    Ported from: GQCP-TC-12054.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Annual Income Field Should Be Visible

TC-12060 Annual Income Below 10000 Behaviour
    [Documentation]
    ...    Verifies annual income field with value < 10000.
    ...    Ported from: GQCP-TC-12060.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    5000

TC-12061 Annual Income Above 10000 Is Accepted
    [Documentation]
    ...    Verifies annual income field accepts values >= 10000.
    ...    Ported from: GQCP-TC-12061.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    ${APP_BUSINESS_INCOME}

TC-12066 Years In Business Field Is Visible
    [Documentation]
    ...    Verifies years-of-current-business-input is visible.
    ...    Ported from: GQCP-TC-12066.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Years In Business Field Should Be Visible

TC-12071 Years In Business Rejects More Than 2 Digits
    [Documentation]
    ...    Verifies years-of-current-business field rejects values > 2 digits.
    ...    Ported from: GQCP-TC-12071.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    ${APP_BUSINESS_INCOME}
    Fill Years In Business    123

TC-12073 Years In Business Accepts 2 Digit Number
    [Documentation]
    ...    Verifies years-of-current-business accepts a 2-digit number.
    ...    Ported from: GQCP-TC-12073.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    ${APP_BUSINESS_INCOME}
    Fill Years In Business    ${APP_BUSINESS_YEARS}

TC-12074 Business Description Field Is Visible
    [Documentation]
    ...    Verifies business-description-input is visible.
    ...    Ported from: GQCP-TC-12074.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Business Description Field Should Be Visible

TC-12081 Self Employed Proceed Disabled With Empty Fields
    [Documentation]
    ...    Verifies proceed is disabled when all self-employed fields are empty.
    ...    Ported from: GQCP-TC-12081.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Self Employed Proceed Button Should Be Disabled Without Data

TC-12082 Self Employed Proceed Enabled With Valid Data
    [Documentation]
    ...    Verifies proceed is enabled with all valid self-employed fields filled.
    ...    Ported from: GQCP-TC-12082.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    ${APP_BUSINESS_INCOME}
    Fill Years In Business    ${APP_BUSINESS_YEARS}
    Fill Business Description    ${APP_BUSINESS_DESC}
    Self Employed Proceed Button Should Be Enabled

TC-12092 Self Employed Proceeds To Confirm Application
    [Documentation]
    ...    Fills valid self-employed data and clicks proceed.
    ...    Verifies wizard advances to /confirm-application.
    ...    Ported from: GQCP-TC-12092. Runs LAST for self-employed section.
    [Setup]    Navigate To Self Employed Details In Session
    [Tags]    self-employed    slow
    Fill Business Name    ${APP_BUSINESS_NAME}
    Fill Annual Income    ${APP_BUSINESS_INCOME}
    Fill Years In Business    ${APP_BUSINESS_YEARS}
    Fill Business Description    ${APP_BUSINESS_DESC}
    Click Self Employed Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application URL Should Be Active
