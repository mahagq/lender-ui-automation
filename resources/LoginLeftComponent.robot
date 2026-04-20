*** Settings ***
Documentation
...    Page object keywords for the Login page left panel component.
...    The left panel contains the GrayQuest branding, headings, trusted-by section,
...    and footer navigation links (About Us, Privacy Policy, T&C, Contact Us).
...
...    Key selectors confirmed from LoginLeftComponent.java in gq_customer_ui_automation:
...      GQ Logo:             first SVG element on page (no data-testid on logo)
...      Register for title:  data-testid='register-for-title'
...      EMI Plans title:     data-testid='emi-plans-title'
...      Info paragraph:      data-testid='info-paragraph'
...      Trusted by image:    img[alt='Trusted by Image desktop'] (no data-testid; 'TrustedBy'
...                           class is CSS-Modules-hashed and resolves to 4 elements)
...      Copyright footer:    data-testid='footer'  (p element; >> nth=0 to skip mobile duplicate)
...      About Us link:       data-testid='about-us-link'  (>> nth=0 to skip mobile duplicate)
...      Privacy Policy link: li[data-testid='privacy-policy-link']  (>> nth=0)
...      T&C link:            data-testid='terms-&-conditions-link'  (>> nth=0)
...      Contact Us link:     data-testid='contact-us-link'  (>> nth=0)
...
...    Note: footer links and images appear twice in the DOM — once in the desktop left panel
...    and once in a mobile-footer-container. Playwright strict mode requires a unique match;
...    >> nth=0 selects the first (desktop) occurrence in all affected locators.
...
...    Satisfies: TC-101 to TC-109 (login left component test cases)

Library     Browser

*** Variables ***
${GQ_LOGO}                  svg >> nth=0
${REGISTER_FOR_TITLE}       css=[data-testid='register-for-title']
${EMI_PLANS_TITLE}          css=[data-testid='emi-plans-title']
${INFO_PARAGRAPH}           css=[data-testid='info-paragraph']
${TRUSTED_BY_IMAGE}         img[alt='Trusted by Image desktop'] >> nth=0
${COPYRIGHT_FOOTER}         p[data-testid='footer'] >> nth=0
${ABOUT_US_LINK}            [data-testid='about-us-link'] >> nth=0
${PRIVACY_LINK_LEFT}        li[data-testid='privacy-policy-link'] >> nth=0
${TC_LINK_LEFT}             [data-testid='terms-&-conditions-link'] >> nth=0
${CONTACT_US_LINK}          [data-testid='contact-us-link'] >> nth=0

*** Keywords ***
GQ Logo Should Be Visible
    [Documentation]
    ...    Asserts the GrayQuest SVG logo is present and visible in the left section.
    ...    The logo has no data-testid — uses first SVG element on the page (>> nth=0).
    ...    Satisfies: TC-101
    Wait For Elements State    ${GQ_LOGO}    visible    timeout=${TIMEOUT}

Get Register For Title Text
    [Documentation]
    ...    Returns the text of the "Register for" heading in the left panel.
    ...    data-testid='register-for-title'. Satisfies: TC-102
    Wait For Elements State    ${REGISTER_FOR_TITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${REGISTER_FOR_TITLE}
    RETURN    ${text}

Get EMI Plans Title Text
    [Documentation]
    ...    Returns the text of the "EMI Plans" heading in the left panel.
    ...    data-testid='emi-plans-title'. Satisfies: TC-102
    Wait For Elements State    ${EMI_PLANS_TITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${EMI_PLANS_TITLE}
    RETURN    ${text}

Get Info Paragraph Text
    [Documentation]
    ...    Returns the subheading paragraph text in the left panel.
    ...    data-testid='info-paragraph'. Satisfies: TC-103
    Wait For Elements State    ${INFO_PARAGRAPH}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${INFO_PARAGRAPH}
    RETURN    ${text}

Trusted By Image Should Be Visible
    [Documentation]
    ...    Asserts the "Trusted by 5M+ Parents" desktop image is visible in the left panel.
    ...    Uses alt='Trusted by Image desktop' (no data-testid; class selector matches 4 elements).
    ...    Satisfies: TC-104
    Wait For Elements State    ${TRUSTED_BY_IMAGE}    visible    timeout=${TIMEOUT}

Get Copyright Footer Text
    [Documentation]
    ...    Returns the copyright footer text from data-testid='footer'.
    ...    Uses >> nth=0 to target the desktop element (mobile duplicate also exists).
    ...    Satisfies: TC-109
    Wait For Elements State    ${COPYRIGHT_FOOTER}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${COPYRIGHT_FOOTER}
    RETURN    ${text}

Click About Us Link And Switch To New Tab
    [Documentation]
    ...    Clicks the About Us link in the left panel footer, switches to the newly
    ...    opened tab, and returns the page title. Satisfies: TC-105
    Wait For Elements State    ${ABOUT_US_LINK}    visible    timeout=${TIMEOUT}
    Get Element States    ${ABOUT_US_LINK}    contains    enabled
    Click    ${ABOUT_US_LINK}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${title}=    Get Title
    Close Page
    RETURN    ${title}

Click Privacy Policy Link And Switch To New Tab
    [Documentation]
    ...    Clicks the Privacy Policy link in the left panel footer, switches to the
    ...    new tab, and returns the page title. Satisfies: TC-106
    Wait For Elements State    ${PRIVACY_LINK_LEFT}    visible    timeout=${TIMEOUT}
    Get Element States    ${PRIVACY_LINK_LEFT}    contains    enabled
    Click    ${PRIVACY_LINK_LEFT}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${title}=    Get Title
    Close Page
    RETURN    ${title}

Click Terms And Conditions Link And Switch To New Tab
    [Documentation]
    ...    Clicks the Terms & Conditions link in the left panel footer, switches to the
    ...    new tab, and returns the page title. Satisfies: TC-107
    Wait For Elements State    ${TC_LINK_LEFT}    visible    timeout=${TIMEOUT}
    Get Element States    ${TC_LINK_LEFT}    contains    enabled
    Click    ${TC_LINK_LEFT}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${title}=    Get Title
    Close Page
    RETURN    ${title}

Click Contact Us Link And Switch To New Tab
    [Documentation]
    ...    Clicks the Contact Us link in the left panel footer, switches to the
    ...    new tab, and returns the page title. Satisfies: TC-108
    Wait For Elements State    ${CONTACT_US_LINK}    visible    timeout=${TIMEOUT}
    Get Element States    ${CONTACT_US_LINK}    contains    enabled
    Click    ${CONTACT_US_LINK}
    Switch Page    NEW
    Wait For Load State    domcontentloaded
    ${title}=    Get Title
    Close Page
    RETURN    ${title}
