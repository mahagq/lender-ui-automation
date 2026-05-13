*** Settings ***
Documentation
...    Page object keywords for the Repayment Schedule page in Application Details.
...    All locators use data-testid CSS selectors.
...    Library: Browser (Playwright).
...    Locators and keywords to be filled after recording review.

Library    Browser

*** Variables ***
# Locators — TBD after recording / testid inspection
# ${REPAYMENT_SCHEDULE_CONTAINER}    css=[data-testid='repayment-schedule-container']

*** Keywords ***
Navigate To Repayment Schedule Within Session
    [Documentation]    Navigate to Repayment Schedule page. URL TBD after recording.
    Go To    ${BASE_URL}
    # TODO: add actual URL path after recording review

Open Browser To Login Page
    [Documentation]    Open browser and navigate to login page.
    New Browser    chromium    headless=${HEADLESS}
    New Page    ${BASE_URL}
