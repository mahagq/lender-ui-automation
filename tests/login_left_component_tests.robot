*** Settings ***
Documentation
...    Login left panel component test suite for the GQ Customer Portal.
...    Tests the branding/navigation panel on the left side of the login page.
...    Ported from loginLeftComponentTest.java in gq_customer_ui_automation.
...
...    Left panel elements:
...      - GrayQuest logo (SVG)
...      - "Register for EMI Plans" headings
...      - Subheading info paragraph
...      - "Trusted by 5M+ Parents" image
...      - Footer links: About Us, Privacy Policy, Terms & Conditions, Contact Us
...      - Copyright notice
...
...    All tests share a single browser context — the left panel is static and does not
...    change between interactions, so re-navigation is only done for new-tab tests.
...    Suite Setup navigates to the login page once. Individual tests re-open the login
...    page via Test Setup where new-tab handling requires a fresh context.
...
...    Satisfies: TC-101 to TC-109

Library          Browser
Resource         ../resources/LoginPage.robot
Resource         ../resources/LoginLeftComponent.robot
Resource         ../variables/variables.robot

Suite Setup      Open Left Component Page
Suite Teardown   Close Browser
Test Tags        allure.label.epic:CP UI Automation    allure.label.feature:Authentication    allure.label.story:Login Left Component

*** Keywords ***
Open Left Component Page
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context
    New Page    ${BASE_URL}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}

Refresh Login Page
    [Documentation]    Navigates back to the login page (used after closing a new tab).
    Go To    ${BASE_URL}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}

*** Test Cases ***

GQ Logo Is Displayed In Left Section
    [Documentation]
    ...    The GrayQuest SVG logo should be present and visible at the top of
    ...    the left panel. Logo has no data-testid — first SVG element is used.
    [Tags]    left-component    logo    ui
    GQ Logo Should Be Visible

Register For EMI Plans Heading Text Is Correct
    [Documentation]
    ...    The left panel main heading is split across two elements:
    ...    data-testid='register-for-title' → "Register for"
    ...    data-testid='emi-plans-title'    → "EMI Plans"
    [Tags]    left-component    ui    heading
    ${register_text}=    Get Register For Title Text
    Should Be Equal    ${register_text}    Register for
    ${emi_text}=    Get EMI Plans Title Text
    Should Be Equal    ${emi_text}    EMI Plans

Subheading Paragraph Text Is Correct
    [Documentation]
    ...    data-testid='info-paragraph' should display:
    ...    "Share a few details, and we\u2019ll create the perfect EMI plan tailored to your needs"
    [Tags]    left-component    ui    text
    ${text}=    Get Info Paragraph Text
    Should Be Equal    ${text}
    ...    Share a few details, and we\u2019ll create the perfect EMI plan tailored to your needs

Trusted By Image Is Visible
    [Documentation]
    ...    The "Trusted by 5M+ Parents" image section should be visible in the left panel.
    ...    Uses partial CSS class selector (no data-testid on this image element).
    [Tags]    left-component    ui    image
    Trusted By Image Should Be Visible

About Us Link Opens About Us Page
    [Documentation]
    ...    The About Us link (data-testid='about-us-link') in the left panel footer should
    ...    be clickable and open the About Us page in a new browser tab.
    ...    Page title should contain "About Us".
    [Tags]    left-component    navigation    new-tab
    ${title}=    Click About Us Link And Switch To New Tab
    Should Contain    ${title}    About Us
    Refresh Login Page

Privacy Policy Link Opens Privacy Policy Page
    [Documentation]
    ...    The Privacy Policy link (li[data-testid='privacy-policy-link']) in the left panel
    ...    footer should open the Privacy Policy page in a new tab.
    ...    Page title should contain "Privacy Policy".
    [Tags]    left-component    navigation    new-tab
    ${title}=    Click Privacy Policy Link And Switch To New Tab
    Should Contain    ${title}    Privacy Policy
    Refresh Login Page

Terms And Conditions Link Opens Terms And Conditions Page
    [Documentation]
    ...    The Terms & Conditions link (data-testid='terms-&-conditions-link') in the left
    ...    panel footer should open the T&C page in a new tab.
    ...    Page title should contain "Terms & Conditions".
    [Tags]    left-component    navigation    new-tab
    ${title}=    Click Terms And Conditions Link And Switch To New Tab
    Should Contain    ${title}    Terms & Conditions
    Refresh Login Page

Contact Us Link Opens Contact Us Page
    [Documentation]
    ...    The Contact Us link (data-testid='contact-us-link') in the left panel footer
    ...    should open the Contact Us page in a new tab.
    ...    Page title should contain "Contact Us".
    [Tags]    left-component    navigation    new-tab
    ${title}=    Click Contact Us Link And Switch To New Tab
    Should Contain    ${title}    Contact Us
    Refresh Login Page

Copyright Footer Text Is Correct
    [Documentation]
    ...    The copyright notice at the bottom of the left panel (p[data-testid='footer'])
    ...    should display: "© <current year> GrayQuest Education Finance Pvt. Ltd."
    ...    Year is derived at runtime to avoid annual test failures.
    [Tags]    left-component    ui    footer-text
    ${year}=    Evaluate    datetime.datetime.now().year    datetime
    ${expected}=    Set Variable    © ${year} GrayQuest Education Finance Pvt. Ltd.
    ${text}=    Get Copyright Footer Text
    Should Be Equal    ${text}    ${expected}
