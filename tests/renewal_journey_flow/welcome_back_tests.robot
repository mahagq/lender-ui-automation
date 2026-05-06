*** Settings ***
Documentation
...    Renewal Journey — Welcome Back screen (appears after Choose Plan in renewal flow).
...    Shows pre-filled applicant details from the previous application.
...    Offers two paths:
...      - "CONTINUE WITH THESE DETAILS" → Verify Details screen
...      - "CHANGE APPLICANT DETAILS" / "Click to change applicant" → Select Applicant (ACF flow)
...
...    Session model:
...      Suite Setup    → Navigate To Welcome Back Via Renewal (login once, create one application, land on /renewal-confirmation)
...      Test Setup     → Navigate To Welcome Back Within Session (Go To /renewal-confirmation — same app, no re-login)
...      Suite Teardown → Close Browser

Resource    ../../resources/ApplicationCreationFlowPage.robot
Resource    ../../resources/WelcomeBackPage.robot
Resource    ../../resources/SelectApplicantPage.robot
Resource    ../../variables/variables.robot
Variables   ../../variables/dynamic_variables.py

Suite Setup     Navigate To Welcome Back Via Renewal
Suite Teardown  Close Browser
Test Setup      Navigate To Welcome Back Within Session
Test Tags       renewal    welcome-back    renewal-journey-flow    allure.label.epic:CP UI Automation    allure.label.feature:Renewal Journey Flow    allure.label.story:Welcome Back

*** Test Cases ***
TC-WB01 Welcome Back Screen Is Visible
    [Tags]    smoke
    Welcome Back Screen Should Be Visible

TC-WB02 Welcome Back Screen URL Is Correct
    Welcome Back Screen URL Should Be Correct

TC-WB03 Welcome Back Heading Is Visible
    Welcome Back Heading Should Be Visible

TC-WB04 Welcome Back Sub Heading Is Visible
    Welcome Back Sub Heading Should Be Visible

TC-WB05 Applicant Name field Is Visible
    Applicant Name Field Should Be Visible

TC-WB06 PAN Number field Is Visible
    PAN Number Field Should Be Visible

TC-WB07 Date of Birth field Is Visible
    Date Of Birth Field Should Be Visible

TC-WB08 Pre Filled Applicant Details Are Visible
    Pre Filled Applicant Details Should Be Visible

TC-WB09 Continue With These Details Button Is Visible
    Continue With These Details Button Should Be Visible

TC-WB10 Change Applicant Button Is Visible
    Change Applicant Button Should Be Visible

TC-WB11 Click to change applicant name and PAN Text Is Visible
    Click To Change Applicant Name And PAN Text Should Be Visible

TC-WB12 Continue With These Details Navigates To Verify Details
    Click Continue With These Details
    Verify Navigated To Verify Details

TC-WB13 Change Applicant Navigates To Select Applicant
    Click Change Applicant
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Select Applicant URL Should Be Active
