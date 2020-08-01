Describe "Function Import-tdObject" {
    
    BeforeAll {
        Set-BuildEnvironment -Path "$(Split-Path -Path $PSCommandPath -Parent)\..\.." -Force
        (Get-ChildItem -Path $env:BHModulePath\Classes\*.ps1) | ForEach-Object {
            . $_
        }
        . (Join-Path -Path "$env:BHModulePath\Private\" -ChildPath "$(Split-Path -Path $PSCommandPath.ToLower().Replace('.tests.ps1', '.ps1') -Leaf)")
        . $env:BHModulePath\Private\Export-tdObject.ps1
        
        $testobject = [PSCustomObject]@{
            Name    = 'Testing'
            Version = 1
        }
        $exportFile = Export-tdObject -Path $TestDrive -FileName 'Test.bin' -Object $testobject
        $importFile = Import-tdObject -FilePath "$TestDrive\Test.bin"
    }

    Context "Unit Tests" -Tag 'Unit' {
        It "Imported object should match exported object" {
            $importedJSON = ConvertTo-Json -InputObject $importFile
            $exportedJSON = ConvertTo-Json -InputObject $testobject
            $importedJSON | Should -Be $exportedJSON
        }
    }
}