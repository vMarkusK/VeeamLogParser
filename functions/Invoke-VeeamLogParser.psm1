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
        [Array]getWarnings([int]$ContentB, [int]$ContentA) {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::WarningPattern) -AllMatches -Context $ContentB, $ContentA

        }

        #Method
        [Array]getErrorsAndWarnings() {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::ErrorPattern), $([LogParser]::WarningPattern) -AllMatches

        }

        #Method
        [Array]getErrorsAndWarnings([int]$ContentB, [int]$ContentA) {
            $Content = $this.getContent()
            return $Content | Select-String -Pattern $([LogParser]::ErrorPattern), $([LogParser]::WarningPattern) -AllMatches -Context $ContentB, $ContentA

        }

    }
    function Invoke-Output ($item) {
        if ($Context) {
            $Select = $item.getErrorsAndWarnings(2,2)
        }
        else {
            $Select =  $item.getErrorsAndWarnings()
        }

        if ($Limit) {
            $Select | Select-Object -Last $Limit
        }
        else {
            $Select
        }

    }

    $LogTypes = @()
    $LogTypes += [LogParser]::new("Endpoint", $VeeamBasePath, "Endpoint", "Svc.VeeamEndpointBackup.log")
    $LogTypes += [LogParser]::new("Mount", $VeeamBasePath, "Backup", "Svc.VeeamMount.log")
    $LogTypes += [LogParser]::new("Backup", $VeeamBasePath, "Backup", "Svc.VeeamBackup.log")
    $LogTypes += [LogParser]::new("EnterpriseServer", $VeeamBasePath, "Backup", "Svc.VeeamBES.log")
    $LogTypes += [LogParser]::new("Broker", $VeeamBasePath, "Backup", "Svc.VeeamBroker.log")
    $LogTypes += [LogParser]::new("Catalog", $VeeamBasePath, "Backup", "Svc.VeeamCatalog.log")
    $LogTypes += [LogParser]::new("RestAPI", $VeeamBasePath, "Backup", "Svc.VeeamRestAPI.log")
    $LogTypes += [LogParser]::new("BackupManager", $VeeamBasePath, "Backup", "VeeamBackupManager.log")
    $LogTypes += [LogParser]::new("CatalogReplication", $VeeamBasePath, "Backup", "CatalogReplicationJob.log")
    $LogTypes += [LogParser]::new("DatabaseMaintenance", $VeeamBasePath, "Backup", "Job.DatabaseMaintenance.log")
    $LogTypes += [LogParser]::new("WebApp", $VeeamBasePath, "Backup", "Veeam.WebApp.log")
    $LogTypes += [LogParser]::new("PowerShell", $VeeamBasePath, "Backup", "VeeamPowerShell.log")

}

Process {

    if ($LogType -eq "All") {
        foreach ($item in $LogTypes) {
            Write-Host "`nProcessing '$($item.File)' in '$($item.BasePath + $item.Folder + "\")'" -ForegroundColor Gray
            Invoke-Output $item
        }
    }
    else {
        $item = $LogTypes | Where-Object {$_.Name -eq $LogType }
        if ($item) {
            Write-Host "`nProcessing '$($item.File)' in '$($item.BasePath + $item.Folder + "\")'" -ForegroundColor Gray
            Invoke-Output $item
        }
        else {
            Throw "Internal Error: LogType Missmatch"
        }
    }
}
}
