*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images
Library           OperatingSystem
Library           RPA.Browser.Selenium
Library           RPA.Desktop
Library           RPA.HTTP
Library           RPA.PDF
Library           RPA.Tables
Library           RPA.Dialogs
Library           RPA.Archive
Library           Collections
Library           RPA.Robocorp.Vault

*** Variables ***
${ORDER_CSV}      ${CURDIR}${/}orders.csv
${Path_URL}=      https://robotsparebinindustries.com/orders.csv
${URL}=           https://robotsparebinindustries.com/#/robot-order
${myrow}=         Head  Body  Legs  Address
${output_folder}  ${CURDIR}${/}output
${img_folder}     ${CURDIR}${/}image_files
${zip_file}       ${output_folder}${/}pdf_archive.zip
${username}=      Get The User Name


***keywords
Directory Cleanup    
    Log To console      Cleaning up content from previous test runs
    Create Directory    ${img_folder}
    Create Directory    ${output_folder}

    Empty Directory     ${img_folder}
    Empty Directory     ${output_folder}

***keywords***
Loop a list
  ${order}=   Get orders
  FOR   ${row}   IN   @{order}
      Fill the form    ${row}
  END 

***keywords***
open robot order website
    Open Available Browser   ${URL}
    Maximize Browser Window
    Click Button    css:button.btn.btn-dark


***keywords***
Get orders
    Download    url=${Path_URL}         target_file=${ORDER_CSV}    overwrite=True
    ${table}=   Read table from CSV    path=${ORDER_CSV}
    [Return]    ${table}

# +
***keywords***
Fill the form   
    [Arguments]      ${myrow}
    Set Local Variable    ${order_no}   ${myrow}[Order number]
    Set Local Variable    ${head}       ${myrow}[Head]
    Set Local Variable    ${body}       ${myrow}[Body]
    Set Local Variable    ${legs}       ${myrow}[Legs]
    Set Local Variable    ${address}    ${myrow}[Address]
    Set Local Variable      ${input_head}       //*[@id="head"]
    Set Local Variable      ${input_body}       body
    Set Local Variable      ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Set Local Variable      ${input_address}    //*[@id="address"] 

    Wait Until Element Is Visible   ${input_head}
    Wait Until Element Is Enabled   ${input_head}
    Select From List By Value       ${input_head}           ${head}
    Wait Until Element Is Enabled   ${input_body}
    Select Radio Button             ${input_body}           ${body}
    Wait Until Element Is Enabled   ${input_legs}
    Input Text                      ${input_legs}           ${legs}
    Wait Until Element Is Enabled   ${input_address}
    Input Text                      ${input_address}        ${address}
    

# -

***keywords***
Preview the robot
    Set Local Variable              ${preview}          //*[@id="preview"]
    Set Local Variable              ${img_preview}      //*[@id="robot-preview-image"]
    Click Button                    ${preview}
    sleep  1s

***keywords*
Submit the order
    Set Local Variable              ${order}       //*[@id="order"]
    Set Local Variable              ${receipt}     //*[@id="receipt"]
    Mute Run On Failure             Page Should Contain Element 
    Click button                    ${order}
    Page Should Contain Element     ${receipt}  ${order} 
    Sleep    1s 

***keywords***
Store the receipt as pdf
      Wait Until Element Is Visible          //*[@id="order-completion"]                    
      ${file}=   Get Element Attribute       //*[@id="order-completion"]      outerHTML
      Html To Pdf     ${file}      ${CURDIR}${/}output${/}receipt_html.pdf

*** Keywords ***
Take a screenshot of the robot
    Screenshot    //*[@id="robot-preview-image"]     ${CURDIR}${/}image_files${/}robot-preview-image.png


*** Keywords ***
Embed the robot screenshot to the receipt PDF file   
    ${images}=    Create List      ${CURDIR}${/}image_files${/}robot-preview-image.png
    Add Files To Pdf    ${images}   ${CURDIR}${/}output${/}receipt_html.pdf    True

***keywords***
Go to order another robot
   Set Local Variable     ${order_another_robot}     //*[@id="order-another"]
   Click Button           ${order_another_robot}
   Sleep  1s 

***keywords***
Log out and close the browser
   Close Browser
   sleep  1s

***keywords***
Create a Zip File of the Receipts
    Archive Folder With ZIP     ${output_folder}  ${zip_file}   recursive=True  include=*.pdf

*** Keywords ***
Get credentials
    Log To Console     Getting Secret from our Vault
    ${robotsparebin}=        Get Secret     robotsparebin    
    open available browser   https://robotsparebinindustries.com/#/
    Input Text        id:username    ${robotsparebin}[username]
    Input Password    id:password    ${robotsparebin}[password]
    sleep  3s
    Close Browser

***keywords***
Get The User Name
    Add heading             I am your Genie
    Add text input          myname   label=What is the name?    placeholder=Give me some input here
    ${result}=              Run dialog
    [Return]                ${result.myname}                    

***keywords***
Display the success dialog
    Add icon      Success
    Add heading   Your orders have been processed
    Add files        all orders have been processed.
    Run dialog     title=Success
    Close Browser

***tasks***
Web store order   
  Directory Cleanup
  open robot order website
  Get orders
  Loop a list
  Preview the robot
  Submit the order
  Store the receipt as pdf
  Take a screenshot of the robot
  Embed the robot screenshot to the receipt PDF file   
  Go to order another robot
  Log out and close the browser
  Create a Zip File of the Receipts
  Get credentials
  Get The User Name
  Display the success dialog  


