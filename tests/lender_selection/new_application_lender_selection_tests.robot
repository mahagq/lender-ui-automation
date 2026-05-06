*** Settings ***
Documentation
...    Lender Selection UI tests for new application journey.
...    Suite Setup creates a fresh application, navigates to lender selection, captures LENDER_APP_ID.
...    Tests N01–N10 are read-only (reset to lender page each test).
...    Tests N11–N12 are state-advancing and run last with special isolation.

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
TC-LS-N01 Lender Selection Page Heading Is Visible After New Application Submit
    [Documentation]    Asserts the lender selection heading is visible on page load.
    Lender Selection Page Should Be Visible

TC-LS-N02 At Least One Available Lender Rank Label Is Displayed
    [Documentation]    Asserts Rank 1 label is present. Rank 2/3 are conditionally logged.
    At Least One Rank Label Should Be Visible

TC-LS-N03 Currently Unavailable Section Is Displayed When Present
    [Documentation]    Asserts unavailable section heading + disclaimer if present. Skips cleanly if absent.
    Currently Unavailable Section Should Be Visible If Present

TC-LS-N04 Lender Disclaimer Text Is Visible
    [Documentation]    Asserts the disclaimer text about lender display order is visible.
    Disclaimer Text Should Be Visible

TC-LS-N05 Loan Offer Details Modal Opens And Shows All Financial Fields
    [Documentation]    Opens the first lender's Loan Offer Details modal and asserts all 10 fields.
    Open Loan Offer Details For First Lender
    Loan Offer Details Modal Should Show All Fields
    Close Modal

TC-LS-N06 Loan Offer Details Modal Closes On Close Button
    [Documentation]    Opens modal and verifies it closes on clicking Close.
    Open Loan Offer Details For First Lender
    Loan Offer Details Modal Should Show All Fields
    Close Modal
    Lender Selection Page Should Be Visible

TC-LS-N07 KFS Modal Opens And Shows Fee And Payment Fields
    [Documentation]    Opens the first lender's KFS modal and asserts all 3 KFS fields.
    Open KFS For First Lender
    KFS Modal Should Show Fields
    Close Modal

TC-LS-N08 KFS Consent Checkbox Can Be Checked And Unchecked
    [Documentation]    Checks then unchecks the KFS consent checkbox.
    Check KFS Consent
    Uncheck KFS Consent

TC-LS-N09 Bank Filter Applies Successfully
    [Documentation]    Clicks Bank filter and verifies page stays on lender selection.
    Click Bank Filter
    Lender Selection Page Should Be Visible

TC-LS-N10 NBFC Filter Applies Successfully
    [Documentation]    Clicks NBFC filter and verifies page stays on lender selection.
    Click NBFC Filter
    Lender Selection Page Should Be Visible

TC-LS-N11 BRE Lender Rejection Redirects To Bank Statement Page
    [Documentation]    Mocks BRE REJECTED. Asserts user lands on bank statement select bank page. State-advancing — runs last.
    [Setup]    NONE
    [Teardown]    Unroute BRE Mock
    Navigate To Lender Selection Within Session    ${LENDER_APP_ID}
    Mock BRE Assign Lender    REJECTED
    Lender Selection Page Should Be Visible
    Check KFS Consent
    Click First Available Continue Button
    Wait For Bureau Decision
    ${url}=    Get Url
    ${on_bank}=    Run Keyword And Return Status    Should Contain    ${url}    /bank-statement/
    IF    not ${on_bank}
        Click View Available Financing
        Check KFS Consent
        Click First Available Continue Button
        Wait For Bureau Decision
        ${url}=    Get Url
    END
    Should Contain    ${url}    /bank-statement/
    Bank Statement Select Bank Page Should Be Visible

TC-LS-N12 BRE Lender Approval Redirects To KYC Page
    [Documentation]    Creates a fresh app within session. Mocks BRE APPROVED. Asserts KYC page reached. State-advancing — runs last.
    [Setup]    Navigate To Lender Selection New App Within Session
    [Teardown]    Unroute BRE Mock
    Mock BRE Assign Lender    APPROVED
    Lender Selection Page Should Be Visible
    Check KFS Consent
    Click First Available Continue Button
    Wait For Bureau Decision
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active
