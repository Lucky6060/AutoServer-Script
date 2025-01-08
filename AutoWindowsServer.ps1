# Variables
$NewComputerName = Read-Host "Enter the desired server name"                        # New computer name
$StaticIP = Read-Host "Enter the desired IP Address"                                # Static IP address
$SubnetMask = Read-Host "Enter Subnet Mask as number fx. 24 and not 255.255..."     # Subnet mask
$DefaultGateway = Read-Host "Enter the desired Default Gateway,"                    # Default gateway
$DNSServer = Read-Host "Enter the desired DNS Server"                               # Primary DNS server
$DomainName = Read-Host "Enter the desired Domain Name, like yourdomain.com"        # Desired domain name
$NetBIOSName = Read-Host "Enter the desired NetBIOS name, like yourdomain"          # NetBIOS name
$SafeModePassword = Read-Host "Enter the desired SafeModePassword"                  # Secure password for DSRM
$Interface = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}                     # Get the active network interface


#Convert Safe Mode password to a secure string
$SecureSafeModePassword = ConvertTo-SecureString $SafeModePassword -AsPlainText -Force

#Installs chocolatey on to the server
Set-ExecutionPolicy Bypass -Scope Process -Force
C:\Users\Adminstrator\AutoServer-Script\ChocoInstaller\Install.ps1 -ChocolateyDownloadUrl C:\Users\Adminstrator\AutoServer-Script\ChocoInstaller\Chocolatey.nupkg


#installs python via chocolatey
choco install python -y




#Set Static IP Address
if  ($StaticIP -in @("DHCP", "dhcp")) {
    Write-Host "IP address is set to DHCP"
    if ($Interface) {
        Set-DhcpClient -InterfaceIndex $Interface.InterfaceIndex
        Write-Host "DHCP has been enabled for the interface: $($Interface.Name)" -ForegroundColor Green
    }
} elseif ($Interface) { 
    New-NetIPAddress -InterfaceIndex $Interface.InterfaceIndex `
        -IPAddress $StaticIP `
        -PrefixLength $SubnetMask `
        -DefaultGateway $DefaultGateway
        Set-DnsClientServerAddress -InterfaceIndex $Interface.InterfaceIndex -ServerAddresses $DNSServer
        Write-Host "Static IP address configured: $StaticIP" -ForegroundColor Green
    } else {
        Write-Host "No active network interface found!" -ForegroundColor Red
        exit
}

#Install DNS, ADDS, and WIM
Install-WindowsFeature -Name AD-Domain-Services, DNS, Windows-Internal-Database -IncludeManagementTools

#Promote the Server to a Domain Controller
Import-Module ADDSDeployment

Install-ADDSForest -DomainName $DomainName `
    -DomainNetBIOSName $NetBIOSName `
    -SafeModeAdministratorPassword $SecureSafeModePassword `
    -Force

#Rename the Computer
Rename-Computer -NewName $NewComputerName -Force

#Post-installation reboot
Write-Host "Installation complete. Reboot the server with Restart-Computer" -ForegroundColor Green