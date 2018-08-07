$moduleRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = "VeeamLogParser"

Describe "General Code validation: $moduleName" {

    $scripts = Get-ChildItem $moduleRoot -Include *.psm1, *.ps1, *.psm1 -Recurse
    $testCase = $scripts | Foreach-Object {@{file = $_}}
    It "Script <file> should be valid powershell" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist
        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should Be 0
    }

    $modules = Get-ChildItem $moduleRoot -Include *.psd1 -Recurse
    $testCase = $modules | Foreach-Object {@{file = $_}}
    It "Module <file> can import cleanly" -TestCases $testCase {
        param($file)

        $file.fullname | Should Exist
        $error.clear()
        {Import-Module  $file.fullname } | Should Not Throw
        $error.Count | Should Be 0
    }
}

