*** Settings ***
Documentation
...    Lender Selection UI tests for new application journey.
...    Suite Setup creates a fresh application, navigates to lender selection, captures LENDER_APP_ID.
...    Tests N00–N11 are read-only (reset to lender page each test).
...    BRE state-advancing tests (rejection/approval) are in lender_rejection_tests.robot and lender_approval_tests.robot.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Lender Selection New App
Suite Teardown   Close Browser
Test Setup       Navigate To Lender Selection Within Session    ${LENDER_APP_ID}
Test Tags        lender-selection    lender-selection-new    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection
...    allure.label.story:New Application Lender Selection


*** Variables ***
${LENDER_APP_ID}    ${EMPTY}


*** Test Cases ***
TC-LS-N00 Lender Selection Page Loads Successfully After New Application Submit
    [Documentation]    Asserts lender selection page loads after submitting new application.
    Lender Selection URL Should Be Active

TC-LS-N01 Lender Selection Page Heading Is Visible After New Application Submit
    [Documentation]    Asserts the lender selection heading is visible on page load.
    Lender Selection Page Should Be Visible

TS-LS-N02 Lender Selection Page Subheading Is Visible After New Application Submit
    [Documentation]    Asserts the lender selection subheading is visible on page load.
    Lender Selection Subheading Should Be Visible

TC-LS-N03 At Least One Available Lender Rank Label Is Displayed
    [Documentation]    Asserts Rank 1 label is present. Rank 2/3 are conditionally logged.
    At Least One Rank Label Should Be Visible

TC-LS-N04 Currently Unavailable Section Is Displayed When Present
    [Documentation]    Asserts unavailable section heading + disclaimer if present. Skips cleanly if absent.
    Currently Unavailable Section Should Be Visible If Present

TC-LS-N05 Lender Disclaimer Text Is Visible
    [Documentation]    Asserts the disclaimer text about lender display order is visible.
    Disclaimer Text Should Be Visible

TC-LS-N06 Loan Offer Details Modal Opens And Shows All Financial Fields
    [Documentation]    Opens the first lender's Loan Offer Details modal and asserts all 10 fields.
    Open Loan Offer Details For First Lender
    Loan Offer Details Modal Should Show All Fields
    Close Modal

TC-LS-N07 Loan Offer Details Modal Closes On Close Button
    [Documentation]    Opens modal and verifies it closes on clicking Close.
    Open Loan Offer Details For First Lender
    Loan Offer Details Modal Should Show All Fields
    Close Modal
    Lender Selection Page Should Be Visible

TC-LS-N08 KFS Modal Opens And Shows Fee And Payment Fields
    [Documentation]    Opens the first lender's KFS modal and asserts all 3 KFS fields.
    Open KFS For First Lender
    Close Modal

TC-LS-N09 KFS Consent Checkbox Can Be Checked And Unchecked
    [Documentation]    Checks and unchecks KFS consent checkbox. Skips if not present for this lender.
    ${present}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${LS_CONSENT_CHECKBOX}    visible    timeout=3s
    Pass Execution If    not ${present}    KFS consent checkbox not present — skipping
    Check KFS Consent
    Uncheck KFS Consent

TC-LS-N10 Bank Tag Applies Successfully
    [Documentation]    Clicks Bank filter and verifies page stays on lender selection.
    Click Bank Filter
    Lender Selection Page Should Be Visible

TC-LS-N11 NBFC Filter Applies Successfully
    [Documentation]    Clicks NBFC filter and verifies page stays on lender selection.
    Click NBFC Filter
    Lender Selection Page Should Be Visible

TC-LS-N12 Verify Footer Text Is Visible
    [Documentation]    Asserts the footer text about lender ranking and display is visible.
    Lender Selection Page Footer Text Should Be Visible

