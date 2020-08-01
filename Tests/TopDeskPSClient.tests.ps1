#Import-Module $PSScriptRoot\..\TopDeskPSClient\TopDeskPSClient.psd1 -Force

Describe "General project validation: $env:BHProjectName" {

    $scripts = Get-ChildItem $env:BHBuildOutput -Include *.ps1, *.psm1, *.psd1 -Recurse

    # TestCases are splatted to the script so we need hashtables
    $testCase = $scripts | Foreach-Object { @{file = $_ } }
    It "Script <file> should be valid powershell" -TestCases $testCase {
        #param($file)

        $file.fullname | Should -Exist

        $contents = Get-Content -Path $file.fullname -ErrorAction Stop
        $errors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
        $errors.Count | Should -Be 0
    }

    It "Module '$env:BHProjectName' can import cleanly" {
        { Import-Module "$env:BHBuildOutput/$env:BHProjectName.psd1" -force }
    }
}