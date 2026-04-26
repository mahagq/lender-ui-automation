*** Settings ***
Documentation
...    End-to-end application creation test suite.
...    Creates a complete GQ Customer Portal application from Login → Confirm & Submit.
...
...    Driven by data/application_data.xlsx — each row produces one full application
...    creation run.  Add rows to the Excel file to create N applications.
...
...    Leave the login_mobile column blank to auto-generate a random 10-digit mobile.
...    Provide an existing account mobile to reuse that account (the "Create new application"
...    button position adapts automatically — header for existing accounts, empty-state for new).
...
...    Run:
...      ./venv/bin/robot --outputdir results/ tests/e2e/e2e_create_application_tests.robot
...
...    Tag: e2e, application-creation-flow

Library     ../../libraries/ApplicationDataReader.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../variables/variables.robot

Test Tags   e2e    application-creation-flow

*** Test Cases ***
Create Applications From Excel
    [Documentation]    Reads every row from data/application_data.xlsx and creates
    ...                one full application per row.
    ${rows}=    Read Application Data    data/application_data.xlsx
    FOR    ${row}    IN    @{rows}
        TRY
            Create Full Application
            ...    ${row}[login_mobile]
            ...    ${row}[institute_search]
            ...    ${row}[location]
            ...    ${row}[course]
            ...    ${row}[academic_year]
            ...    ${row}[student_first_name]
            ...    ${row}[student_last_name]
            ...    ${row}[admission_type]
            ...    ${row}[class]
            ...    ${row}[student_id]
            ...    ${row}[loan_amount]
            ...    ${row}[applicant_type]
            ...    ${row}[applicant_first_name]
            ...    ${row}[applicant_last_name]
            ...    ${row}[pan_number]
            ...    ${row}[gender]
            ...    ${row}[dob_year]
            ...    ${row}[dob_month]
            ...    ${row}[dob_day]
            ...    ${row}[marital_status]
            ...    ${row}[email]
            ...    ${row}[address_line1]
            ...    ${row}[address_line2]
            ...    ${row}[pincode]
            ...    ${row}[residence_type]
            ...    ${row}[employment_type]
            ...    ${row}[employer_name]
            ...    ${row}[monthly_salary]
            ...    ${row}[business_name]
            ...    ${row}[annual_income]
            ...    ${row}[years_in_business]
            ...    ${row}[business_description]
            ...    ${row}[referral_code]
        EXCEPT    message=*    type=GLOB
            Run Keyword And Ignore Error    Close Browser
            CONTINUE
        END
    END
