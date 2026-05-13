*** Settings ***
Documentation
...    Test suite for View Applicant Details flow in Application Details.
...    Locators and test cases to be filled after recording review.

Library      Browser
Resource     ../../resources/ViewApplicantDetailsPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Open Browser To Login Page
Suite Teardown   Close Browser
Test Setup       Navigate To View Applicant Details Within Session
Test Tags        application-details    view-applicant-details
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:View Applicant Details

*** Test Cases ***
# TC-AD-VA-001 placeholder — to be filled after recording
