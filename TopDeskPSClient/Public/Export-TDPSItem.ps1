function Export-TDPSItem {
    [CmdletBinding()]
    param (
        # Object to export
        [Parameter(Mandatory=$true)]
        [psobject]
        $PSObject,
        # Path to export File
        [Parameter(Mandatory=$true)]
        [string]
        $Path,
        # Name of export file
        [Parameter(Mandatory=$true)]
        [string]
        $FileName
    )
    
    #! These can be removed (Export & Import TDPSItem), used for testing import and export. Will not be used outside module.
        Write-Output ("Calling Export-tdObject")
        Export-tdObject -Path $Path -Object $PSObject -FileName $FileName
}