*** Settings ***
Documentation
...    Test suite for Upload Documents flow in Application Details.
...    Locators and test cases to be filled after recording review.

Library      Browser
Resource     ../../resources/UploadDocumentsPage.robot
Resource     ../../variables/variables.robot

Suite Setup      Open Browser To Login Page
Suite Teardown   Close Browser
Test Setup       Navigate To Upload Documents Within Session
Test Tags        application-details    upload-documents
...    allure.label.epic:CP UI Automation
...    allure.label.feature:Application Details
...    allure.label.story:Upload Documents

*** Test Cases ***
# TC-AD-UD-001 placeholder — to be filled after recording
