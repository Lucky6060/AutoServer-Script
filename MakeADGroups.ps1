function CreateADGroup {
    # Group details
    $GroupName = Read-Host "Enter the name of the group"
    $Description = Read-Host "Enter the description for the group (optional)"
    $GroupScope = Read-Host "Enter the group scope (Global, Universal, or DomainLocal)"
    $GroupCategory = Read-Host "Enter the group type (Security or Distribution)"
    $OU = Read-Host "Enter the Organizational Unit (OU) path (e.g., OU=Groups,DC=zbc,DC=dk)"
    
    # Validate inputs
    if (-not $GroupName -or -not $GroupScope -or -not $GroupCategory -or -not $OU) {
        Write-Host "All inputs are required to create the group except the description. Please try again." -ForegroundColor Red
        return
    }

    if ($GroupScope -notin @("Global", "Universal", "DomainLocal")) {
        Write-Host "Invalid group scope. Please enter one of the following: Global, Universal, or DomainLocal." -ForegroundColor Red
        return
    }

    if ($GroupCategory -notin @("Security", "Distribution")) {
        Write-Host "Invalid group type. Please enter 'Security' or 'Distribution'." -ForegroundColor Red
        return
    }

    try {
        # Create the group
        New-ADGroup -Name $GroupName `
                    -Description $Description `
                    -GroupScope $GroupScope `
                    -GroupCategory $GroupCategory `
                    -Path $OU

        Write-Host "Group '$GroupName' created successfully!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to create group '$GroupName'. Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Run the function to create the group
do {
    CreateADGroup
    $Continue = Read-Host "Do you want to create another group? (yes/no)"
} while ($Continue -match '^(yes|y)$')




