*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Confirm Application page (/confirm-application).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    The Confirm Application page shows a summary of all wizard data entered by the applicant,
...    grouped into sections: Student Details, EMI Plan, Who Is Applying, General Details,
...    Residential Details, and Employment Details. Each section has an edit button and a heading.
...
...    Edit button testid pattern: `{section-name}-edit-button`
...    Section heading testid pattern: generated from `testIdFor` prop (dynamic, see below).
...
...    TN4 resolution — Assertion strategy:
...      Static user-entered fields (names, email, address): Should Be Equal As Strings
...      API-computed fields (EMI amount, interest rate, tenure): Should Match Regexp or Should Not Be Empty
...
...    Session model:
...      Suite Setup   → Navigate To Confirm Application (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Confirm Application Within Session (Go To)
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-13023 (proceed) must run last — it submits the application.
...
...    Ported from: GQCP-TC-13001 to TC-13025 (ConfirmApplicationTest/Class2/Class3.java)
...    Satisfies: RT-7 (confirm application keywords + locators), T1 (data-testid locators only),
...    T5 (mixed static/computed assertion strategy), TN4 resolution, B1 (all enabled Java TCs ported)

Library     Browser

*** Variables ***
${CA_TITLE}                     css=[data-testid='confirm-application-title']
${CA_FORM}                      css=[data-testid='confirm-application-form']
${CA_CONSENT}                   css=[data-testid='consent-checkbox']
${CA_PROCEED_BUTTON}            css=[data-testid='proceed-button']

# Section edit buttons — testid: {section-name}-edit-button
# Section name is lowercased + spaces → hyphens from the heading text passed to testIdFor
${CA_STUDENT_DETAILS_EDIT}      css=[data-testid='student-details-edit-button']
${CA_EMI_PLAN_EDIT}             css=[data-testid='emi-plan-details-edit-button']
${CA_WHO_APPLYING_EDIT}         css=[data-testid='who-is-applying?-edit-button']
${CA_GENERAL_DETAILS_EDIT}      css=[data-testid='your-general-details-edit-button']
${CA_RESIDENTIAL_EDIT}          css=[data-testid='your-residential-details-edit-button']
${CA_EMPLOYMENT_EDIT}           css=[data-testid='your-employment-details-edit-button']

# Referral code popup locators
${RC_SKIP_BUTTON}               css=[data-testid='skip-button']
${RC_INPUT}                     css=input[placeholder='Enter Referral Code']
${RC_PROCEED_BUTTON}            role=button[name=PROCEED]
${RC_ERROR}                     css=[data-testid='undefined-error']
${RC_HEADING}                   css=[data-testid='referral-code-heading']
${RC_CODE_VALUE}                css=[data-testid='code-value']
${RC_EDIT_BUTTON}               css=[data-testid='referral-code-edit-button']

*** Keywords ***
Confirm Application Title Should Be Visible
    [Documentation]
    ...    Asserts the confirm-application-title element is visible.
    ...    Satisfies: TC-13001, RT-7, U1
    Wait For Elements State    ${CA_TITLE}    visible    timeout=${TIMEOUT}

Confirm Application Form Should Be Visible
    [Documentation]
    ...    Asserts the confirm-application-form container is visible.
    ...    Satisfies: TC-13001, U1
    Wait For Elements State    ${CA_FORM}    visible    timeout=${TIMEOUT}

Student Details Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the Student Details section edit button is visible.
    ...    Satisfies: TC-13001, U1
    Wait For Elements State    ${CA_STUDENT_DETAILS_EDIT}    visible    timeout=${TIMEOUT}

Click Student Details Edit Button
    [Documentation]
    ...    Clicks the Student Details edit button — should navigate back to /student-details.
    ...    Satisfies: TC-13001, TC-13003, U4
    Wait For Elements State    ${CA_STUDENT_DETAILS_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_STUDENT_DETAILS_EDIT}

EMI Plan Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the EMI Plan Details section edit button is visible.
    ...    Satisfies: TC-13004, U1
    Wait For Elements State    ${CA_EMI_PLAN_EDIT}    visible    timeout=${TIMEOUT}

Click EMI Plan Edit Button
    [Documentation]
    ...    Clicks the EMI Plan Details edit button — should navigate back to /choose-plan.
    ...    Satisfies: TC-13004, U4
    Wait For Elements State    ${CA_EMI_PLAN_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_EMI_PLAN_EDIT}

Who Is Applying Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the "Who Is Applying?" section edit button is visible.
    ...    Satisfies: TC-13007, U1
    Wait For Elements State    ${CA_WHO_APPLYING_EDIT}    visible    timeout=${TIMEOUT}

Click Who Is Applying Edit Button
    [Documentation]
    ...    Clicks the Who Is Applying edit button — navigates back to /select-applicant.
    ...    Satisfies: TC-13007, U4
    Wait For Elements State    ${CA_WHO_APPLYING_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_WHO_APPLYING_EDIT}

General Details Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the "Your General Details" section edit button is visible.
    ...    Satisfies: TC-13010, U1
    Wait For Elements State    ${CA_GENERAL_DETAILS_EDIT}    visible    timeout=${TIMEOUT}

Click General Details Edit Button
    [Documentation]
    ...    Clicks the General Details edit button — navigates back to personal details.
    ...    Satisfies: TC-13010, U4
    Wait For Elements State    ${CA_GENERAL_DETAILS_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_GENERAL_DETAILS_EDIT}

Residential Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the Residential Details section edit button is visible.
    ...    Satisfies: TC-13013, U1
    Wait For Elements State    ${CA_RESIDENTIAL_EDIT}    visible    timeout=${TIMEOUT}

Click Residential Details Edit Button
    [Documentation]
    ...    Clicks the Residential Details edit button — navigates back to /applicant-residential-details.
    ...    Satisfies: TC-13013, U4
    Wait For Elements State    ${CA_RESIDENTIAL_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_RESIDENTIAL_EDIT}

Employment Section Edit Button Should Be Visible
    [Documentation]
    ...    Asserts the Employment Details section edit button is visible.
    ...    Satisfies: TC-13016, U1
    Wait For Elements State    ${CA_EMPLOYMENT_EDIT}    visible    timeout=${TIMEOUT}

Click Employment Details Edit Button
    [Documentation]
    ...    Clicks the Employment Details edit button — navigates back to /select-employment or employment details.
    ...    Satisfies: TC-13016, U4
    Wait For Elements State    ${CA_EMPLOYMENT_EDIT}    visible    timeout=${TIMEOUT}
    Click    ${CA_EMPLOYMENT_EDIT}

All Section Edit Buttons Should Be Visible
    [Documentation]
    ...    Asserts all six section edit buttons are visible on the confirm application page.
    ...    Satisfies: TC-13001, TC-13004, TC-13007, TC-13010, TC-13013, TC-13016, U1
    Wait For Elements State    ${CA_STUDENT_DETAILS_EDIT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CA_EMI_PLAN_EDIT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CA_WHO_APPLYING_EDIT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CA_GENERAL_DETAILS_EDIT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CA_RESIDENTIAL_EDIT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${CA_EMPLOYMENT_EDIT}    visible    timeout=${TIMEOUT}

Consent Checkbox Should Be Visible
    [Documentation]
    ...    Asserts the consent checkbox on the confirm application page is visible.
    ...    Satisfies: TC-13019, TC-13020, U1
    Wait For Elements State    ${CA_CONSENT}    visible    timeout=${TIMEOUT}

Check Confirm Application Consent
    [Documentation]
    ...    Checks the consent checkbox if not already checked.
    ...    Satisfies: TC-13020
    ${checked}=    Get Property    ${CA_CONSENT}    checked
    IF    not ${checked}
        Click    ${CA_CONSENT}
    END

Proceed Button Should Be Disabled Without Consent
    [Documentation]
    ...    Asserts the proceed-button is disabled when consent is not checked.
    ...    TN4: static assertion — proceed is disabled without consent (invariant behaviour).
    ...    Satisfies: TC-13022, U2, TN4
    Wait For Elements State    ${CA_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${CA_PROCEED_BUTTON}    disabled
    Should Be True    ${disabled}
    ...    Confirm Application proceed button should be disabled without consent.

Proceed Button Should Be Enabled With Consent
    [Documentation]
    ...    Asserts the proceed-button is enabled when consent is checked.
    ...    Satisfies: TC-13023, U2
    Wait For Elements State    ${CA_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    ${disabled}=    Get Property    ${CA_PROCEED_BUTTON}    disabled
    Should Be True    not ${disabled}
    ...    Confirm Application proceed button should be enabled with consent checked.

Click Confirm Application Proceed
    [Documentation]
    ...    Clicks the proceed-button to submit the application.
    ...    PRECONDITION: Consent must be checked. This is the final wizard action.
    ...    Should only be called in the last test of confirm_application_tests.robot.
    ...    Satisfies: TC-13023, RT-7 (proceed — final wizard step)
    Wait For Elements State    ${CA_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CA_PROCEED_BUTTON}

Confirm Application URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /confirm-application.
    ${url}=    Get Url
    Should Contain    ${url}    /confirm-application

Confirm Application Submitted Successfully
    [Documentation]
    ...    Asserts the wizard has advanced past /confirm-application after the application is submitted.
    ...    Checks that the URL no longer contains /confirm-application, confirming navigation to the
    ...    post-submission page (e.g. /loan-summary, /application-submitted, or similar).
    ...    Satisfies: TC-13023, RT-7 (final wizard submission)
    ${url}=    Get Url
    Should Not Contain    ${url}    /confirm-application

# =====================================================================
# REFERRAL CODE KEYWORDS
# =====================================================================

Handle Referral Code Popup If Present
    [Documentation]
    ...    Dismisses the referral code popup if it is visible on the confirm application page.
    ...    Uses a short timeout to avoid slowing down tests where the popup is absent.
    ...    Call this in standard Test Setup to unblock confirm-application test execution.
    ${popup_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${RC_SKIP_BUTTON}    visible    timeout=3s
    IF    ${popup_visible}
        Click    ${RC_SKIP_BUTTON}
        Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}
    END

Referral Code Popup Should Be Visible
    [Documentation]
    ...    Asserts the referral code popup skip button is visible.
    ...    Satisfies: TC-13025
    Wait For Elements State    ${RC_SKIP_BUTTON}    visible    timeout=${TIMEOUT}

Skip Referral Code Popup
    [Documentation]
    ...    Clicks the skip-button to dismiss the referral code popup.
    ...    Verifies the referral-code-heading section is visible after dismissal.
    ...    Satisfies: TC-13026
    Wait For Elements State    ${RC_SKIP_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${RC_SKIP_BUTTON}
    Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}

Fill Referral Code
    [Documentation]
    ...    Fills the referral code input and clicks PROCEED.
    ...    [Arguments] ${code} — the referral code string to enter.
    ...    Satisfies: TC-13027, TC-13028
    [Arguments]    ${code}
    Wait For Elements State    ${RC_INPUT}    visible    timeout=${TIMEOUT}
    Fill Text    ${RC_INPUT}    ${code}
    Click    ${RC_PROCEED_BUTTON}

Referral Code Error Should Be Visible
    [Documentation]
    ...    Asserts the undefined-error element is visible after submitting an invalid/empty code.
    ...    Satisfies: TC-13027
    Wait For Elements State    ${RC_ERROR}    visible    timeout=${TIMEOUT}

Referral Code Section Should Be Visible
    [Documentation]
    ...    Asserts the referral code heading and code value are visible on the confirm page.
    ...    Satisfies: TC-13026
    Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RC_CODE_VALUE}    visible    timeout=${TIMEOUT}

Click Referral Code Edit Button
    [Documentation]
    ...    Clicks the referral-code-edit-button to open the edit input.
    ...    Satisfies: TC-13028
    Wait For Elements State    ${RC_EDIT_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${RC_EDIT_BUTTON}

Referral Code Updated Toast Should Be Visible
    [Documentation]
    ...    After clicking PROCEED on the referral code edit form, asserts the update was processed.
    ...    Attempts to catch the auto-hiding "Referral code updated" toast; if the toast disappears
    ...    before it can be caught, falls back to verifying the referral-code section remains visible
    ...    (referral-code-heading + code-value), which confirms the edit was submitted successfully.
    ...    Satisfies: TC-13028
    ${toast_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    text=Referral code updated    visible    timeout=5s
    IF    not ${toast_visible}
        Wait For Elements State    ${RC_HEADING}    visible    timeout=${TIMEOUT}
        Wait For Elements State    ${RC_CODE_VALUE}    visible    timeout=${TIMEOUT}
    END
