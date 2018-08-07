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
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, ParameterSetName="Endpoint", HelpMessage="Parse Endpoint Log Files")]
    [ValidateNotNullorEmpty()]
        [Switch]$Endpoint,
    [Parameter(Mandatory=$True, ValueFromPipeline=$False, ParameterSetName="Mount", HelpMessage="Parse Mount Log Files")]
    [ValidateNotNullorEmpty()]
        [Switch]$Mount

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

        if (Test-Path $($VeeamBasePath + $Folder)) {
            Write-Host "Parsing Log Files(s): $($VeeamBasePath + $Folder + "\" + $File) `n" -ForegroundColor Gray
            $Content = Get-Content $($VeeamBasePath + $Folder + "\" + $File)
            if ($Context) {
                Write-Host "`nParsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamWarningPattern -AllMatches -Context 2, 2
                if ($Select.Count -gt 0 ) {
                    $Select
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
                Write-Host "`nParsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamErrorPattern -AllMatches -Context 2, 2
                if ($Select.Count -gt 0 ) {
                    $Select
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "`nParsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamWarningPattern -AllMatches
                if ($Select.Count -gt 0 ) {
                    $Select
                }
                else {
                    Write-Host "No matching lines found!" -ForegroundColor Yellow
                }
                Write-Host "`nParsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                [Array]$Select = $Content | Select-String -Pattern $VeeamErrorPattern -AllMatches
                if ($Select.Count -gt 0 ) {
                    $Select
                }
                else {
                    Write-Host "No matching lines found in '$($VeeamBasePath + $Folder)'!" -ForegroundColor Yellow
                }
            }
        }
        else {
            Throw "No Log Files found in '$VeeamBasePath'"
        }
    }
}

Process {

    if ($Endpoint) {
        LogParser -Folder "Endpoint" -File "Svc.VeeamEndpointBackup.*"
    }
    elseif ($Mount) {
        LogParser -Folder "Backup" -File "Svc.VeeamMount.*"
    }

}
}
