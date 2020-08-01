<#
.Synopsis
	Build script (https://github.com/rbury/TopDeskPSClient)
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
    $ReleaseNotes = (Get-Content -Path "./ReleaseNotes.md") -replace '## v0.0.0', ('## ' + $env:PROJECT_VERSION)
    Update-Metadata -Path "$env:BuildOutput/$env:ProjectName.psd1" -PropertyName ReleaseNotes -Value $ReleaseNotes
}

task offlineInitialize {
    Get-Item env:BH* | Remove-Item -ErrorAction SilentlyContinue
    Set-BuildEnvironment -ErrorAction Stop

    if (Get-Module $env:BHProjectName) {
        Remove-Module $env:BHProjectName
    }

    if (Test-Path -Path "$env:BHBuildOutput") {
        Remove-Item "$env:BHBuildOutput" -Recurse -Force
    }

    #$null = New-Item "$env:BHBuildOutput/$env:BHProjectName" -ItemType Directory -Force
}

task offlineBuild {
    $buildvars = (Get-Item env:BH*)
    $buildvars | ForEach-Object {Write-Output $_}
    $null = New-Item -Path  "$env:BHBuildOutput/$env:BHProjectName.psm1" -Force
    @'
Set-StrictMode -Version latest
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
'@ | Add-Content -Path "$env:BHBuildOutput/$env:BHProjectName.psm1" -Force
    Get-ChildItem -Path "$env:BHModulePath/Classes/*.ps1" -Recurse | Get-Content | Add-Content "$env:BHBuildOutput/$env:BHProjectName.psm1" -Force
    Get-ChildItem -Path "$env:BHModulePath/Private/*.ps1" -Recurse | Get-Content | Add-Content "$env:BHBuildOutput/$env:BHProjectName.psm1" -Force
    $Public = @( Get-ChildItem -Path "$env:BHModulePath/Public/*.ps1" -Force )
    $Public | Get-Content | Add-Content "$env:BHBuildOutput/$env:BHProjectName.psm1" -Force
    $PublicFunctions = $Public.BaseName
    Copy-Item -Path "$env:BHPSModuleManifest" -Destination "$env:BHBuildOutput/" -Force
    Write-Output (Get-ChildItem -Path "$env:BHBuildOutput")
    Write-Output (Convert-Path -Path "$env:BHBuildOutput/$env:BHProjectName.psd1")
    #Set-ModuleFunction -Name (Convert-Path -Path "$env:BHBuildOutput/$env:BHProjectName.psd1") -FunctionsToExport $PublicFunctions
    Update-Metadata -Path (Convert-Path -Path "$env:BHBuildOutput/$env:BHProjectName.psd1") -PropertyName 'FunctionsToExport' -Value $PublicFunctions
}

task offlineTest {
    if(Get-Module -Name $env:BHProjectName) {Remove-Module -Name $env:BHProjectName -Force}
    Import-Module "$env:BHBuildOutput/$env:BHProjectName.psd1" -Force
    #$res = Invoke-Pester -Script "$env:BHProjectPath/Tests/$env:BHProjectName.tests.ps1" -Output Detailed #-PassThru
    $res = Invoke-Pester -Path "$env:BHProjectPath/Tests" -Output Detailed 

    if ($res.FailedCount -gt 0) {

        throw "$($res.FailedCount) tests failed."

    }
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
    $res = Invoke-Pester -Script "$env:ProjectPath/Tests/$env:ProjectName.tests.ps1" #-PassThru

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
task vscBuild offlineInitialize, offlineBuild, offlineTest