#-------------------------------------------------------------------------------------------------------------------------------

#Visual studio Powershell Code for automation of AD user add

#Variable List:
 # The AD Group the script the users will be added to!
 # In our case we have a group called MonkeyMembers & our Domain is @Monkey.local
 $adGroup = "MonkeyMembers"
 $DomainPrefix = "@Monkey.local"

#Checking if the $adGroup exsists.
#if not we would like for it to be created! on $DomainPrefix
write-host "Checking for '$adGroup' in '$DomainPrefix'"
#This command tests the DC if DGroup is equal to adGroup.
$DGroup = Get-ADGroup - Filter { Name -eq $adGroup } -server $DomainPrefix
if ($DGroup) {
    #if it's true that means the group already exists. and we wont need to add it.
    write-host "The ADGroup'$adGroup' exists on the domain controller. `nLet's continue to the user creation process.`n"
} else {
    #else we will make the user press 'Enter' and we will commit the changes :)
    Read-Host-host "The ADGroup'$adGroup' does not exist on the Domain Controller! `nCreating ADgroup [PRESS ENTER]"
    New-ADGroup -Name $adGroup -GroupScope Global -GroupCategory Security -SamAccountName $adGroup -Server $DomainPrefix
} else {
    Write-Host "Code is broken... Help"
}

# Ask the script-runner about user details (First name)
$firstName = Read-Host "Enter the user's first name"
# Ask the script-runner about user details (Middle name)
$middleName = Read-Host "Enter the user's middle name (optional)"
# Ask the script-runner about user details (Last name)
$lastName = Read-Host "Enter the user's last name"

# Assemble the FullName Variable! (and if your name doesn't have to contain a middlename we have accounted for that! :o )
if ($middleName) {
    $fullName = "$firstName $middleName $lastName"
} else {
    $fullName = "$firstName $lastName"
}

# Generate the username (e.g., FirstName.LastName)
#Takes your first name and lastname and makes it all lowercase with a dot to sepperate the two :)
$username = "$firstName.$lastName".ToLower()

# Generate the default password (e.g., FirstNameLastInitial@2025)
# we have decided to do the password, Name(first initial of your last name)@Currentyear(this being 2025 in this case)
$currentYear = (Get-Date).Year
$passwordPlain = "$firstName$($lastName.Substring(0,1))@$currentYear"
$password = ConvertTo-SecureString $passwordPlain -AsPlainText -Force

# Confirm the full name/username/temporaryPass (we ask the Script-Runner to confirm since if there's a typo it's not easy to correct ESPECIALLY WHEN WORKING WITH AZURE!)
# Also i'm in love with confirmation pages... and reading out what info i've inputted along the way.
Write-Host "Full Name: $fullName"
Write-Host "Username: $username"
Write-Host "Default Password: $passwordPlain"
$confirmation = Read-Host "Is this information correct? Password is Temporary and will be changed upon logon! (yes/no)"

# If yes the script will try and add the user to the AD Group (in our case MonkeyMembers) No/Nothing/Typo we have an else statement that calls you stupid XD
if ($confirmation -eq "yes") {
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
    }
} else {
    Write-Host "Script Failed! mayday mayday. Are you stupid? why didn't you type Yes >:C"
}

#-------------------------------------------------------------------------------------------------------------------------------