<#
.Synopsis
	Build script (https://github.com/rbury/PSModuleTemplate)
#>

task regularBuild {
    if (!(Test-Path -Path $env:BuildOutput -PathType Container)) {
        New-Item -Path $env:BuildOutput -ItemType Directory
    }

    New-Item -Path  "$env:BuildOutput/$env:ProjectName.psm1" -Force
    @'
    Set-StrictMode -Version latest
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
'@ | Add-Content -Path "$env:BuildOutput/$env:ProjectName.psm1" -Force
    if (Test-Path -Path "$env:ModulePath/Classes" -PathType Container) {
        Get-ChildItem -Path "$env:ModulePath/Classes/*.ps1" -Recurse | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    }
    if (Test-Path -Path "$env:ModulePath/Private" -PathType Container) {
        Get-ChildItem -Path "$env:ModulePath/Private/*.ps1" -Recurse | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    }
    $Public = @( Get-ChildItem -Path "$env:ModulePath/Public/*.ps1" -Force )
    $Public | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    $PublicFunctions = $Public.BaseName

    Write-Output ("Copying {0} to {1}" -f ($env:PSModuleManifest), ($env:BuildOutput))
    Copy-Item -Path $env:PSModuleManifest -Destination $env:BuildOutput -Force
    Write-Output ("Contents: {0}" -f (Get-ChildItem -Path $env:BuildOutput))

    $newversion = (($env:PROJECT_VERSION -split '-')[0]).Replace('v', '')
    Set-ModuleFunction -Name "$env:BuildOutput/$env:ProjectName.psd1" -FunctionsToExport $PublicFunctions
    Update-Metadata -Path "$env:BuildOutput/$env:ProjectName.psd1" -PropertyName ModuleVersion -Value $newversion
}

task testBuild {
    if (!(Test-Path -Path $env:BuildOutput -PathType Container)) {
        New-Item -Path $env:BuildOutput -ItemType Directory
    }

    New-Item -Path  "$env:BuildOutput/$env:ProjectName.psm1" -Force
    @'
    Set-StrictMode -Version latest
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
'@ | Add-Content -Path "$env:BuildOutput/$env:ProjectName.psm1" -Force
    if (Test-Path -Path "$env:ModulePath/Classes" -PathType Container) {
        Get-ChildItem -Path "$env:ModulePath/Classes/*.ps1" -Recurse | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    }
    if (Test-Path -Path "$env:ModulePath/Private" -PathType Container) {
        Get-ChildItem -Path "$env:ModulePath/Private/*.ps1" -Recurse | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    }
    $Public = @( Get-ChildItem -Path "$env:ModulePath/Public/*.ps1" -Force )
    $Public | Get-Content | Add-Content "$env:BuildOutput/$env:ProjectName.psm1" -Force
    $PublicFunctions = $Public.BaseName

    Copy-Item -Path $env:PSModuleManifest -Destination $env:BuildOutput -Force
    Get-ChildItem -Path $env:BuildOutput

    Set-ModuleFunction -Name "$env:BuildOutput\$env:ProjectName.psd1" -FunctionsToExport $PublicFunctions
}

task Test {
    Import-Module "$env:BuildOutput/$env:ProjectName.psd1" -Force
    $res = Invoke-Pester -Script "$env:ProjectPath/Tests/$env:ProjectName.tests.ps1" -PassThru

    if ($res.FailedCount -gt 0) {

        throw "$($res.FailedCount) tests failed."

    }
}

task GenDocs {

    if (Test-Path -Path "$env:BuildOutput/en-US" ) {
        $null = Remove-Item "$env:BuildOutput/en-US" -Recurse -Force
    }
    Import-Module "$env:BuildOutput/$env:ProjectName.psd1" -Force

    New-MarkdownHelp -Module $env:ProjectName -OutputFolder "$env:BuildOutput/en-US" -WithModulePage -ErrorAction SilentlyContinue
    New-ExternalHelp -OutputPath "$env:BuildOutput/en-US" -Path "$env:BuildOutput/en-US" -ShowProgress -Force -ErrorAction SilentlyContinue
    $null = Remove-Item "$env:BuildOutput/en-US/*.md" -Recurse -Force

}

task Archive {
    Compress-Archive -Path "$env:BuildOutput/*" -DestinationPath "$env:BuildOutput/$env:ProjectName.zip"
}

task Build regularBuild