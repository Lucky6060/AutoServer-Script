# Variables
$NewComputerName = Read-Host "Enter the desired server name"                        # New computer name
$StaticIP = Read-Host "Enter the desired IP Address (or type 'DHCP' for DHCP)"      # Static IP address or DHCP
$DomainName = Read-Host "Enter the desired Domain Name, like yourdomain.com"        # Desired domain name
$NetBIOSName = Read-Host "Enter the desired NetBIOS name, like yourdomain"          # NetBIOS name
$SafeModePassword = Read-Host "Enter the desired SafeModePassword"                  # Secure password for DSRM
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}                     # Get the active network interface

# Convert Safe Mode password to a secure string
$SecureSafeModePassword = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force

# Enables Remoting for the use of invoke command
Enable-PSRemoting -Force


# Set IP as DHCP
if ($StaticIP -notin @("DHCP", "dhcp")) {
    $SubnetMask = Read-Host "Enter Subnet Mask as number fx. 24 and not 255.255..." # Subnet mask
    $DefaultGateway = Read-Host "Enter the desired Default Gateway"                 # Default gateway
    $DNSServer = Read-Host "Enter the desired DNS Server"                           # Primary DNS server
} else {
    $SubnetMask = $null
    $DefaultGateway = $null
    $DNSServer = $null
}


# Set Static IP Address
if  ($StaticIP.ToUpper() -eq "DHCP") {
    Write-Host "Configuring IP address as DHCP..." -ForegroundColor Yellow
    if ($Interface) {
        try {
            Set-NetIPInterface -InterfaceIndex $Interface.InterfaceIndex -Dhcp Enabled
            Write-Host "DHCP has been enabled for the interface: $($Interface.Name)" -ForegroundColor Green
        } catch{
            Write-Host "Failed to enable DHCP. Error: $_" -ForegroundColor Red
        }
    }
} 
elseif ($Interface) { 
    Write-Host "Configuring static IP address..." -ForegroundColor Yellow
    try{
        New-NetIPAddress -InterfaceIndex $Interface.InterfaceIndex `
            -IPAddress $StaticIP `
            -PrefixLength $SubnetMask `
            -DefaultGateway $DefaultGateway
        Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $DNSServer
        Write-Host "Static IP address configured: $StaticIP" -ForegroundColor Green
    } catch{
        Write-Host "Failed to configure static IP. Error: $_" -ForegroundColor Red
    }
 } else {
     Write-Host "No active network interface found!" -ForegroundColor Red
    exit
}


# Install DNS, ADDS, and WIM
Install-WindowsFeature -Name AD-Domain-Services, DNS, Windows-Internal-Database -IncludeManagementTools

# Promote the Server to a Domain Controller
Import-Module ADDSDeployment

Install-ADDSForest -DomainName $DomainName `
    -DomainNetBIOSName $NetBIOSName `
    -SafeModeAdministratorPassword $SecureSafeModePassword `
    -Force

# Rename the Computer
Rename-Computer -NewName $NewComputerName -Force

# Post-installation reboot
Write-Host "Installation complete. Reboot the server with Restart-Computer" -ForegroundColor Green