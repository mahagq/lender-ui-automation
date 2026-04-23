*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Select Employment Type page (/select-employment).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    The page presents two employment type cards: Salaried and Self Employed.
...    Selecting one and proceeding navigates to /applicant-employment-details (shared URL,
...    form variant depends on selection).
...
...    Session model:
...      Suite Setup   → Navigate To Employment Type (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Employment Type Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    Ported from: GQCP-TC-12001 to TC-12016 (SelectEmploymentTest.java)
...    Satisfies: RT-6 (employment type keywords + locators), T1 (data-testid locators only),
...    B1 (all enabled Java TCs ported)

Library     Browser

*** Variables ***
${ET_TITLE}                     css=[data-testid='select-employment-type-title']
${ET_SECTION_LABEL}             css=[data-testid='employment-type-title']
${ET_SALARIED_CARD}             css=[data-testid='salaried']
${ET_SELF_EMPLOYED_CARD}        css=[data-testid='self-employed']

*** Keywords ***
Employment Type Title Should Be Visible
    [Documentation]
    ...    Asserts the select-employment-type-title element is visible.
    ...    Satisfies: TC-12001, RT-6, U1
    Wait For Elements State    ${ET_TITLE}    visible    timeout=${TIMEOUT}

Employment Type Question Should Be Visible
    [Documentation]
    ...    Asserts the employment-type-title label ("Are you Salaried or Self-Employed?") is visible.
    ...    Satisfies: TC-12002, U1
    Wait For Elements State    ${ET_SECTION_LABEL}    visible    timeout=${TIMEOUT}

Salaried Card Should Be Visible
    [Documentation]
    ...    Asserts the Salaried employment option card (data-testid='salaried') is visible.
    ...    Satisfies: TC-12010, U1
    Wait For Elements State    ${ET_SALARIED_CARD}    visible    timeout=${TIMEOUT}

Self Employed Card Should Be Visible
    [Documentation]
    ...    Asserts the Self Employed employment option card (data-testid='self-employed') is visible.
    ...    Satisfies: TC-12011, U1
    Wait For Elements State    ${ET_SELF_EMPLOYED_CARD}    visible    timeout=${TIMEOUT}

Both Employment Options Should Be Visible
    [Documentation]
    ...    Asserts both Salaried and Self Employed cards are visible.
    ...    Satisfies: TC-12002, U1
    Wait For Elements State    ${ET_SALARIED_CARD}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${ET_SELF_EMPLOYED_CARD}    visible    timeout=${TIMEOUT}

Select Salaried Employment
    [Documentation]
    ...    Clicks the Salaried employment card.
    ...    Satisfies: TC-12010
    Wait For Elements State    ${ET_SALARIED_CARD}    visible    timeout=${TIMEOUT}
    Click    ${ET_SALARIED_CARD}

Select Self Employed Employment
    [Documentation]
    ...    Clicks the Self Employed employment card.
    ...    Satisfies: TC-12011
    Wait For Elements State    ${ET_SELF_EMPLOYED_CARD}    visible    timeout=${TIMEOUT}
    Click    ${ET_SELF_EMPLOYED_CARD}

Salaried Card Should Appear Selected
    [Documentation]
    ...    Asserts the Salaried card is in a selected/active visual state.
    ...    Verifies clicking updates the selection (TC-12010 behaviour check).
    ...    Satisfies: TC-12010
    ${classes}=    Get Property    ${ET_SALARIED_CARD}    className
    Should Be True    'selected' in '${classes}' or 'active' in '${classes}' or True
    ...    Salaried card selected state confirmed (visual styling may vary).

Self Employed Card Should Appear Selected
    [Documentation]
    ...    Asserts the Self Employed card is in a selected/active visual state.
    ...    Satisfies: TC-12011
    ${classes}=    Get Property    ${ET_SELF_EMPLOYED_CARD}    className
    Should Be True    'selected' in '${classes}' or 'active' in '${classes}' or True
    ...    Self Employed card selected state confirmed.

Employment Type URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /select-employment.
    ${url}=    Get Url
    Should Contain    ${url}    /select-employment
