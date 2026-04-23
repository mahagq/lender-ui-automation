*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Student Details page (/student-details).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    The Student Details page is the first step of the Application Creation wizard.
...    It collects GILE information (institute, location, board, academic year) plus
...    student personal details (name, type, class, student ID) and loan amount.
...
...    Session model:
...      Suite Setup   → Create Application And Navigate To Student Details (ApplicationCreationFlowPage.robot)
...      Test Setup    → Navigate To Student Details Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    The submit (Show Plans) test runs last — it advances the wizard to /choose-plan.
...
...    Satisfies: RT-2 (student details keywords + locators), T1 (data-testid locators only)

Library     Browser

*** Variables ***
# Page title and section labels
# NOTE: 'student-details-title' testid was renamed to 'gile-form-title' on UAT.
# 'admission-type-title', 'annual-fee-title', 'student-details-note', 'loan-amount-note'
# have been REMOVED — the page now only contains GILE selection dropdowns.
${SD_TITLE}                         css=[data-testid='gile-form-title']

# GILE dropdowns (institute/location/board/academic year)
${SD_INSTITUTE_SELECT}              css=[data-testid='institute-id-react-select']
${SD_LOCATION_SELECT}               css=[data-testid='location-id-react-select']
${SD_BOARD_SELECT}                  css=[data-testid='board-id-react-select']
${SD_ACADEMIC_YEAR_SELECT}          css=[data-testid='academic-year-id-react-select']

# Student details form
${SD_FORM}                          css=[data-testid='student-details-form']
${SD_FIRST_NAME}                    css=[data-testid='first-name-input']
${SD_LAST_NAME}                     css=[data-testid='last-name-input']
${SD_STUDENT_TYPE_RADIO}            css=[data-testid='student-type-radio']
${SD_CLASS_SELECT}                  css=[data-testid='class-id-react-select']
${SD_STUDENT_ID}                    css=[data-testid='student-id-input']
${SD_LOAN_AMOUNT}                   css=[data-testid='loan-amount-input']
# NOTE: show-plans-button uses 'testidfor' attribute, not 'data-testid'
${SD_SHOW_PLANS_BUTTON}             css=[testidfor='show-plans-button']

*** Keywords ***
Student Details Title Should Be Visible
    [Documentation]
    ...    Asserts the student-details-title element is visible.
    ...    Satisfies: TC-5001, RT-2, U1
    Wait For Elements State    ${SD_TITLE}    visible    timeout=${TIMEOUT}

Student Details Form Should Be Visible
    [Documentation]
    ...    Asserts the student-details form container is visible.
    ...    Satisfies: TC-5001, RT-2, U1
    Wait For Elements State    ${SD_FORM}    visible    timeout=${TIMEOUT}

Admission Type Title Should Be Visible
    [Documentation]
    ...    Asserts the class dropdown (class-id-react-select) is visible in the personal
    ...    details section (replaces the removed admission-type-title section on UAT).
    ...    Requires GILE dropdowns to be filled first (personal details section is hidden
    ...    until GILE is complete). Use Navigate To Student Details With GILE Filled setup.
    ...    Satisfies: TC-5006, U1
    Wait For Elements State    ${SD_CLASS_SELECT}    visible    timeout=${TIMEOUT}

Annual Fee Title Should Be Visible
    [Documentation]
    ...    Asserts the loan-amount-input is visible in the personal details section
    ...    (replaces the removed annual-fee-title section on UAT).
    ...    Requires GILE dropdowns to be filled first (personal details section is hidden
    ...    until GILE is complete). Use Navigate To Student Details With GILE Filled setup.
    ...    Satisfies: TC-5007, U1
    Wait For Elements State    ${SD_LOAN_AMOUNT}    visible    timeout=${TIMEOUT}

GILE Institute Dropdown Should Be Visible
    [Documentation]
    ...    Asserts the institute GILE dropdown (institute-id-react-select) is visible.
    ...    Satisfies: TC-5002, U1
    Wait For Elements State    ${SD_INSTITUTE_SELECT}    visible    timeout=${TIMEOUT}

GILE Location Dropdown Should Be Visible
    [Documentation]
    ...    Asserts the location GILE dropdown (location-id-react-select) is visible.
    ...    Satisfies: TC-5003, U1
    Wait For Elements State    ${SD_LOCATION_SELECT}    visible    timeout=${TIMEOUT}

GILE Board Dropdown Should Be Visible
    [Documentation]
    ...    Asserts the board GILE dropdown (board-id-react-select) is visible.
    ...    Satisfies: TC-5004, U1
    Wait For Elements State    ${SD_BOARD_SELECT}    visible    timeout=${TIMEOUT}

GILE Academic Year Dropdown Should Be Visible
    [Documentation]
    ...    Asserts the academic year GILE dropdown (academic-year-id-react-select) is visible.
    ...    Satisfies: TC-5005, U1
    Wait For Elements State    ${SD_ACADEMIC_YEAR_SELECT}    visible    timeout=${TIMEOUT}

First Name Input Should Be Visible
    [Documentation]
    ...    Asserts the first-name-input field is visible.
    ...    Satisfies: TC-5009, U1
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${TIMEOUT}

Last Name Input Should Be Visible
    [Documentation]
    ...    Asserts the last-name-input field is visible.
    ...    Satisfies: TC-5010, U1
    Wait For Elements State    ${SD_LAST_NAME}    visible    timeout=${TIMEOUT}

Student ID Input Should Be Visible
    [Documentation]
    ...    Asserts the student-id-input field is visible.
    ...    Satisfies: TC-5012, U1
    Wait For Elements State    ${SD_STUDENT_ID}    visible    timeout=${TIMEOUT}

Loan Amount Input Should Be Visible
    [Documentation]
    ...    Asserts the loan-amount-input field is visible.
    ...    Satisfies: TC-5013, U1
    Wait For Elements State    ${SD_LOAN_AMOUNT}    visible    timeout=${TIMEOUT}

Show Plans Button Should Be Visible
    [Documentation]
    ...    Asserts the show-plans-button is visible on the page.
    ...    Uses LONG_TIMEOUT — the button only appears after form validation completes
    ...    across all GILE and personal detail fields, which can take up to 30s.
    ...    Satisfies: TC-5014, U1
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}

Fill First Name
    [Documentation]
    ...    Fills the first-name-input with the given value.
    ...    Satisfies: TC-5009
    [Arguments]    ${value}
    Wait For Elements State    ${SD_FIRST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SD_FIRST_NAME}    ${value}

Fill Last Name
    [Documentation]
    ...    Fills the last-name-input with the given value.
    ...    Satisfies: TC-5010
    [Arguments]    ${value}
    Wait For Elements State    ${SD_LAST_NAME}    visible    timeout=${TIMEOUT}
    Fill Text    ${SD_LAST_NAME}    ${value}

Fill Student ID
    [Documentation]    Fills the student-id-input with the given value.
    [Arguments]    ${value}
    Wait For Elements State    ${SD_STUDENT_ID}    visible    timeout=${TIMEOUT}
    Fill Text    ${SD_STUDENT_ID}    ${value}

Fill Loan Amount
    [Documentation]    Fills the loan-amount-input with the given value.
    [Arguments]    ${value}
    Wait For Elements State    ${SD_LOAN_AMOUNT}    visible    timeout=${TIMEOUT}
    Fill Text    ${SD_LOAN_AMOUNT}    ${value}

Student Type Radio Should Be Visible
    [Documentation]
    ...    Asserts the first student-type-radio element is visible.
    ...    Uses >> nth=0 because two radio buttons share the data-testid (EXISTING and NEW).
    ...    Satisfies: TC-5011, U1
    Wait For Elements State    ${SD_STUDENT_TYPE_RADIO} >> nth=0    visible    timeout=${TIMEOUT}

Student Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /student-details.
    ${url}=    Get Url
    Should Contain    ${url}    /student-details
