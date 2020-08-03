Describe "Function Connect-TopDeskPSClient" {
    
    BeforeAll {
        Set-BuildEnvironment -Path "$(Split-Path -Path $PSCommandPath -Parent)\..\.." -Force
        (Get-ChildItem -Path $env:BHModulePath\Classes\*.ps1) | ForEach-Object {
            . $_
        }
        . (Join-Path -Path "$env:BHModulePath\Public\" -ChildPath "$(Split-Path -Path $PSCommandPath.ToLower().Replace('.tests.ps1', '.ps1') -Leaf)")
        $url = 'https://fakefortesting.topdesk.net'
    }

    Context "Unit Tests - Client should not be created with invald URL or Credential" -Tag 'Unit' {
        It "Should fail with connection error - credential" {
            $cred = New-Object -TypeName pscredential -ArgumentList @('tester',('testpass' | ConvertTo-SecureString -AsPlainText))
            try {
                Connect-TopDeskPSClient -url $url -PSCredential $cred
            } catch {
                $_ | Should -Be 'Connection Failed'
            }
        }
        It "Should fail with validation - url" {
            $cred = New-Object -TypeName pscredential -ArgumentList @('tester',('testpass' | ConvertTo-SecureString -AsPlainText))
            try {
                Connect-TopDeskPSClient -url 'http://baddomain' -PSCredential $cred
            }
            catch {
                $_ | Should -Match "Cannot validate argument on parameter 'url'"
            }
        }
    }
}