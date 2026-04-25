*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Select Applicant Type page (/select-applicant).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Session model:
...      Suite Setup   → Navigate To Select Applicant (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Select Applicant Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-7008 (select + proceed) must run last — it advances the wizard.
...
...    Ported from: GQCP-TC-7001 to TC-7011 (WhoisApplyingGrayQuestEducationFinance.java)
...    Satisfies: RT-4 (select applicant keywords + locators), T1 (data-testid locators only),
...    B1 (all enabled Java TCs ported)

Library     Browser

*** Variables ***
${SA_TITLE}                     css=[data-testid='select-applicant-title']
${SA_NOTE}                      css=[data-testid='select-applicant-note']
${SA_PARENT_OPTION}             css=[data-testid='Parent/Guardian-0']
${SA_STUDENT_OPTION}            css=[data-testid='Student-1']
${SA_APPLICANT_TYPE_ERROR}      css=[data-testid='applicant-type-error']
${SA_AGE_CHECKBOX}              css=[data-testid='age-checkbox']
${SA_SALARY_CHECKBOX}           css=[data-testid='salary-checkbox']
${SA_CONSENT_ERROR}             css=[data-testid='conset-error']
${SA_SUBMIT_BUTTON}             css=[data-testid='submit-applicant-type-button']
${SA_BACK_BUTTON}               css=[data-testid='back-button']

*** Keywords ***
Select Applicant Title Should Be Visible
    [Documentation]
    ...    Asserts the select-applicant-title element is visible.
    ...    Satisfies: TC-7001, RT-4, U1
    Wait For Elements State    ${SA_TITLE}    visible    timeout=${TIMEOUT}

Select Applicant Note Should Be Visible
    [Documentation]
    ...    Asserts the select-applicant-note (info text) is visible.
    ...    Satisfies: TC-7001, U1
    Wait For Elements State    ${SA_NOTE}    visible    timeout=${TIMEOUT}

Both Applicant Options Should Be Visible
    [Documentation]
    ...    Asserts both Parent/Guardian and Student option cards are visible.
    ...    Satisfies: TC-7002, U1
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${SA_STUDENT_OPTION}    visible    timeout=${TIMEOUT}

Select Parent Guardian Option
    [Documentation]
    ...    Clicks the Parent/Guardian option card (data-testid='Parent/Guardian-0').
    ...    Satisfies: TC-7003
    Wait For Elements State    ${SA_PARENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_PARENT_OPTION}

Select Student Option
    [Documentation]
    ...    Clicks the Student option card (data-testid='Student-1').
    ...    Satisfies: TC-7004
    Wait For Elements State    ${SA_STUDENT_OPTION}    visible    timeout=${TIMEOUT}
    Click    ${SA_STUDENT_OPTION}

Age Consent Checkbox Should Appear After Student Selection
    [Documentation]
    ...    Asserts the age-checkbox appears after the Student option is selected.
    ...    Satisfies: TC-7005, U1
    Wait For Elements State    ${SA_AGE_CHECKBOX}    visible    timeout=${TIMEOUT}

Salary Consent Checkbox Should Appear After Student Selection
    [Documentation]
    ...    Asserts the salary-checkbox appears after the Student option is selected.
    ...    Satisfies: TC-7006, U1
    Wait For Elements State    ${SA_SALARY_CHECKBOX}    visible    timeout=${TIMEOUT}

Submit Button Should Be Disabled Without Selection
    [Documentation]
    ...    Asserts the submit-applicant-type-button is disabled when no option is selected.
    ...    Satisfies: TC-7007, U2
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SA_SUBMIT_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Submit button should be disabled before an applicant type is selected.

Submit Button Should Be Enabled After Selection
    [Documentation]
    ...    Asserts the submit-applicant-type-button is enabled after a valid selection.
    ...    Satisfies: TC-7008, U2
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${SA_SUBMIT_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Submit button should be enabled after selecting an applicant type.

Click Submit Applicant Type Button
    [Documentation]
    ...    Clicks the submit-applicant-type-button to proceed to /applicant-basic-details.
    ...    Satisfies: TC-7008, RT-4 (proceed)
    Wait For Elements State    ${SA_SUBMIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_SUBMIT_BUTTON}

Select Applicant URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /select-applicant.
    ${url}=    Get Url
    Should Contain    ${url}    /select-applicant

Age Checkbox Should Be Visible After Selection
    [Documentation]
    ...    Asserts age-checkbox is visible after any radio option is selected.
    ...    Satisfies: TC-7010
    Wait For Elements State    ${SA_AGE_CHECKBOX}    visible    timeout=${TIMEOUT}

Salary Checkbox Should Be Visible After Selection
    [Documentation]
    ...    Asserts salary-checkbox is visible after any radio option is selected.
    ...    Satisfies: TC-7010
    Wait For Elements State    ${SA_SALARY_CHECKBOX}    visible    timeout=${TIMEOUT}

Check Age Eligibility Checkbox
    [Documentation]    Checks the age-checkbox eligibility consent if not already checked.
    Wait For Elements State    ${SA_AGE_CHECKBOX}    visible    timeout=${TIMEOUT}
    ${checked}=    Get Property    ${SA_AGE_CHECKBOX}    checked
    IF    not ${checked}
        Click    ${SA_AGE_CHECKBOX}
    END

Check Salary Eligibility Checkbox
    [Documentation]    Checks the salary-checkbox eligibility consent if not already checked.
    Wait For Elements State    ${SA_SALARY_CHECKBOX}    visible    timeout=${TIMEOUT}
    ${checked}=    Get Property    ${SA_SALARY_CHECKBOX}    checked
    IF    not ${checked}
        Click    ${SA_SALARY_CHECKBOX}
    END

Check Both Eligibility Checkboxes
    [Documentation]    Checks both age and salary eligibility checkboxes.
    Check Age Eligibility Checkbox
    Check Salary Eligibility Checkbox

Eligibility Consent Error Should Be Visible
    [Documentation]
    ...    Asserts conset-error is visible after submit without eligibility checkboxes.
    ...    Note: testid typo 'conset-error' is intentional — matches UAT source.
    ...    Satisfies: TC-7N-02, TC-7N-03
    Wait For Elements State    ${SA_CONSENT_ERROR}    visible    timeout=${TIMEOUT}

Navigate Back From Select Applicant
    [Documentation]    Clicks back-button on /select-applicant to return to /choose-plan.
    ...    Satisfies: TC-7015
    Wait For Elements State    ${SA_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SA_BACK_BUTTON}
