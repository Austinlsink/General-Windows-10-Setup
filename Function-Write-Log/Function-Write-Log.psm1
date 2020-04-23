################################################################################
## Global Varables
################################################################################
$logPath = "C:\log.txt"
################################################################################
## Writes the header to the log file.
################################################################################
function WriteHeader ($company, $scriptVer, $scriptNum, $overWrite)
{
    # Setting the overWrite var to 1 will clear the log.
    if ($overWrite -eq 1)
    {
        Clear-Content $logPath
    }
    $ErrorActionPreference = "Stop"               # Forces non-terminating error to go into the log
    $dateRun   = Get-Date                         # Current date and time
    $winVer    = [environment]::OSVersion.Version # Current Windows version
    # Write the header of the log
    "# $company - Part $scriptNum Script Results`n" +
    "> Date run:        $dateRun`n"               +
    "> Windows version: $winVer`n"                +
    "> Script Version:  $scriptVer`n"             +
    "> Script Number:   $scriptNum`n"             +
    "- - -`n" +
    "*The steps that are ==highlighted== failed. Please check those steps manually.*`n" +
    "- - -" | Add-Content $logPath
}
################################################################################
## Appends events to the log file.
################################################################################
function AppendLogFile ($msg, $type, $errorDesc) 
{
    switch ($type) {
        "normal"     {$msg + "`n- - -`n" | Add-Content -Path $logPath; break}
        "header1"    {"# "   + $msg      | Add-Content -Path $logPath; break}
        "header2"    {"## "  + $msg      | Add-Content -Path $logPath; break}
        "header3"    {"### " + $msg      | Add-Content -Path $logPath; break}
        "emphasize"  {  break}
        "successful" {  break}
        "error"      {"==$msg==`n" +
                      "**Error Description:**`n" +
                      "$errorDesc`n" +
                      "- - -" | Add-Content -Path $logPath; break}
        Default { Write-Output "Failed to write '$msg' to the log."}
    }
    Write-Output "`n`n* $msg`n`n"
}