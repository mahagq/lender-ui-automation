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
# NOTE: Both gile-form-title (GILE section) and student-details-title (personal details section)
# coexist on the page. student-details-title is only visible after GILE dropdowns are filled.
# Confirmed by recording login_20260424_145708.js (lines 30, 64).
${SD_TITLE}                         css=[data-testid='gile-form-title']
${SD_STUDENT_DETAILS_TITLE}         css=[data-testid='student-details-title']

# Page subtitle (visible on initial page load, above GILE section)
${SD_PAGE_SUBTITLE}                 text=Enter the Student Details to

# Facing issue support link and modal (testid confirmed in recording login_20260424_145708.js)
${SD_FACING_ISSUE_LINK}             css=[data-testid='facing-issue-text'] >>nth=0
${SD_SUPPORT_HEADING}               text=Facing any issues?
${SD_SUPPORT_CONTACT}               text=Contact Number:
${SD_SUPPORT_EMAIL}                 text=Support Email:
${SD_SUPPORT_CLOSE}                 css=button[aria-label="Close"]

# GILE dropdowns (institute/location/board/academic year)
${SD_INSTITUTE_SELECT}              css=[data-testid='institute-id-react-select']
${SD_LOCATION_SELECT}               css=[data-testid='location-id-react-select']
${SD_BOARD_SELECT}                  css=[data-testid='board-id-react-select']
${SD_ACADEMIC_YEAR_SELECT}          css=[data-testid='academic-year-id-react-select']

# Student details form and section titles
# NOTE: admission-type-title and annual-fee-title were previously believed removed.
# Recording login_20260424_145708.js (lines 65–66) confirms both exist on UAT.
${SD_FORM}                          css=[data-testid='student-details-form']
${SD_ADMISSION_TYPE_TITLE}          css=[data-testid='admission-type-title']
${SD_ANNUAL_FEE_TITLE}              css=[data-testid='annual-fee-title']

# Student personal detail inputs
${SD_FIRST_NAME}                    css=[data-testid='first-name-input']
${SD_LAST_NAME}                     css=[data-testid='last-name-input']
${SD_STUDENT_TYPE_RADIO}            css=[data-testid='student-type-radio']
${SD_EXISTING_STUDENT}              text=Existing Student
${SD_NEW_ADMISSION}                 text=New Admission
${SD_CLASS_SELECT}                  css=[data-testid='class-id-react-select']
${SD_STUDENT_ID}                    css=[data-testid='student-id-input']
${SD_LOAN_AMOUNT}                   css=[data-testid='loan-amount-input']

# Validation error messages (visible after Show Plans clicked with empty required fields)
${SD_FIRST_NAME_ERROR}              css=[data-testid='first-name-input-error']
${SD_LAST_NAME_ERROR}               css=[data-testid='last-name-input-error']
${SD_CLASS_ERROR}                   css=[data-testid='class-id-react-select-error']
${SD_LOAN_AMOUNT_ERROR}             css=[data-testid='loan-amount-input-error']

# NOTE: show-plans-button uses 'testidfor' attribute, not 'data-testid'
${SD_SHOW_PLANS_BUTTON}             css=[testidfor='show-plans-button']

# Close button — /student-details has no back-button; the exit control is a Close button
${SD_CLOSE_BUTTON}                  css=[data-testid='close-button']

# react-select first option — approved T1 exception (react-select package class, not CSS Modules)
${SD_INSTITUTE_INPUT}               css=[data-testid='institute-id-react-select'] input[role='combobox']
${SD_LOCATION_FIRST_OPTION}         css=[data-testid='location-id-react-select'] input[role='combobox']
${SD_BOARD_FIRST_OPTION}            css=[data-testid='board-id-react-select'] input[role='combobox']
${SD_ACADEMIC_YEAR_FIRST_OPTION}    css=[data-testid='academic-year-id-react-select'] .react-select__option:first-child
${SD_CLASS_FIRST_OPTION}            css=[data-testid='class-id-react-select'] .react-select__option:first-child

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
    ...    Asserts the admission-type-title element is visible in the personal details section.
    ...    Requires GILE dropdowns to be filled first (personal details section is hidden
    ...    until GILE is complete). Use Navigate To Student Details With GILE Filled setup.
    ...    Satisfies: TC-5006, U1
    Wait For Elements State    ${SD_ADMISSION_TYPE_TITLE}    visible    timeout=${TIMEOUT}

Annual Fee Title Should Be Visible
    [Documentation]
    ...    Asserts the annual-fee-title element is visible in the personal details section.
    ...    Requires GILE dropdowns to be filled first (personal details section is hidden
    ...    until GILE is complete). Use Navigate To Student Details With GILE Filled setup.
    ...    Satisfies: TC-5007, U1
    Wait For Elements State    ${SD_ANNUAL_FEE_TITLE}    visible    timeout=${TIMEOUT}

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

Page Subtitle Should Be Visible
    [Documentation]
    ...    Asserts the "Enter the Student Details to" subtitle text is visible on page load.
    ...    Satisfies: TC-5015, U1
    Wait For Elements State    ${SD_PAGE_SUBTITLE}    visible    timeout=${TIMEOUT}

Student Details Section Title Should Be Visible
    [Documentation]
    ...    Asserts the student-details-title section heading is visible.
    ...    This title appears in the personal details section, visible after GILE is filled.
    ...    Requires Navigate To Student Details With GILE Filled setup.
    ...    Satisfies: TC-5016, U1
    Wait For Elements State    ${SD_STUDENT_DETAILS_TITLE}    visible    timeout=${TIMEOUT}

Facing Issue Link Should Be Visible
    [Documentation]
    ...    Asserts the facing-issue-text support link is visible on the page.
    ...    Satisfies: TC-5017, U1
    Wait For Elements State    ${SD_FACING_ISSUE_LINK}    visible    timeout=${TIMEOUT}

Support Modal Shows Contact And Email
    [Documentation]
    ...    Clicks the facing-issue-text link, asserts the support modal shows
    ...    Contact Number and Support Email, then closes the modal.
    ...    Satisfies: TC-5018, U1
    Wait For Elements State    ${SD_FACING_ISSUE_LINK}    visible    timeout=${TIMEOUT}
    Click    ${SD_FACING_ISSUE_LINK}
    Wait For Elements State    ${SD_SUPPORT_CONTACT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${SD_SUPPORT_EMAIL}    visible    timeout=${TIMEOUT}
    Click    ${SD_SUPPORT_CLOSE}
    Wait For Elements State    ${SD_SUPPORT_CONTACT}    hidden    timeout=${TIMEOUT}

Existing Student Option Should Be Visible
    [Documentation]
    ...    Asserts the "Existing Student" student-type option is visible in the personal
    ...    details section. Requires GILE filled.
    ...    Satisfies: TC-5019, U1
    Wait For Elements State    ${SD_EXISTING_STUDENT}    visible    timeout=${TIMEOUT}

New Admission Option Should Be Visible
    [Documentation]
    ...    Asserts the "New Admission" student-type option is visible in the personal
    ...    details section. Requires GILE filled.
    ...    Satisfies: TC-5020, U1
    Wait For Elements State    ${SD_NEW_ADMISSION}    visible    timeout=${TIMEOUT}

Show Plans Validation Errors Should Be Visible
    [Documentation]
    ...    Clicks the Show Plans button without filling required personal detail fields
    ...    and asserts all four validation error messages are visible.
    ...    Requires GILE filled (so personal details section is visible) but personal
    ...    detail fields must remain empty.
    ...    Satisfies: TC-5021, U1
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}
    Wait For Elements State    ${SD_FIRST_NAME_ERROR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${SD_LAST_NAME_ERROR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${SD_CLASS_ERROR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${SD_LOAN_AMOUNT_ERROR}    visible    timeout=${TIMEOUT}

Student Details URL Should Be Active
    [Documentation]    Helper — asserts the current URL contains /student-details.
    ${url}=    Get Url
    Should Contain    ${url}    /student-details

Select GILE Institute
    [Documentation]
    ...    Types the institute search term, waits 2s for async API results, then selects
    ...    the first result using ArrowDown + Enter keyboard navigation.
    ...    react-select portals the menu outside the container so CSS descendant selectors
    ...    cannot reach the options — keyboard navigation is the reliable alternative.
    ...    Mirrors Search And Select First Option In React Select (ApplicationCreationFlowPage.robot).
    ...    Satisfies: TC-5022
    Wait For Elements State    ${SD_INSTITUTE_INPUT}    visible    timeout=${TIMEOUT}
    Click    ${SD_INSTITUTE_INPUT}
    Type Text    ${SD_INSTITUTE_INPUT}    ${APP_INSTITUTE_SEARCH}
    Sleep    2s
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Select GILE Location
    [Documentation]
    ...    Opens the location dropdown and selects the first option via ArrowDown + Enter.
    ...    Requires institute to be selected first (cascade dependency).
    ...    Clicks the container (not the inner input) and waits 500ms for the portal menu
    ...    to render — mirrors Select First Option In React Select (ApplicationCreationFlowPage.robot).
    ...    Satisfies: TC-5023
    Wait For Elements State    ${SD_LOCATION_SELECT}    visible    timeout=${TIMEOUT}
    Click    ${SD_LOCATION_SELECT}
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Select GILE Board
    [Documentation]
    ...    Opens the board dropdown and selects the first option via ArrowDown + Enter.
    ...    Requires institute + location to be selected first.
    ...    Clicks the container (not the inner input) and waits 500ms for the portal menu
    ...    to render — mirrors Select First Option In React Select (ApplicationCreationFlowPage.robot).
    ...    Satisfies: TC-5024
    Wait For Elements State    ${SD_BOARD_SELECT}    visible    timeout=${TIMEOUT}
    Click    ${SD_BOARD_SELECT}
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Select GILE Academic Year
    [Documentation]
    ...    Opens the academic year dropdown and selects the first option via ArrowDown + Enter.
    ...    Requires institute + location + board to be selected first.
    ...    Clicks the container and waits 500ms for the portal menu to render.
    ...    Satisfies: TC-5025
    Wait For Elements State    ${SD_ACADEMIC_YEAR_SELECT}    visible    timeout=${TIMEOUT}
    Click    ${SD_ACADEMIC_YEAR_SELECT}
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Select GILE Class
    [Documentation]
    ...    Opens the class dropdown and selects the first option via ArrowDown + Enter.
    ...    Requires GILE filled (personal details section visible).
    ...    Clicks the container and waits 500ms for the portal menu to render.
    ...    Satisfies: TC-5026
    Wait For Elements State    ${SD_CLASS_SELECT}    visible    timeout=${TIMEOUT}
    Click    ${SD_CLASS_SELECT}
    Sleep    500ms
    Keyboard Key    press    ArrowDown
    Keyboard Key    press    Enter

Personal Details Section Should Appear After GILE
    [Documentation]
    ...    Asserts student-details-title becomes visible after all GILE dropdowns are filled.
    ...    Satisfies: TC-5025
    Wait For Elements State    ${SD_STUDENT_DETAILS_TITLE}    visible    timeout=${LONG_TIMEOUT}

Personal Details Section Should Not Be Visible
    [Documentation]
    ...    Asserts student-details-title is hidden before GILE is filled.
    ...    Satisfies: TC-5N-01
    Wait For Elements State    ${SD_STUDENT_DETAILS_TITLE}    hidden    timeout=${TIMEOUT}

Show Plans Button Should Not Be Visible
    [Documentation]
    ...    Asserts show-plans-button is not present before GILE is complete.
    ...    Satisfies: TC-5N-02
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    hidden    timeout=${TIMEOUT}

Student First Name Error Should Be Visible
    [Documentation]    Asserts first-name-input-error is visible. Satisfies: TC-5N-04, TC-5N-07.
    Wait For Elements State    ${SD_FIRST_NAME_ERROR}    visible    timeout=${TIMEOUT}

Student Last Name Error Should Be Visible
    [Documentation]    Asserts last-name-input-error is visible. Satisfies: TC-5N-03, TC-5N-07.
    Wait For Elements State    ${SD_LAST_NAME_ERROR}    visible    timeout=${TIMEOUT}

Student Class Error Should Be Visible
    [Documentation]    Asserts class-id-react-select-error is visible. Satisfies: TC-5N-03, TC-5N-07.
    Wait For Elements State    ${SD_CLASS_ERROR}    visible    timeout=${TIMEOUT}

Student Loan Amount Error Should Be Visible
    [Documentation]    Asserts loan-amount-input-error is visible. Satisfies: TC-5N-06, TC-5N-08.
    Wait For Elements State    ${SD_LOAN_AMOUNT_ERROR}    visible    timeout=${TIMEOUT}

Click Show Plans Button
    [Documentation]    Clicks the Show Plans button. Satisfies: TC-5N-03 through TC-5N-08.
    Wait For Elements State    ${SD_SHOW_PLANS_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${SD_SHOW_PLANS_BUTTON}

Navigate Back From Student Details
    [Documentation]
    ...    Clicks the Close button on /student-details to return to /my-applications.
    ...    /student-details has no back-button — the exit control is data-testid='close-button'.
    ...    Satisfies: TC-5027
    Wait For Elements State    ${SD_CLOSE_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${SD_CLOSE_BUTTON}
