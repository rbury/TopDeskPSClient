function Get-APIResponse {
    [CmdletBinding(PositionalBinding = $false,
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
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [TopDeskPSClient]
        $Client,
        # Parameter help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Body')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Body,
        # Parameter help description
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Header')]
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Body')]
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
                        $Client.APICall($Method, $Headers, $Body, $EndPoint)
                    }
                    else {
                        $Client.APICall($Method, $EndPoint, $Body)
                    }
                }
                'Header' {
                    $Client.APICall($Method, $EndPoint, $Headers)
                }
                Default {
                    $Client.APICall($Method, $EndPoint)
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