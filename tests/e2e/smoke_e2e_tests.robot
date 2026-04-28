*** Settings ***
Documentation
...    Smoke E2E test — single fixed happy-path run of the full application creation journey.
...    Login → Dashboard → Student Details → Choose Plan → Select Applicant →
...    Basic Details → Onboarding → Personal Details → Residential Details →
...    Employment (Salaried) → Confirm Application → Assert Success.
...
...    Uses a randomly generated mobile (new account per run).
...    Fixed stub data from APP_* variables in variables.robot.
...
...    Run:
...      ./venv/bin/robot --outputdir results/ tests/e2e/smoke_e2e_tests.robot
...
...    Tags: e2e, smoke

Library     ../../libraries/ApplicationDataReader.py
Resource    ../../resources/E2EApplicationFlow.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Test Tags   e2e    smoke

*** Test Cases ***
Smoke E2E Create Application — Salaried Parent Guardian
    [Documentation]
    ...    Full end-to-end happy path: new user, salaried employment, Parent/Guardian applicant type.
    ...    Uses fixed APP_* stub data. Mobile is auto-generated (new account each run).
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Application
    ...    ${EMPTY}
    ...    ${APP_INSTITUTE_SEARCH}
    ...    ${EMPTY}
    ...    ${EMPTY}
    ...    ${EMPTY}
    ...    ${APP_STUDENT_FIRST_NAME}
    ...    ${APP_STUDENT_LAST_NAME}
    ...    New Admission
    ...    ${EMPTY}
    ...    ST_001
    ...    ${APP_LOAN_AMOUNT}
    ...    Parent/Guardian
    ...    ${APP_FIRST_NAME}
    ...    ${APP_LAST_NAME}
    ...    ${APP_PAN_NUMBER}
    ...    Female
    ...    ${APP_DOB_YEAR}
    ...    ${APP_DOB_MONTH}
    ...    ${APP_DOB_DAY}
    ...    Married
    ...    ${APP_EMAIL}
    ...    ${APP_ADDRESS_LINE1}
    ...    ${APP_ADDRESS_LINE2}
    ...    ${APP_PINCODE}
    ...    Self Owned
    ...    Salaried
    ...    ${APP_EMPLOYER_NAME}
    ...    ${APP_MONTHLY_SALARY}
    ...    ${EMPTY}
    ...    ${EMPTY}
    ...    ${EMPTY}
    ...    ${EMPTY}
    ...    ${EMPTY}
