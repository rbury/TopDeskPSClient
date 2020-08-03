function Get-APIResponse {
    [CmdletBinding(PositionalBinding = $false,
        DefaultParametersetName = 'Default',
        ConfirmImpact = 'Medium')]
    [OutputType([psobject])]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
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
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Body')]
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Default')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Body,
        # Parameter help description
        [Parameter(Mandatory = $false,
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
                Default {
                    if ($PSBoundParameters.ContainsKey('Headers')) {
                        $Script:Client.APICall($Method, $EndPoint, $Headers)
                    }
                    else {
                        $Script:Client.APICall($Method, $EndPoint)
                    }
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