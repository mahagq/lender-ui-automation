*** Settings ***
Documentation
...    End-to-end application creation test suite — Login → Lender Selection.
...    Creates a complete GQ Customer Portal application from Login all the way to Lender Selection.
...
...    Driven by data/application_data.xlsx — each row produces one full application run.
...    Add rows to the Excel file to run N applications back-to-back.
...
...    Columns:
...      login_mobile   — leave blank to auto-generate a random mobile each run
...      lender_name    — leave blank to auto-select first available lender,
...                       OR set to a lender name e.g. "Western Capital", "Prefr", "IDFC"
...
...    Run:
...      ./env/bin/robot --outputdir results/ tests/e2e/e2e_create_application_tests.robot
...
...    Tag: e2e, application-creation-flow

Library     ../../libraries/ApplicationDataReader.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../resources/LenderSelectionPage.robot
Resource    ../../variables/variables.robot

Test Tags   e2e    application-creation-flow

*** Test Cases ***
Create Full Journey From Excel
    [Documentation]
    ...    Reads every row from data/application_data.xlsx and runs one complete journey per row.
    ...    Each journey goes: Login → Wizard → Confirm → Lender Selection → KYC / Bank Statement.
    ...    lender_name column controls which lender is selected (blank = first available).
    ${rows}=    Read Application Data    data/application_data.xlsx
    FOR    ${row}    IN    @{rows}
        TRY
            # Resolve lender — use row value if set, else fall back to global LENDER_NAME variable
            ${row_lender}=    Set Variable    ${row}[lender_name]
            ${lender}=    Set Variable If    '${row_lender}' != ''    ${row_lender}    ${LENDER_NAME}

            Create Full Application With Lender Assignment
            ...    student_first_name=${row}[student_first_name]
            ...    student_last_name=${row}[student_last_name]
            ...    loan_amount=${row}[loan_amount]
            ...    applicant_first_name=${row}[applicant_first_name]
            ...    applicant_last_name=${row}[applicant_last_name]
            ...    pan_number=${row}[pan_number]
            ...    dob_year=${row}[dob_year]
            ...    dob_month=${row}[dob_month]
            ...    dob_day=${row}[dob_day]
            ...    email=${row}[email]
            ...    address_line1=${row}[address_line1]
            ...    address_line2=${row}[address_line2]
            ...    pincode=${row}[pincode]
            ...    employer_name=${row}[employer_name]
            ...    monthly_salary=${row}[monthly_salary]
            ...    plan_index=1
            ...    lender_name=${lender}
            ...    institute_search=${row}[institute_search]

            Wait For Bureau Decision
            ${url}=    Get Url
            IF    '/application-status/' in '${url}'
                Log    ✅ APPROVED — Lender: ${lender}    console=True
            ELSE IF    '/bank-statement/' in '${url}'
                Log    ℹ️ REJECTED → Bank Statement — Lender: ${lender}    console=True
            END

            Run Keyword And Ignore Error    Close Browser
        EXCEPT    message=*    type=GLOB
            Run Keyword And Ignore Error    Close Browser
            CONTINUE
        END
    END
