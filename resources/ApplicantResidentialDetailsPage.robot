*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Applicant Residential Details page (/applicant-residential-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    Collects current address (line 1, line 2, pincode — city/state auto-populate)
...    and residence type (Own / Rented / etc. radio options).
...
...    Session model (used within applicant_journey_tests.robot sequential flow):
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
${RD_ADDR_LINE1}                css=[data-testid='addr-line-1-input']
${RD_ADDR_LINE2}                css=[data-testid='addr-line-2-input']
${RD_PINCODE}                   css=[data-testid='pincode-input']
${RD_CITY_STATE}                css=[data-testid='city-state']
${RD_CITY_INPUT}                css=[data-testid='city-input']
${RD_STATE_SELECT}              css=[data-testid='state-react-select']
${RD_RESIDENCE_TYPE_TITLE}      css=[data-testid='residence-type-title']
${RD_TYPE_RADIO}                css=[data-testid='type-radio']
${RD_PROCEED_BUTTON}            css=[data-testid='proceed-button']

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
    ...    Satisfies: TC-11003, U1
    Wait For Elements State    ${RD_TYPE_RADIO}    visible    timeout=${TIMEOUT}

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
    [Documentation]    Selects the first residence type radio option.
    Wait For Elements State    ${RD_TYPE_RADIO}    visible    timeout=${TIMEOUT}
    Click    ${RD_TYPE_RADIO} >> nth=0

Proceed Button Should Be Visible
    [Documentation]
    ...    Asserts the proceed-button is visible.
    ...    Satisfies: TC-11009, U2
    Wait For Elements State    ${RD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}

Click Residential Details Proceed
    [Documentation]
    ...    Clicks the proceed-button to advance to /select-employment.
    ...    Satisfies: TC-11010, RT-5 (proceed)
    Wait For Elements State    ${RD_PROCEED_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${RD_PROCEED_BUTTON}

Residential Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /applicant-residential-details.
    ${url}=    Get Url
    Should Contain    ${url}    /applicant-residential-details
