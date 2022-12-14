*** Settings ***
Documentation       This program automatically places robot orders on the website from the order csv files.

Library             RPA.Browser.Selenium
Library             RPA.PDF
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive


*** Tasks ***
This program automatically places robot orders on the website from the order csv files.
    Open order webpage
    Get orders
    Log    Done.
    [Teardown]    Close browser and zip folder


*** Keywords ***
Open order webpage
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    orders.csv    overwrite=true
    ${orders}=    Read table from CSV    orders.csv
    FOR    ${order}    IN    @{orders}
        Close popup
        Fill out form    ${order}
        Preview robot
        Place order
        Check for error    ${order}
        Order another robot
    END

Close popup
    Click Button When Visible    css:.btn.btn-dark

Fill out form
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview robot
    Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image

Place order
    Click Button    id:order

Check for error
    [Arguments]    ${order}
    ${errorcheck}=    Is Element Visible    id:order-completion
    IF    ${errorcheck} == ${False}
        Place order
    ELSE
        Create receipt pdf    ${order}
    END

Create receipt pdf
    [Arguments]    ${order}
    ${exists}=    Does Directory Exist    ${OUTPUT_DIR}${/}Receipts
    IF    ${exists} == ${False}    Create Directory    ${OUTPUT_DIR}${/}Receipts
    Wait Until Element Is Visible    id:order-completion
    ${Receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${Receipt}    ${OUTPUT_DIR}${/}Receipts${/}receipt${order}[Order number].pdf
    Capture Element Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}robot${order}[Order number].png
    Add Watermark Image To Pdf
    ...    ${OUTPUT_DIR}${/}robot${order}[Order number].png
    ...    ${OUTPUT_DIR}${/}Receipts${/}receipt${order}[Order number].pdf
    ...    ${OUTPUT_DIR}${/}Receipts${/}receipt${order}[Order number].pdf
    Remove File    ${OUTPUT_DIR}${/}robot${order}[Order number].png

Order another robot
    Click Button    id:order-another

Close browser and zip folder
    Close Browser
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    Receipts.zip
