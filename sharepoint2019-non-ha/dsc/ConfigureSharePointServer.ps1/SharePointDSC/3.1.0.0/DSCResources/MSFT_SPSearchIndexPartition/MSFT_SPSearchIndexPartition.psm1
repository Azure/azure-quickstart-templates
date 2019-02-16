function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.UInt32]    
        $Index,
        
        [Parameter(Mandatory = $true)]  
        [System.String[]]  
        $Servers,
        
        [Parameter()] 
        [System.String]
        $RootDirectory,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting Search Index Partition '$Index' settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]
        $ConfirmPreference = 'None'

        $ssa = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName      
        $currentTopology = $ssa.ActiveTopology
        
        $searchComponent = Get-SPEnterpriseSearchComponent -SearchTopology $currentTopology | `
                                Where-Object -FilterScript {
                                    ($_.GetType().Name -eq "IndexComponent") `
                                    -and ($_.IndexPartitionOrdinal -eq $params.Index) 
                                }
        
        $IndexComponents = $searchComponent.ServerName
        $rootDirectory = $searchComponent.RootDirectory

        if ($rootDirectory -eq "")
        {
            $ssi = Get-SPEnterpriseSearchServiceInstance
            $component = $ssi.Components | Select-Object -First 1
            $rootDirectory = $component.IndexLocation
        }

        return @{
            Index = $params.Index
            Servers = $IndexComponents
            RootDirectory = $rootDirectory
            ServiceAppName = $params.ServiceAppName
            InstallAccount = $params.InstallAccount
        }
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.UInt32]    
        $Index,
        
        [Parameter(Mandatory = $true)]  
        [System.String[]]  
        $Servers,
        
        [Parameter()] 
        [System.String]
        $RootDirectory,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting Search Index Partition '$Index' settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments @($PSBoundParameters, $CurrentValues) `
                        -ScriptBlock {
        $params = $args[0]
        $CurrentValues = $args[1]
        $ConfirmPreference = 'None'

        $AllSearchServers = $params.Servers

        # Ensure the search service instance is running on all servers
        foreach($searchServer in $AllSearchServers) 
        {
            $searchService = Get-SPEnterpriseSearchServiceInstance -Identity $searchServer
            if($searchService.Status -eq "Offline") 
            {
                Write-Verbose -Message "Start Search Service Instance"
                Start-SPEnterpriseSearchServiceInstance -Identity $searchService
            }

            #Wait for Search Service Instance to come online
            $loopCount = 0
            $online = Get-SPEnterpriseSearchServiceInstance -Identity $searchServer 
            do 
            {
                $online = Get-SPEnterpriseSearchServiceInstance -Identity $searchServer 
                Write-Verbose -Message "Waiting for service: $($online.TypeName)"
                $loopCount++
                Start-Sleep -Seconds 30
            } 
            until ($online.Status -eq "Online" -or $loopCount -eq 20)
        }

        if ($params.ContainsKey("RootDirectory") -eq $true) 
        {
            # Create the index partition directory on each remote server
            foreach($IndexPartitionServer in $params.Servers) 
            {
                $networkPath = "\\$IndexPartitionServer\" + $params.RootDirectory.Replace(":\", "$\")
                New-Item -Path $networkPath -ItemType Directory -Force
            }

            # Create the directory on the local server as it will not apply the topology without it
            if ((Test-Path -Path $params.RootDirectory) -eq $false) 
            {
                New-Item $params.RootDirectory -ItemType Directory -Force
            }
        }
        
        # Get all service service instances to assign topology components to
        $AllSearchServiceInstances = @{}
        foreach ($server in $AllSearchServers) 
        {
            $si = Get-SPEnterpriseSearchServiceInstance -Identity $server
            $AllSearchServiceInstances.Add($server, $si)
        }

        # Get current topology and prepare a new one
        $ssa = Get-SPEnterpriseSearchServiceApplication -Identity $params.ServiceAppName
        $currentTopology = $ssa.ActiveTopology
        $newTopology = New-SPEnterpriseSearchTopology -SearchApplication $ssa `
                                                      -Clone `
                                                      -SearchTopology $currentTopology

        $componentTypes = @{
            Servers = "IndexComponent"
        }

        # Build up the topology changes for each object type
        @("Servers") | ForEach-Object -Process {
            $CurrentSearchProperty = $_
            Write-Verbose -Message "Setting components for '$CurrentSearchProperty' property"

            if ($null -eq $CurrentValues.$CurrentSearchProperty) 
            {
                $ComponentsToAdd = $params.$CurrentSearchProperty
            } 
            else 
            {
                $ComponentsToAdd = @()
                $ComponentsToRemove = @()

                $components = $params.$CurrentSearchProperty | Where-Object -FilterScript {
                    $CurrentValues.$CurrentSearchProperty.Contains($_) -eq $false 
                }
                foreach($component in $components) 
                {
                    $ComponentsToAdd += $component
                }
                $components = $CurrentValues.$CurrentSearchProperty | Where-Object -FilterScript {
                    $params.$CurrentSearchProperty.Contains($_) -eq $false 
                }
                foreach($component in $components) 
                {
                    $ComponentsToRemove += $component
                }
            }
            foreach($componentToAdd in $ComponentsToAdd) 
            {
                $NewComponentParams = @{
                    SearchTopology = $newTopology
                    SearchServiceInstance = $AllSearchServiceInstances.$componentToAdd
                }
                switch($componentTypes.$CurrentSearchProperty) 
                {
                    "IndexComponent" {
                        $NewComponentParams.Add("IndexPartition", $params.Index)
                        if ($params.ContainsKey("RootDirectory") -eq $true) 
                        {
                            if ([string]::IsNullOrEmpty($params.RootDirectory) -eq $false) 
                            {
                                $NewComponentParams.Add("RootDirectory", $params.RootDirectory)
                            }
                        }
                        New-SPEnterpriseSearchIndexComponent @NewComponentParams
                    }
                }
            }
            foreach($componentToRemove in $ComponentsToRemove) 
            {
                $component = Get-SPEnterpriseSearchComponent -SearchTopology $newTopology | `
                    Where-Object -FilterScript {
                        ($_.GetType().Name -eq $componentTypes.$CurrentSearchProperty) `
                            -and ($_.ServerName -eq $componentToRemove) `
                            -and ($_.IndexPartitionOrdinal -eq $params.Index)
                }
                if ($null -ne $component) 
                {
                    $component | Remove-SPEnterpriseSearchComponent -SearchTopology $newTopology `
                                                                    -Confirm:$false
                }
        
            }
        }

        # Apply the new topology
        Set-SPEnterpriseSearchTopology -Identity $newTopology
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.UInt32]    
        $Index,
        
        [Parameter(Mandatory = $true)]  
        [System.String[]]  
        $Servers,
        
        [Parameter()] 
        [System.String]
        $RootDirectory,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $ServiceAppName,
        
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing Search Index Partition '$Index' settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                              -DesiredValues $PSBoundParameters `
                                              -ValuesToCheck @("Servers")
}

Export-ModuleMember -Function *-TargetResource
