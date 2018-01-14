#
# xCluster: DSC resource to configure a Windows Failover Cluster. If the
# cluster does not exist, it will create one in the domain and assign a local
# link address to the cluster. Then, it will add all specified nodes to the
# cluster.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [string[]] $Nodes,

        [string[]] $ClusterIPAddresses
    )

    $cluster = Get-Cluster -Name . -ErrorAction SilentlyContinue
    
    if ($null -eq $cluster)
    {
        throw "Can't find the cluster '$($Name)'."
    }

    $allNodes = @()

    foreach ($node in ($cluster | Get-ClusterNode -ErrorAction SilentlyContinue))
    {
        $allNodes += $node.Name
    }

    $retvalue = @{
        Name = $Name
        Nodes = $allNodes
    }

    $retvalue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [string[]] $Nodes,

        [string[]] $ClusterIPAddresses 
    )

    $bCreate = $true

    if ($bCreate)
    { 
        $cluster = CreateFailoverCluster -ClusterName $Name -StaticAddress $ClusterIPAddresses[0]
    }

    Start-Sleep -Seconds 5    

    $nostorage=$true
        
    Write-Verbose -Message "Adding specified nodes to cluster '$($Name)' ..."
        
    #Add Nodes to cluster

    $allNodes = @()
    
    While (!$allNodes) {

        Start-Sleep -Seconds 30

        Write-Verbose -Message "Finding nodes in cluster '$($Name)' ..."

        $allNodes = Get-ClusterNode -Cluster $Name -ErrorAction SilentlyContinue

    }

    Write-Verbose -Message "Existing nodes found in cluster '$($Name)' are: $($allNodes) ..."
    
    Write-Verbose -Message "Adding specified nodes to cluster '$($Name)' ..."

    foreach ($node in $Nodes)
    {
        $foundNode = $allNodes | where-object { $_.Name -eq $node }

        if ($foundNode -and ($foundNode.State -ne "Up"))
        {
            Write-Verbose -Message "Removing node '$($node)' since it's in the cluster but is not UP ..."
            
            Remove-ClusterNode $foundNode -Cluster $Name -Force | Out-Null

            AddNodeToCluster -ClusterName $Name -NodeName $node -Nostorage $nostorage

            continue
        }
        elseif ($foundNode)
        {
            Write-Verbose -Message "Node '$($node)' already in the cluster, skipping ..."

            continue
        }

        AddNodeToCluster -ClusterName $Name -NodeName $node -Nostorage $nostorage

    }
   
    # Set Cluster IP Addresses

    Start-Sleep -Seconds 5

    $clusterGroup = $cluster | Get-ClusterGroup

    $clusterIpAddrRes = $clusterGroup | Get-ClusterResource | Where-Object { $_.ResourceType.Name -in "IP Address", "IPv6 Address", "IPv6 Tunnel Address" }

    Write-Verbose -Message "Removing all Cluster IP Address resources except the first IPv4 Address ..."
    
    $firstClusterIpv4AddrRes = $clusterIpAddrRes | Where-Object { $_.ResourceType.Name -eq "IP Address" } | Select-Object -First 1
    
    $clusterIpAddrRes | Where-Object { $_.Name -ne $firstClusterIpv4AddrRes.Name } | Remove-ClusterResource -Force | Out-Null

    Write-Verbose -Message "Adding new Cluster IP Address resources ..."

    $clusterResourceDependencyExpr = "([$($firstClusterIpv4AddrRes.Name)])"

    $subnetMask=(Get-ClusterNetwork)[0].AddressMask

    for ($count=1; $count -le $ClusterIPAddresses.Length - 1; $count++) {

        $newClusterIpv4AddrResName = "Cluster IP Address $($ClusterIPAddresses[$count])"

        Write-Verbose -Message "Adding $newClusterIpv4AddrRes ..."

        Add-ClusterResource -Name $newClusterIpv4AddrResName -Group "Cluster Group" -ResourceType "IP Address" 

        $newClusterIpv4AddrRes = Get-ClusterResource -Name $newClusterIpv4AddrResName

        Write-Verbose -Message "Updating properties for $newClusterIpv4AddrRes ..."

        Start-Sleep -Seconds 5

        $newClusterIpv4AddrRes |
        Set-ClusterParameter -Multiple @{
                                "Address" = $ClusterIPAddresses[$count]
                                "SubnetMask" = $subnetMask
                                "EnableDhcp" = 0
                            }

        $newClusterIpv4AddrRes | Start-ClusterResource
        
        $clusterResourceDependencyExpr += " and ([$newClusterIpv4AddrResName])"

    }

    # Set Cluster Resource Dependencies

    Write-Verbose -Message "Setting dependency on Cluster Name resource for IP Addresses ..."

    Set-ClusterResourceDependency -Resource "Cluster Name" -Dependency $clusterResourceDependencyExpr
    
}

#
# The Test-TargetResource function will check the following (in order):
# 1. Is the machine in a domain?
# 2. Does the cluster exist in the domain?
# 3. Are the expected nodes in the cluster's nodelist, and are they all up?
#
# This will return FALSE if any of the above is not true, which will cause
# the cluster to be configured.
#
function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [string[]] $Nodes,

        [string[]] $ClusterIPAddresses
    )

    $bRet = $false
    
    Write-Verbose -Message "Checking if cluster '$($Name)' is present ..."
    try
        {
            $cluster = Get-Cluster -Name . -ErrorAction SilentlyContinue
            
            if ($cluster)
            {
                Write-Verbose -Message "Cluster $($Name)' is present."
                Write-Verbose -Message "Checking if the expected nodes are in cluster $($Name)' ..."

                $allNodes = @()

                While (!$allNodes) {

                    Start-Sleep -Seconds 30

                    Write-Verbose -Message "Finding nodes in cluster '$($Name)' ..."

                    $allNodes = Get-ClusterNode -Cluster . -ErrorAction SilentlyContinue

                }

                Write-Verbose -Message "Existing nodes found in cluster '$($Name)' are: $($allNodes) ..."

                $bRet = $true
                foreach ($node in $Nodes)
                {
                    $foundNode = $allNodes | where-object { $_.Name -eq $node }

                    if (!$foundNode)
                    {
                        Write-Verbose -Message "Node '$($node)' NOT found in the cluster."
                        $bRet = $bRet -and $false
                    }
                    elseif ($foundNode.State -ne "Up")
                    {
                        Write-Verbose -Message "Node '$($node)' found in the cluster, but is not UP."
                        $bRet = $bRet -and $false
                    }
                    else
                    {
                        Write-Verbose -Message "Node '$($node)' found in the cluster."
                        $bRet = $bRet -and $true
                    }
                }

                if ($bRet)
                {
                    Write-Verbose -Message "All expected nodes found in cluster $($Name)."
                }
                else
                {
                    Write-Verbose -Message "At least one node is missing from cluster $($Name)."
                }
            }
        }
        catch
        {
            Write-Verbose -Message "Error testing cluster $($Name)."
            throw $_
        }

        $bRet
}

function AddNodeToCluster
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$NodeName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Bool]$Nostorage,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ClusterName
    )

    
    $RetryCounter = 0

    While ($true) {
        
        try {
            
            if ($Nostorage)
            {
               Write-Verbose -Message "Adding node $($node)' to the cluster without storage ..."
                
               Add-ClusterNode -Cluster $ClusterName -Name $NodeName -NoStorage -ErrorAction Stop | Out-Null
           
            }
            else
            {
               Write-Verbose -Message "Adding node $($node)' to the cluster"
                
               Add-ClusterNode -Cluster $ClusterName -Name $NodeName -ErrorAction Stop | Out-Null

            }

            Write-Verbose -Message "Successfully added node $($node)' to cluster '$($Name)'."

            return $true
        }
        catch [System.Exception] 
        {
            $RetryCounter = $RetryCounter + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($RetryCounter)' times"
            
            if ($RetryCounter -eq 10) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($RetryCounter)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 5

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($RetryCounter)' times"
        }
    }
}

function CreateFailoverCluster
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$ClusterName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$StaticAddress
    )

    $RetryCounter = 0

    While ($true) {
        
        try {
            
            Write-Verbose -Message "Creating Cluster '$($Name)'."
            
            $cluster = New-Cluster -Name $ClusterName -Node $env:COMPUTERNAME -StaticAddress $StaticAddress -NoStorage -Force -ErrorAction Stop
    
            Write-Verbose -Message "Successfully created cluster '$($Name)'."

            return $cluster
        }
        catch [System.Exception] 
        {
            $RetryCounter = $RetryCounter + 1
            
            $ErrorMSG = "Error occured: '$($_.Exception.Message)', failed after '$($RetryCounter)' times"
            
            if ($RetryCounter -eq 10) 
            {
                Write-Verbose "Error occured: $ErrorMSG, reach the maximum re-try: '$($RetryCounter)' times, exiting...."

                Throw $ErrorMSG
            }

            start-sleep -seconds 5

            Write-Verbose "Error occured: $ErrorMSG, retry for '$($RetryCounter)' times"
        }
    }
}

Export-ModuleMember -Function *-TargetResource
