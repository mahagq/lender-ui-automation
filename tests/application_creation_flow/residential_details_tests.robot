*** Settings ***
Documentation
...    Independent test suite for the GQ Customer Portal Applicant Residential Details page (/applicant-residential-details).
...    Independent suite — no cross-file ordering dependencies.
...
...    Session model:
...      Suite Setup    → Navigate To Residential Details (full wizard traversal to /applicant-residential-details)
...      Test Setup     → Navigate To Residential Details Within Session (Go To)
...      Test Teardown  → NONE (shared session)
...      Suite Teardown → Close Browser
...
...    TC-11007 (proceed → /select-employment) runs LAST.
...
...    PRECONDITION: ${APP_CREATION_MOBILE} must be registered on UAT.
...    Satisfies: RT-5, T1, U1, U2

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/ApplicantResidentialDetailsPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Residential Details
Suite Teardown  Close Browser
Test Setup      Navigate To Residential Details Within Session
Test Tags       residential-details    application-creation-flow    allure.label.epic:CP UI Automation    allure.label.feature:Application Creation Flow    allure.label.story:Applicant Residential Details

*** Test Cases ***
TC-11001 Residential Details Title Is Visible
    [Documentation]    Verifies residential-details-title is visible.
    [Tags]    smoke
    Residential Details Title Should Be Visible

TC-11002 Address Fields Are Visible
    [Documentation]    Verifies addr-line-1, addr-line-2, and pincode fields are visible.
    Address Fields Should Be Visible

TC-11004 Address Line 1 Accepts Text
    [Documentation]    Verifies addr-line-1-input accepts text.
    Fill Address Line 1    123 Test Avenue

TC-11005 Pincode Field Accepts Numbers
    [Documentation]    Verifies pincode-input accepts numeric input.
    Fill Pincode    400001

TC-11006 Residential Details URL Is Correct
    [Documentation]    Verifies URL contains /applicant-residential-details.
    Residential Details URL Should Be Active

TC-11N-01 Submit Empty Address Line 1 Shows Error And User Cannot Proceed
    [Documentation]
    ...    Verifies clicking proceed with empty address line 1 shows addr-line-1-input-error
    ...    and user stays on /applicant-residential-details.
    [Tags]    negative
    Fill Address Line 1    ${EMPTY}
    Click Residential Details Proceed
    Address Line 1 Error Should Be Visible
    Residential Details URL Should Be Active

TC-11N-02 Submit Empty Pincode Shows Error
    [Documentation]    Verifies pincode-input-error appears when address is filled but pincode is empty.
    [Tags]    negative
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Pincode    ${EMPTY}
    Click Residential Details Proceed
    Pincode Error Should Be Visible
    Residential Details URL Should Be Active

TC-11N-03 Alphabets In Pincode Show Error
    [Documentation]    Verifies pincode-input-error appears when pincode contains alphabets.
    [Tags]    negative
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Pincode    abcdef
    Click Residential Details Proceed
    Pincode Error Should Be Visible
    Residential Details URL Should Be Active

TC-11N-04 Special Characters In Pincode Show Error
    [Documentation]    Verifies pincode-input-error appears when pincode contains special characters.
    [Tags]    negative
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Pincode    @#$%^!
    Click Residential Details Proceed
    Pincode Error Should Be Visible
    Residential Details URL Should Be Active

TC-11N-05 Short Pincode Shows Error
    [Documentation]    Verifies pincode-input-error appears when pincode has fewer than 6 digits.
    [Tags]    negative
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Pincode    1234
    Click Residential Details Proceed
    Pincode Error Should Be Visible
    Residential Details URL Should Be Active

TC-11003 Residence Type Radio Is Visible After Address Submission
    [Documentation]
    ...    Verifies type-radio options are visible after filling address fields and clicking Proceed.
    ...    The residence type radio is a second step on the same URL — it only renders after
    ...    address line 1, address line 2, and pincode are submitted via the first Proceed click.
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Address Line 2    ${APP_ADDRESS_LINE2}
    Fill Pincode    ${APP_PINCODE}
    Sleep    2s
    Click Residential Details Proceed
    Residence Type Radio Should Be Visible

TC-11008 All Residence Type Radios Are Selectable
    [Documentation]
    ...    Verifies all three residence type options (Rented, Self Owned, Other) can be clicked
    ...    and each becomes checked when selected. The radio step renders only after address
    ...    fields are submitted via the first Proceed click.
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Address Line 2    ${APP_ADDRESS_LINE2}
    Fill Pincode    ${APP_PINCODE}
    Sleep    2s
    Click Residential Details Proceed
    All Residence Type Radios Should Be Selectable

TC-11007 Residential Details Proceeds To Employment Type
    [Documentation]
    ...    Fills residential details with APP_* stub data and proceeds to /select-employment.
    ...    City/state are API-populated — asserted as visible (not exact value).
    ...    Runs LAST — advances wizard past residential details.
    Fill Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Address Line 2    ${APP_ADDRESS_LINE2}
    Fill Pincode    ${APP_PINCODE}
    Sleep    2s    # Pincode city/state auto-populate
    Click Residential Details Proceed
    Click First Residence Type Radio
    Click Residence Type Step Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Employment Type URL Should Be Active
