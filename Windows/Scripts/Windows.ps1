# Setup
@echo off
#Requires -RunAsAdministrator

# Execution Poilcy Setup
Get-ExecutionPolicy
$Execution = Get-ExecutionPolicy
if (Restricted -eq $Execution)
{
    Write-Host "Warning: " -ForegroundColor Yellow -noNewLine
    Write-Host "Execution Policy is Restricted." -ForegroundColor Red
    Set-ExecutionPolicy Unrestricted -Force
}

# Setup Continued
$CurrentUser = Whoami
New-Item -ItemType Directory -Path "C:\Users\$CurrentUser\Desktop\ScriptLogs"
Start-Transcript Out-File "C:\Users\$CurrentUser\Desktop\ScriptLogs\Logs.txt"

# Users
Whoami
Get-LocalUser
Get-LocalUser | ConvertTo-Html -Title "Local Users" -body (Get-Date) | Out-File C:\Users\$CurrentUser\Desktop\ScriptLogs\userList.html
Get-LocalUser Guest | Disable-LocalUser
Write-Host "Disabled Guest User" -ForegroundColor Green
Net User

do {
$Delete = Read-host -Prompt "Should a user be deleted? Y/N"
    if ($Delete -eq "Y") {
        $DelUser = Read-host -Prompt "What user?"
            net user $DelUser /DELETE | out-null }
    else {break}
    net user
    } while ($Delete -eq "Y")

do {
$Add = Read-host -Prompt "Should a user be added? Y/N"
    if ($Add -eq "Y") {
        $AddUser = Read-host -Prompt "Username?"
            net user $AddUser /Add | out-null }
    else {break}
    net user
    } while ($Add -eq "Y")

# wp status
Get-MpComputerStatus
Set-MpPreference -DisableRealtimeMonitoring $false
Update-MpSignature

# Firewall
Get-NetFirewallProfile
Set-NetFirewallProfile -Enabled True -Profile Domain, Private, Public 

# TCP Ports Block
New-NetFirewallRule -DisplayName "TCP | Block FTP" -Direction Inbound -Protocol TCP  -LocalPort 21 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SSH" -Direction Inbound -Protocol TCP  -LocalPort 22 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block Telnet" -Direction Inbound -Protocol TCP  -LocalPort 23 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SMTP" -Direction Inbound -Protocol TCP  -LocalPort 25 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block HTTP" -Direction Inbound -Protocol TCP  -LocalPort 80 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SNMP1" -Direction Inbound -Protocol TCP  -LocalPort 161 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SNMP2" -Direction Inbound -Protocol TCP  -LocalPort 162 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block WebLogic" -Direction Inbound -Protocol TCP -LocalPort 4444 -Action Block
New-NetFirewallRule -Displayname "TCP | Block HTTP-ALT1" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Block
New-NetFirewallRule -Displayname "TCP | Block RANDAN-HTTP" -Direction Inbound -Protocol TCP -LocalPort 8088 -Action Block
New-NetFirewallRule -Displayname "TCP | Block HTTP-ALT2" -Direction Inbound -Protocol TCP -LocalPort 8888 -Action Block

Read-Host -Prompt "Blocked TCP Ports 21,22,23.25.80,161,162,3389,4444,8080,8088,8888. Press enter to continue."

# UDP Ports Block
New-NetFirewallRule -DisplayName "UDP | Block SNMP" -Direction Inbound -Protocol UDP -LocalPort 161 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block SNMP" -Direction Inbound -Protocol UDP -LocalPort 162 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block LDAP1" -Direction Inbound -Protocol UDP -LocalPort 389 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block LDAP2" -Direction Inbound -Protocol UDP -LocalPort 636 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block RDP" -Direction Inbound -Protocol UDP -LocalPort 3389 -Action Block

Read-Host -Prompt "Blocked UDP Ports 161, 162, 389, 636, 3389. Press enter to continue."

# Services
$Service0 = Get-Service -Name "TermService"
Stop-Service -InputObject $Service0 -Force
Set-Service TermService -StartupType Disabled -Force
Write-Host "Remote Desktop Services Stopped and Disabled"  

$Service1 = Get-Service -Name "RemoteRegistry"
Stop-Service -InputObject $Service1 -Force
Set-Service RemoteRegistry -StartupType Disabled -Force
Write-Host "Remote Registry Stopped and Disabled" -ForegroundColor Green

$Service2 = Get-Service -Name "RpcLocator"
Stop-Service -InputObject $Service2 -Force
Set-Service RpcLocator -StartupType Disabled -Force
Write-Host "Remote Procedure Call Locator Stopped and Disabled" -ForegroundColor Green

$Service3 = Get-Service -Name "SessionEnv"
Stop-Service -InputObject $Service3 -Force
Set-Service SessionEnv -StartupType Disabled -Force
Write-Host "Remote Desktop Configuration Stopped and Disabled" -ForegroundColor Green

$Service4 = Get-Service -Name "wuauserv"
start-Service -InputObject $Service4 -Force
Set-Service RpcLocator -StartupType Automatic -Force
Write-Host "Windows Update is Started and Set to Automatic start" -ForegroundColor Green

$Service5 = Get-Service -Name "SharedAccess"
Stop-Service -InputObject $Service5 -Force
Set-Service SharedAccess -StartupType Disabled -Force
Write-Host "Internet Connection Sharing (ICS) Stopped and Disabled" -ForegroundColor Green

$Service6 = Get-Service -Name "SSDPSRV"
Stop-Service -InputObject $Service6 -Force
Set-Service SSDPSRV -StartupType Disabled -Force
Write-Host "SSDP Discovery Stopped and Disabled" -ForegroundColor Green

$Service7 = Get-Service -Name "XblAuthManager"
Stop-Service -InputObject $Service7 -Force
Set-Service XblAuthManager -StartupType Disabled -Force
Write-Host "Xbox Live Auth Manager Stopped and Disabled" -ForegroundColor Green

$Service8 = Get-Service -Name "upnphost"
Stop-Service -InputObject $Service8 -Force
Set-Service upnphost -StartupType Disabled -Force
Write-Host "UPnP Device Host Stopped and Disabled" -ForegroundColor Green

$Service9 = Get-Service -Name "EventLog"
start-Service -InputObject $Service9 -Force
Set-Service EventLog -StartupType Automatic -Force
Write-Host "Windows EventLog is Started and Set to Automatic start" -ForegroundColor Green

$Service10 = Get-Service -Name "DcpSvc"
Stop-Service -InputObject $Service10 -Force
Set-Service DcpSvc -StartupType Disabled -Force
Write-Host "Data Collection and Publishing Service Stopped and Disabled" -ForegroundColor Green

$Service11 = Get-Service -Name "DiagTrack"
Stop-Service -InputObject $Service11 -Force
Set-Service DiagTrack -StartupType Disabled -Force
Write-Host "Diagnostics Tracking Service Stopped and Disabled" -ForegroundColor Green

$Service12 = Get-Service -Name "SensrSvc"
Stop-Service -InputObject $Service12 -Force
Set-Service SensrSvc -StartupType Disabled -Force
Write-Host "Monitors Various Sensors Stopped and Disabled" -ForegroundColor Green

$Service13 = Get-Service -Name "dmwappushservice"
Stop-Service -InputObject $Service13 -Force
Set-Service dmwappushservice -StartupType Disabled -Force
Write-Host "Push Message Routing Service Stopped and Disabled" -ForegroundColor Green

$Service14 = Get-Service -Name "lfsvc"
Stop-Service -InputObject $Service14 -Force
Set-Service lfsvc -StartupType Disabled -Force
Write-Host "Geolocation Service Stopped and Disabled" -ForegroundColor Green

$Service15 = Get-Service -Name "DcpSvc"
Stop-Service -InputObject $Service15 -Force
Set-Service DcpSvc -StartupType Disabled -Force
Write-Host "Data Collection and Publishing Service Stopped and Disabled" -ForegroundColor Green

$Service16 = Get-Service -Name "RemoteAccess"
Stop-Service -InputObject $Service16 -Force
Set-Service RemoteAccess -StartupType Disabled -Force
Write-Host "Routing and Remote Access Stopped and Disabled" -ForegroundColor Green

$Service17 = Get-Service -Name "TrkWks"
Stop-Service -InputObject $Service17 -Force
Set-Service TrkWks -StartupType Disabled -Force
Write-Host "Distributed Link Tracking Client Stopped and Disabled" -ForegroundColor Green

$Service18 = Get-Service -Name "WbioSrvc"
Stop-Service -InputObject $Service18 -Force
Set-Service WbioSrvc -StartupType Disabled -Force
Write-Host "Windows Biometric Service Stopped and Disabled" -ForegroundColor Green

$Service19 = Get-Service -Name "WMPNetworkSvc"
Stop-Service -InputObject $Service19 -Force
Set-Service WMPNetworkSvc -StartupType Disabled -Force
Write-Host "Windows Media Player Network Sharing Service Stopped and Disabled" -ForegroundColor Green

$Service20 = Get-Service -Name "XblGameSave"
Stop-Service -InputObject $Service20 -Force
Set-Service XblGameSave -StartupType Disabled -Force
Write-Host "Xbox Live Game Save Service Stopped and Disabled" -ForegroundColor Green

$Service21 = Get-Service -Name "XboxNetApiSvc"
Stop-Service -InputObject $Service21  -Force
Set-Service XboxNetApiSvc -StartupType Disabled -Force
Write-Host "Xbox Live Networking Service Stopped and Disabled" -ForegroundColor Green

Read-Host -Prompt "Services Finished! Press enter to continue." -ForegroundColor Green


# Local Security Policy
net accounts /maxpwage:31
net accounts /minpwage:21
net accounts /minpwlen:12
net accounts /lockoutduration:30
net accounts /lockoutthreshold:5
net accounts /complexity:ON
net accounts

# services
Set-SmbServerConfiguration -EnableSMB1Protocol $false

# quick virus scan
Start-MpScan -ScanType Fullscan
echo "Scan Completed."
Start-Sleep -Seconds 10

# Computer Search
Get-ChildItem -Path C:\ -Include *.jpg,*.png,*.jpeg,*.avi,*.mp4,*.mp3,*.wav -Exclude *.dll,*.doc,*.docx,  -File -Recurse -ErrorAction SilentlyContinue
Get-ChildItem | ConvertTo-HTML -Title "Suspect Files" -body (Get-Date) | Put-File C:\Users\$CurrentUser\Desktop\ScriptLogs\SuspectFiles.html

Read-Host -Prompt "HTML file created in ScriptLogs Folder. Press enter to continue"

# Application Updates
$Path = C:\Users\$CurrentUser\Downloads
$Updater = "chrome_installer.exe";
Invoke-WebRequest "http://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $Path\$Updater;
Start-Process -FilePath $Path\$Updater -Args "/silent /install" -Verb RunAs -Wait;
Remove-Item $Path\$Updater

# Microsoft Updates
Write-Host "Starting Updates."
control /name Microsoft.WindowsUpdate
Read-Host -Prompt "Press enter to continue." -ForegroundColor Yellow
