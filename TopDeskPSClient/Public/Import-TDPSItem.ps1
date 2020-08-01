function Import-TDPSItem {
    [CmdletBinding()]
    param (
        # Path to file to import
        [Parameter(Mandatory=$true)]
        [string]
        $FilePath
    )
    
    #! These can be removed (Export & Import TDPSItem), used for testing import and export. Will not be used outside module.
        Import-tdObject -FilePath $FilePath
}