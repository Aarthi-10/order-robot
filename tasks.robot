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
${ORDER_CSV}=    ${CURDIR}${/}orders.csv
${Path_URL}=     https://robotsparebinindustries.com/orders.csv
${URL}=          https://robotsparebinindustries.com/#/robot-order
${myrow}=        Head  Body  Legs  Address
${output_folder}  ${CURDIR}${/}output
${img_folder}     ${CURDIR}${/}image_files
${zip_file}       ${output_folder}${/}pdf_archive.zip


***keywords
Directory Cleanup    
    Log To console      Cleaning up content from previous test runs
    Create Directory    ${img_folder}
    Create Directory    ${output_folder}

    Empty Directory     ${img_folder}
    Empty Directory     ${output_folder}

***tasks***
Loop a list
  ${order}=   Create list   Head   Body   Legs
  FOR   ${row}   IN   @{order}
      Log  ${row}
  END 

***keywords***
open robot order website
   open available Browser    ${URL}
   Click Button    css:button.btn.btn-dark

***keywords***
Get order
   @{orders}=    Read Table From Csv   ${ORDER_CSV}    header=True
       FOR    ${order}    IN    @{orders}
          Log  ${order}
       END

***keywords***
Fill the form   
    Set Local Variable    ${order_no}   ${myrow}\'[Order number]'
    Set Local Variable    ${head}       ${myrow}\'[Head]''
    Set Local Variable    ${body}       ${myrow}\'[Body]'
    Set Local Variable    ${legs}       ${myrow}\'[Legs]'
    Set Local Variable    ${address}    ${myrow}\'[Address]'
    Set Local Variable    ${input_address}    //*[@id="address"]
    Set Local Variable    ${input_body}       //*[@id="id-body-3"]
    Set Local Variable    ${input_head}       //*[@id="head"]
    Set Local Variable    ${input_legs}       xpath://html/body/div/div/div[1]/div/div[1]/form/div[3]/input
    Select From List By Label  ${input_head}  D.A.V.E head
    sleep   1s
    Click Button              //*[@id="id-body-3"]
    sleep   1s
    Input Text             ${input_legs}      id="3"
    sleep   1s
    Input Text            ${input_address}    Los angels
    sleep   1s


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
    Page Should Contain Element        ${receipt}  ${order} 
    Sleep    1s 

***keywords***
Store the receipt as pdf
      Wait Until Element Is Visible          //*[@id="order-completion"]                    
      ${file}=   Get Element Attribute       //*[@id="order-completion"]      outerHTML
      Html To Pdf     ${file}      ${CURDIR}${/}output${/}receipt_html.pdf

*** Keywords ***
Take a screenshot of the robot
    Screenshot    //*[@id="robot-preview-image"]     ${CURDIR}${/}image_files${/}robot-preview-image.png


***keywords***
Embed the robot screenshot to the receipt PDF file   
    ${images}=    Create List      ${CURDIR}${/}image_files${/}robot-preview-image.png
    Add Files To Pdf    ${images}   ${CURDIR}${/}output${/}receipt_html.pdf    True

***keywords***
Go to order another robot
   Set Local Variable     ${order_another_robot}     //*[@id="order-another"]
   Click Button           ${order_another_robot}
  Get order
  Fill the form 
  Select From List By Label  ${input_head}  
    sleep   1s
    Click Button              //*[@id="id-body-3"]
    sleep   1s
    Input Text             ${input_legs}      id="3"
    sleep   1s
    Input Text            ${input_address}    Los angels
    sleep   1s
  Preview the robot
  Submit the order
  Store the receipt as pdf
  Take a screenshot of the robot
  Embed the robot screenshot to the receipt PDF file   
  Go to order another robot
  Log out and close the browser
  Create a Zip File of the Receipts

***keywords***
Log out and close the browser
   Close Browser
   sleep  1s

***keywords***
Create a Zip File of the Receipts
    Archive Folder With ZIP     ${output_folder}  ${zip_file}   recursive=True  include=*.pdf

***tasks***
Web store order   
  Directory Cleanup
  open robot order website
  Get order
  Fill the form  
  Preview the robot
  Submit the order
  Store the receipt as pdf
  Take a screenshot of the robot
  Embed the robot screenshot to the receipt PDF file   
  Go to order another robot
  Log out and close the browser
  Create a Zip File of the Receipts



