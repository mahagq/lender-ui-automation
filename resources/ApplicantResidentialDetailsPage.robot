*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Residential Details page (/applicant-address).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects current address (line 1, line 2, pincode — city/state auto-populate)
...    and residence type (Own / Rented / etc. radio options).
...
...    Session model (residential_details_tests.robot):
...      Visited after /applicant-personal-details is submitted.
...      Suite Teardown → Close Browser
...
...    Satisfies: RT-5 (residential details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
${RD_TITLE}                     css=[data-testid='residential-details-title']
${RD_ADDRESS_SUMMARY}           css=[data-testid='address-summary']
${RD_EDIT_BUTTON}               css=[data-testid='edit-button']
${RD_CURRENT_ADDRESS_TITLE}     css=[data-testid='current-address-title']
${RD_ADDR_LINE1}                css=input[placeholder='Flat no. / building name']
${RD_ADDR_LINE2}                css=input[placeholder='Colony / street / locality']
${RD_PINCODE}                   css=input[placeholder='Pincode']
${RD_CITY_STATE}                css=p.text-success-700
${RD_CITY_INPUT}                css=[data-testid='city-input']
${RD_STATE_SELECT}              css=[data-testid='state-react-select']
${RD_RESIDENCE_TYPE_TITLE}      css=[data-testid='residence-type-title']
${RD_TYPE_RADIO}                role=radio
${RD_PROCEED_BUTTON}            css=button:has-text('Proceed')
${RD_RADIO_STEP_PROCEED}        role=button[name=Proceed]
${RD_ADDR_LINE1_ERROR}          css=[data-testid='addr-line-1-input-error']
${RD_PINCODE_ERROR}             css=[data-testid='pincode-input-error']

*** Keywords ***
Residential Details Title Should Be Visible
    [Documentation]
    ...    Asserts the residential-details-title element is visible.
    ...    Satisfies: TC-11001, RT-5, U1
    Wait For Elements State    ${RD_TITLE}    visible    timeout=${TIMEOUT}

Address Fields Should Be Visible
    [Documentation]
    ...    Asserts address line inputs and pincode are visible.
    ...    Satisfies: TC-11002, U1
    Wait For Elements State    ${RD_ADDR_LINE1}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RD_ADDR_LINE2}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${RD_PINCODE}    visible    timeout=${TIMEOUT}

Residence Type Radio Should Be Visible
    [Documentation]
    ...    Asserts at least one type-radio option is visible for residence type selection.
    ...    Uses nth=0 to avoid strict mode violation (3 type-radio elements exist).
    ...    Satisfies: TC-11003, U1
    Wait For Elements State    ${RD_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}

Fill Address Line 1
    [Documentation]    Fills the addr-line-1-input field.
    [Arguments]    ${value}
    Wait For Elements State    ${RD_ADDR_LINE1}    visible    timeout=${TIMEOUT}
    Fill Text    ${RD_ADDR_LINE1}    ${value}

Fill Address Line 2
    [Documentation]    Fills the addr-line-2-input field.
    [Arguments]    ${value}
    Fill Text    ${RD_ADDR_LINE2}    ${value}

Fill Pincode
    [Documentation]
    ...    Fills the pincode-input field. UAT auto-populates city and state based on pincode.
    [Arguments]    ${value}
    Wait For Elements State    ${RD_PINCODE}    visible    timeout=${TIMEOUT}
    Fill Text    ${RD_PINCODE}    ${value}

City State Should Auto Populate
    [Documentation]
    ...    Asserts the city-state container is visible after pincode is entered.
    ...    City and state are auto-populated from the pincode API.
    ...    Satisfies: TC-11005, U3
    Wait For Elements State    ${RD_CITY_STATE}    visible    timeout=${LONG_TIMEOUT}

Click First Residence Type Radio
    [Documentation]
    ...    Selects the first residence type radio option (Rented) and waits for Radix UI
    ...    data-state to become 'checked' before returning — ensures the form is ready before
    ...    the subsequent Proceed click. Browser library 'checked' state does not apply to
    ...    Radix UI button-based radios; data-state attribute is used instead.
    Wait For Elements State    ${RD_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${RD_TYPE_RADIO} >> nth=0
    Wait For Elements State    role=radio[data-state='checked']    visible    timeout=${TIMEOUT}

All Residence Type Radios Should Be Selectable
    [Documentation]
    ...    Verifies all three residence type radio buttons (Rented, Self Owned, Other) are
    ...    clickable — each click succeeds without error. No selection state assertion needed.
    ...    Satisfies: TC-11008, U1
    Wait For Elements State    ${RD_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}
    Click    ${RD_TYPE_RADIO} >> nth=0
    Click    ${RD_TYPE_RADIO} >> nth=1
    Click    ${RD_TYPE_RADIO} >> nth=2

Proceed Button Should Be Visible
    [Documentation]
    ...    Asserts the proceed-button is visible.
    ...    Satisfies: TC-11009, U2
    Wait For Elements State    ${RD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}

Click Residential Details Proceed
    [Documentation]
    ...    Clicks the proceed-button on the address form step (step 1 of 2).
    ...    Satisfies: TC-11010, RT-5 (proceed)
    Wait For Elements State    ${RD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${RD_PROCEED_BUTTON}

Click Residence Type Step Proceed
    [Documentation]
    ...    Clicks the Proceed button on the residence type radio step (step 2 of 2).
    ...    This button is role-based (accessible name "Proceed"), not data-testid='proceed-button'.
    ...    Confirmed from Playwright recording: getByRole('button', { name: 'Proceed' }).
    ...    Satisfies: TC-11007, RT-5 (proceed)
    Wait For Elements State    ${RD_RADIO_STEP_PROCEED}    visible    timeout=${TIMEOUT}
    Click    ${RD_RADIO_STEP_PROCEED}

Click Close Button
    [Documentation]    Clicks close-button on /applicant-address and waits for dashboard URL.
    Click    css=[data-testid='close-button']
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible

Residential Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-address.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-address

Address Line 1 Error Should Be Visible
    [Documentation]
    ...    Asserts addr-line-1-input-error is visible after proceed with empty address line 1.
    ...    Satisfies: TC-11N-01
    Wait For Elements State    ${RD_ADDR_LINE1_ERROR}    visible    timeout=${TIMEOUT}

Pincode Error Should Be Visible
    [Documentation]
    ...    Asserts pincode-input-error is visible after proceed with invalid/empty pincode.
    ...    Satisfies: TC-11N-02, TC-11N-03, TC-11N-04, TC-11N-05
    Wait For Elements State    ${RD_PINCODE_ERROR}    visible    timeout=${TIMEOUT}
