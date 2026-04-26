*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Employment Details page (/applicant-employment-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    This file covers BOTH employment detail variants on the same URL (/applicant-employment-details):
...      - Salaried: employer name, net monthly salary, consent, in-words display, proceed
...      - Self-Employed: business name, annual income, years in business, business description, proceed
...    The form rendered depends on the selection made on /select-employment.
...    Pattern mirrors DashboardPage.robot (single resource, multiple variant sections).
...
...    Session model:
...      Suite Setup   → Navigate To Employment Type (ApplicationCreationFlowPage.robot)
...      Per-variant setup → Navigate To Salaried/Self Employed Details In Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    Ported from: GQCP-TC-12017–12046 (salaried), TC-12047–12094 (self-employed)
...    Satisfies: RT-6 (employment detail keywords + locators, both variants),
...    T1 (data-testid locators only), T4 (dual-variant coverage), TN3 resolution,
...    B1 (all enabled Java TCs ported)

Library     Browser

*** Variables ***
# --- SALARIED EMPLOYMENT DETAILS ---
${SED_WORK_TITLE}               css=[data-testid='work-title']
${SED_EMPLOYER_NAME}            css=[data-testid='employer-name-input']
${SED_SALARY_INPUT}             css=[data-testid='net-monthly-salary-input']
${SED_IN_WORDS}                 css=[data-testid='in-words']
${SED_CONSENT}                  css=[data-testid='consent-checkbox']
${SED_CONSENT_ERROR}            css=[data-testid='consent-checkbox-error']
${SED_NOTE}                     css=[data-testid='employment-details-note']
${SED_PROCEED_BUTTON}           css=[data-testid='proceed-button']
${SED_EMPLOYER_ERROR}           css=[data-testid='employer-name-input-error']
${SED_SALARY_ERROR}             css=[data-testid='net-monthly-salary-input-error']

# --- SELF-EMPLOYED DETAILS ---
${SE_BUSINESS_NAME_TITLE}       css=[data-testid='business-name-title']
${SE_BUSINESS_NAME}             css=[data-testid='business-name-input']
${SE_ANNUAL_INCOME}             css=[data-testid='business-annual-income-input']
${SE_YEARS}                     css=[data-testid='years-of-current-business-input']
${SE_DESCRIPTION}               css=[data-testid='business-description-input']
${SE_INFO}                      css=[data-testid='info']
${SE_PROCEED_BUTTON}            css=[data-testid='proceed-button']
${SE_BUSINESS_NAME_ERROR}       css=[data-testid='business-name-input-error']
${SE_ANNUAL_INCOME_ERROR}       css=[data-testid='business-annual-income-input-error']
${SE_YEARS_ERROR}               css=[data-testid='years-of-current-business-input-error']

*** Keywords ***
# =====================================================================
# SALARIED EMPLOYMENT KEYWORDS (TC-12017 to TC-12046)
# =====================================================================

Employer Name Field Should Be Visible
    [Documentation]
    ...    Asserts the employer-name-input field is visible in the salaried form.
    ...    Satisfies: TC-12014, TC-12017, U1
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}

Fill Employer Name
    [Documentation]
    ...    Fills the employer-name-input field.
    ...    Satisfies: TC-12014, TC-12017–12020
    [Arguments]    ${value}
    Wait For Elements State    ${SED_EMPLOYER_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_EMPLOYER_NAME}    ${value}

Monthly Salary Field Should Be Visible
    [Documentation]
    ...    Asserts the net-monthly-salary-input field is visible.
    ...    Satisfies: TC-12021, U1
    Wait For Elements State    ${SED_SALARY_INPUT}    visible    timeout=${TIMEOUT}

Fill Monthly Salary
    [Documentation]
    ...    Fills the net-monthly-salary-input field.
    ...    Satisfies: TC-12021–12030
    [Arguments]    ${value}
    Wait For Elements State    ${SED_SALARY_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${SED_SALARY_INPUT}    ${value}

In Words Display Should Be Visible
    [Documentation]
    ...    Asserts the in-words salary display element is visible after salary entry.
    ...    Satisfies: TC-12021, U3
    Wait For Elements State    ${SED_IN_WORDS}    visible    timeout=${TIMEOUT}

Salaried Consent Should Be Visible
    [Documentation]
    ...    Asserts the consent-checkbox is visible on the salaried employment form.
    ...    Satisfies: TC-12031, TC-12032, U1
    Wait For Elements State    ${SED_CONSENT}    visible    timeout=${TIMEOUT}

Check Salaried Consent
    [Documentation]
    ...    Checks the consent-checkbox if not already checked.
    ...    Satisfies: TC-12032
    ${checked}=    Get Property    ${SED_CONSENT}    checked
    IF    not ${checked}
        Click    ${SED_CONSENT}
    END

Salaried Proceed Button Should Be Disabled Without Data
    [Documentation]
    ...    Asserts the proceed-button is disabled when required salaried fields are empty.
    ...    Satisfies: TC-12034, U2
    Wait For Elements State    ${SED_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SED_PROCEED_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Salaried proceed button should be disabled with empty fields.

Salaried Proceed Button Should Be Enabled
    [Documentation]
    ...    Asserts the proceed-button is enabled with valid salaried employment data.
    ...    Satisfies: TC-12035, U2
    Wait For Elements State    ${SED_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SED_PROCEED_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Salaried proceed button should be enabled with valid data and consent checked.

Click Salaried Proceed
    [Documentation]
    ...    Clicks proceed on the salaried employment form to advance the wizard.
    ...    Satisfies: TC-12035, TC-12045, RT-6 (proceed)
    Wait For Elements State    ${SED_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SED_PROCEED_BUTTON}

# =====================================================================
# SELF-EMPLOYED KEYWORDS (TC-12047 to TC-12094)
# =====================================================================

Business Name Field Should Be Visible
    [Documentation]
    ...    Asserts the business-name-input field is visible in the self-employed form.
    ...    Satisfies: TC-12047, TC-12054, U1
    Wait For Elements State    ${SE_BUSINESS_NAME}    visible    timeout=${TIMEOUT}

Fill Business Name
    [Documentation]
    ...    Fills the business-name-input field.
    ...    Satisfies: TC-12047–12053
    [Arguments]    ${value}
    Wait For Elements State    ${SE_BUSINESS_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SE_BUSINESS_NAME}    ${value}

Annual Income Field Should Be Visible
    [Documentation]
    ...    Asserts the business-annual-income-input field is visible.
    ...    Satisfies: TC-12054, U1
    Wait For Elements State    ${SE_ANNUAL_INCOME}    visible    timeout=${TIMEOUT}

Fill Annual Income
    [Documentation]
    ...    Fills the business-annual-income-input field.
    ...    Satisfies: TC-12054–12065
    [Arguments]    ${value}
    Wait For Elements State    ${SE_ANNUAL_INCOME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SE_ANNUAL_INCOME}    ${value}

Years In Business Field Should Be Visible
    [Documentation]
    ...    Asserts the years-of-current-business-input field is visible.
    ...    Satisfies: TC-12066, U1
    Wait For Elements State    ${SE_YEARS}    visible    timeout=${TIMEOUT}

Fill Years In Business
    [Documentation]
    ...    Fills the years-of-current-business-input field. Max 2 digits (TC-12071).
    ...    Satisfies: TC-12066–12073
    [Arguments]    ${value}
    Wait For Elements State    ${SE_YEARS}    visible    timeout=${TIMEOUT}
    Fill Text    ${SE_YEARS}    ${value}

Business Description Field Should Be Visible
    [Documentation]
    ...    Asserts the business-description-input field is visible.
    ...    Satisfies: TC-12074, U1
    Wait For Elements State    ${SE_DESCRIPTION}    visible    timeout=${TIMEOUT}

Fill Business Description
    [Documentation]
    ...    Fills the business-description-input field.
    ...    Satisfies: TC-12074–12080
    [Arguments]    ${value}
    Wait For Elements State    ${SE_DESCRIPTION}    visible    timeout=${TIMEOUT}
    Fill Text    ${SE_DESCRIPTION}    ${value}

Self Employed Proceed Button Should Be Disabled Without Data
    [Documentation]
    ...    Asserts the proceed-button is disabled when required self-employed fields are empty.
    ...    Satisfies: TC-12081, U2
    Wait For Elements State    ${SE_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SE_PROCEED_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Self-employed proceed button should be disabled with empty fields.

Self Employed Proceed Button Should Be Enabled
    [Documentation]
    ...    Asserts the proceed-button is enabled with valid self-employed data.
    ...    Satisfies: TC-12082, U2
    Wait For Elements State    ${SE_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SE_PROCEED_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Self-employed proceed button should be enabled with valid data.

Click Self Employed Proceed
    [Documentation]
    ...    Clicks proceed on the self-employed form to advance the wizard.
    ...    Satisfies: TC-12082, TC-12092, RT-6 (proceed)
    Wait For Elements State    ${SE_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SE_PROCEED_BUTTON}

Employment Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-employment-details.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-employment-details

# =====================================================================
# SALARIED VALIDATION KEYWORDS
# =====================================================================

Employer Name Error Should Be Visible
    [Documentation]
    ...    Asserts employer-name-input-error is visible after proceed with invalid/empty employer name.
    ...    Satisfies: TC-12N-S01, TC-12N-S02
    Wait For Elements State    ${SED_EMPLOYER_ERROR}    visible    timeout=${TIMEOUT}

Monthly Salary Error Should Be Visible
    [Documentation]
    ...    Asserts net-monthly-salary-input-error is visible after proceed with invalid/empty salary.
    ...    Satisfies: TC-12N-S03, TC-12N-S04, TC-12N-S05
    Wait For Elements State    ${SED_SALARY_ERROR}    visible    timeout=${TIMEOUT}

Salaried Consent Error Should Be Visible
    [Documentation]
    ...    Asserts consent-checkbox-error is visible after proceed without consent.
    ...    Satisfies: TC-12N-S06
    Wait For Elements State    ${SED_CONSENT_ERROR}    visible    timeout=${TIMEOUT}

Uncheck Salaried Consent
    [Documentation]    Unchecks the salaried consent-checkbox if currently checked.
    ${checked}=    Get Property    ${SED_CONSENT}    checked
    IF    ${checked}
        Click    ${SED_CONSENT}
    END

# =====================================================================
# SELF-EMPLOYED VALIDATION KEYWORDS
# =====================================================================

Business Name Error Should Be Visible
    [Documentation]
    ...    Asserts business-name-input-error is visible after proceed with invalid/empty business name.
    ...    Satisfies: TC-12N-SE01, TC-12N-SE02
    Wait For Elements State    ${SE_BUSINESS_NAME_ERROR}    visible    timeout=${TIMEOUT}

Annual Income Error Should Be Visible
    [Documentation]
    ...    Asserts business-annual-income-input-error is visible after proceed with invalid/empty income.
    ...    Satisfies: TC-12N-SE03, TC-12N-SE04
    Wait For Elements State    ${SE_ANNUAL_INCOME_ERROR}    visible    timeout=${TIMEOUT}

Years In Business Error Should Be Visible
    [Documentation]
    ...    Asserts years-of-current-business-input-error is visible after proceed with invalid/empty years.
    ...    Satisfies: TC-12N-SE05, TC-12N-SE06
    Wait For Elements State    ${SE_YEARS_ERROR}    visible    timeout=${TIMEOUT}
