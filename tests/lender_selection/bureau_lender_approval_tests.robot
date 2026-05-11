*** Settings ***
Documentation
...    Lender BRE Approval test — new application journey.
...    Suite Setup creates a fresh application (plan 1) and navigates to lender selection.
...    TC-LS-NA01 selects Western Capital → real BRE → asserts user reaches KYC page.

Library      Browser
Resource     ../../resources/ApplicationCreationFlowPage.robot
Resource     ../../variables/variables.robot
Variables    ../../variables/dynamic_variables.py

Suite Setup      Navigate To Lender Selection New App
Suite Teardown   Close Browser
Test Tags        lender-selection    lender-approval    regression
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Lender Selection
...    allure.label.story:Lender BRE Approval


*** Variables ***
${LENDER_APP_ID}    ${EMPTY}


*** Test Cases ***
TC-LS-NA01 BRE Lender Approval Redirects To KYC Page
    [Documentation]
    ...    Real BRE — selects Western Capital from the lender list.
    ...    Asserts user reaches KYC page after successful lender assignment.
    Lender Selection Page Should Be Visible
    Check KFS Consent For Lender If Present    Western Capital
    Click Lender Continue Button By Name    Western Capital
    Wait For Bureau Decision
    Successful Lender Assignment Should Be Visible
    Click Proceed To KYC
    OKYC URL Should Be Active
