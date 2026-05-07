*** Settings ***
Documentation
...    E2E lender selection tests.
...    Each test owns its browser session (New Browser / Close Browser).
...    E01: New application → BRE APPROVED → KYC
...    E02: New application → BRE REJECTED → Bank Statement page (Plan 2)
...    E03: Renewal application → BRE APPROVED → KYC
...    E04: Renewal application → BRE REJECTED → Bank Statement page (Plan 2)

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../resources/E2EApplicationFlow.robot
Resource     ../../resources/LenderSelectionPage.robot
Resource     ../../resources/OKYCPage.robot
Resource     ../../resources/BankStatementPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Test Tags        lender-selection-e2e    regression    robot:skip
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection E2E


*** Test Cases ***
TC-LS-E01 Full New Application Journey Lender Approved Reaches KYC
    [Documentation]    Full E2E: Login → Application Creation → Lender Selection → BRE APPROVED → KYC page.
    [Tags]    smoke    e2e-accept
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Application With Lender Assignment
    ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    ${APP_LOAN_AMOUNT}
    ...    ${APP_FIRST_NAME}    ${APP_LAST_NAME}    ${APP_PAN_NUMBER}
    ...    ${APP_DOB_YEAR}    ${APP_DOB_MONTH}    ${APP_DOB_DAY}
    ...    ${APP_EMAIL}    ${APP_ADDRESS_LINE1}    ${APP_ADDRESS_LINE2}    ${APP_PINCODE}
    ...    ${APP_EMPLOYER_NAME}    ${APP_MONTHLY_SALARY}
    ...    lender_decision=APPROVED
    OKYC URL Should Be Active

TC-LS-E02 Full New Application Journey Lender Rejected Reaches Bank Statement
    [Documentation]    Full E2E: Login → Application Creation (Plan 2) → Lender Selection → BRE REJECTED → Bank Statement page.
    [Tags]    e2e-reject
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Application With Lender Assignment
    ...    ${APP_STUDENT_FIRST_NAME}    ${APP_STUDENT_LAST_NAME}    ${APP_LOAN_AMOUNT}
    ...    ${APP_FIRST_NAME}    ${APP_LAST_NAME}    ${APP_PAN_NUMBER}
    ...    ${APP_DOB_YEAR}    ${APP_DOB_MONTH}    ${APP_DOB_DAY}
    ...    ${APP_EMAIL}    ${APP_ADDRESS_LINE1}    ${APP_ADDRESS_LINE2}    ${APP_PINCODE}
    ...    ${APP_EMPLOYER_NAME}    ${APP_MONTHLY_SALARY}
    ...    plan_index=2    lender_decision=REJECTED
    Bank Statement Select Bank URL Should Be Active

TC-LS-E03 Full Renewal Journey Lender Approved Reaches KYC
    [Documentation]    Full E2E: Login (RENEWAL_MOBILE) → Renewal Application → Lender Selection → BRE APPROVED → KYC page.
    [Tags]    smoke    e2e-accept    renewal
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Renewal Application With Lender Assignment
    ...    lender_decision=APPROVED
    OKYC URL Should Be Active

TC-LS-E04 Full Renewal Journey Lender Rejected Reaches Bank Statement
    [Documentation]    Full E2E: Login (RENEWAL_MOBILE) → Renewal Application (Plan 2) → Lender Selection → BRE REJECTED → Bank Statement page.
    [Tags]    e2e-reject    renewal
    [Teardown]    Run Keyword And Ignore Error    Close Browser
    Create Full Renewal Application With Lender Assignment
    ...    plan_index=2    lender_decision=REJECTED
    Bank Statement Select Bank URL Should Be Active
