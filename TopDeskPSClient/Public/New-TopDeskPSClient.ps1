function New-TopDeskPSClient {
    [cmdletBinding(DefaultParameterSetName = 'url',
        PositionalBinding = $false,
        ConfirmImpact = 'Medium')]
    [OutputType([psobject])]
    param (
        [Parameter(Mandatory = $true,
            ParameterSetName = 'url',
            ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'load',
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        #[ValidatePattern("(^https)(:\/\/)([^\s,]+)")]
        [ValidatePattern("(^https)(:\/\/)([^\s,]+)(\.topdesk\.net)")]
        [string]
        $url,
        [Parameter(Mandatory = $true,
            ParameterSetName = 'url',
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $PSCredential,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'load',
            ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Load,
        [Parameter(Mandatory = $false,
            ParameterSetName = 'url',
            ValueFromPipelineByPropertyName = $true)]
        [switch]
        $Save
    )

    switch ($PSCmdlet.ParameterSetName) {
        'load' {
            return [TopDeskPSClient]::new($url, $true, $true)
            break
        }
        'url' {
            if ($Save) {
                return [TopDeskPSClient]::new($url, $PSCredential, $true)
            }
            else {
                return [TopDeskPSClient]::new($url, $PSCredential)
            }
            break
        }
    }

}