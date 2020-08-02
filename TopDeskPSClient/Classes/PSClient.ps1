Class TopDeskPSClient {

    [string] $version
    [string] $productversion
    [string] $url
    hidden [bool] $connected
    hidden [string] $instance
    hidden [pscredential] $APICred

    TopDeskPSClient([string]$url, [pscredential]$cred) {
        $this.connected = $false
        if ($url) {
            $this.url = $url
            $this.instance = $url.Replace("https://", "")
            $this.APICred = $cred
            if (!($this.Connect())) {
                $this.connected = $false
                $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new('Connection Failed', 'Check the url and credentials provided are valid', [System.Management.Automation.ErrorCategory]::ConnectionError, $null))
            }   
        }
    }

    TopDeskPSClient([string]$url, [pscredential]$cred, [bool]$save) {
        $this.connected = $false
        if ($url) {
            $this.url = $url
            $this.instance = $url.Replace("https://", "")
            $this.APICred = $cred
            if ($this.Connect()) {
                $this.SaveConnection()
            }
            else {
                $this.connected = $false
                $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new('Connection Failed', 'Check the url and credentials provided are valid', [System.Management.Automation.ErrorCategory]::ConnectionError, $null))
            }
        }
    }

    TopDeskPSClient() {
        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new('url and credential are required', 'Please provide a url and credential to create client', [System.Management.Automation.ErrorCategory]::SyntaxError, $null))
    }

    TopDeskPSClient([string]$url, [bool]$load) {
        $this.url = $url
        $this.instance = $url.Replace('https://', '')
        $this.connected = $false
        $this.LoadConnection()
        if (!($this.Connect())) {
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new('Connection Failed', 'Check the url and credentials provided are valid', [System.Management.Automation.ErrorCategory]::ConnectionError, $null))
        }
    }

    [string] ToString() {
        return @(
            'TopDeskPSClient', 'API: ' + $this.version, 'URL: ' + $this.url
        )
    }

    [psobject] APICall([string]$Method, [hashtable]$Headers, [string]$Body, [string]$EndPoint) {
        if ($this.connected) {
            $null = $Headers.Add('Authorization', ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.APICred.UserName + ':' + $this.APICred.GetNetworkCredential().Password))))
            $rhv = ""
            $scv = ""
            $request = Invoke-RestMethod -Method $Method -Uri $($this.url + '/tas/api/' + $EndPoint) -Body $Body -Headers $Headers -ResponseHeadersVariable rhv -StatusCodeVariable scv
            return @{
                Name       = 'API Request'
                Status     = 0
                Response   = $rhv
                StatusCode = $scv
                Data       = $request
            }
        }
        else {
            return @{
                Name       = 'API Request'
                Status     = 1
                Response   = $null
                StatusCode = $null
                Data       = $null
            }
        }
    }

    [psobject] APICall([string]$Method, [hashtable]$Headers, [string]$EndPoint) {
        if ($this.connected) {
            $null = $Headers.Add('Authorization', ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.APICred.UserName + ':' + $this.APICred.GetNetworkCredential().Password))))
            $rhv = ""
            $scv = ""
            $request = Invoke-RestMethod -Method $Method -Uri $($this.url + '/tas/api/' + $EndPoint) -Headers $Headers -ResponseHeadersVariable rhv -StatusCodeVariable scv
            return @{
                Name       = 'API Request'
                Status     = 0
                Response   = $rhv
                StatusCode = $scv
                Data       = $request
            }
        }
        else {
            return @{
                Name       = 'API Request'
                Status     = 1
                Response   = $null
                StatusCode = $null
                Data       = $null
            }
        }
    }

    [psobject] APICall([string]$Method, [string]$Body, [string]$EndPoint) {
        if ($this.connected) {
            $Headers = @{'Authorization' = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.APICred.UserName + ':' + $this.APICred.GetNetworkCredential().Password))) }
            $rhv = ""
            $scv = ""
            $request = Invoke-RestMethod -Method $Method -Uri $($this.url + '/tas/api/' + $EndPoint) -Body $Body -Headers $Headers -ResponseHeadersVariable rhv -StatusCodeVariable scv
            return @{
                Name       = 'API Request'
                Status     = 0
                Response   = $rhv
                StatusCode = $scv
                Data       = $request
            }
        }
        else {
            return @{
                Name       = 'API Request'
                Status     = 1
                Response   = $null
                StatusCode = $null
                Data       = $null
            }
        }
    }

    [psobject] APICall([string]$Method, [string]$EndPoint) {
        if ($this.connected) {
            $Headers = @{'Authorization' = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.APICred.UserName + ':' + $this.APICred.GetNetworkCredential().Password))) }
            $rhv = ""
            $scv = ""
            $request = Invoke-RestMethod -Method $Method -Uri $($this.url + '/tas/api/' + $EndPoint) -Headers $Headers -ResponseHeadersVariable rhv -StatusCodeVariable scv
            return @{
                Name       = 'API Request'
                Status     = 0
                Response   = $rhv
                StatusCode = $scv
                Data       = $request
            }
        }
        else {
            return @{
                Name       = 'API Request'
                Status     = 1
                Response   = 'TopDeskPSClient must be connected, use Connect-TopDeskPSClient'
                StatusCode = $null
                Data       = $null
            }
        }
    }

    [psobject] APICall([string]$EndPoint) {
        if ($this.connected) {
            $Headers = @{'Authorization' = ('Basic ' + [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($this.APICred.UserName + ':' + $this.APICred.GetNetworkCredential().Password))) }
            $rhv = ""
            $scv = ""
            $request = Invoke-RestMethod -Method GET -Uri $($this.url + '/tas/api/' + $EndPoint) -Headers $Headers -ResponseHeadersVariable rhv -StatusCodeVariable scv
            return @{
                Name       = 'API Request'
                Status     = 0
                Response   = $rhv
                StatusCode = $scv
                Data       = $request
            }
        }
        else {
            return @{
                Name       = 'API Request'
                Status     = 1
                Response   = 'TopDeskPSClient must be connected, use Connect-TopDeskPSClient'
                StatusCode = $null
                Data       = $null
            }
        }
    }

    [void] LoadConnection() {
        if ($null -ne $this.instance) {
            $_settingPath = "$env:APPDATA/TopDeskPSClient/$($this.instance).bin"
            if (Test-Path -Path "$_settingPath" -PathType Leaf) {
                Write-Verbose ("Importing settings from {0}" -f $_settingPath)
                $_mySettings = Import-tdObject -FilePath $_settingPath
                if ($_mySettings.Status -eq 0) {
                    Write-Verbose ("Settings loaded")
                    $this.APICred = New-Object -TypeName pscredential -ArgumentList @($_mySettings.CRD[0], ($_mySettings.CRD[1] | ConvertTo-SecureString))
                }
                else {
                    $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new("TopDesk instance saved settings are corrupted.", $null, [System.Management.Automation.ErrorCategory]::InvalidData, $null))
                }
            }
        }
    }

    [void] SaveConnection() {
        if ($null -ne $this.instance) {
            $_savePath = "$env:APPDATA/TopDeskPSClient"
            if (!(Test-Path -Path $_savePath)) {
                $null = New-Item -path $_savePath -ItemType Container
            }
            $_mySettings = @{
                Name   = $this.instance
                Status = 0
                'CRD'  = @(
                    ($this.APICred.UserName),
                    ($this.APICred.Password | ConvertFrom-SecureString)
                )
            }
            Export-tdObject -Path $_savePath -Object $_mySettings -FileName "$($this.instance).bin"
        }
    }

    [bool] Connect() {
        if (($null -ne $this.apicred) -and ($null -ne $this.url)) {
            $this.connected = $true
            $_version = $this.APICall('GET', 'version')
            if ($_version.status -eq 0) {
                $this.connected = $true
                $this.version = $_version.data.version
                $prodVersion = $this.APICall('GET', 'productVersion')
                $this.productversion = "$($prodVersion.Data.major).$($prodVersion.Data.minor).$($prodVersion.Data.patch)"
                return $true
            }
            else {
                $this.connected = $false
                Write-Verbose ("Connection Failed - status {0}" -f $_version.status)
                Write-Verbose ("Response: {0}" -f $_version.Response)
                Write-Verbose ("Data: {0}" -f $_version.Data)
                return $false
            }
        }
        else {
            $this.connected = $false
            return $false
        }
    }

}