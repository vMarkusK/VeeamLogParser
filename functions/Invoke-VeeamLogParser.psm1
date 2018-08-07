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
        [Switch]$Endpoint

)

Process {

    if ($Endpoint) {
        $Folder = "Endpoint"
        $File = "Svc.VeeamEndpointBackup.*"
        if (Test-Path $($VeeamBasePath + $Folder)) {
            if ($Context) {
                Write-Host "Parsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                Get-Content $($VeeamBasePath + $Folder + "\" + $File) | Select-String -Pattern $VeeamWarningPattern -AllMatches -Context 2, 2
                ""
                Write-Host "Parsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                Get-Content $($VeeamBasePath + $Folder + "\" + $File) | Select-String -Pattern $VeeamErrorPattern -AllMatches -Context 2, 2

            }
            else {
                Write-Host "Parsing Warning Log messages with Pattern '$VeeamWarningPattern':" -ForegroundColor Gray
                Get-Content $($VeeamBasePath + $Folder + "\" + $File) | Select-String -Pattern $VeeamWarningPattern -AllMatches
                ""
                Write-Host "Parsing Error Log messages with Pattern '$VeeamErrorPattern':" -ForegroundColor Gray
                Get-Content $($VeeamBasePath + $Folder + "\" + $File) | Select-String -Pattern $VeeamErrorPattern -AllMatches

            }
        }
        else {
            Throw "No Endpoint Log Files found in '$VeeamBasePath'"
        }

    }

}
}
