function CreateADGroup {
    # Group details
    $GroupName = Read-Host "Enter the name of the group"
    $Description = Read-Host "Enter the description for the group (optional)"
    $GroupScope = Read-Host "Enter the group scope (Global, Universal, or DomainLocal)"
    $GroupCategory = Read-Host "Enter the group type (Security or Distribution)"
    $OU = Read-Host "Enter the Organizational Unit (OU) path (e.g., OU=Groups,DC=zbc,DC=dk)"
    
    if ( -not $GroupName -or -not $GroupScope -or -not $GroupCategory -or -not $OU ) {
        Write-Host "All inputs are need to create the group except the description. Please try again." -ForegroundColor Red
        return
    }

    try{
        # Create the group
        New-ADGroup -Name $GroupName `
                    -Description $Description`
                    -GroupScope $GroupName
                    -GroupCategory $GroupCategory
                    -Path $OU
        

        Write-Host Write-Host "Group '$GroupName' created successfully!" -ForegroundColor Green   
    }catch{
        Write-Host "Failed to create group '$GroupName'. Error: $_" -ForegroundColor Red
    }
}

# Run the function to create the group
do {
    CreateADGroup
    $Continue = Read-Host "Do you want to create another group? (yes/no)"
} while ($Continue -match '^(yes|y)$')





