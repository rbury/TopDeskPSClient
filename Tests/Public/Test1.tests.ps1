Import-Module $PSScriptRoot\..\TopDeskPSClient\TopDeskPSClient.psd1 -Force

Describe Get-Test {
    InModuleScope -ModuleName TopDeskPSClient {
        Context "Perform Test" {
            It "Returns $true" {
                Get-Test | Should -Be $true
            }
        }
    }
}