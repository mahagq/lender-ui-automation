*** Settings ***
Documentation
...    Page Object keywords for the Renewal Journey "Verify Details" screen.
...    Reached by clicking "CONTINUE WITH THESE DETAILS" on the Welcome Back screen.
...    Shows pre-filled residential and employment details from the previous application.
...    Supports:
...      - Viewing pre-filled details
...      - Editing residential section (address, residence type)
...      - Editing employment section (business fields)
...      - Skipping employment review via skip-button
...      - Confirming and proceeding to application submission

Library    Browser

*** Variables ***
# Page sections
${VD_ADDRESS_TITLE}         css=[data-testid='current-address-title']
${VD_ADDR_LINE1}            css=[data-testid='addr-line-1-input']
${VD_RESIDENCE_RADIO_WRAP}  css=[data-testid='type-radio-container-1']
${VD_RESIDENCE_RADIO}       css=[data-testid='type-radio']
${VD_SKIP_BUTTON}           css=[data-testid='skip-button']
${VD_BUSINESS_NAME}         css=[data-testid='business-name-input']
${VD_ANNUAL_INCOME}         css=[data-testid='business-annual-income-input']
${VD_YEARS_IN_BUSINESS}     css=[data-testid='years-of-current-business-input']
${VD_BUSINESS_DESC}         css=[data-testid='business-description-input']
${VD_CONSENT}               css=[data-testid='consent-checkbox']
${VD_CONFIRM_BUTTON}        text=CONFIRM AND PROCEED
${VD_PROCEED_BUTTON}        css=[data-testid='proceed-button']
${VD_EDIT_DETAILS}          text=EDIT DETAILS
${VD_BACK_BUTTON}           text=BACK

*** Keywords ***
Verify Details Page Should Be Visible
    [Documentation]    Verifies the Verify Details screen has loaded (address title visible).
    [Tags]    smoke
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${LONG_TIMEOUT}

Residential Section Should Be Visible
    [Documentation]    Verifies residential address title and address line 1 are visible.
    Wait For Elements State    ${VD_ADDRESS_TITLE}    visible    timeout=${TIMEOUT}

Residential Edit Button Should Be Visible
    [Documentation]    Verifies the "EDIT DETAILS" button for the residential section is visible.
    Wait For Elements State    ${VD_EDIT_DETAILS}    visible    timeout=${TIMEOUT}

Employment Skip Button Should Be Visible
    [Documentation]    Verifies the skip button (to skip employment review) is visible.
    Wait For Elements State    ${VD_SKIP_BUTTON}    visible    timeout=${TIMEOUT}

Employment Edit Button Should Be Visible
    [Documentation]    Verifies the "EDIT DETAILS" button for the employment section is visible.
    ${count}=    Get Element Count    ${VD_EDIT_DETAILS}
    Should Be True    ${count} >= 2    msg=Expected at least 2 EDIT DETAILS buttons (residential + employment)

Consent And Confirm Button Should Be Visible
    [Documentation]    Verifies consent checkbox and CONFIRM AND PROCEED button are visible.
    Wait For Elements State    ${VD_CONSENT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${VD_CONFIRM_BUTTON}    visible    timeout=${TIMEOUT}

# ── Skip Journey ────────────────────────────────────────────────────────────────

Click Skip Employment
    [Documentation]    Clicks the skip button to dismiss the employment review section.
    Wait For Elements State    ${VD_SKIP_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${VD_SKIP_BUTTON}

Employment Section Should Be Dismissed After Skip
    [Documentation]    After clicking skip, the skip button should no longer be visible.
    Wait For Elements State    ${VD_SKIP_BUTTON}    hidden    timeout=${TIMEOUT}

Click Confirm And Proceed
    [Documentation]    Checks consent and clicks CONFIRM AND PROCEED.
    ${checked}=    Get Property    ${VD_CONSENT}    checked
    IF    not ${checked}
        Click    ${VD_CONSENT}
    END
    Click    ${VD_CONFIRM_BUTTON}

Click Confirm And Proceed Without Consent
    [Documentation]    Clicks CONFIRM AND PROCEED without checking consent (negative test).
    ${checked}=    Get Property    ${VD_CONSENT}    checked
    IF    ${checked}
        Click    ${VD_CONSENT}
    END
    Click    ${VD_CONFIRM_BUTTON}

Verify Details Consent Error Should Be Visible
    [Documentation]    Verifies a consent-related error message is shown on the Verify Details screen.
    Wait For Elements State    css=[data-testid='consent-checkbox-error']    visible    timeout=${TIMEOUT}

# ── Edit Residential ────────────────────────────────────────────────────────────

Click Edit Residential Details
    [Documentation]    Clicks the first "EDIT DETAILS" button to open the residential edit form.
    Wait For Elements State    ${VD_EDIT_DETAILS}    visible    timeout=${TIMEOUT}
    Click    ${VD_EDIT_DETAILS} >> nth=0

Residential Edit Form Should Be Visible
    [Documentation]    Verifies address line 1 input is visible after clicking Edit on residential.
    Wait For Elements State    ${VD_ADDR_LINE1}    visible    timeout=${TIMEOUT}

Fill Verify Details Address Line 1
    [Documentation]    Fills address line 1 in the residential edit form.
    [Arguments]    ${address}
    Fill Text    ${VD_ADDR_LINE1}    ${address}

Click Residence Type Radio In Edit Form
    [Documentation]    Clicks the first residence type radio option in the residential edit form.
    Wait For Elements State    ${VD_RESIDENCE_RADIO}    visible    timeout=${TIMEOUT}
    Click    ${VD_RESIDENCE_RADIO} >> nth=0

Verify Details Address Line 1 Error Should Be Visible
    [Documentation]    Verifies address line 1 validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='addr-line-1-input-error']    visible    timeout=${TIMEOUT}

Verify Details Pincode Error Should Be Visible
    [Documentation]    Verifies pincode validation error is shown in the residential edit form.
    Wait For Elements State    css=[data-testid='pincode-input-error']    visible    timeout=${TIMEOUT}

Click Back From Edit
    [Documentation]    Clicks BACK to return to the Verify Details screen without saving.
    Wait For Elements State    ${VD_BACK_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${VD_BACK_BUTTON}

# ── Edit Employment ─────────────────────────────────────────────────────────────

Click Edit Employment Details
    [Documentation]    Clicks the second "EDIT DETAILS" button to open the employment edit form.
    @{edit_buttons}=    Get Elements    ${VD_EDIT_DETAILS}
    Click    ${edit_buttons}[1]

Employment Edit Form Should Be Visible
    [Documentation]    Verifies business name input is visible after clicking Edit on employment.
    Wait For Elements State    ${VD_BUSINESS_NAME}    visible    timeout=${TIMEOUT}

Fill Verify Business Name
    [Arguments]    ${name}
    Fill Text    ${VD_BUSINESS_NAME}    ${name}

Fill Verify Annual Income
    [Arguments]    ${income}
    Fill Text    ${VD_ANNUAL_INCOME}    ${income}

Fill Verify Years In Business
    [Arguments]    ${years}
    Fill Text    ${VD_YEARS_IN_BUSINESS}    ${years}

Fill Verify Business Description
    [Arguments]    ${desc}
    Fill Text    ${VD_BUSINESS_DESC}    ${desc}

Verify Details Business Name Error Should Be Visible
    [Documentation]    Verifies business name validation error is shown in the employment edit form.
    Wait For Elements State    css=[data-testid='business-name-input-error']    visible    timeout=${TIMEOUT}

Verify Details Annual Income Error Should Be Visible
    [Documentation]    Verifies annual income validation error is shown in the employment edit form.
    Wait For Elements State    css=[data-testid='business-annual-income-input-error']    visible    timeout=${TIMEOUT}

Verify Details URL Should Be Active
    [Documentation]    Asserts that the current URL is the verify-details page.
    ${url}=    Get Url
    Should Contain    ${url}    /verify-details
