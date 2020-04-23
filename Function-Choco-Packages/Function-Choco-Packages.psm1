## Import functions from the Function-Write-Log folder.
Import-Module .\Function-Write-Log

################################################################################
## Install chocolately package manager to manage programs.
################################################################################
function InstallChoco() {
    try {
        Function-Choco-Packages\ChocolateyInstall.ps1
        #Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        AppendLogFile -msg "Chocolately package manager has now been installed." -type "normal"
    }
    catch {
        AppendLogFile -msg "Chocolately package manager install has failed." -type "error" -errorDesc "$_"
    }
}

################################################################################
## Set chocolately package manager source and disable public repo.
################################################################################
function ConfigureChoco() {
    try {
        choco source add -n=infinite -s="http://10.11.12.110:8081/repository/nuget-group/"
        choco.exe source disable -n=chocolatey
        AppendLogFile -msg "Chocolately package manager has successfully configured." -type "normal"
    }
    catch {
        AppendLogFile -msg "Chocolately package manager configuration has failed." -type "error" -errorDesc "$_"
    }
}

