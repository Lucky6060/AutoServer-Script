#-------------------------------------------------------------------------------------------------------------------------------

#Automatic User Creation Via Documents

#Variable List:
        # The AD Group the script the users will be added to!
        # In our case we have a group called MonkeyMembers & our Domain is @Monkey.local
        $adGroup = "MonkeyMembers"
        $DomainPrefix = "@Monkey.local"
        
#Stupid function that does NATHING... NATHING (it finds the CSV folders information and pastes it out.)
Function PathInformationFunction {
    Param (
        #Variable for the CSV Path, IMPORTANT!
        $CSV_PATH = "C:\KodningFolder\JoachimRepo\AutoServer\User creation folder.csv")
        #First we start by importing the code.
        $CSV_COMPLETION = Import-CSV -Path "$CSV_PATH"

        #Were making an if statement to see if the CSV path was valid :)
        if ($CSV_COMPLETION) {
            Write-Host "The CSV PATH: '$CSV_PATH' is functional"
            # Her bruger vi Foreach jeg fandt på microsoft learn.
            # Vi skal bruge dette da vi skal havde en function kørende der lopper indtil dokumentet er tomt.
            foreach ($row in $CSV_COMPLETION) {
                    $UserID = $row.USERID
                    $FirstName = $row.FIRSTNAME
                    $MiddleName = $row.MIDDLENAME
                    $LastName = $row.LASTNAME

                    Write-Host "UserID: $UserID, First Name: $FirstName, Middle Name: $MiddleName, Last Name: $LastName"}
        } else {
    Write-Host "did not work"}
}

#Function that will one by one create users in the AD group.
Function UserCreationFunction {
    Param (
        #Variables for the user creation.
        $UserID,
        $Firstname,
        $Middlename,
        $Lastname
        )
            Write-Host "Creating user account for $fullName..."
        
            # Using the Get-ADUser combined with SamAccountName to find any username Equal to our Username.
            $existingUser = Get-ADUser -Filter { SamAccountName -eq $username }
            if ($existingUser) {
                Write-Host "Error!!! A user already has the username '$username' please run the script again and try something else."
            } else {
                # This creates the ADuser
                New-ADUser -Name $fullName `
                    -GivenName $firstName `
                    -Surname $lastName `
                    -SamAccountName $username `
                    -UserPrincipalName "$username$DomainPrefix" `
                    -AccountPassword $password `
                    -Enabled $true
        
                # After user creation we will add it to the group in our case MonkeyMembers!
                Add-ADGroupMember -Identity $adGroup -Members $username
                Write-Host "Success! :o $fullName ($username) has been added to the group '$adGroup'."
                Write-Host "Temp/Default Password: $passwordPlain (ask the user to change it at first login)."
            } else {
            Write-Host "UserCreation Script Failed! mayday mayday. Are you stupid? why didn't you type Yes >:C" 
        }
}

#This is the start of the script! (excluding functions of course)

#We are calling the function that reads out the CSV file via PathInformationFunction
PathInformationFunction

#We are adding a small pop up that warns the user that by pressing enter they agree to the following users stated will be added to the viable adgroup.
Read-Host "`nIs this information correct? (Press 'ENTER' to continue) `nWARNING!!! Pressing Enter will begin the Process of adding every user to the '$adGroup'"
foreach ($row in $CSV_COMPLETION) {
    $UserID = $row.USERID
    $FirstName = $row.FIRSTNAME
    $MiddleName = $row.MIDDLENAME
    $LastName = $row.LASTNAME

    UserCreationFunction($UserID, $FirstName, $MiddleName, $LastName)
}


#-------------------------------------------------------------------------------------------------------------------------------