function Get-APIResponse {
    [CmdletBinding(PositionalBinding = $false,
        DefaultParameterSetName = 'Default',
        ConfirmImpact = 'Medium')]
    [OutputType([psobject])]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Body')]
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Header')]
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Method')]
        [ValidateSet('GET', 'PUT', 'POST', 'PATCH', 'DELETE')]
        [string]
        $Method,
        # Parameter help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $EndPoint,
        # Parameter help description
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Body',
            ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Header',
            ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Method',
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Body,
        # Parameter help description
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Body',
            ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $true,
            ParameterSetName = 'Header',
            ValueFromPipelineByPropertyName = $true)]
        [Parameter(Mandatory = $false,
            ParameterSetName = 'Method',
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Headers
    )

    Begin {}
    Process {
        $EndPoint = $EndPoint.Replace('/tas/api', '').TrimStart('/')

        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Body' {
                    If ($PSBoundParameters.ContainsKey('Headers')) {
                        $Script:Client.APICall($Method, $Headers, $Body, $EndPoint)
                    }
                    else {
                        $Script:Client.APICall($Method, $EndPoint, $Body)
                    }
                }
                'Header' {
                    $Script:Client.APICall($Method, $EndPoint, $Headers)
                }
                'Method' {
                    $Script:Client.APICall($Method, $EndPoint)
                }
                'Default' {
                    $Script:Client.APICall($EndPoint)
                }
            }
        }
        catch {
            $thiserror = $_
            return [PSCustomObject]@{
                Name       = 'API Request'
                Status     = if ($null -ne ($thiserror.Exception.HResult)) { $thiserror.Exception.HResult }
                Response   = if ($null -ne ($thiserror.Exception.Message)) { $thiserror.Exception.Message }
                StatusCode = if ($null -ne ($thiserror.Exception.response.StatusCode)) { $thiserror.Exception.response.StatusCode }
                Data       = if ($null -ne ($thiserror.TargetObject.RequestUri.AbsolutePath)) { $thiserror.TargetObject.RequestUri.AbsolutePath }
            }
        }
    }
    End {}
}