*** Settings ***
Documentation
...    Smoke E2E — complete customer journey from Login to Lender Selection / KYC.
...
...    Flow:
...      Login → Dashboard → Student Details → Choose Plan → Select Applicant →
...      Basic Details → Onboarding → Personal Details → Residential Details →
...      Employment (Salaried) → Confirm Application → Lender Selection → KYC / Bank Statement
...
...    Lender is DYNAMIC:
...      - Set env var LENDER_NAME=<lender>  to pick a specific lender (e.g. "Western Capital")
...      - Leave LENDER_NAME blank           to auto-select the first available lender
...      - Pass lender_name per-row in application_data.xlsx for data-driven runs
...
...    Run:
...      ./env/bin/robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot
...
...      # With a specific lender:
...      LENDER_NAME="Western Capital" ./env/bin/robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot

Library     ../../libraries/ApplicationDataReader.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../resources/LenderSelectionPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Test Tags   e2e    smoke

*** Test Cases ***
Smoke E2E Full Journey — Login To Lender Selection
    [Documentation]
    ...    Complete happy-path journey: new user, salaried employment, Parent/Guardian applicant.
    ...    Mobile is auto-generated each run (new account every time).
    ...    Lender is DYNAMIC — set LENDER_NAME env var or leave blank for first available lender.
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Application With Lender Assignment
    ...    student_first_name=${APP_STUDENT_FIRST_NAME}
    ...    student_last_name=${APP_STUDENT_LAST_NAME}
    ...    loan_amount=${APP_LOAN_AMOUNT}
    ...    applicant_first_name=${APP_FIRST_NAME}
    ...    applicant_last_name=${APP_LAST_NAME}
    ...    pan_number=${APP_PAN_NUMBER}
    ...    dob_year=${APP_DOB_YEAR}
    ...    dob_month=${APP_DOB_MONTH}
    ...    dob_day=${APP_DOB_DAY}
    ...    email=${APP_EMAIL}
    ...    address_line1=${APP_ADDRESS_LINE1}
    ...    address_line2=${APP_ADDRESS_LINE2}
    ...    pincode=${APP_PINCODE}
    ...    employer_name=${APP_EMPLOYER_NAME}
    ...    monthly_salary=${APP_MONTHLY_SALARY}
    ...    plan_index=1
    ...    lender_name=${LENDER_NAME}
    Wait For Bureau Decision
    ${url}=    Get Url
    IF    '/application-status/' in '${url}'
        Log    ✅ Lender APPROVED — reached KYC page    console=True
        Successful Lender Assignment Should Be Visible
    ELSE IF    '/bank-statement/' in '${url}'
        Log    ℹ️ Lender REJECTED — redirected to Bank Statement    console=True
    ELSE
        Log    ⚠️ Unknown state after bureau decision: ${url}    console=True
    END
