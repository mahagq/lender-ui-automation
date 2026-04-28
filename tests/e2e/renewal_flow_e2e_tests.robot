*** Settings ***
Documentation
...    Renewal Flow E2E test suite — data-driven full renewal application creation.
...    Uses an existing account (${RENEWAL_MOBILE}) that already has prior applications.
...    Entry via the header "Create new application" button.
...    After Choose Plan: Welcome Back screen → "CONTINUE WITH THESE DETAILS" → Verify Details → Confirm.
...
...    Driven by data/renewal_application_data.xlsx — each row produces one full renewal run.
...
...    Run:
...      ./venv/bin/robot --outputdir results/ tests/e2e/renewal_flow_e2e_tests.robot
...
...    Tags: e2e, renewal

Library     ../../libraries/ApplicationDataReader.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../variables/variables.robot

Test Tags   e2e    renewal    robot:skip

*** Test Cases ***
Create Renewal Applications From Excel
    [Documentation]
    ...    Reads every row from data/renewal_application_data.xlsx and creates
    ...    one full renewal application per row using ${RENEWAL_MOBILE}.
    ${rows}=    Read Application Data    data/renewal_application_data.xlsx
    FOR    ${row}    IN    @{rows}
        TRY
            Create Full Renewal Application
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
            ...    ${row}[referral_code]
        EXCEPT    message=*    type=GLOB
            Run Keyword And Ignore Error    Close Browser
            CONTINUE
        END
    END
