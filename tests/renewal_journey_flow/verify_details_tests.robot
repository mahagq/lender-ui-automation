*** Settings ***
Documentation
...    Renewal Journey — Verify Details screen.
...    Reached after clicking "CONTINUE WITH THESE DETAILS" on the Welcome Back screen.
...    Shows pre-filled residential and employment details from the previous application.
...    Supports: viewing, editing residential section, editing employment section,
...    skipping employment review, and confirming to submit.
...
...    Session model:
...      Suite Setup    → Navigate To Verify Details Via Renewal (login once, create one application, land on /renewal-details)
...      Test Setup     → Navigate To Verify Details Within Session (Go To /renewal-details — same app, no re-login)
...      Suite Teardown → Close Browser
...
...    TC-VD09 runs 2nd-to-last — submits the shared application.
...    TC-VD25 runs LAST with [Setup] Navigate To Verify Details New Application Within Session
...    (creates one fresh application within the existing browser session, no re-login).

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/WelcomeBackPage.robot
Resource    ../../resources/VerifyDetailsPage.robot
Resource    ../../resources/ConfirmApplicationPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Verify Details Via Renewal
Suite Teardown  Close Browser
Test Setup      Navigate To Verify Details Within Session
Test Tags       renewal    verify-details    renewal-journey-flow    allure.label.epic:CP UI Automation    allure.label.feature:Renewal Journey Flow    allure.label.story:Verify Details

*** Test Cases ***
# ── Visibility ──────────────────────────────────────────────────────────────────

TC-VD01 Verify Details Page Is Visible
    [Tags]    smoke
    Verify Details Page Should Be Visible

TC-VD02 Residential Section Title And Address Are Visible
    Residential Section Should Be Visible

TC-VD03 Residential Edit Details Button Is Visible
    Residential Edit Button Should Be Visible

TC-VD04 Employment Skip Button Is Visible
    Employment Skip Button Should Be Visible

TC-VD05 Employment Edit Details Button Is Visible
    Employment Edit Button Should Be Visible

TC-VD06 Consent Checkbox And Confirm Button Are Visible
    Consent And Confirm Button Should Be Visible

# ── Skip Journey ────────────────────────────────────────────────────────────────

TC-VD07 Skip Employment Dismisses Employment Section
    [Tags]    skip-journey
    Click Skip Employment
    Employment Section Should Be Dismissed After Skip

TC-VD08 Skip Employment And Confirm Proceeds Successfully
    [Tags]    skip-journey    negative
    Click Skip Employment
    Employment Section Should Be Dismissed After Skip
    Consent And Confirm Button Should Be Visible

# ── Edit Residential ────────────────────────────────────────────────────────────

TC-VD10 Edit Residential Opens Address Fields
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible

TC-VD11 Edit Address Line 1 And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Residence Type Radio In Edit Form
    Click    css=[data-testid='proceed-button']
    Residential Section Should Be Visible

TC-VD12 Edit Residence Type Radio And Submit Updates Value
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Click Residence Type Radio In Edit Form
    Click    css=[data-testid='proceed-button']
    Residential Section Should Be Visible

TC-VD13 Empty Address Line 1 Shows Error And User Cannot Proceed
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${EMPTY}
    Click    css=[data-testid='proceed-button']
    Verify Details Address Line 1 Error Should Be Visible

TC-VD14 Invalid Pincode In Edit Form Shows Error
    [Tags]    edit-residential    negative
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Fill Verify Details Address Line 1    ${APP_ADDRESS_LINE1}
    Fill Text    css=[data-testid='pincode-input']    abcdef
    Click    css=[data-testid='proceed-button']
    Verify Details Pincode Error Should Be Visible

TC-VD15 Back From Residential Edit Returns To Verify Details
    [Tags]    edit-residential
    Click Edit Residential Details
    Residential Edit Form Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

# ── Edit Employment ─────────────────────────────────────────────────────────────

TC-VD16 Edit Employment Opens Business Fields
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible

TC-VD17 Edit Business Name And Submit Updates Value
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Business Name    ${APP_BUSINESS_NAME}
    Fill Verify Annual Income    ${APP_BUSINESS_INCOME}
    Fill Verify Years In Business    ${APP_BUSINESS_YEARS}
    Fill Verify Business Description    ${APP_BUSINESS_DESC}
    Click    css=[data-testid='proceed-button']
    Verify Details Page Should Be Visible

TC-VD18 Edit Annual Income And Submit Updates Value
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Annual Income    ${APP_BUSINESS_INCOME}
    Click    css=[data-testid='proceed-button']
    Verify Details Page Should Be Visible

TC-VD19 Edit Years In Business And Submit
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Years In Business    ${APP_BUSINESS_YEARS}
    Click    css=[data-testid='proceed-button']
    Verify Details Page Should Be Visible

TC-VD20 Edit Business Description And Submit
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Business Description    ${APP_BUSINESS_DESC}
    Click    css=[data-testid='proceed-button']
    Verify Details Page Should Be Visible

TC-VD21 Empty Business Name Shows Error
    [Tags]    edit-employment    negative
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Business Name    ${EMPTY}
    Click    css=[data-testid='proceed-button']
    Verify Details Business Name Error Should Be Visible

TC-VD22 Alphabets In Annual Income Show Error
    [Tags]    edit-employment    negative
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Fill Verify Annual Income    abcdef
    Click    css=[data-testid='proceed-button']
    Verify Details Annual Income Error Should Be Visible

TC-VD23 Back From Employment Edit Returns To Verify Details
    [Tags]    edit-employment
    Click Edit Employment Details
    Employment Edit Form Should Be Visible
    Click Back From Edit
    Verify Details Page Should Be Visible

# ── Proceed ─────────────────────────────────────────────────────────────────────

TC-VD24 Confirm And Proceed Without Consent Shows Consent Error
    [Tags]    negative
    Click Confirm And Proceed Without Consent
    Verify Details Consent Error Should Be Visible

TC-VD09 Skip Both Sections Then Confirm And Proceed Submits Application
    [Tags]    skip-journey
    [Documentation]    Skips employment review then confirms with consent — verifies successful submission.
    ...    Runs 2nd-to-last: submits the shared application leaving it in a terminal state.
    Click Skip Employment
    Click Confirm And Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully

TC-VD25 Confirm And Proceed With Consent Submits Application
    [Setup]    Navigate To Verify Details New Application Within Session
    [Documentation]    Confirms with consent after creating a fresh application within the same session.
    ...    Runs LAST — TC-VD09 submitted the shared app, so this test needs its own fresh application.
    Click Skip Employment
    Click Confirm And Proceed
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Confirm Application Submitted Successfully
