*** Settings ***
Documentation
...    Test suite for Repayment Schedule flow in Application Details.
...    Locators and test cases to be filled after recording review.

Library      Browser
Resource     ../../resources/RepaymentSchedulePage.robot
Resource     ../../variables/variables.robot

Suite Setup      Open Browser To Login Page
Suite Teardown   Close Browser
Test Setup       Navigate To Repayment Schedule Within Session
Test Tags        application-details    repayment-schedule
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:Repayment Schedule

*** Test Cases ***
# TC-AD-RS-001 placeholder — to be filled after recording
