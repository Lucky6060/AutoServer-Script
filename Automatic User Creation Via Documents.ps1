#-------------------------------------------------------------------------------------------------------------------------------

#Automatic User Creation Via Documents
        #'Enable-PSRemoting -Force' on the domain controller for credentials to work.
        $Credentials = Get-Credential
        #First we start by importing the code.
        #These values will be automated in the future but for now it's important to keep track of their hard coded values.
        $SERVER_CSV_PATH = "C:\KodningFolder\JoachimRepo\AutoServer\ServerVariables.csv"
        $SERVER_CSV_COMPLETION = Import-CSV -Path "$SERVER_CSV_PATH"
        $USER_CSV_PATH = $Server_CSV_COMPLETION.UserCSVPath
        $USER_CSV_COMPLETION = Import-CSV -Path "$USER_CSV_PATH"

        #Server Variables
        # The AD Group the script the users will be added to!
        # In our case we have a group called MonkeyMembers & our Domain is @Monkey.local (the @ is important)
        $adGroup = $SERVER_CSV_COMPLETION.ADGroup
        $DomainPrefix = $SERVER_CSV_COMPLETION.DomainPrefix
        $serverName = $SERVER_CSV_COMPLETION.ServerName

#-------------------------------------------------------------------------------------------------------------------------------

#Stupid function that does NATHING... NATHING (it finds the CSV folders information and pastes it out.)
Function PathInformationFunction {
    #Were making an if statement to see if the CSV path was valid :)
    if ($USER_CSV_COMPLETION) {
        Write-Host "The CSV PATH: '$USER_CSV_PATH' is functional`n"
        # Her bruger vi Foreach jeg fandt på microsoft learn.
        # Vi skal bruge dette da vi skal havde en function kørende der lopper indtil dokumentet er tomt.
        foreach ($row in $USER_CSV_COMPLETION) {
                $UserID = $row.USERID
                $FirstName = $row.FIRSTNAME
                $MiddleName = $row.MIDDLENAME
                $LastName = $row.LASTNAME

                Write-Host "UserID: $UserID, First Name: $FirstName, Middle Name: $MiddleName, Last Name: $LastName"}
        } else {
    Write-Host "did not work`n"}
}

#Function that will one by one create users in the AD group.
Function UserCreationFunction {
    #Type sum
    Write-Host "Creating user account for $Firstname..."
        
    # Using the Get-ADUser combined with SamAccountName to find any username Equal to our Username.
    $InvokeResults = Invoke-Command -ComputerName $serverName -Credential $Credentials -ScriptBlock {
    $existingUser = Get-ADUser -Filter { SamAccountName -eq $username }
    if ($existingUser) {
        } else {
            # This creates the ADuser
            New-ADUser -Name $FullName `
                -GivenName $FirstName `
                -Surname $LastName `
                -SamAccountName $username `
                -UserPrincipalName "$username@$DomainPrefix" `
                -AccountPassword $password `
                -Enabled $true
        
                # After user creation we will add it to the group in our case MonkeyMembers!
                Add-ADGroupMember -Identity $adGroup -Members $username
        }
    } 
    #Error Codes for this function... These aren't really important they are just for finishing touches.
    <#if ($InvokeResults = -ne) {
        Write-Host "Error!!! the invoke has failed with the message: '$InvokeResults'"
    }#>
    if ($existingUser) {
        Write-Host "Error!!! A user already has the username '$username' please run the script again and try something else."
    } else  {
            Write-Host "Success! $fullName ($username) has been added to the group '$adGroup'."
            Write-Host "Temp/Default Password: $passwordPlain (ask the user to change it at first login).`n"
    }
}
#i would have liked to have the UserAssembleFunction here but because everything was out of scope and using objects didn't work i've given up on this idea...

#-------------------------------------------------------------------------------------------------------------------------------
#This is the start of the script! (excluding functions of course)
#Calls upon the PathInformationFunction
PathInformationFunction

#We are adding a small pop up that warns the user that by pressing enter they agree to the following users stated will be added to the viable adgroup.
Read-Host "`nIs this information correct? (Press 'ENTER' to continue) `nWARNING!!! Pressing Enter will begin the Process of adding every user to the '$adGroup'"

#This Foreach will one by one go through every user in the CSV file. Create a username, Fullname, And a password.
foreach ($row in $USER_CSV_COMPLETION) {
    $UserID = $row.USERID
    $FirstName = $row.FIRSTNAME
    $MiddleName = $row.MIDDLENAME
    $LastName = $row.LASTNAME

    # Generate the username (e.g., FirstName.LastName)
    #Takes your first name and lastname and makes it all lowercase with a dot to sepperate the two :)
    $username = "$firstName.$lastName".ToLower()

    # Assemble the FullName Variable! (and if your name doesn't have to contain a middlename we have accounted for that! :o )
    if ($middleName) {
        $FullName = "$FirstName $MiddleName $LastName"
    } else {
        $FullName = "$FirstName $LastName" 
    }

    # Generate the default password (e.g., FirstNameLastInitial@2025)
    # we have decided to do the password, Name(first initial of your last name)@Currentyear(this being 2025 in this case)
    $currentYear = (Get-Date).Year
    $passwordPlain = "$firstName$($lastName.Substring(0,1))@$currentYear"
    $password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

    #Calls upon the UserCreationFunction
    UserCreationFunction ($FullName, $Username, $PasswordPlain, $Password)
}

#-------------------------------------------------------------------------------------------------------------------------------