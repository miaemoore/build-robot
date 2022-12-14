*** Settings ***
Documentation       This program automatically places robot orders on the website from the order csv files.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.PDF


*** Tasks ***
This program automatically places robot orders on the website from the order csv files.
    Open order webpage
    Close popup
    Fill out form
    Preview robot
    Place order
    Check for error
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
    IF    ${errorcheck} == ${False}    Place order    ELSE    Create receipt pdf

Create receipt pdf
    Wait Until Element Is Visible    id:order-completion
    ${Receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${Receipt}    ${OUTPUT_DIR}${/}receipt.pdf
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot.png
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}robot.png
    ...    ${OUTPUT_DIR}${/}receipt.pdf
    ...    ${OUTPUT_DIR}${/}receipt.pdf
