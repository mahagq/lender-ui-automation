*** Settings ***
Documentation
...    Lender Selection UI tests for renewal (existing) application journey.
...    Suite Setup logs in with RENEWAL_MOBILE, creates renewal application, navigates to lender selection.
...    Tests R01–R04 are read-only (reset to lender page each test).
...    Tests R05–R06 are state-advancing and run last.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Navigate To Lender Selection Renewal App
Suite Teardown   Close Browser
Test Setup       Navigate To Lender Selection Within Session    ${LENDER_RENEWAL_APP_ID}
Test Tags        lender-selection    lender-selection-renewal    renewal    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection
...    allure.label.story:Renewal Application Lender Selection


*** Variables ***
${LENDER_RENEWAL_APP_ID}    ${EMPTY}


*** Test Cases ***
TC-LS-R01 Lender Selection Page Is Visible After Renewal Application Submit
    [Documentation]    Asserts the lender selection heading is visible after renewal application submit.
    Lender Selection Page Should Be Visible

TC-LS-R02 At Least One Rank Label Is Displayed For Renewal Application
    [Documentation]    Asserts Rank 1 label visible for renewal app lender set.
    At Least One Rank Label Should Be Visible

TC-LS-R03 Loan Offer Details Modal Works For Renewal Application Lender
    [Documentation]    Opens first lender's Loan Offer Details and asserts all 10 fields visible.
    Open Loan Offer Details For First Lender
    Loan Offer Details Modal Should Show All Fields
    Close Modal

TC-LS-R04 KFS Consent Checkbox Is Toggleable For Renewal Application
    [Documentation]    Checks and unchecks KFS consent checkbox. Skips if not present for this lender.
    ${present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_CONSENT_CHECKBOX}    visible    timeout=3s
    Pass Execution If    not ${present}    KFS consent checkbox not present — skipping
    Check KFS Consent
    Uncheck KFS Consent
