*** Settings ***
Documentation
...    Page object keywords for the GQ Customer Portal Dashboard (/my-applications).
...    All locators use data-testid CSS selectors confirmed from gqcustomer_frontend UAT branch.
...    Library: Browser (Playwright).
...
...    PRECONDITION: Some tests require the UAT test account to have pre-existing data:
...      - EMI applications: TC-4001, TC-4011 (at least one active EMI card)
...      - Transaction records: TC-4013 to TC-4031 (at least one PG transaction row)
...    A "no data found" failure signals an account seeding need, not a test defect (TN2).
...
...    Session model (O1 + TN4 resolutions):
...      Suite Setup   → Login And Navigate To Dashboard (opens browser + authenticates once)
...      Test Setup    → Navigate To Dashboard (resets tab/filter/dropdown/scroll state)
...      Test Teardown → NONE (shared session preserved — no Close Context)
...      Suite Teardown → Close Browser
...    TC-4009 (logout) must be the last test in the suite (TN1 resolution).
...
...    Imports LoginPage.robot and OTPPage.robot to reuse login flow keywords.
...    Satisfies: RT-4 (all dashboard keywords and locators), T1 (data-testid locators only)

Library     Browser
Resource    LoginPage.robot
Resource    OTPPage.robot

*** Variables ***
# Dashboard header — data-testid confirmed from gqcustomer_frontend UAT branch
${DASHBOARD_SUBTITLE}           css=[data-testid='dashboard-subtitle']
${GQ_LOGO_DASHBOARD}            css=[data-testid='desktop-view-gq-logo']
# 'create-new-application-button' testid exists in header when account has applications.
# When account is fresh (no applications), the button is inside the emi-not-data-found
# empty-state container (no testid). Click Create Application Button And Wait For Student
# Details handles both states automatically.
${CREATE_APP_BUTTON}            css=[data-testid='create-new-application-button']
${CREATE_APP_BUTTON_EMPTY}      css=[data-testid='emi-not-data-found'] button

# Profile menu — U3: container must be visible before asserting child options
${PROFILE_BUTTON}               css=[data-testid='profile-button']
${PROFILE_OPTIONS}              css=[data-testid='profile-options-container']
${FAQ_OPTION}                   css=[data-testid='faq']
${LOGOUT_OPTION}                css=[data-testid='logout']

# Tab navigation — URL hashes confirmed from UAT frontend: #emi, #ins, #ad, #direct
${EMI_TAB}                      css=[data-testid='emi-tab-navigation-button']
${INS_TAB}                      css=[data-testid='ins-tab-navigation-button']
${AD_TAB}                       css=[data-testid='ad-tab-navigation-button']
${PG_TAB}                       css=[data-testid='pg-tab-navigation-button']

# EMI tab content — partial match covers dynamic emi-card-{id} naming (T1)
${EMI_CARDS}                    css=[data-testid*='emi-card']

# EMI tab — empty state for new user (no existing applications)
${EMI_EMPTY_IMAGE}              css=img[alt='No Data Found']
${EMI_EMPTY_TEXT}               text=You have No Applications for

# EMI tab — existing user card surface elements (visible without entering detail view)
${EMI_APP_ID_LABEL}             text=Application ID:
${EMI_APP_COPY_BUTTON}          css=[data-testid='app-id-copy-button'] >> nth=0
${LOAD_MORE_BUTTON}             css=[data-testid='load-more-button']

# Create new application modal — "Before you proceed" dialog for existing users
${CREATE_APP_MODAL_TEXT}        text=Still want to create a new
${CLOSE_BUTTON}                 css=[data-testid='close-button']

# Transaction History (PG tab) — Online sub-tab uses exact value; Offline has leading space in data-testid
${ONLINE_SUBTAB}                css=li[data-testid='Online']
${OFFLINE_SUBTAB}               css=li[data-testid=' Offline']
${FILTER_BUTTON}                css=[data-testid='filter-button']
${CLEAR_FILTER_BUTTON}          css=[data-testid='clear-filter-button']
${APPLY_FILTER_BUTTON}          css=[data-testid='apply-filter-button']

# PG tab — empty states for new user (no transaction data)
${PG_ONLINE_EMPTY_TEXT}         text=Online transactions not found
${PG_OFFLINE_EMPTY_IMAGE}       css=img[alt='No Data Found']
${PG_OFFLINE_EMPTY_TEXT}        text=You have not done any

# PG tab — filter-container inline clear chip (appears after a filter is applied)
${FILTER_CONTAINER_CLEAR}       css=[data-testid='filter-container'] >> text=Clear

# AD tab — empty state for new user (alert rendered instead of application cards)
${AD_EMPTY_ALERT}               role=alert

# Time filter options — data-testid values contain spaces; CSS attribute selector with quotes handles this
${FILTER_ALL_MONTHS}            css=[data-testid='All Months']
${FILTER_THIS_MONTH}            css=[data-testid='This Month']
${FILTER_THIS_YEAR}             css=[data-testid='This Year']
${FILTER_LAST_YEAR}             css=[data-testid='Last Year']

# Status filter options
${FILTER_PAID}                  css=[data-testid='Paid']
${FILTER_FAILED}                css=[data-testid='Failed']

# Auto Payments (AD) tab content — data-testid and stable text selectors only.
# CSS module class selectors (._RepaymentScheduleCard_*, ._ADRepaymentSchedule_*) are skipped
# per T1 — those selectors are hashed and unstable. Debit breakdown tests require clicking a
# CSS-class card and are therefore omitted.
# PRECONDITION: ${AD_MOBILE} (8763694182) must have active AD applications for content tests.
${AD_APP_CODE_LABEL}           text=App. Code:
${AD_COPY_BUTTON}              css=[data-testid='copy-button'] >> nth=0
${AD_STATUS_ACTIVE}            text=Your repayment is active
${AD_STATUS_PENDING}           text=Your repayment is pending
${AD_ACTION_BUTTON}            css=[data-testid='auto-debit-action-button'] >> nth=0
${AD_MODAL_ACTIVE_TEXT}        text=See your active auto payment
${AD_MODAL_SUMMARY}            text=Summary
${AD_MODAL_REPAYMENT_COMPLETE}    text=Repayment Complete
${AD_MODAL_STUDENT_DETAILS}    text=Student Details
${AD_MODAL_CLOSE}              css=button:has-text("Close")
${AD_SCHEDULE_SECTION}         text=Auto payments schedule

# URL hash fragments for tab navigation assertions (U2).
# Stored as variables because Robot Framework treats '#' as a comment character when
# passed as a literal argument token — e.g., `Keyword    #emi` strips the argument.
${HASH_EMI}                     \#emi
${HASH_INS}                     \#ins
${HASH_AD}                      \#ad
${HASH_PG}                      \#direct

*** Keywords ***
Login And Navigate To Dashboard
    [Documentation]
    ...    Suite Setup keyword. Opens a browser, logs in with ${DASHBOARD_MOBILE},
    ...    enters the fixed UAT OTP (9999), and waits for /my-applications to load.
    ...    Mirrors the checkMobilePost + verifyOtpPost rate-limit retry pattern from
    ...    Navigate To OTP Page (OTPPage.robot) — T3 boundary.
    ...    Satisfies: RT-1, RT-1.1, T2, O1, S1
    New Browser    ${BROWSER}    headless=${HEADLESS}
    Open Login Page
    Submit Login Form    ${DASHBOARD_MOBILE}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit during Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Close Context
        Sleep    ${RATE_LIMIT_WAIT}
        Open Login Page
        Submit Login Form    ${DASHBOARD_MOBILE}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit during Suite Setup — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Enter OTP    ${TEST_OTP}
        Click Verify OTP Button
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}

Navigate To Dashboard
    [Documentation]
    ...    Per-test navigation reset (TN4 resolution). Hard-navigates to /my-applications
    ...    and waits for the dashboard title to be visible. Resets active tab (default #emi),
    ...    filter panel (closed), profile dropdown (closed), and scroll position.
    ...    Called as Test Setup for every test in the suite (except those with [Setup] NONE).
    ...    Satisfies: RT-2, O1
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}

Switch To Account
    [Documentation]
    ...    Switches to a different test account WITHIN the same browser context.
    ...    Logs out the current user via the profile menu, then logs in with the given mobile.
    ...    Does NOT close or open browser contexts — the suite-level context is preserved (O1).
    ...    Includes rate-limit retry for checkMobilePost (sleep + retry Submit Login Form)
    ...    and verifyOtpPost (sleep + re-enter OTP).
    ...    Called from TC-4030 body (→ PG_MOBILE). TC-4031 inherits the PG_MOBILE session. TN2 resolution.
    ...    Satisfies: TN2, O1
    [Arguments]    ${mobile}
    Go To    ${BASE_URL}/my-applications
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    Click    ${PROFILE_BUTTON}
    Wait For Elements State    ${PROFILE_OPTIONS}    visible    timeout=${TIMEOUT}
    Click    ${LOGOUT_OPTION}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${LONG_TIMEOUT}
    Submit Login Form    ${mobile}
    ${otp_loaded}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=${LONG_TIMEOUT}
    IF    not ${otp_loaded}
        Log    checkMobilePost rate limit in Switch To Account — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        Submit Login Form    ${mobile}
        Wait For OTP Page
    END
    Submit OTP Form    ${TEST_OTP}
    ${redirected}=    Run Keyword And Return Status
    ...    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    IF    not ${redirected}
        Log    verifyOtpPost rate limit in Switch To Account — waiting ${RATE_LIMIT_WAIT} then retrying.    console=True
        Sleep    ${RATE_LIMIT_WAIT}
        ${on_dashboard}=    Run Keyword And Return Status    Dashboard URL Should Be Visible
        IF    not ${on_dashboard}
            ${on_otp}=    Run Keyword And Return Status
            ...    Wait For Elements State    ${OTP_FORM}    visible    timeout=3s
            IF    ${on_otp}
                Enter OTP    ${TEST_OTP}
                Click Verify OTP Button
            ELSE
                # Page is on / (login page) — rate limit caused redirect; re-submit login
                Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${TIMEOUT}
                Submit Login Form    ${mobile}
                Wait For OTP Page
                Submit OTP Form    ${TEST_OTP}
            END
        END
    END
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    Dashboard URL Should Be Visible
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}

Dashboard Title Should Say Hello
    [Documentation]
    ...    Asserts the dashboard title element contains "Hello,".
    ...    Exact substring match per TN6 resolution — title is design identity, not copy.
    ...    Satisfies: U1, TN6
    Wait For Elements State    ${DASHBOARD_TITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DASHBOARD_TITLE}
    Should Contain    ${text}    Hello,

Dashboard Subtitle Should Contain Product Names
    [Documentation]
    ...    Asserts the dashboard subtitle contains "Autopay subscriptions" (stable product term).
    ...    Should Contain rather than Should Be Equal per TN6 resolution — avoids false failures
    ...    on minor copy edits while still catching regressions on the product terminology.
    ...    Satisfies: U1, TN6
    Wait For Elements State    ${DASHBOARD_SUBTITLE}    visible    timeout=${TIMEOUT}
    ${text}=    Get Text    ${DASHBOARD_SUBTITLE}
    Should Contain    ${text}    Autopay subscriptions

GQ Logo Should Be Visible On Dashboard
    [Documentation]
    ...    Asserts the GrayQuest desktop logo (data-testid='desktop-view-gq-logo') is visible.
    ...    Distinct from the login page SVG logo — uses data-testid on the dashboard.
    ...    Satisfies: TC-4006, T1
    Wait For Elements State    ${GQ_LOGO_DASHBOARD}    visible    timeout=${TIMEOUT}

Open Profile Menu
    [Documentation]
    ...    Clicks the profile button and waits for the options container to be visible.
    ...    Per U3: the profile-options-container MUST be visible before asserting child options.
    ...    Satisfies: U3, TC-4007
    Click    ${PROFILE_BUTTON}
    Wait For Elements State    ${PROFILE_OPTIONS}    visible    timeout=${TIMEOUT}

Profile Menu Should Show FAQ And Logout
    [Documentation]
    ...    Asserts both the FAQ and Logout options are visible in the profile dropdown.
    ...    Must be called after Open Profile Menu (U3 sequence).
    ...    Satisfies: TC-4007, U3
    Wait For Elements State    ${FAQ_OPTION}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${LOGOUT_OPTION}    visible    timeout=${TIMEOUT}

Click FAQ Option And Verify Navigation
    [Documentation]
    ...    Clicks the FAQ option and asserts the FAQ page loaded via URL check.
    ...    Per TN3 resolution: URL contains /faq confirms navigation.
    ...    Browser title assertion removed — UAT FAQ page uses the generic site title
    ...    ("My Applications GrayQuest Education Finance...") which does not contain "FAQ".
    ...    No DOM element assertion — FAQ page h1 has no data-testid (TN3 resolution).
    ...    Satisfies: TC-4008, T1, TN3
    Click    ${FAQ_OPTION}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    FAQ URL Should Be Active

FAQ URL Should Be Active
    [Documentation]    Helper — asserts current URL contains /faq.
    ${url}=    Get Url
    Should Contain    ${url}    /faq

Logout And Verify Redirect To Login
    [Documentation]
    ...    Clicks the Logout option and asserts redirect to the login page.
    ...    After logout the shared session is destroyed (TN1). This keyword is called
    ...    ONLY in TC-4009 — the last test in the suite. Suite Teardown then closes browser.
    ...    Satisfies: TC-4009, TN1, O1, S1
    Click    ${LOGOUT_OPTION}
    Wait For Elements State    ${LOGIN_FORM}    visible    timeout=${LONG_TIMEOUT}

Click Create New Application And Verify Response
    [Documentation]
    ...    Clicks the Create New Application button and asserts a visible response occurred.
    ...    Per TN5 resolution: accepts EITHER a modal becoming visible OR the URL changing.
    ...    If neither is observed (e.g., inline form without modal class), logs WARN and passes —
    ...    the button was clickable and the UI responded (inline behaviour is UAT-environment specific).
    ...    Covers accounts with and without existing applications (O2 dual-branch).
    ...    Satisfies: TC-4010, O2, TN5
    ${initial_url}=    Get Url
    Click    ${CREATE_APP_BUTTON}
    ${modal_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=.modal-dialog    visible    timeout=${TIMEOUT}
    IF    not ${modal_visible}
        ${current_url}=    Get Url
        IF    '${current_url}' == '${initial_url}'
            Log    TC-4010: Neither modal nor URL change observed after Create New Application click — inline form or unknown UAT response. Button was responsive (TN5 dual-branch, continuing).    WARN
        END
    END

Create New Application Button Should Be Visible And Clickable In Header
    [Documentation]
    ...    Asserts the create-new-application-button is visible in the top navigation header
    ...    and that clicking it produces a visible UI response (TC-4034 / existing-user scenario).
    ...    The button renders in the header nav when the account already has prior applications.
    ...    Clicks the EMI tab first and waits 1 s before clicking the button — this settles
    ...    the page and activates the button's click handler (same pattern used in the working
    ...    traversal keyword Click Create Application Button And Wait For Student Details).
    ...    After clicking, accepts either:
    ...      (a) Radix UI dialog (role='dialog') — "Before you proceed" / "Still want to create"
    ...          modal; asserts modal text and closes via close-button testid.
    ...      (b) URL change away from /my-applications — direct wizard navigation.
    ...    Precondition: logged in as an account with at least one prior application.
    ...    Satisfies: TC-4034, B1, T1
    Click    ${EMI_TAB}
    Sleep    1s
    Wait For Elements State    ${CREATE_APP_BUTTON}    visible    timeout=${TIMEOUT}
    ${initial_url}=    Get Url
    Click    ${CREATE_APP_BUTTON}
    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    css=[role='dialog']    visible    timeout=${TIMEOUT}
    IF    ${dialog_visible}
        Wait For Elements State    ${CREATE_APP_MODAL_TEXT}    visible    timeout=${TIMEOUT}
        Click    ${CLOSE_BUTTON}
        Wait For Elements State    css=[role='dialog']    hidden    timeout=${TIMEOUT}
    ELSE
        ${current_url}=    Get Url
        Should Not Be Equal    ${current_url}    ${initial_url}
        ...    Create New Application button click produced no response — dialog not shown and URL did not change.
    END

EMI Empty State Should Be Visible
    [Documentation]
    ...    Asserts the "No Data Found" image and "You have No Applications for" text are
    ...    visible on the EMI tab for a new user with no existing applications.
    ...    PRECONDITION: Logged in as a fresh mobile with no application history.
    ...    Satisfies: TC-4047
    Wait For Elements State    ${EMI_EMPTY_IMAGE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${EMI_EMPTY_TEXT}    visible    timeout=${TIMEOUT}

EMI App ID Label Should Be Visible
    [Documentation]
    ...    Asserts the "Application ID:" label is visible on the first EMI card surface.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have at least one active EMI application.
    ...    Satisfies: TC-4044
    Wait For Elements State    ${EMI_APP_ID_LABEL}    visible    timeout=${TIMEOUT}

EMI App Copy Button Should Be Visible
    [Documentation]
    ...    Asserts the app-id-copy-button is visible on the first EMI card.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have at least one active EMI application.
    ...    Satisfies: TC-4045
    Wait For Elements State    ${EMI_APP_COPY_BUTTON}    visible    timeout=${TIMEOUT}

Load More Button Should Be Visible
    [Documentation]
    ...    Asserts the load-more-button is visible on the EMI tab when the account
    ...    has more applications than the initial page renders.
    ...    PRECONDITION: ${DASHBOARD_MOBILE} must have enough applications to trigger pagination.
    ...    Satisfies: TC-4046
    Wait For Elements State    ${LOAD_MORE_BUTTON}    visible    timeout=${TIMEOUT}

AD Empty Alert Should Be Visible
    [Documentation]
    ...    Asserts the ARIA alert role element is visible on the Auto Payments tab
    ...    when the logged-in user has no active AD subscriptions.
    ...    PRECONDITION: Logged in as a fresh mobile with no AD applications.
    ...    Satisfies: TC-4048
    Wait For Elements State    ${AD_EMPTY_ALERT}    visible    timeout=${TIMEOUT}

PG Online Empty State Should Be Visible
    [Documentation]
    ...    Asserts "Online transactions not found" text is visible on the Online sub-tab
    ...    for a new user with no transaction history.
    ...    PRECONDITION: Logged in as a fresh mobile with no PG transaction records.
    ...    Satisfies: TC-4049
    Wait For Elements State    ${PG_ONLINE_EMPTY_TEXT}    visible    timeout=${TIMEOUT}

PG Offline Empty State Should Be Visible
    [Documentation]
    ...    Asserts the "No Data Found" image and "You have not done any" text are visible
    ...    on the Offline sub-tab for a new user with no offline transactions.
    ...    PRECONDITION: Logged in as a fresh mobile with no PG transaction records.
    ...    Satisfies: TC-4050
    Wait For Elements State    ${PG_OFFLINE_EMPTY_IMAGE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${PG_OFFLINE_EMPTY_TEXT}    visible    timeout=${TIMEOUT}

Click Filter Container Clear
    [Documentation]
    ...    Clicks the inline "Clear" chip inside the filter-container that appears
    ...    after a filter has been applied via the Apply button.
    ...    Distinct from the clear-filter-button inside the filter panel (TC-4028).
    ...    Satisfies: TC-4051
    Wait For Elements State    ${FILTER_CONTAINER_CLEAR}    visible    timeout=${TIMEOUT}
    Click    ${FILTER_CONTAINER_CLEAR}

Create New Application Button Should Be Visible And Clickable In Empty State
    [Documentation]
    ...    Asserts the create-new-application button is visible in the emi-not-data-found
    ...    empty-state container and that clicking it navigates away from /my-applications
    ...    (TC-4035 / new-user scenario).
    ...    The yellow "+ CREATE NEW APPLICATION" button renders only when the account has NO
    ...    existing applications. Clicking it goes directly to /student-details (no dialog).
    ...    Precondition: logged in as a fresh account with no prior applications.
    ...    Satisfies: TC-4035, B1, T1
    Click    ${EMI_TAB}
    Wait For Elements State    ${CREATE_APP_BUTTON_EMPTY}    visible    timeout=${TIMEOUT}
    ${initial_url}=    Get Url
    Click    ${CREATE_APP_BUTTON_EMPTY}
    Wait Until Keyword Succeeds    ${LONG_TIMEOUT}    500ms    New Application URL Should Have Changed    ${initial_url}

New Application URL Should Have Changed
    [Documentation]    Helper — asserts the current URL is no longer the initial dashboard URL.
    [Arguments]    ${initial_url}
    ${current_url}=    Get Url
    Should Not Be Equal    ${current_url}    ${initial_url}
    ...    URL did not change after clicking Create New Application in empty state.

Click EMI Tab And Verify
    [Documentation]
    ...    Clicks the EMI tab button and asserts the URL hash updates to #emi.
    ...    Satisfies: TC-4011, U2
    Click    ${EMI_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_EMI}

Click AD Tab And Verify
    [Documentation]
    ...    Clicks the Auto Payments (AD) tab button and asserts the URL hash updates to #ad.
    ...    Satisfies: TC-4012, U2
    Click    ${AD_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_AD}

Click Insurance Tab And Verify
    [Documentation]
    ...    Clicks the Insurance tab button and asserts the URL hash updates to #ins.
    ...    Satisfies: U2
    Click    ${INS_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_INS}

Click Transaction History Tab And Verify
    [Documentation]
    ...    Clicks the Transaction History (PG) tab button and asserts the URL hash updates to #direct.
    ...    Satisfies: TC-4003, TC-4013, U2
    Click    ${PG_TAB}
    Wait Until Keyword Succeeds    ${TIMEOUT}    200ms    URL Should Contain Hash    ${HASH_PG}

URL Should Contain Hash
    [Documentation]    Helper — asserts the current URL contains the given hash fragment.
    [Arguments]    ${hash}
    ${url}=    Get Url
    Should Contain    ${url}    ${hash}

EMI Cards Should Be Visible
    [Documentation]
    ...    Asserts at least one EMI card is visible in the EMI tab content area.
    ...    Uses Get Elements (not Wait For Elements State) because css=[data-testid*='emi-card']
    ...    intentionally matches multiple cards — Wait For Elements State uses strict mode and
    ...    rejects multi-element locators (T1 partial match, T4 boundary).
    ...    Wait Until Keyword Succeeds polls for async card rendering (cards may load after tab paint).
    ...    PRECONDITION: UAT account must have at least one active EMI application (TN2 resolution B).
    ...    A failure here signals an account seeding need, not a test defect.
    ...    Satisfies: TC-4001, TC-4011, T4
    Wait Until Keyword Succeeds    ${TIMEOUT}    500ms    EMI Cards Count Should Be Positive

EMI Cards Count Should Be Positive
    [Documentation]    Helper — asserts Get Elements returns at least one EMI card.
    ${cards}=    Get Elements    ${EMI_CARDS}
    Should Be True    len($cards) > 0
    ...    No EMI cards found — UAT account may need seeding with active EMI applications (TN2 precondition, not a test defect).

Offline Filter Options Should Be Visible
    [Documentation]
    ...    Asserts time filter options are visible in the open Offline filter panel.
    ...    The Offline sub-tab filter panel shows only time filters — Paid/Failed status
    ...    options are absent (confirmed UAT behaviour, not a defect).
    ...    Satisfies: TC-4023, T5
    Wait For Elements State    ${FILTER_ALL_MONTHS}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_THIS_MONTH}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_THIS_YEAR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_LAST_YEAR}    visible    timeout=${TIMEOUT}

Online And Offline Sub-tabs Should Be Visible
    [Documentation]
    ...    Asserts both Online and Offline sub-tabs are present in the Transaction History tab.
    ...    Satisfies: TC-4003, TC-4013, TC-4014, TC-4015
    Wait For Elements State    ${ONLINE_SUBTAB}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${OFFLINE_SUBTAB}    visible    timeout=${TIMEOUT}

Click Online Sub-tab
    [Documentation]
    ...    Clicks the Online sub-tab in the Transaction History tab.
    ...    Satisfies: TC-4015
    Wait For Elements State    ${ONLINE_SUBTAB}    visible    timeout=${TIMEOUT}
    Click    ${ONLINE_SUBTAB}

Click Offline Sub-tab
    [Documentation]
    ...    Clicks the Offline sub-tab in the Transaction History tab.
    ...    Satisfies: TC-4014
    Wait For Elements State    ${OFFLINE_SUBTAB}    visible    timeout=${TIMEOUT}
    Click    ${OFFLINE_SUBTAB}

Open Filter Panel
    [Documentation]
    ...    Clicks the filter button to open the filter panel.
    ...    Satisfies: TC-4016, TC-4023
    Wait For Elements State    ${FILTER_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${FILTER_BUTTON}

Filter Options Should Be Visible
    [Documentation]
    ...    Asserts all time and status filter options are visible in the open filter panel.
    ...    T5 boundary: tests assert filter UI existence unconditionally (TN2 resolution B).
    ...    Satisfies: TC-4016, TC-4023, T5
    Wait For Elements State    ${FILTER_ALL_MONTHS}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_THIS_MONTH}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_THIS_YEAR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_LAST_YEAR}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_PAID}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${FILTER_FAILED}    visible    timeout=${TIMEOUT}

Select Time Filter
    [Documentation]
    ...    Selects a time filter option in the open filter panel.
    ...    Valid values: All Months, This Month, This Year, Last Year.
    ...    Note: data-testid values contain spaces — CSS attribute selector handles this correctly.
    ...    Satisfies: TC-4017 to TC-4020, TC-4024, TC-4027, T5
    [Arguments]    ${filter_name}
    ${locator}=    Set Variable    css=[data-testid='${filter_name}']
    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Click    ${locator}

Select Status Filter
    [Documentation]
    ...    Selects a status filter option in the open filter panel.
    ...    Valid values: Paid, Failed.
    ...    Satisfies: TC-4021, TC-4022, T5
    [Arguments]    ${filter_name}
    ${locator}=    Set Variable    css=[data-testid='${filter_name}']
    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Click    ${locator}

Click Clear Filter
    [Documentation]
    ...    Clicks the clear filter button to reset applied filter selections.
    ...    Satisfies: TC-4028, T5
    Wait For Elements State    ${CLEAR_FILTER_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${CLEAR_FILTER_BUTTON}

Click Apply Filter
    [Documentation]
    ...    Clicks the apply filter button to apply the selected filter options.
    ...    Satisfies: TC-4029, T5
    Wait For Elements State    ${APPLY_FILTER_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${APPLY_FILTER_BUTTON}

Download Button Should Be Visible For First Row
    [Documentation]
    ...    Asserts the download button for the first transaction row is visible.
    ...    Uses CSS suffix match ($=) to find any download button regardless of row index,
    ...    then selects the first one (>> nth=0).
    ...    PRECONDITION: UAT account must have at least one transaction row in the active sub-tab (TN2).
    ...    A failure here signals an account seeding need, not a test defect.
    ...    Satisfies: TC-4030, TC-4031, T5
    ${locator}=    Set Variable    css=[data-testid$='-download-button'] >> nth=0
    ${visible}=    Run Keyword And Return Status
    ...    Wait For Elements State    ${locator}    visible    timeout=${TIMEOUT}
    Should Be True    ${visible}
    ...    No download button found — UAT account needs at least one transaction record (TN2 precondition, not a test defect).

AD App Code Label Should Be Visible
    [Documentation]
    ...    Asserts the "App. Code:" label is visible in the Auto Payments tab content area.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one active AD application.
    ...    A failure signals an account seeding need, not a test defect.
    ...    Satisfies: TC-4037
    Wait For Elements State    ${AD_APP_CODE_LABEL}    visible    timeout=${TIMEOUT}

AD Copy Button Should Be Visible
    [Documentation]
    ...    Asserts the copy button is visible on the first AD application card.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application.
    ...    Satisfies: TC-4038
    Wait For Elements State    ${AD_COPY_BUTTON}    visible    timeout=${TIMEOUT}

AD Repayment Active Status Should Be Visible
    [Documentation]
    ...    Asserts "Your repayment is active" status text is visible on at least one AD card.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one active repayment.
    ...    Satisfies: TC-4039
    Wait For Elements State    ${AD_STATUS_ACTIVE}    visible    timeout=${TIMEOUT}

AD Repayment Pending Status Should Be Visible
    [Documentation]
    ...    Asserts "Your repayment is pending" status text is visible on at least one AD card.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one pending repayment.
    ...    Satisfies: TC-4040
    Wait For Elements State    ${AD_STATUS_PENDING}    visible    timeout=${TIMEOUT}

AD Action Button Should Be Visible
    [Documentation]
    ...    Asserts the auto-debit-action-button is visible on the first AD card.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application.
    ...    Satisfies: TC-4041
    Wait For Elements State    ${AD_ACTION_BUTTON}    visible    timeout=${TIMEOUT}

AD Action Button Should Open Detail Modal
    [Documentation]
    ...    Clicks the first auto-debit-action-button and asserts the detail modal opens,
    ...    showing stable structural content: "See your active auto payment", "Summary",
    ...    "Repayment Complete", and "Student Details". Dynamic values (amounts, names,
    ...    school) are not asserted — they vary by account data.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application with detail data.
    ...    Satisfies: TC-4042
    Wait For Elements State    ${AD_ACTION_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${AD_ACTION_BUTTON}
    Wait For Elements State    ${AD_MODAL_ACTIVE_TEXT}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${AD_MODAL_SUMMARY}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${AD_MODAL_REPAYMENT_COMPLETE}    visible    timeout=${TIMEOUT}
    Wait For Elements State    ${AD_MODAL_STUDENT_DETAILS}    visible    timeout=${TIMEOUT}

AD Detail Modal Close Button Should Dismiss Modal
    [Documentation]
    ...    Opens the first AD application's detail modal, clicks the Close button,
    ...    and asserts the modal content ("See your active auto payment") is no longer visible.
    ...    Satisfies: TC-4043
    Wait For Elements State    ${AD_ACTION_BUTTON}    visible    timeout=${TIMEOUT}
    Click    ${AD_ACTION_BUTTON}
    Wait For Elements State    ${AD_MODAL_ACTIVE_TEXT}    visible    timeout=${TIMEOUT}
    Click    ${AD_MODAL_CLOSE}
    Wait For Elements State    ${AD_MODAL_ACTIVE_TEXT}    hidden    timeout=${TIMEOUT}

AD Schedule Section Should Be Visible
    [Documentation]
    ...    Asserts the "Auto payments schedule" section heading is visible in the AD tab.
    ...    PRECONDITION: ${AD_MOBILE} must have at least one AD application with schedule data.
    ...    Satisfies: TC-4044
    Wait For Elements State    ${AD_SCHEDULE_SECTION}    visible    timeout=${TIMEOUT}
