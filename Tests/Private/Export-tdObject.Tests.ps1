Describe "Function Export-tdObject" {
    
    #Import-Module -Name $env:BHModulePath/TopDeskPSClient.psd1 -Force
    BeforeAll {
        Set-BuildEnvironment -Path "$(Split-Path -Path $PSCommandPath -Parent)\..\.." -Force
        (Get-ChildItem -Path $env:BHModulePath\Classes\*.ps1) | ForEach-Object {
            . $_
        }
        . (Join-Path -Path "$env:BHModulePath\Private\" -ChildPath "$(Split-Path -Path $PSCommandPath.ToLower().Replace('.tests.ps1', '.ps1') -Leaf)")
        . $env:BHModulePath\Private\Import-tdObject.ps1
        $testobject = [PSCustomObject]@{
            Name    = 'Testing'
            Version = 1
        }
        $exportFile = Export-tdObject -Path $TestDrive -FileName 'Test.bin' -Object $testobject
    }

    Context "Unit Tests" -Tag 'Unit' {
        It "Exported file should exist" {
            $exportFile | Should -Exist
        }
        It "Exported file should be 709b" {
            (Get-Item -Path $exportFile).Length | Should -Be 709
        }
        It "Imported object should be the same as exported" {
            $imported = Import-tdObject -FilePath "$TestDrive\Test.bin"
            $importedJSON = ConvertTo-Json -InputObject $imported
            $exportedJSON = ConvertTo-Json -InputObject $testobject
            $importedJSON | Should -Be $exportedJSON
        }
    }
}