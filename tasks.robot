*** Settings ***
Documentation       This program automatically places robot orders on the website from the order csv files.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.PDF
Library             RPA.Excel.Files
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault


*** Tasks ***
This program automatically places robot orders on the website from the order csv files.
    Get csv file
    Log    Done.


*** Keywords ***
Get csv file
    Add heading    Order File
    Add text    Please provide csv order file link:
    Add text input    csv    placeholder=https://robotsparebinindustries.com/orders.csv
    ${input}=    Run dialog
    Get orders    ${input.csv}

Open order webpage
    ${website}=    Get Secret    website
    Open Available Browser    ${website}[address]

Get orders
    [Arguments]    ${input.csv}
    Download    ${input.csv}    orders.csv    overwrite=true
    ${orders}=    Read table from CSV    orders.csv
    Open order webpage
    FOR    ${order}    IN    @{orders}
        Close popup
        Fill out form    ${order}
        Preview robot
        Place order    ${order}
        Order another robot
    END
    [Teardown]    Close browser and zip folder

Close popup
    Click Button When Visible    css:.btn.btn-dark

Fill out form
    [Arguments]    ${order}
    Select From List By Index    id:head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    class:form-control    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview robot
    Wait And Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image

Place order
    [Arguments]    ${order}
    Wait and Click Button    id:order
    Check for error    ${order}

Check for error
    [Arguments]    ${order}
    ${errorcheck}=    Is Element Visible    id:order-completion
    IF    ${errorcheck} == ${False}
        Place order    ${order}
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
    Wait And Click Button    id:order-another

Close browser and zip folder
    Close Browser
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    ${OUTPUT_DIR}${/}Receipts.zip
