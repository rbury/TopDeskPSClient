Describe "Function Get-APIResponse" {
    
    BeforeAll {
        Set-BuildEnvironment -Path "$(Split-Path -Path $PSCommandPath -Parent)\..\.." -Force
        (Get-ChildItem -Path $env:BHModulePath\Classes\*.ps1) | ForEach-Object {
            . $_
        }
        . $env:BHModulePath\Public\New-TopDeskPSClient.ps1
        . (Join-Path -Path "$env:BHModulePath\Public\" -ChildPath "$(Split-Path -Path $PSCommandPath.ToLower().Replace('.tests.ps1', '.ps1') -Leaf)")
    }

    Context "Unit Tests - Client Disconnected" -Tag 'Unit' {
        # Tests will require valid client
    }
}