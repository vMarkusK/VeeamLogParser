function Invoke-VeeamLogParser {
<#
    .DESCRIPTION
       VeeamLogParser

    .NOTES
        File Name  : Invoke-VeeamLogParser.psm1
        Author     : Markus Kraus
        Version    : 1.0
        State      : Ready

    .LINK
        https://mycloudrevolution.com/

    .EXAMPLE
        Invoke-VeeamLogParser

    .PARAMETER VeeamBasePath
        Base Path of the Veeam Log Files

    #>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Base Path of the Veeam Log Files")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamBasePath = "C:\ProgramData\Veeam\",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="My Parameter")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamWarningPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sWarning",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="My Parameter")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamErrorPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sError",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Show messages in Context")]
    [ValidateNotNullorEmpty()]
        [Switch]$Context,
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Show messages limited number of messages")]
    [ValidateNotNullorEmpty()]
        [Int]$Limit,
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="Log Type")]
    [ValidateNotNullorEmpty()]
    [ValidateSet("All","Endpoint","Mount","Backup","EnterpriseServer","Broker","Catalog","RestAPI","BackupManager",
    "CatalogReplication","DatabaseMaintenance")]
        [String]$LogType
)

Begin {
    function LogParser {
        param (
            [Parameter(Mandatory=$True)]
            [ValidateNotNullorEmpty()]
                [String]$Folder,
            [Parameter(Mandatory=$True)]
            [ValidateNotNullorEmpty()]
                [String]$File
        )

        Write-Host "`nParsing Log Files(s): $($VeeamBasePath + $Folder + "\" + $File) `n" -ForegroundColor Gray
        if (Test-Path $($VeeamBasePath + $Folder)) {
            if (Test-Path $($VeeamBasePath + $Folder + "\" + $File)   ) {
                try {
                    $Content = Get-Content $($VeeamBasePath + $Folder + "\" + $File)
                }
                catch {
                    Write-Warning "Failed to get Content from File: '$($VeeamBasePath + $Folder + "\" + $File)'"
                }
            }
            else {
                Write-Warning "File $($VeeamBasePath + $Folder + "\" + $File) not found!"
            }
            if ($Context) {
                Write-Host "`nParsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamWarningPattern -AllMatches -Context 2, 2
                if ($Select.Count -gt 0 ) {
                    if ($Limit) {
                        $Select | Select-Object -Last $Limit
                    }
                    else {
                        $Select
                    }
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
                Write-Host "`nParsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamErrorPattern -AllMatches -Context 2, 2
                if ($Select.Count -gt 0 ) {
                    if ($Limit) {
                        $Select | Select-Object -Last $Limit
                    }
                    else {
                        $Select
                    }
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "`nParsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamWarningPattern -AllMatches
                if ($Select.Count -gt 0 ) {
                    if ($Limit) {
                        $Select | Select-Object -Last $Limit
                    }
                    else {
                        $Select
                    }
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
                Write-Host "`nParsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamErrorPattern -AllMatches
                if ($Select.Count -gt 0 ) {
                    if ($Limit) {
                        $Select | Select-Object -Last $Limit
                    }
                    else {
                        $Select
                    }
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
            }
        }
        else {
            Write-Warning "Folder '$($VeeamBasePath + $Folder)' not Found!"
        }
    }
}

Process {

    if ($LogType -eq "All") {
        LogParser -Folder "Endpoint" -File "Svc.VeeamEndpointBackup.log"
        LogParser -Folder "Backup" -File "Svc.VeeamMount.log"
        LogParser -Folder "Backup" -File "Svc.VeeamBackup.log"
        LogParser -Folder "Backup" -File "Svc.VeeamBES.log"
        LogParser -Folder "Backup" -File "Svc.VeeamBroker.log"
        LogParser -Folder "Backup" -File "Svc.VeeamCatalog.log"
        LogParser -Folder "Backup" -File "Svc.VeeamRestAPI.log"
        LogParser -Folder "Backup" -File "VeeamBackupManager.log"
        LogParser -Folder "Backup" -File "CatalogReplicationJob.log"
        LogParser -Folder "Backup" -File "Job.DatabaseMaintenance.log"
    }
    elseif ($LogType -eq "Endpoint") {
        LogParser -Folder "Endpoint" -File "Svc.VeeamEndpointBackup.log"
    }
    elseif ($LogType -eq "Mount") {
        LogParser -Folder "Backup" -File "Svc.VeeamMount.log"
    }
    elseif ($LogType -eq "Backup") {
        LogParser -Folder "Backup" -File "Svc.VeeamBackup.log"
    }
    elseif ($LogType -eq "EnterpriseServer") {
        LogParser -Folder "Backup" -File "Svc.VeeamBES.log"
    }
    elseif ($LogType -eq "Broker") {
        LogParser -Folder "Backup" -File "Svc.VeeamBroker.log"
    }
    elseif ($LogType -eq "Catalog") {
        LogParser -Folder "Backup" -File "Svc.VeeamCatalog.log"
    }
    elseif ($LogType -eq "RestAPI") {
        LogParser -Folder "Backup" -File "Svc.VeeamRestAPI.log"
    }
    elseif ($LogType -eq "BackupManager") {
        LogParser -Folder "Backup" -File "VeeamBackupManager.log"
    }
    elseif ($LogType -eq "CatalogReplication") {
        LogParser -Folder "Backup" -File "CatalogReplicationJob.log"
    }
    elseif ($LogType -eq "DatabaseMaintenance") {
        LogParser -Folder "Backup" -File "Job.DatabaseMaintenance.log"
    }
}
}
