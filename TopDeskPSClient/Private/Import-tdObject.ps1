function Import-tdObject {
    [CmdletBinding(DefaultParameterSetName='Path',
    PositionalBinding=$false,
    ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param (
        # Path to import file
        [Parameter(Mandatory = $true,
            ParameterSetName = "Path",
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ -PathType leaf })]
        [Alias('Path,File')]
        [string]
        $FilePath,

        # Literal path to import file
        [Parameter(Mandatory = $true,
            ParameterSetName = "LiteralPath",
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -LiteralPath $_ -PathType leaf })]
        [string]
        $LiteralPath
    )
    
    begin {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' { $_importPath = Resolve-Path -Path $FilePath | Select-Object -ExpandProperty Path}
            'LiteralPath' { $_importPath = Resolve-Path -LiteralPath $LiteralPath | Select-Object -ExpandProperty Path}
        }
    }
    
    process {
            [tdpsUtils]::ImporttdpsObject($_importPath)
    }
    
    end {}
}