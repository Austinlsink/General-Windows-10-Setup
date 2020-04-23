################################################################################
## Program Information
## --------------------
## Program Name: Non-client Specific Setup
## Program Num.: 1
## Author:       Austin Sink
## Version:      2.0
## Last Updated: 12_10_2019
################################################################################
################################################################################
## Documentation
## --------------------
## Before running this script, copy "Non-Client-Specific" folder onto the
## desktop.
################################################################################

## Global variables
$publicWin10Desktop = "C:\Users\Public\Public Desktop"
$startMenuShortcuts = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"

## Change directory
Set-Location "~\Desktop\Non-Client-Specific"

## Import functions from the Function-Write-Log folder.
Import-Module .\Function-Write-Log
## Import functions from the Function-Choco-Packages folder.
Import-Module .\Function-Choco-Packages

## Write the the header to the log file.
WriteHeader -company "Non-client" -scriptVer 2.0 -scriptNum 1

## Terminates the script if the computer is not on 1903 or higher.
if ([System.Environment]::OSVersion.Version.Build -gt 17134) 
{
	AppendLogFile -msg "Windows build check has passed." -type "normal"
}
else 
{
	AppendLogFile -msg "Please upgrade to 1903 or higher before continuing." -type "error" -errorDesc "$_"
	Get-Content C:\log.txt | clip.exe
	Start-Process -Path "https://stackedit.io/app#"
	exit
}

################################################################################
## Enable system restore and create a restore point.
################################################################################
Enable-ComputerRestore "C:\"
Checkpoint-Computer "Before the setup script."

################################################################################
## Prompt the user for a computer name.
################################################################################
$response = Read-Host -Prompt "Is the computer already renamed? (y/n)"
if ($response -eq "n") {
	try {
		$input = Read-Host Type what you want to name this computer
		Rename-Computer -newname $input
		AppendLogFile -msg "Computer rename will to '$input' after reboot." -type "normal"
	}
	catch {
		AppendLogFile -msg "Rename computer has failed." -type "error" -errorDesc "$_"
	}
}

################################################################################
## Change the power settings.
################################################################################
try {
	# Set to never go to sleep on ac.
	powercfg /change standby-timeout-ac 0
	# Set to never turn off hard disk on ac.  
	powercfg /change disk-timeout-ac 0     
	# Set to never hibernate on ac. 
	powercfg /change hibernate-timeout-ac 0
	# Set USB selective suspend to disabled when plugged in.
	powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
	# Set closing the lid on ac to do nothing.
	powercfg -setacvalueindex 381b4222-f694-41f0-9685-ff5bb260df2e 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
	# Set fast startup to 'off'.
	REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /V HiberbootEnabled /T REG_dWORD /D 0 /F
	AppendLogFile -msg "The power settings have been set." -type "normal"
}
catch {
	AppendLogFile -msg "Setting the power settings have failed." -type "error" -errorDesc "$_"
}

################################################################################
## Change the power settings for the network adapters.
################################################################################
try {
	# Set network adapter power settings.
	$adapter = Get-NetAdapter -Physical | Get-NetAdapterPowerManagement
	$adapter.AllowComputerToTurnOffDevice = 'Disabled'
	$adapter | Set-NetAdapterPowerManagement
	AppendLogFile -msg "The power settings on the network adapters have been set." -type "normal"
}
catch {
	AppendLogFile -msg "The power settings on the network adapters have not been set." -type "error" -errorDesc "$_"
}

################################################################################
## Add computer, network and recycle bin icons to desktop.
################################################################################

################################################################################
## Enable RDP connections.
################################################################################
try {
	Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
	Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
	Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
	AppendLogFile -msg "The RDP connection is on." -type "normal"
}
catch {
	AppendLogFile -msg "The RDP connection failed to turn on." -type "error" -errorDesc "$_"
}

################################################################################
## Disable the firewall on private and domain networks.
################################################################################
# Firewall settings are client specific. Reference the client's setup sheet for details.
try {
	Set-NetFirewallProfile -Profile Domain,Private -Enabled False
	AppendLogFile -msg "The private and domain firewall is off." -type "normal"
}
catch {
	AppendLogFile -msg "The private and domain firewall failed to turn off." -type "error" -errorDesc "$_"
}

################################################################################
## Install chocolately package manager to manage programs.
################################################################################
try {
	InstallChoco   # Pulls from Function-Choco-Packages folder.
    AppendLogFile -msg "Chocolately package manager has now been installed." -type "normal"
}
catch {
    AppendLogFile -msg "Chocolately package manager install has failed." -type "error" -errorDesc "$_"
}

################################################################################
## Configure chocolately package manager to manage programs.
################################################################################
try {
	ConfigureChoco # Pulls from Function-Choco-Packages folder.
	AppendLogFile -msg "Chocolately package manager has now been configured." -type "normal"
}
catch {
	AppendLogFile -msg "Chocolately package manager failed to configure." -type "error" -errorDesc "$_"
}


################################################################################
## Ask if the user needs Dell Command Update.
################################################################################
try {
    $response = Read-Host -Prompt "Will the user need Dell Command Update? (y/n)"
    if ($response -eq "y") {
        choco install dellcommandupdate-uwp -y
        AppendLogFile -msg "Installed Dell Command Update." -type "normal"
    }
}
catch {
    AppendLogFile -msg "Dell Command Update has failed to install." -type "error" -errorDesc "$_"
}

################################################################################
## Install Adobe Reader.
################################################################################
try {
    choco install adobereader -y
    AppendLogFile -msg "Adobe Reader has now been installed." -type "normal"
}
catch {
    AppendLogFile -msg "Adobe Reader has failed to install." -type "error" -errorDesc "$_"
}

################################################################################
## Install Chrome.
################################################################################
try {
    choco install googlechrome -y
    AppendLogFile -msg "Chrome has now been installed." -type "normal"
}
catch {
	AppendLogFile -msg "Chrome has failed to install." -type "error" -errorDesc "$_"
}

################################################################################
## Set Chrome as default browser.
################################################################################
try {
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\{0}\UserChoice\ftp" -name ProgId ChromeHTML
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\{0}\UserChoice\http"  -name ProgId ChromeHTML
	Set-ItemProperty "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\{0}\UserChoice\https" -name ProgId ChromeHTML
	AppendLogFile -msg "Successfully set Chrome as default browser." -type "normal"
}
catch {
	AppendLogFile -msg "Failed to set Chrome as default browser." -type "error" -errorDesc "$_"
}

################################################################################
## Install Java.
################################################################################
try {
    choco install jre8 -y
    AppendLogFile -msg "Java has now been installed." -type "normal"
}
catch {
    AppendLogFile -msg "Java has failed to install." -type "error" -errorDesc "$_"
}

################################################################################
## Copy shortcuts to the public desktop.
################################################################################
try {
    Copy-Item "$startMenuShortcuts\Acrobat Reader DC.lnk" -Destination $publicWin10Desktop
    AppendLogFile -msg "Shortcuts copied to public desktop." -type "normal"
}
catch {
    AppendLogFile -msg "Shortcuts failed to copy to the public desktop." -type "error" -errorDesc "$_"
}

################################################################################
## Install PSWindowsUpdate.
################################################################################
try {
	Install-Module PSWindowsUpdate
	AppendLogFile -msg "PSWindowsUpdate is now install." -type "normal"
}
catch {
	AppendLogFile -msg "PSWindowsUpdate has failed to install." -type "error" -errorDesc "$_"
}

################################################################################
## Get Windows updates.
################################################################################
try {
	get-WindowsUpdate
	AppendLogFile -msg "PSWindowsUpdate successfully checked for updates." -type "normal"
}
catch {
	AppendLogFile -msg "PSWindowsUpdate has failed to check for updates." -type "error" -errorDesc "$_"
}

################################################################################
## Download and install Windows updates.
################################################################################
try {
	install-windowsupdate
	AppendLogFile -msg "PSWindowsUpdate successfully downloaded and installed updates." -type "normal"
}
catch {
	AppendLogFile -msg "PSWindowsUpdate has failed to download and install updates." -type "error" -errorDesc "$_"
}

################################################################################
## Remove unnecessary Windows 10 apps.
################################################################################
#try {
#	.\decrapifier.ps1 -onedrive -appsonly
#	AppendLogFile -msg "The computer has been decrapped." -type "normal"
#}
#catch {
#	AppendLogFile -msg "The computer failed to run decrapifier." -type "error" -errorDesc "$_"
#}

################################################################################
## Ask the user if they want to restart now or later.
################################################################################
$restart = Read-Host -Prompt "Do you want to restart 'now' or 'later'?"
if ($restart -eq "now") {
    AppendLogFile -msg "The computer has rebooted." -type "normal"
    restart-computer -force
}
else {
    AppendLogFile -msg "The computer still needs to reboot." -type "error" -errorDesc "Please reboot the computer."
	Get-Content C:\log.txt | clip.exe
	Start-Process "https://stackedit.io/app#"
}