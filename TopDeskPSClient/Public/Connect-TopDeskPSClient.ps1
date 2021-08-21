$Script:Client = [TopDeskPSClient]::new()

function Connect-TopDeskPSClient {
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
        if (!(Invoke-WebRequest -Uri $url -UseBasicParsing | Select-Object statuscode).StatusCode -eq '200') {
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new("Not able to reach URL, please check the address.", $null, [System.Management.Automation.ErrorCategory]::ConnectionError, $null))
        }
        switch ($PSCmdlet.ParameterSetName) {
            'load' {
                if ($Load) {
                    $Script:Client = [TopDeskPSClient]::new($url, $true)
                    return $true
                    break
                }
            }
            'url' {
                if ($Save) {
                    if ($PSCmdlet.ShouldProcess('New TopDeskClient', 'Save Credentials')) {
                        $Script:Client = [TopDeskPSClient]::new($url, $PSCredential, $true)
                        return $true
                    }
                }
                else {
                    $Script:Client = [TopDeskPSClient]::new($url, $PSCredential)
                    return $true
                }
                break
            }
        }
    }
    End { }

}