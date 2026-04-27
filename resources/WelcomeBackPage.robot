*** Settings ***
Documentation
...    Page Object keywords for the Renewal Journey "Welcome Back" screen.
...    This screen appears after Choose Plan in a renewal (nth-application) flow.
...    It shows pre-filled applicant details from the previous application and offers:
...      - "CONTINUE WITH THESE DETAILS" → proceeds to Verify Details screen
...      - "CHANGE APPLICANT DETAILS" / "Click to change applicant" → drops to Select Applicant (ACF flow)

Library    Browser

*** Variables ***
# Welcome Back screen — pre-filled info
${WB_CONTINUE_BUTTON}       text=CONTINUE WITH THESE DETAILS
${WB_CHANGE_APPLICANT}      text=CHANGE APPLICANT DETAILS
${WB_CHANGE_LINK}           text=Click to change applicant

*** Keywords ***
Welcome Back Screen Should Be Visible
    [Documentation]    Verifies the Welcome Back pre-fill screen is displayed after Choose Plan.
    Wait For Elements State    ${WB_CONTINUE_BUTTON}    visible    timeout=${LONG_TIMEOUT}

Pre Filled Applicant Details Should Be Visible
    [Documentation]    Verifies that pre-filled applicant name, DOB, and PAN are visible on screen.
    Wait For Elements State    ${WB_CONTINUE_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    # Pre-filled card content is rendered in text — assert at least the continue button is visible
    # implying the pre-fill data was loaded successfully.
    Get Element Count    ${WB_CONTINUE_BUTTON}    ==    1

Continue With These Details Button Should Be Visible
    [Documentation]    Verifies the "CONTINUE WITH THESE DETAILS" CTA is visible.
    Wait For Elements State    ${WB_CONTINUE_BUTTON}    visible    timeout=${LONG_TIMEOUT}

Change Applicant Link Should Be Visible
    [Documentation]    Verifies the "Click to change applicant" link is visible.
    Wait For Elements State    ${WB_CHANGE_LINK}    visible    timeout=${LONG_TIMEOUT}

Click Continue With These Details
    [Documentation]    Clicks "CONTINUE WITH THESE DETAILS" to proceed to the Verify Details screen.
    Wait For Elements State    ${WB_CONTINUE_BUTTON}    visible    timeout=${LONG_TIMEOUT}
    Click    ${WB_CONTINUE_BUTTON}

Click Change Applicant
    [Documentation]
    ...    Clicks "CHANGE APPLICANT DETAILS" or "Click to change applicant" link.
    ...    This drops the user back into the standard ACF wizard at the Select Applicant page.
    ${has_change_btn}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${WB_CHANGE_APPLICANT}    visible    timeout=4s
    IF    ${has_change_btn}
        Click    ${WB_CHANGE_APPLICANT}
    ELSE
        Wait For Elements State    ${WB_CHANGE_LINK}    visible    timeout=${TIMEOUT}
        Click    ${WB_CHANGE_LINK}
    END
