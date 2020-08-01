function Export-tdObject {
    [CmdletBinding(DefaultParameterSetName = 'Path',
        PositionalBinding = $false,
        ConfirmImpact = 'Medium')]
    [OutputType([string])]

    param (

        # Path to export directory
        [Parameter(Mandatory = $true,
            ParameterSetName = "Path",
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string]
        $Path,

        # Literal path to export directory
        [Parameter(Mandatory = $true,
            ParameterSetName = "LiteralPath",
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { Test-Path -LiteralPath $_ -PathType Container })]
        [string]
        $LiteralPath,

        # Object(s) to be exported
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('ExportObject')]
        [psobject]
        $Object,

        # File name to hold exported object
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name,File')]
        [string]
        $FileName
        
    )
    
    begin {
        switch ($PSCmdlet.ParameterSetName) {
            'Path' { $_exportPath = Resolve-Path -Path $Path | Select-Object -ExpandProperty Path } 
            'LiteralPath' { $_exportPath = Resolve-Path -LiteralPath $LiteralPath | Select-Object -ExpandProperty Path }
        }
    }
    
    process {
        $_exportFile = (Join-Path -Path $_exportPath -ChildPath $FileName)
        [TDPSUtils]::ExporttdpsObject($_exportFile,$Object)
    }
    
    end {}
}
