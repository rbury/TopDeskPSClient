function New-TopDeskPSClient {
    [cmdletBinding(DefaultParameterSetName = 'url',
        PositionalBinding = $false,
        SupportsShouldProcess,
        ConfirmImpact = 'Low')]
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

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }
    Process {

        switch ($PSCmdlet.ParameterSetName) {
            'load' {
                if ($Load) {
                    return [TopDeskPSClient]::new($url, $true)
                    break
                }
            }
            'url' {
                if ($Save) {
                    if ($PSCmdlet.ShouldProcess('New TopDeskClient', 'Save Credentials')) {
                            return [TopDeskPSClient]::new($url, $PSCredential, $true)
                        }
                    }
                    else {
                        return [TopDeskPSClient]::new($url, $PSCredential)
                    }
                    break
                }
            }
        }
        End {}

    }