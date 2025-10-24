# Requires -RunAsAdministrator

# --- Execution Policy Setup ---
$Execution = Get-ExecutionPolicy
if ($Execution -eq 'Restricted') {
Write-Host "Warning: Execution Policy is Restricted. Setting to Unrestricted..." -ForegroundColor Yellow
Set-ExecutionPolicy Unrestricted -Force
}

# --- Setup Continued ---
$LogPath = "$env:USERPROFILE\Desktop\ScriptLogs"
New-Item -ItemType Directory -Path $LogPath -Force

# Stop any previous transcript and start a new one
Stop-Transcript | Out-Null
Start-Transcript -Path "$LogPath\Logs.txt" -Append

# --- Users ---
Write-Host "Current User: $(whoami)"
Get-LocalUser
Get-LocalUser | ConvertTo-Html -Title "Local Users" -Body "Local Users as of $(Get-Date)" | Out-File "$LogPath\userList.html"
Disable-LocalUser -Name Guest -ErrorAction SilentlyContinue
Write-Host "Disabled Guest User" -ForegroundColor Green
Net User

# --- Add/Delete Users ---
do {
$Delete = Read-host -Prompt "Should a user be deleted? Y/N"
if ($Delete -eq "Y") {
$DelUser = Read-host -Prompt "What user?"
Remove-LocalUser -Name $DelUser -ErrorAction SilentlyContinue | Out-Null
Write-Host "Attempted to delete user $DelUser" -ForegroundColor Green
}
} while ($Delete -eq "Y")

do {
$Add = Read-host -Prompt "Should a user be added? Y/N"
if ($Add -eq "Y") {
$AddUser = Read-host -Prompt "Username?"
New-LocalUser -Name $AddUser -Description "New user account" | Out-Null
Write-Host "Attempted to add user $AddUser" -ForegroundColor Green
}
} while ($Add -eq "Y")
Net User

# --- Windows Defender ---
Write-Host "Checking Windows Defender status..."
Get-MpComputerStatus
Set-MpPreference -DisableRealtimeMonitoring $false
Update-MpSignature
Write-Host "Windows Defender updated and realtime monitoring is enabled." -ForegroundColor Green

# --- Firewall ---
Write-Host "Enabling firewall profiles..."
Get-NetFirewallProfile
Set-NetFirewallProfile -Enabled True -Profile Domain, Private, Public

# --- Block TCP Ports ---
Write-Host "Blocking inbound TCP ports..."
New-NetFirewallRule -DisplayName "TCP | Block FTP" -Direction Inbound -Protocol TCP -LocalPort 21 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block Telnet" -Direction Inbound -Protocol TCP -LocalPort 23 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SMTP" -Direction Inbound -Protocol TCP -LocalPort 25 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block RDP" -Direction Inbound -Protocol TCP -LocalPort 3389 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block SNMP" -Direction Inbound -Protocol TCP -LocalPort 161, 162 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block HTTP" -Direction Inbound -Protocol TCP -LocalPort 80, 8080, 8088, 8888 -Action Block
New-NetFirewallRule -DisplayName "TCP | Block WebLogic" -Direction Inbound -Protocol TCP -LocalPort 4444 -Action Block

Read-Host -Prompt "Blocked TCP Ports 21, 22, 23, 25, 80, 161, 162, 3389, 4444, 8080, 8088, 8888. Press enter to continue."

# --- Block UDP Ports ---
Write-Host "Blocking inbound UDP ports..."
New-NetFirewallRule -DisplayName "UDP | Block SNMP" -Direction Inbound -Protocol UDP -LocalPort 161, 162 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block LDAP" -Direction Inbound -Protocol UDP -LocalPort 389, 636 -Action Block
New-NetFirewallRule -DisplayName "UDP | Block RDP" -Direction Inbound -Protocol UDP -LocalPort 3389 -Action Block

Read-Host -Prompt "Blocked UDP Ports 161, 162, 389, 636, 3389. Press enter to continue."

# --- Services ---
Write-Host "Stopping and disabling services..." -ForegroundColor Cyan
$ServicesToDisable = @(
"TermService", "RemoteRegistry", "RpcLocator", "SessionEnv", "SharedAccess",
"SSDPSRV", "XblAuthManager", "upnphost", "DcpSvc", "DiagTrack",
"SensrSvc", "dmwappushservice", "lfsvc", "RemoteAccess", "TrkWks",
"WbioSrvc", "WMPNetworkSvc", "XblGameSave", "XboxNetApiSvc"
)

foreach ($service in $ServicesToDisable) {
try {
Stop-Service -Name $service -Force -ErrorAction Stop
Set-Service -Name $service -StartupType Disabled -Force -ErrorAction Stop
Write-Host "Service '$service' stopped and disabled." -ForegroundColor Green
}
catch {
Write-Host "Warning: Could not stop or disable service '$service'. Error: $_" -ForegroundColor Yellow
}
}
Read-Host -Prompt "Services Finished! Press enter to continue." -ForegroundColor Green

# --- Local Security Policy ---
Write-Host "Configuring local security policy..."
net accounts /maxpwage:31
net accounts /minpwage:21
net accounts /minpwlen:12
net accounts /lockoutduration:30
net accounts /lockoutthreshold:5
net accounts /complexity:ON
net accounts

# --- SMB Protocol ---
Write-Host "Disabling SMBv1 Protocol..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# --- Quick Virus Scan ---
Write-Host "Starting a full system virus scan. This may take a while..." -ForegroundColor Yellow
Start-MpScan -ScanType Fullscan
Write-Host "Scan Completed."
Start-Sleep -Seconds 10

# --- Computer Search ---
Write-Host "Searching for suspect files..."
Get-ChildItem -Path C:\ -Include *.jpg, *.png, *.jpeg, *.avi, *.mp4, *.mp3, *.wav -File -Recurse -ErrorAction SilentlyContinue | `
ConvertTo-HTML -Title "Suspect Files" -Body "Suspect Files as of $(Get-Date)" | `
Out-File "$LogPath\SuspectFiles.html"

Read-Host -Prompt "HTML file created in ScriptLogs Folder. Press enter to continue"

# --- Application Updates ---
Write-Host "Starting Google Chrome update..."
$ChromeUpdaterPath = "$LogPath\chrome_installer.exe"
try {
Invoke-WebRequest "http://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $ChromeUpdaterPath -ErrorAction Stop
Start-Process -FilePath $ChromeUpdaterPath -Args "/silent /install" -Wait -ErrorAction Stop
Remove-Item -Path $ChromeUpdaterPath -Force
Write-Host "Google Chrome updated successfully." -ForegroundColor Green
}
catch {
Write-Host "Error updating Google Chrome: $_" -ForegroundColor Red
}

# --- Microsoft Updates ---
Write-Host "Starting Windows Updates. Please proceed with updates manually in the next window." -ForegroundColor Yellow
control /name Microsoft.WindowsUpdate
Read-Host -Prompt "Press enter to continue." -ForegroundColor Yellow

Stop-Transcript
