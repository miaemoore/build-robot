*** Settings ***
Documentation       This program automatically places robot orders on the website from the order csv files.

Library             RPA.Browser.Selenium    auto_close=${False}


*** Tasks ***
This program automatically places robot orders on the website from the order csv files.
    Open order webpage
    Close popup
    Fill out form
    Preview robot
    Place order
    Check for error
    Receipt
    Log    Done.


*** Keywords ***
Open order webpage
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Close popup
    Click Button When Visible    css:.btn.btn-dark

Fill out form
    Select From List By Index    id:head    1
    Select Radio Button    body    2
    Input Text    class:form-control    3
    Input Text    address    Address 123

Preview robot
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image

Place order
    Click Button    id:order

Check for error
    ${errorcheck}=    Is Element Visible    id:order-completion
    IF    ${errorcheck} == ${False}    Place order    ELSE    Receipt

Receipt
    Wait Until Element Is Visible    id:order-completion
