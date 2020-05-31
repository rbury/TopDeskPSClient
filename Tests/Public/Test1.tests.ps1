Import-Module $PSScriptRoot\..\MyProject\MyProject.psd1 -Force

Describe Get-Test {
    InModuleScope -ModuleName MyProject {
        Context "Perform Test" {
            It "Returns $true" {
                Get-Test | Should -Be $true
            }
        }
    }
}