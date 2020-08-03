[Flags()] enum incidentorder {
    call_dateasc = 1
    call_datedes = 2
    creation_dateasc = 4
    creation_datedes = 8
    modification_dateasc = 16
    modification_datedes = 32
    target_dateasc = 64
    target_datedes = 128
    closed_dateasc = 256
    closed_datedes = 512
}

function Get-IncidentList {
    [CmdletBinding(PositionalBinding = $false,
        DefaultParameterSetName = 'Default',
        ConfirmImpact = 'Low')]
    [OutputType([psobject])]
    param (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The offset at which to start listing the incidents at. Default value: 0')]
        [ValidateNotNullOrEmpty()]
        [int]
        $start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The amount of incidents to be returned per request. Default value: 10. Allowed values: 1-10000')]
        [ValidateRange(1, 1000)]
        [int]
        $page_size,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Order the retrieved incidents by these criteria: call_date, creation_date, modification_date, target_date, closed_date ascending or descending.')]
        [incidentorder]
        $order_by,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are completed / not completed')]
        [bool]
        $completed,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are closed / not closed')]
        [bool]
        $closed,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are resolved depending on the setting "Call is resolved when" (Module Settings -> Call Management -> General)')]
        [bool]
        $resolved,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are major calls / not major calls.Retrieve only incidents that are major calls / not major calls.')]
        [bool]
        $major_call,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Whether to return archived incidents. Default value: false.')]
        [bool]
        $archived,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with target date greater or equal to this day 00:00:00.')]
        [datetime]
        $target_date_start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with target date smaller or equal to this day 23:59:59.')]
        [datetime]
        $target_date_end,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with call date greater or equal to this day 00:00:00.')]
        [datetime]
        $call_date_start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with call date smaller or equal to this day 23:59:59.')]
        [datetime]
        $call_date_end,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with creation date greater or equal to this day 00:00:00.')]
        [datetime]
        $creation_date_start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with creation date smaller or equal to this day 23:59:59.')]
        [datetime]
        $creation_date_end,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with modification date greater or equal to this day 00:00:00.')]
        [datetime]
        $modification_date_start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with modification date smaller or equal to this day 23:59:59.')]
        [datetime]
        $modification_date_end,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with closed date greater or equal to this day 00:00:00.')]
        [datetime]
        $closed_date_start,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with closed date smaller or equal to this day 23:59:59.')]
        [datetime]
        $closed_date_end,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Return only specified fields. The fields are a comma separated list. A field can also contain sub entities (e.g caller.id).')]
        [string[]]
        $fields,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents reported by one of these caller ids.')]
        [string[]]
        $caller,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents assigned to one of these operator group ids or "unassigned" for unassigned incidents.')]
        [string[]]
        $operator_group,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents assigned to one of these operator ids or "unassigned" for unassigned incidents.')]
        [string[]]
        $operator,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with one of these processing status ids.')]
        [string[]]
        $processing_status,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that have one of these main incident ids. Overrides any status filter as only partials have main incidents.')]
        [string[]]
        $main_incident,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only firstLine/secondLine/partial incidents.')]
        [ValidateSet('firstLine', 'secondLine', 'partial')]
        [string[]]
        $status,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents reported by callers from one of these branch ids.')]
        [string[]]
        $caller_branch,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that have one of the specified objects set (by id).')]
        [string[]]
        $object_id,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that have one of the specified objects set (by object name).')]
        [string[]]
        $object_name,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are linked to one of the specified objects (by id).')]
        [string[]]
        $linked_object_id,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents that are linked to one of the specified objects (by object name).')]
        [string[]]
        $linked_object_name,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with external link id equal to one of these values. Should be used in combination with external_link_type.')]
        [string[]]
        $external_link_id,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve only incidents with external link type equal to one of these values. Should be used in combination with external_link_id.')]
        [string[]]
        $external_link_type,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve one or more incidents with the given ids, make sure "page_size" is set accordingly to get all results.')]
        [string[]]
        $id,
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Retrieve one or more incidents with the given external numbers.')]
        [string[]]
        $external_number
    )
    
    begin {
        [hashtable]$_headerslist = @{
            'Content-Type' = 'application/json'
        }
        [string]$_endpoint = 'incidents?'
    }
    
    process {
        foreach ($item in $PSBoundParameters.Keys) {
            switch ($item) {
                'start' {
                    $_endpoint += '&start=' + $start
                    break
                }
                'page_size' {
                    $_endpoint += '&page_size=' + $page_size
                    break
                }
                'order_by' {
                    $_endpoint += '&order_by='
                    $orderstring = ''
                    foreach ($item in ($order_by -split (','))) {
                        $newitem = $item.Substring(0, $($item.Length) - 3).Trim()
                        $neworder = $item.Substring($($item.Length) - 3, 3)
                        if ($neworder -eq 'des') {
                            $neworder = 'desc'
                        }
                        $orderstring += $newitem + '+' + $neworder + ','
                    }
                    $_endpoint += ($orderstring -replace ".$")
                    break
                }
                'completed' {
                    $_endpoint += '&completed=' + $completed
                    break
                }
                'closed' {
                    $_endpoint += '&closed=' + $closed
                    break
                }
                'resolved' {
                    $_endpoint += '&resolved=' + $resolved
                    break
                }
                'major_call' {
                    $_endpoint += '&major_call=' + $major_call
                    break
                }
                'archived' {
                    $_endpoint += '&archived=' + $archived
                    break
                }
                'target_date_start' {
                    $_endpoint += '&target_date_start=' + $target_date_start.ToString("yyyy-MM-dd")
                    break
                }
                'target_date_end' {
                    $_endpoint += '&target_date_end=' + $target_date_end.ToString("yyyy-MM-dd")
                    break
                }
                'call_date_start' {
                    $_endpoint += '&call_date_start=' + $call_date_start.ToString("yyyy-MM-dd")
                    break
                }
                'call_date_end' {
                    $_endpoint += '&call_date_end=' + $call_date_end.ToString("yyyy-MM-dd")
                    break
                }
                'creation_date_start' {
                    $_endpoint += '&creation_date_start=' + $creation_date_start.ToString("yyyy-MM-dd")
                    break
                }
                'creation_date_end' {
                    $_endpoint += '&creation_date_end=' + $creation_date_end.ToString("yyyy-MM-dd")
                    break
                }
                'modification_date_start' {
                    $_endpoint += '&modification_date_start=' + $modification_date_start.ToString("yyyy-MM-dd")
                    break
                }
                'modification_date_end' {
                    $_endpoint += '&modification_date_end=' + $modification_date_end.ToString("yyyy-MM-dd")
                    break
                }
                'closed_date_start' {
                    $_endpoint += '&closed_date_start=' + $closed_date_start.ToString("yyyy-MM-dd")
                    break
                }
                'closed_date_end' {
                    $_endpoint += '&closed_date_end=' + $closed_date_end.ToString("yyyy-MM-dd")
                    break
                }
                'fields' {
                    $_endpoint += '&fields=' + ($fields -join ',')
                    break
                }
                'caller' {
                    foreach ($item in $caller) {
                        $_endpoint += '&caller=' + $item
                    }
                    break
                }
                'operator_group' {
                    foreach ( $item in $operator_group) {
                        $_endpoint += '&operator_group=' + $item
                    }
                    break
                }
                'operator' {
                    foreach ( $item in $operator) {
                        $_endpoint += '&operator=' + $item
                    }
                    break
                }
                'processing_status' {
                    foreach ( $item in $processing_status) {
                        $_endpoint += '&processing_status=' + $item
                    }
                    break
                }
                'main_incident' {
                    foreach ( $item in $main_incident) {
                        $_endpoint += '&main_incident_id=' + $item
                    }
                    break
                }
                'status' {
                    foreach ( $item in $status ) {
                        $_endpoint += '&status=' + $status
                    }
                }
                'caller_branch' {
                    foreach ( $item in $caller_branch) {
                        $_endpoint += '&caller_branch=' + $item
                    }
                    break
                }
                'object_id' {
                    foreach ( $item in $object_id) {
                        $_endpoint += '&object_id=' + $item
                    }
                    break
                }
                'linked_object_id' {
                    foreach ( $item in $linked_object_id) {
                        $_endpoint += '&linked_object_id=' + $item
                    }
                    break
                }
                'linked_object_name' {
                    foreach ( $item in $linked_object_name) {
                        $_endpoint += '&linked_object_name=' + $item
                    }
                    break
                }
                'external_link_id' {
                    foreach ( $item in $external_link_id) {
                        $_endpoint += '&external_link_id=' + $item
                    }
                    break
                }
                'external_link_type' {
                    foreach ( $item in $external_link_type) {
                        $_endpoint += '&external_link_type=' + $item
                    }
                    break
                }
                'id' {
                    foreach ( $item in $id) {
                        $_endpoint += '&id=' + $item
                    }
                    break
                }
                'external_number' {
                    foreach ( $item in $external_number) {
                        $_endpoint += '&external_number=' + $item
                    }
                    break
                }
            }
        }
        if($_endpoint.EndsWith('?')) {
            $_endpoint = $_endpoint.Substring(0,($_endpoint.Length)-1)
        }
        Write-Warning ("Endpoint: {0}" -f $_endpoint)
        $IncidentList = Get-APIResponse -Method GET -Endpoint $_endpoint -Headers $_headerslist -Verbose
        if(($null -ne $IncidentList) -and (($IncidentList.StatusCode -eq 200) -or ($IncidentList.StatusCode -eq 206))) {
            return $IncidentList.Data
        } else {
            return "Status: $($IncidentList.Status) Response: $($IncidentList.Response) StatusCode: $($IncidentList.StatusCode)"
        }
    }
    
    end {
        
    }
}