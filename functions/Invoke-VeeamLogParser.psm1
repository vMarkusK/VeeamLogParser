function Invoke-VeeamLogParser {
<#
    .DESCRIPTION
       The Veeam Log Parser Function extracts Error and Warning Messages from the Veeam File Logs of various products and services.

    .NOTES
        File Name  : Invoke-VeeamLogParser.psm1
        Author     : Markus Kraus
        Version    : 1.0
        State      : Ready

    .LINK
        https://mycloudrevolution.com/

    .EXAMPLE
        Invoke-VeeamLogParser -LogType Endpoint -Limit 2

    .PARAMETER VeeamBasePath
        The Base Path of the Veeam Log Files

        Default: "C:\ProgramData\Veeam\"

    .PARAMETER VeeamWarningPattern
        The RegEx Pattern of Warning Messages

        Default: "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sWarning"

    .PARAMETER VeeamErrorPattern
        The RegEx Pattern of Error Messages

        Default: "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sError"

    .PARAMETER Context
        Show messages in Context

    .PARAMETER Limit
        Show limited number of messages

    .PARAMETER LogType
        The products or services Log you want to show

        Valid Pattern:  "All","Endpoint","Mount","Backup","EnterpriseServer","Broker","Catalog","RestAPI","BackupManager",
                        "CatalogReplication","DatabaseMaintenance","WebApp","PowerShell"
    #>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="The Base Path of the Veeam Log Files")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamBasePath = "C:\ProgramData\Veeam\",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="The RegEx Pattern of Warning Messages")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamWarningPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sWarning",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="The RegEx Pattern of Error Messages")]
    [ValidateNotNullorEmpty()]
        [String] $VeeamErrorPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sError",
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Show messages in Context")]
    [ValidateNotNullorEmpty()]
        [Switch]$Context,
    [Parameter(Mandatory=$False, ValueFromPipeline=$False, HelpMessage="Show limited number of messages")]
    [ValidateNotNullorEmpty()]
        [Int]$Limit,
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, HelpMessage="The products or services Log you want to show")]
    [ValidateNotNullorEmpty()]
    [ValidateSet("All","Endpoint","Mount","Backup","EnterpriseServer","Broker","Catalog","RestAPI","BackupManager",
    "CatalogReplication","DatabaseMaintenance","WebApp","PowerShell")]
        [String]$LogType
)

Begin {

    class LogParser {
        #Properties
        [String]$Name
        [String]$BasePath
        [String]$Folder
        [String]$File

        #Static
        Static [String] $WarningPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sWarning"
        Static [String] $ErrorPattern = "\[\d+.\d+.\d+\s\d+\:\d+:\d+]\s\<\d+\>\sError"

        #Constructor
        LogParser ([String] $Name, [String]$BasePath, [String]$Folder, [String]$File) {
            $this.Name = $Name
            $this.BasePath = $BasePath
            $this.Folder = $Folder
            $this.File = $File
        }

        #Method
        [Bool]checkFolder() {
            return Test-Path $($this.BasePath + $this.Folder)
        }

        #Method
        [Bool]checkFile() {
            return Test-Path $($this.BasePath + $this.Folder + "\" + $this.File)
        }

        #Method
        [Array]getContent() {
            if ($this.checkFolder()) {
                if ($this.checkFile()) {
                    return Get-Content $($this.BasePath + $this.Folder + "\" + $this.File)
                }
                else {
                    return Write-Warning "File not found"
                }
            }
            else {
                return Write-Warning "Folder not found"
            }
        }

        #Method
        [Array]getErrors() {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::ErrorPattern) -AllMatches

        }

        #Method
        [Array]getErrors([int]$ContentB, [int]$ContentA) {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::ErrorPattern) -AllMatches -Context $ContentB, $ContentA
        }

        #Method
        [Array]getWarnings() {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::WarningPattern) -AllMatches

        }

        #Method
        [Array]getErrorsAndWarnings() {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::ErrorPattern), $([LogParser]::WarningPattern)

        }

    }
    function Invoke-LogParser {
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
        Invoke-LogParser -Folder "Endpoint" -File "Svc.VeeamEndpointBackup.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamMount.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBackup.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBES.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBroker.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamCatalog.log"
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamRestAPI.log"
        Invoke-LogParser -Folder "Backup" -File "VeeamBackupManager.log"
        Invoke-LogParser -Folder "Backup" -File "CatalogReplicationJob.log"
        Invoke-LogParser -Folder "Backup" -File "Job.DatabaseMaintenance.log"
        Invoke-LogParser -Folder "Backup" -File "Veeam.WebApp.log"
        Invoke-LogParser -Folder "Backup" -File "VeeamPowerShell.log"
    }
    elseif ($LogType -eq "Endpoint") {
        Invoke-LogParser -Folder "Endpoint" -File "Svc.VeeamEndpointBackup.log"
    }
    elseif ($LogType -eq "Mount") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamMount.log"
    }
    elseif ($LogType -eq "Backup") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBackup.log"
    }
    elseif ($LogType -eq "EnterpriseServer") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBES.log"
    }
    elseif ($LogType -eq "Broker") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamBroker.log"
    }
    elseif ($LogType -eq "Catalog") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamCatalog.log"
    }
    elseif ($LogType -eq "RestAPI") {
        Invoke-LogParser -Folder "Backup" -File "Svc.VeeamRestAPI.log"
    }
    elseif ($LogType -eq "BackupManager") {
        Invoke-LogParser -Folder "Backup" -File "VeeamBackupManager.log"
    }
    elseif ($LogType -eq "CatalogReplication") {
        Invoke-LogParser -Folder "Backup" -File "CatalogReplicationJob.log"
    }
    elseif ($LogType -eq "DatabaseMaintenance") {
        Invoke-LogParser -Folder "Backup" -File "Job.DatabaseMaintenance.log"
    }
    elseif ($LogType -eq "WebApp") {
        Invoke-LogParser -Folder "Backup" -File "Veeam.WebApp.log"
    }
    elseif ($LogType -eq "PowerShell") {
        Invoke-LogParser -Folder "Backup" -File "VeeamPowerShell.log"
    }

}
}
