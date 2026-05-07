*** Settings ***
Documentation
...    Test suite for the GQ Customer Portal Student Details page (/student-details).
...    New page — no Java TC coverage. TC-5001 to TC-5014.
...
...    Session model:
...      Suite Setup   → Create Application And Navigate To Student Details
...      Test Setup    → Navigate To Student Details Within Session
...      Test Teardown → NONE (shared session)
...      Suite Teardown → Close Browser
...    TC-5014 (submit with valid data) runs last — it advances the wizard to /choose-plan.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-2, B2 (new-page coverage), T1, U1

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/StudentDetailsPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Create Application And Navigate To Student Details
Suite Teardown  Close Browser
Test Setup      Navigate To Student Details Within Session
Test Tags       student-details    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Student Details

*** Test Cases ***
TC-5001 Student Details Page Title Is Visible
    [Documentation]    Verifies the student-details-title is visible on page load.
    [Tags]    smoke
    Student Details Title Should Be Visible
    Student Details Form Should Be Visible

TC-5002 GILE Institute Dropdown Is Visible
    [Documentation]    Verifies the institute-id-react-select dropdown is visible.
    GILE Institute Dropdown Should Be Visible

TC-5003 GILE Location Dropdown Is Visible
    [Documentation]    Verifies the location-id-react-select dropdown is visible.
    GILE Location Dropdown Should Be Visible

TC-5004 GILE Board Dropdown Is Visible
    [Documentation]    Verifies the board-id-react-select dropdown is visible.
    GILE Board Dropdown Should Be Visible

TC-5005 GILE Academic Year Dropdown Is Visible
    [Documentation]    Verifies the academic-year-id-react-select dropdown is visible.
    GILE Academic Year Dropdown Should Be Visible

TC-5006 Admission Type Title Is Visible
    [Documentation]
    ...    Verifies the admission-type-title element is visible in the personal details section.
    ...    Requires GILE filled. Confirmed by recording login_20260424_145708.js (line 65).
    [Setup]    Navigate To Student Details With GILE Filled
    Admission Type Title Should Be Visible

TC-5007 Annual Fee Title Is Visible
    [Documentation]
    ...    Verifies the annual-fee-title element is visible in the personal details section.
    ...    Requires GILE filled. Confirmed by recording login_20260424_145708.js (line 66).
    [Setup]    Navigate To Student Details With GILE Filled
    Annual Fee Title Should Be Visible

TC-5008 Student Details URL Is Correct
    [Documentation]    Verifies the page URL contains /student-details.
    Student Details URL Should Be Active

TC-5009 First Name Input Is Visible And Accepts Text
    [Documentation]    Verifies the first-name-input is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    First Name Input Should Be Visible
    Fill First Name    TestFirst

TC-5010 Last Name Input Is Visible And Accepts Text
    [Documentation]    Verifies the last-name-input is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Last Name Input Should Be Visible
    Fill Last Name    TestLast

TC-5011 Student Type Radio Is Visible
    [Documentation]    Verifies the student-type-radio options are visible on the page. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Student Type Radio Should Be Visible

TC-5012 Student ID Input Is Visible And Accepts Text
    [Documentation]    Verifies the student-id-input field is visible and accepts text input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Student ID Input Should Be Visible
    Fill Student ID    SD98765

TC-5013 Loan Amount Input Is Visible And Accepts Numbers
    [Documentation]    Verifies the loan-amount-input field is visible and accepts numeric input. Requires GILE filled.
    [Setup]    Navigate To Student Details With GILE Filled
    Loan Amount Input Should Be Visible
    Fill Loan Amount    75000

TC-5014 Show Plans Button Is Visible
    [Documentation]
    ...    Verifies the show-plans-button is visible after all fields (GILE + personal details)
    ...    are filled. show-plans-button only appears when the form is complete.
    ...    This test runs last — submit is NOT called here to preserve wizard state.
    [Tags]    smoke
    [Setup]    Navigate To Student Details With All Fields Filled
    Show Plans Button Should Be Visible

TC-5015 Page Subtitle Text Is Visible
    [Documentation]
    ...    Verifies the "Enter the Student Details to" subtitle text is visible on the page.
    ...    Satisfies: TC-5015
    Page Subtitle Should Be Visible

TC-5016 Student Details Section Title Is Visible
    [Documentation]
    ...    Verifies the student-details-title section heading is visible in the personal
    ...    details section after GILE is filled. student-details-title coexists with
    ...    gile-form-title on the same page.
    ...    Satisfies: TC-5016
    [Setup]    Navigate To Student Details With GILE Filled
    Student Details Section Title Should Be Visible

TC-5017 Facing Issues Support Link Is Visible
    [Documentation]
    ...    Verifies the facing-issue-text support link is visible on the page.
    ...    Satisfies: TC-5017
    Facing Issue Link Should Be Visible

TC-5018 Facing Issues Modal Shows Contact And Email
    [Documentation]
    ...    Verifies clicking the facing-issue-text link opens a support modal showing
    ...    Contact Number and Support Email entries, then closes the modal.
    ...    Satisfies: TC-5018
    Support Modal Shows Contact And Email

TC-5019 Student Type Has Existing Student Option
    [Documentation]
    ...    Verifies the "Existing Student" student-type option is visible in the personal
    ...    details section. Requires GILE filled.
    ...    Satisfies: TC-5019
    [Setup]    Navigate To Student Details With GILE Filled
    Existing Student Option Should Be Visible

TC-5020 Student Type Has New Admission Option
    [Documentation]
    ...    Verifies the "New Admission" student-type option is visible in the personal
    ...    details section. Requires GILE filled.
    ...    Satisfies: TC-5020
    [Setup]    Navigate To Student Details With GILE Filled
    New Admission Option Should Be Visible

TC-5021 Show Plans Shows Validation Errors When Required Fields Empty
    [Documentation]
    ...    Verifies clicking Show Plans without filling required personal detail fields
    ...    shows validation errors for first name, last name, class, and loan amount.
    ...    Requires GILE filled so the personal details section is visible.
    ...    Satisfies: TC-5021
    [Setup]    Navigate To Student Details With GILE Filled
    Show Plans Validation Errors Should Be Visible

# ===========================================================================
# GILE SELECTION — positive interaction (TC-5022–TC-5027)
# ===========================================================================

TC-5022 GILE Institute Dropdown Accepts Search And Selects First Option
    [Documentation]
    ...    Types search term into institute dropdown, waits for async results,
    ...    and selects the first option. Verifies dropdown interaction completes.
    ...    Satisfies: TC-5022
    Select GILE Institute
    GILE Institute Dropdown Should Be Visible

TC-5023 GILE Location Dropdown Is Selectable After Institute Selection
    [Documentation]
    ...    After institute is selected, verifies location dropdown is enabled
    ...    and first option can be selected.
    ...    Satisfies: TC-5023
    Select GILE Institute
    Select GILE Location
    GILE Location Dropdown Should Be Visible

TC-5024 GILE Board Dropdown Is Selectable After Institute And Location
    [Documentation]
    ...    After institute + location are selected, verifies board dropdown
    ...    is enabled and first option can be selected.
    ...    Satisfies: TC-5024
    Select GILE Institute
    Select GILE Location
    Select GILE Board
    GILE Board Dropdown Should Be Visible

TC-5025 Personal Details Section Appears After All GILE Dropdowns Filled
    [Documentation]
    ...    Fills all 4 GILE dropdowns in sequence and verifies the personal
    ...    details section (student-details-title) becomes visible.
    ...    Satisfies: TC-5025
    Select GILE Institute
    Select GILE Location
    Select GILE Board
    Select GILE Academic Year
    Personal Details Section Should Appear After GILE

TC-5026 Class Dropdown Is Visible And Selectable After GILE Filled
    [Documentation]
    ...    Verifies class dropdown is visible and first option is selectable
    ...    after GILE section is complete.
    ...    Satisfies: TC-5026
    [Setup]    Navigate To Student Details With GILE Filled
    Select GILE Class

TC-5027 Close Button Navigates To Dashboard
    [Documentation]
    ...    Verifies the Close button on /student-details navigates back to /my-applications.
    ...    /student-details has no back-button — exit is via data-testid='close-button'.
    ...    Satisfies: TC-5027
    Navigate Back From Student Details
    ${url}=    Get Url
    Should Contain    ${url}    /my-applications

# ===========================================================================
# NEGATIVE SCENARIOS (TC-5N-01–TC-5N-08)
# ===========================================================================

TC-5N-01 Personal Details Section Hidden Before GILE Is Filled
    [Documentation]
    ...    Verifies student-details-title is not visible on fresh page load
    ...    before any GILE dropdown is selected.
    ...    Satisfies: TC-5N-01
    [Tags]    negative
    Personal Details Section Should Not Be Visible

TC-5N-02 Show Plans Button Hidden Before GILE Is Filled
    [Documentation]
    ...    Verifies show-plans-button is not visible before GILE is complete.
    ...    Satisfies: TC-5N-02
    [Tags]    negative
    Show Plans Button Should Not Be Visible

TC-5N-03 Show Plans With Only First Name Shows Three Errors
    [Documentation]
    ...    Fills only first name, clicks Show Plans, and verifies last name,
    ...    class, and loan amount errors are all shown.
    ...    Satisfies: TC-5N-03
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Click Show Plans Button
    Student Last Name Error Should Be Visible
    Student Class Error Should Be Visible
    Student Loan Amount Error Should Be Visible

TC-5N-04 Show Plans With Only Last Name Shows Three Errors
    [Documentation]
    ...    Fills only last name, clicks Show Plans, and verifies first name,
    ...    class, and loan amount errors are all shown.
    ...    Satisfies: TC-5N-04
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Click Show Plans Button
    Student First Name Error Should Be Visible
    Student Class Error Should Be Visible
    Student Loan Amount Error Should Be Visible

TC-5N-05 Show Plans With Name Fields Filled But No Class Or Loan Shows Two Errors
    [Documentation]
    ...    Fills first and last name only, clicks Show Plans, and verifies
    ...    class and loan amount errors are shown.
    ...    Satisfies: TC-5N-05
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Click Show Plans Button
    Student Class Error Should Be Visible
    Student Loan Amount Error Should Be Visible

TC-5N-06 Show Plans With Name And Class Filled But No Loan Shows Loan Error
    [Documentation]
    ...    Fills first name, last name, and class, clicks Show Plans,
    ...    and verifies only loan amount error is shown.
    ...    Satisfies: TC-5N-06
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

TC-5N-07 Show Plans With Only Loan Amount Filled Shows Three Errors
    [Documentation]
    ...    Fills only loan amount, clicks Show Plans, and verifies first name,
    ...    last name, and class errors are all shown.
    ...    Satisfies: TC-5N-07
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill Loan Amount    ${APP_LOAN_AMOUNT}
    Click Show Plans Button
    Student First Name Error Should Be Visible
    Student Last Name Error Should Be Visible
    Student Class Error Should Be Visible

TC-5N-08 Show Plans With Loan Amount Zero Shows Loan Error
    [Documentation]
    ...    Fills all required fields with loan amount = 0, clicks Show Plans,
    ...    and verifies the loan amount error is shown.
    ...    Satisfies: TC-5N-08
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    0
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

TC-5N-09 Numeric Student First Name Shows First Name Error
    [Documentation]
    ...    Verifies first-name-input-error appears when student first name contains only numbers.
    ...    Satisfies: TC-5N-09
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    12345
    Click Show Plans Button
    Student First Name Error Should Be Visible

TC-5N-10 Special Chars In Student First Name Show First Name Error
    [Documentation]
    ...    Verifies first-name-input-error appears when student first name contains special characters.
    ...    Satisfies: TC-5N-10
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    Test@#!
    Click Show Plans Button
    Student First Name Error Should Be Visible

TC-5N-11 Numeric Student Last Name Shows Last Name Error
    [Documentation]
    ...    Verifies last-name-input-error appears when student last name contains only numbers.
    ...    Satisfies: TC-5N-11
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill Last Name    12345
    Click Show Plans Button
    Student Last Name Error Should Be Visible

TC-5N-12 Special Chars In Student Last Name Show Last Name Error
    [Documentation]
    ...    Verifies last-name-input-error appears when student last name contains special characters.
    ...    Satisfies: TC-5N-12
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill Last Name    Test@#!
    Click Show Plans Button
    Student Last Name Error Should Be Visible

TC-5N-13 Alphabets In Loan Amount Show Loan Amount Error
    [Documentation]
    ...    Verifies loan-amount-input-error appears when loan amount contains alphabetic characters.
    ...    Fills valid names and class so only the loan amount error is shown.
    ...    Satisfies: TC-5N-13
    [Setup]    Navigate To Student Details With GILE Filled
    [Tags]    negative
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    abcde
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

# ===========================================================================
# Extra SCENARIOS 
# ===========================================================================

GILE Location Resets When Institute Is Changed
    [Documentation]
    ...    Verifies that changing the institute selection resets the location dropdown
    ...    (i.e. location selection is cleared and dropdown goes back to placeholder state).
    [Tags]    robot:skip
    Select GILE Institute
    Select GILE Location
    ${location}=    Get Selected GILE Location
    Should Not Be Empty    ${location}    msg=Precondition failed: location should be selected
    Select Different GILE Institute
    ${location_after}=    Get Selected GILE Location
    Should Be Empty    ${location_after}    msg=Location should be reset after changing institute

GILE Board Resets When Location Is Changed
    [Documentation]
    ...    Verifies that changing the location selection resets the board dropdown
    ...    (i.e. board selection is cleared and dropdown goes back to placeholder state).
    [Tags]    robot:skip
    Select GILE Institute
    Select GILE Location
    Select GILE Board
    ${board}=    Get Selected GILE Board
    Should Not Be Empty    ${board}    msg=Precondition failed: board should be selected
    Select Different GILE Location
    ${board_after}=    Get Selected GILE Board
    Should Be Empty    ${board_after}    msg=Board should be reset after changing location

Academic Year Dropdown Shows Default Placeholder
    [Documentation]
    ...    Verifies that the academic year dropdown shows the default placeholder text
    ...    before any selection is made, and that it is selectable after institute, location, and board are selected.
    [Tags]    robot:skip
    Select GILE Institute
    Select GILE Location
    Select GILE Board
    Academic Year Dropdown Should Show Placeholder
    Select GILE Academic Year
    GILE Academic Year Dropdown Should Be Visible

Loan Amount Negative Value Shows Error
    [Documentation]
    ...    Verifies that entering a negative value in the loan amount field shows a validation error.
    ...    Satisfies: TC-5N-14
    [Setup]    Navigate To Student Details With GILE Filled
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    -50000
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

Loan Amount Accepts Decimal Values Shows Error
    [Documentation]
    ...    Verifies that entering a decimal value in the loan amount field shows a validation error.
    ...    Satisfies: TC-5N-15
    [Setup]    Navigate To Student Details With GILE Filled
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    50000.75
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

Loan Amount With Leading Zeros Shows Error
    [Documentation]
    ...    Verifies that entering a loan amount with leading zeros shows a validation error.
    ...    Satisfies: TC-5N-16
    [Setup]    Navigate To Student Details With GILE Filled
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    00050000
    Click Show Plans Button
    Student Loan Amount Error Should Be Visible

Error Messages Disappear After Correct Input Is Entered
    [Documentation]
    ...    Verifies that after triggering validation errors, correcting the input removes the error messages.
    ...    Satisfies: TC-5N-17
    [Tags]    robot:skip
    [Setup]    Navigate To Student Details With GILE Filled
    Click Show Plans Button
    Student First Name Error Should Be Visible
    Student Last Name Error Should Be Visible
    Student Class Error Should Be Visible
    Student Loan Amount Error Should Be Visible
    Fill First Name    ${APP_STUDENT_FIRST_NAME}
    Fill Last Name    ${APP_STUDENT_LAST_NAME}
    Select GILE Class
    Fill Loan Amount    ${APP_LOAN_AMOUNT}
    Click Show Plans Button
    Student First Name Error Should Not Be Visible
    Student Last Name Error Should Not Be Visible
    Student Class Error Should Not Be Visible
    Student Loan Amount Error Should Not Be Visible


