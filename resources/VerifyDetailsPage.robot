*** Settings ***
Documentation
...    Page Object keywords for the Renewal Journey "Verify Details" screen.
...    Reached by clicking "CONTINUE WITH THESE DETAILS" on the Welcome Back screen.
...    Shows pre-filled residential and employment details from the previous application.
...    Supports:
...      - Viewing pre-filled details
...      - Editing residential section (address, residence type)
...      - Editing employment section via multi-step flow:
...          1. Employment Type Selection (salaried / self-employed cards)
...          2. Salaried form (employer-name, net-monthly-salary) or SE form (business fields)
...      - Confirming and proceeding to application submission

Library    Browser

*** Variables ***
# Page sections
${VD_ADDRESS_TITLE}         xpath=//h3[normalize-space()='Residential details']
${VD_ADDR_LINE1}            css=[data-testid='addr-line-1-input']
${VD_RESIDENCE_RADIO_WRAP}  css=[data-testid='type-radio-container-1']
${VD_RESIDENCE_RADIO}       css=[data-testid='type-radio']
${VD_CONSENT}               css=[data-testid='consent-checkbox']
${VD_CONFIRM_BUTTON}        text=CONFIRM AND PROCEED
${VD_PROCEED_BUTTON}        css=[data-testid='proceed-button']
${VD_EDIT_DETAILS}          text=EDIT DETAILS
${VD_BACK_BUTTON}           role=button[name=BACK]

# Employment type selection cards
${VD_SALARIED_CARD}         css=[data-testid='salaried']
${VD_SELF_EMPLOYED_CARD}    css=[data-testid='self-employed']

# Submit button in employment edit sub-forms
${VD_SUBMIT_BUTTON}         role=button[name=SUBMIT]

*** Keywords ***
Verify Details Page Should Be Visible
    [Documentation]    Verifies the Verify Details screen has loaded (address title visible).
    [Tags]    smoke
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${LONG_TIMEOUT}

Residential Section Should Be Visible
    [Documentation]    Verifies residential address title is visible.
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${TIMEOUT}

Residential Edit Button Should Be Visible
    [Documentation]    Verifies the first "EDIT DETAILS" button (residential) is visible.
    Wait For Elements State    ${VD_EDIT_DETAILS} >> nth=0    visible    timeout=${TIMEOUT}

Employment Edit Button Should Be Visible
    [Documentation]    Verifies the second "EDIT DETAILS" button (employment) is visible.
    ${count}=    Get Element Count    ${VD_EDIT_DETAILS}
    Should Be True    ${count} >= 2    msg=Expected at least 2 EDIT DETAILS buttons (residential + employment)

# ── Confirm flow ────────────────────────────────────────────────────────────────

Click Confirm And Proceed
    [Documentation]    Clicks CONFIRM AND PROCEED on /renewal-details, then handles consent + PROCEED on /confirm-application.
    Click    ${VD_CONFIRM_BUTTON}
    Wait For Elements State    css=[data-testid='consent-checkbox']    visible    timeout=${LONG_TIMEOUT}
    ${checked}=    Get Property    css=[data-testid='consent-checkbox']    checked
    IF    not ${checked}
        Click    css=[data-testid='consent-checkbox']
    END
    Click    css=[data-testid='proceed-button']

Click Confirm And Proceed Without Consent
    [Documentation]    Clicks CONFIRM AND PROCEED then lands on /confirm-application without checking consent.
    Click    ${VD_CONFIRM_BUTTON}
    Wait For Elements State    css=[data-testid='proceed-button']    visible    timeout=${LONG_TIMEOUT}

Verify Details Consent Error Should Be Visible
    [Documentation]    Verifies PROCEED button is disabled when consent is not checked on /confirm-application.
    ${disabled}=    Get Property    css=[data-testid='proceed-button']    disabled
    Should Be True    ${disabled}    msg=PROCEED button must be disabled when consent is not checked

# ── Edit Residential ────────────────────────────────────────────────────────────

Click Edit Residential Details
    [Documentation]    Clicks the first "EDIT DETAILS" button (nth=0) to open the residential edit form.
    Wait For Elements State    ${VD_EDIT_DETAILS} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${VD_EDIT_DETAILS} >> nth=0

Residential Edit Form Should Be Visible
    [Documentation]    Verifies address line 1 input is visible after clicking Edit on residential.
    Wait For Elements State    ${VD_ADDR_LINE1}    visible    timeout=${TIMEOUT}

Fill Verify Details Address Line 1
    [Documentation]    Fills address line 1 in the residential edit form.
    [Arguments]    ${address}
    Fill Text    ${VD_ADDR_LINE1}    ${address}

Click Residence Type Radio In Edit Form
    [Documentation]    Clicks the first residence type radio option (Rented) in the residential edit form.
    Wait For Elements State    ${VD_RESIDENCE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${VD_RESIDENCE_RADIO} >> nth=0

Click Self Owned Residence Type
    [Documentation]    Clicks the Self Owned radio option (nth=1) in the residential edit form.
    Wait For Elements State    ${VD_RESIDENCE_RADIO} >> nth=1    visible    timeout=${TIMEOUT}
    Click    ${VD_RESIDENCE_RADIO} >> nth=1

Click Other Residence Type
    [Documentation]    Clicks the Other radio option (nth=2) in the residential edit form.
    Wait For Elements State    ${VD_RESIDENCE_RADIO} >> nth=2    visible    timeout=${TIMEOUT}
    Click    ${VD_RESIDENCE_RADIO} >> nth=2

Submit Residential Edit
    [Documentation]    Clicks the SUBMIT button in the residential edit form.
    Click    ${VD_PROCEED_BUTTON}

Verify Details Address Line 1 Error Should Be Visible
    [Documentation]    Verifies address line 1 validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='addr-line-1-input-error']    visible    timeout=${TIMEOUT}

Verify Details Pincode Error Should Be Visible
    [Documentation]    Verifies pincode validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='pincode-input-error']    visible    timeout=${TIMEOUT}

Click Back From Edit
    [Documentation]    Clicks BACK to return without saving (works from residential form, employment type selection, salaried form, and SE form).
    Wait For Elements State    ${VD_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${VD_BACK_BUTTON}

# ── Edit Employment — Type Selection ────────────────────────────────────────────

Click Edit Employment Details
    [Documentation]    Clicks the second "EDIT DETAILS" button (nth=1) to open employment type selection.
    @{edit_buttons}=    Get Elements    ${VD_EDIT_DETAILS}
    Click    ${edit_buttons}[1]

Employment Type Selection Should Be Visible
    [Documentation]    Verifies salaried and self-employed option cards are visible on type selection screen.
    Wait For Elements State    ${VD_SALARIED_CARD}       visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VD_SELF_EMPLOYED_CARD}  visible    timeout=${TIMEOUT}

Click Salaried Option
    [Documentation]    Clicks the Salaried card in the employment type selection screen.
    Click    ${VD_SALARIED_CARD}

Click Self Employed Option
    [Documentation]    Clicks the Self-Employed card in the employment type selection screen.
    Click    ${VD_SELF_EMPLOYED_CARD}

# ── Edit Employment — Salaried Sub-form ─────────────────────────────────────────

Salaried Fields Should Be Visible
    [Documentation]    Verifies employer name and monthly salary inputs are visible in the salaried form.
    Wait For Elements State    css=[data-testid='employer-name-input']       visible    timeout=${TIMEOUT}
    Wait For Elements State    css=[data-testid='net-monthly-salary-input']  visible    timeout=${TIMEOUT}

Fill VD Employer Name
    [Arguments]    ${name}
    Fill Text    css=[data-testid='employer-name-input']    ${name}

Fill VD Monthly Salary
    [Arguments]    ${salary}
    Fill Text    css=[data-testid='net-monthly-salary-input']    ${salary}

Submit Employment Edit
    [Documentation]    Clicks the SUBMIT button inside employment edit sub-forms.
    Click    ${VD_SUBMIT_BUTTON}

Employer Name Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='employer-name-input-error']    visible    timeout=${TIMEOUT}

Monthly Salary Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='net-monthly-salary-input-error']    visible    timeout=${TIMEOUT}

# ── Edit Employment — Self-Employed Sub-form ─────────────────────────────────────

Self Employed Fields Should Be Visible
    [Documentation]    Verifies all business fields are visible in the self-employed form.
    Wait For Elements State    css=[data-testid='business-name-input']                visible    timeout=${TIMEOUT}
    Wait For Elements State    css=[data-testid='business-annual-income-input']       visible    timeout=${TIMEOUT}
    Wait For Elements State    css=[data-testid='years-of-current-business-input']    visible    timeout=${TIMEOUT}
    Wait For Elements State    css=[data-testid='business-description-input']         visible    timeout=${TIMEOUT}

Fill VD Business Name
    [Arguments]    ${name}
    Fill Text    css=[data-testid='business-name-input']    ${name}

Fill VD Annual Income
    [Arguments]    ${income}
    Fill Text    css=[data-testid='business-annual-income-input']    ${income}

Fill VD Years In Business
    [Arguments]    ${years}
    Fill Text    css=[data-testid='years-of-current-business-input']    ${years}

Fill VD Business Description
    [Arguments]    ${desc}
    Fill Text    css=[data-testid='business-description-input']    ${desc}

Business Name Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='business-name-input-error']    visible    timeout=${TIMEOUT}

Annual Income Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='business-annual-income-input-error']    visible    timeout=${TIMEOUT}

# ── URL assertion ────────────────────────────────────────────────────────────────

Verify Details URL Should Be Active
    [Documentation]    Asserts that the current URL is the verify-details page.
    ${url}=    Get Url
    Should Contain    ${url}    /renewal-details
