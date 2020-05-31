using namespace Microsoft.PowerShell.Commands

[CmdletBinding()]
param(
    [ValidateSet("CurrentUser", "AllUsers")]
    $Scope = "CurrentUser",
    $Task = 'Build'
)

[ModuleSpecification[]]$RequiredModules = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName RequiredModules
$Policy = (Get-PSRepository PSGallery).InstallationPolicy
Set-PSRepository PSGallery -InstallationPolicy Trusted

try {
    $RequiredModules | ForEach-Object {
        if ( !( ($null -eq (Get-Module -Name $_.Name -ListAvailable)) ) ) {
            if ((Get-Module -Name $_.Name -ListAvailable).Version.ToString() -ne $_.RequiredVersion) {
                try {
                    Remove-Module -Name $_.Name -Force -ErrorAction SilentlyContinue
                }
                catch {
                    $thiserror = $_
                    Write-Warning ("Problem: {0}`r`n{1}" -f $thiserror.Exception.Message, $thiserror.ScriptStackTrace)
                }
                Install-Module -Name $_.Name -RequiredVersion $_.RequiredVersion -Scope $Scope -Repository PSGallery -SkipPublisherCheck -ErrorAction SilentlyContinue -Force
            }
        }
        else {
            Install-Module -Name $_.Name -RequiredVersion $_.RequiredVersion -Scope $Scope -Repository PSGallery -SkipPublisherCheck -ErrorAction SilentlyContinue -Force
        }
    }
}
finally {
    Set-PSRepository PSGallery -InstallationPolicy $Policy
}

$RequiredModules | Import-Module

Invoke-Build -Task $Task