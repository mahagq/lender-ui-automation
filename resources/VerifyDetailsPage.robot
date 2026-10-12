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
${VD_ADDRESS_TITLE}          xpath=//h3[normalize-space()='Residential details']
${VD_EMPLOYMENT_TITLE}       xpath=//h3[normalize-space()='Employment details']
${INFO_BANNER_TEXT}          xpath=//p[.//strong[text()='current address']]
${EXPECTED_TEXT}             Please ensure your current address is updated
${EMPLOYMENT_INFO_BANNER}    xpath=//p[.//strong[contains(text(),'current employment details')]]
${EMPLOYMENT_EXPECTED_TEXT}  Please ensure your current employment details are up to date to improve approval chances.

#Edit residential details locators
${CURRENT_ADDRESS_TITLE}     css=[data-testid="current-address-title"]
${RESIDENCE_TYPE_TITLE}      css=[data-testid="residence-type-title"]
${VD_ADDR_LINE1}             css=[data-testid='addr-line-1-input']
${VD_ADDR_LINE2}             css=[data-testid='addr-line-2-input']
${VD_RESIDENCE_RADIO_WRAP}   css=[data-testid='type-radio-container-1']
${VD_RESIDENCE_RADIO}        css=[data-testid='type-radio']
${VD_CONSENT}                css=[data-testid='consent-checkbox']
${VD_CONFIRM_BUTTON}         text=CONFIRM AND PROCEED
${VD_PROCEED_BUTTON}         xpath=//button[.//span[contains(text(),'SUBMIT')]]
${VD_EDIT_DETAILS}           text=EDIT DETAILS
${VD_BACK_BUTTON}            role=button[name=BACK]

# Employment type selection cards
${EMPLOYMENT_TYPE_SELECTION_TITLE}    xpath=//label[contains(normalize-space(),'Salaried or Self-Employed')]
${VD_SALARIED_CARD}         css=[data-testid='salaried']
${VD_SELF_EMPLOYED_CARD}    css=[data-testid='self-employed']

# Submit button in employment edit sub-forms
${VD_SUBMIT_BUTTON}         css=button:has-text("SUBMIT")

*** Keywords ***
Verify Details Page Should Be Visible
    [Documentation]    Verifies the Verify Details screen has loaded (address title visible).
    [Tags]    smoke
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${LONG_TIMEOUT}

# ── URL assertion ────────────────────────────────────────────────────────────────

Verify Details URL Should Be Active
    [Documentation]    Asserts that the current URL is the verify-details page.
    ${url}=    Get Url
    Should Contain    ${url}    /renewal-details

# ── Residential Details Visibility ────────────────────────────────────────────────────────────────

Residential Section Should Be Visible
    [Documentation]    Verifies residential address title is visible.
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${TIMEOUT}

Residential Edit Button Should Be Visible
    [Documentation]    Verifies the first "EDIT DETAILS" button (residential) is visible.
    Wait For Elements State    ${VD_EDIT_DETAILS} >> nth=0    visible    timeout=${TIMEOUT}

Verify Residential Info Banner Text
    [Documentation]    Verifies the info banner about updating current address is visible with correct text.
    Wait For Elements State    ${INFO_BANNER_TEXT}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${INFO_BANNER_TEXT}
    Should Be Equal    ${text}    ${EXPECTED_TEXT}   

# ── Employment section display ───────────────────────────────────────────────────

Employment Section Should Be Visible
    [Documentation]    Verifies the Employment details section heading is visible on Verify Details.
    Wait For Elements State    ${VD_EMPLOYMENT_TITLE}    visible    timeout=${TIMEOUT}

Employment Edit Button Should Be Visible
    [Documentation]    Verifies the second "EDIT DETAILS" button (employment) is visible.
    ${count}=    Get Element Count    ${VD_EDIT_DETAILS}
    Should Be True    ${count} >= 2    msg=Expected at least 2 EDIT DETAILS buttons (residential + employment)

Verify Employment Info Banner Text
    [Documentation]    Verifies the info banner about updating current employment details is visible with correct text.
    Wait For Elements State    ${EMPLOYMENT_INFO_BANNER}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${EMPLOYMENT_INFO_BANNER}
    Should Be Equal    ${text}    ${EMPLOYMENT_EXPECTED_TEXT}

# ── Confirm flow ────────────────────────────────────────────────────────────────

Click Confirm And Proceed Without Consent
    [Documentation]    Clicks CONFIRM AND PROCEED then lands on /review-application without checking consent.
    Wait For Elements State    ${VD_CONFIRM_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${VD_CONFIRM_BUTTON}

Verify Details Consent Error Should Be Visible
    [Documentation]    Verifies PROCEED button is disabled when consent is not checked on /review-application.
    ${disabled}=    Get Property    css=[data-testid='proceed-button']    disabled
    Should Be True    ${disabled}    msg=PROCEED button must be disabled when consent is not checked

# ── Edit Residential ────────────────────────────────────────────────────────────

Click Edit Residential Details
    [Documentation]    Clicks the first "EDIT DETAILS" button (nth=0) to open the residential edit form.
    Wait For Elements State    ${VD_EDIT_DETAILS} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${VD_EDIT_DETAILS} >> nth=0

Current Address Title Should Be Visible
    [Documentation]    Verifies the "Current address" title is visible in the residential edit form.
    Wait For Elements State    ${CURRENT_ADDRESS_TITLE}    visible    timeout=${TIMEOUT}

Residence Type Title Should Be Visible
    [Documentation]    Verifies the "Residence type" title is visible in the residential edit form.
    Wait For Elements State    ${RESIDENCE_TYPE_TITLE}    visible    timeout=${TIMEOUT}
    
Residential Edit Form Should Be Visible
    [Documentation]    Verifies address line 1 input is visible after clicking Edit on residential.
    Wait For Elements State    ${VD_ADDR_LINE1}    visible    timeout=${TIMEOUT}

Fill Verify Details Address Line 1
    [Documentation]    Fills address line 1 in the residential edit form.
    [Arguments]    ${address}
    Fill Text    ${VD_ADDR_LINE1}    ${address}

Fill Verify Details Address Line 2
    [Documentation]    Fills address line 2 in the residential edit form.
    [Arguments]    ${address}
    Fill Text    ${VD_ADDR_LINE2}    ${address}

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

Verify Details Address Line 2 Error Should Be Visible
    [Documentation]    Verifies address line 2 validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='addr-line-2-input-error']    visible    timeout=${TIMEOUT}

Verify Details Pincode Error Should Be Visible
    [Documentation]    Verifies pincode validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='pincode-input-error']    visible    timeout=${TIMEOUT}

Click Back From Edit
    [Documentation]    Clicks BACK to return without saving (works from residential form, employment type selection, salaried form, and SE form).
    Wait For Elements State    ${VD_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${VD_BACK_BUTTON}

Address Line 1 Field Should Have Value
    [Documentation]    Asserts that address line 1 field has expected value.
    [Arguments]    ${expected_value}
    ${value}=    Get Property    ${VD_ADDR_LINE1}    value
    Should Be Equal    ${value}    ${expected_value}

Address Line 2 Field Should Have Value
    [Documentation]    Asserts that address line 2 field in the residential edit form has a non-empty value.
    [Arguments]    ${expected_value}
    ${value}=    Get Property    ${VD_ADDR_LINE2}    value
    Should Be Equal    ${value}    ${expected_value}

Pincode Field Should Have Value
    [Documentation]    Asserts that pincode field in the residential edit form has a non-empty value.
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='pincode-input']    value
    Should Be Equal    ${value}    ${expected_value}

# ── Edit Employment — Type Selection ────────────────────────────────────────────

Click Edit Employment Details
    [Documentation]    Clicks the second "EDIT DETAILS" button (nth=1) to open employment type selection.
    @{edit_buttons}=    Get Elements    ${VD_EDIT_DETAILS}
    Click    ${VD_EDIT_DETAILS} >> nth=1

Employment Type Selection Title Should Be Visible
    [Documentation]    Verifies the title is visible in the employment type selection screen.
    Wait For Elements State    ${EMPLOYMENT_TYPE_SELECTION_TITLE}    visible    timeout=${TIMEOUT}

Employment Type Selection Should Be Visible
    [Documentation]    Verifies salaried and self-employed option cards are visible on type selection screen.
    Wait For Elements State    ${VD_SALARIED_CARD}       visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VD_SELF_EMPLOYED_CARD}  visible    timeout=${TIMEOUT}

#Previously Selected Employment Type Should Be Indicated
   # [Arguments]    ${employment_type}
    #${is_selected}=    Get Attribute    css=[data-testid='${employment_type}']    data-is-selected
   # Should Be Equal    ${is_selected}    true   # Note: data-is-selected is a string "true"/"false", not a boolean

Previously Selected Employment Type Should Be Indicated
    ${salaried}=        Get Attribute    css=[data-testid='salaried']        data-is-selected
    ${self_employed}=   Get Attribute    css=[data-testid='self-employed']   data-is-selected
    ${is_salaried}=    Run Keyword And Return Status    Should Be Equal    ${salaried}    true
    ${is_self}=        Run Keyword And Return Status    Should Be Equal    ${self_employed}    true
    Should Be True     ${is_salaried} or ${is_self}

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

Employer Name Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='employer-name-input']    value
    Should Be Equal    ${value}    ${expected_value}

Monthly Salary Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='net-monthly-salary-input']    value
    Should Be Equal    ${value}    ${expected_value}

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

Years In Business Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='years-of-current-business-input-error']    visible    timeout=${TIMEOUT}

Business Description Error Should Be Visible In VD
    Wait For Elements State    css=[data-testid='business-description-input-error']    visible

Business Name Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='business-name-input']    value
    Should Be Equal    ${value}    ${expected_value}

Annual Income Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='business-annual-income-input']    value
    Should Be Equal    ${value}    ${expected_value}

Years In Business Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='years-of-current-business-input']    value
    Should Be Equal    ${value}    ${expected_value}

Business Description Field Should Have Value
    [Arguments]    ${expected_value}
    ${value}=    Get Property    css=[data-testid='business-description-input']    value
    Should Be Equal    ${value}    ${expected_value}

# ── Confirm Application page assertion ───────────────────────────────────────────

Confirm Application Page Should Be Visible
    [Documentation]    Verifies URL reached /review-application and consent checkbox is visible.
    ${url}=    Get Url
    Should Contain    ${url}    /review-application
    Wait For Elements State    css=[data-testid='consent-checkbox']    visible    timeout=${TIMEOUT}

Confirm Application Proceed Button Should Be Enabled With Consent
    [Documentation]    Checks consent on /review-application and verifies PROCEED becomes enabled.
    ${checked}=    Get Attribute    css=[data-testid='consent-checkbox']    aria-checked
    IF    '${checked}' != 'true'
        Click    css=[data-testid='consent-checkbox']
    END
    ${disabled}=    Get Property    css=[data-testid='proceed-button']    disabled
    Should Be True    not ${disabled}    msg=PROCEED button must be enabled after checking consent
