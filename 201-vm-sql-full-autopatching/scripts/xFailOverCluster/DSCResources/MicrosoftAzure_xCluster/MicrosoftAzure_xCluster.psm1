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

        [string[]] $Nodes
    )

    $ComputerInfo = Get-WmiObject Win32_ComputerSystem
    if (($ComputerInfo -eq $null) -or ($ComputerInfo.Domain -eq $null))
    {
        throw "Can't find machine's domain name."
    }
    
    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
        $cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
        if ($null -eq $cluster)
        {
            throw "Can't find the cluster '$($Name)'."
        }

        $allNodes = @()
        foreach ($node in ($cluster | Get-ClusterNode))
        {
            $allNodes += $node.Name
        }
    }
    finally
    {
        if ($context)
        {
            $context.Undo()
            $context.Dispose()
            CloseUserToken($newToken)
        }
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

        [string[]] $Nodes
    )

    $bCreate = $true

    Write-Verbose -Message "Checking if cluster '$($Name)' is present ..."
    try
    {
        $ComputerInfo = Get-WmiObject Win32_ComputerSystem
        if (($ComputerInfo -eq $null) -or ($ComputerInfo.Domain -eq $null))
        {
            throw "Can't find machine's domain name."
        }

        $cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
        if ($cluster)
        {
            $bCreate = $false
        }
    }
    catch
    {
        $bCreate = $true
    }

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

        if ($bCreate)
        {
            Write-Verbose -Message "Cluster '$($Name)' is NOT present."
            
            $cluster = New-Cluster -Name $Name -Node $env:COMPUTERNAME -NoStorage -Force -ErrorAction Stop
            
            Write-Verbose -Message "Successfully created cluster '$($Name)'."

            # See http://social.technet.microsoft.com/wiki/contents/articles/14776.how-to-configure-windows-failover-cluster-in-azure-for-alwayson-availability-groups.aspx
            # for why the following workaround is necessary.
            Write-Verbose -Message "Stopping the Cluster Name resource ..."
            $clusterGroup = $cluster | Get-ClusterGroup
            $clusterNameRes = $clusterGroup | Get-ClusterResource "Cluster Name"
            $clusterNameRes | Stop-ClusterResource | Out-Null

            Write-Verbose -Message "Stopping the Cluster IP Address resources ..."
            $clusterIpAddrRes = $clusterGroup | Get-ClusterResource | Where-Object { $_.ResourceType.Name -in "IP Address", "IPv6 Address", "IPv6 Tunnel Address" }
            $clusterIpAddrRes | Stop-ClusterResource | Out-Null

            Write-Verbose -Message "Removing all Cluster IP Address resources except the first IPv4 Address ..."
            $firstClusterIpv4AddrRes = $clusterIpAddrRes | Where-Object { $_.ResourceType.Name -eq "IP Address" } | Select-Object -First 1
            $clusterIpAddrRes | Where-Object { $_.Name -ne $firstClusterIpv4AddrRes.Name } | Remove-ClusterResource -Force | Out-Null

            Write-Verbose -Message "Seting the Cluster IP Address to a local link address ..."
            $clusterIpAddrRes | Set-ClusterParameter -Multiple @{
                "Address" = "169.254.1.1"
                "SubnetMask" = "255.255.0.0"
                "EnableDhcp" = 0
                "OverrideAddressMatch" = 1
            } -ErrorAction Stop

            Write-Verbose -Message "Starting the Cluster Name resource ..."
            $clusterNameRes | Start-ClusterResource -ErrorAction Stop | Out-Null

            Write-Verbose -Message "Starting Cluster '$($Name)' ..."
            Start-Cluster -Name $Name -ErrorAction Stop | Out-Null
            (Get-Cluster).SameSubnetThreshold = 20
        }
        $version=[system.environment]::OSVersion.Version
        if (($version.Major -eq 6) -and ($version.Minor -eq 3))
        {
            $nostorage=$true
        }
        else
        {
            $nostorage=$false
        } 
        Write-Verbose -Message "Adding specified nodes to cluster '$($Name)' ..."
        $allNodes = Get-ClusterNode -Cluster $Name
        foreach ($node in $Nodes)
        {
            $foundNode = $allNodes | where-object { $_.Name -eq $node }

            if ($foundNode -and ($foundNode.State -ne "Up"))
            {
                Write-Verbose -Message "Removing node '$($node)' since it's in the cluster but is not UP ..."
                Remove-ClusterNode $foundNode -Cluster $cluster -Force | Out-Null
            }
            elseif ($foundNode)
            {
                Write-Verbose -Message "Node $($node)' already in the cluster, skipping ..."
                continue
            }

            if ( $nostorage)
            {
                $cluster | Add-ClusterNode $node -NoStorage -ErrorAction Stop | Out-Null
                Write-Verbose -Message "Adding node $($node)' to the cluster without storage ..."
           
            }
            else
            {
                Write-Verbose -Message "Adding node $($node)' to the cluster"
                $cluster | Add-ClusterNode $node -ErrorAction Stop | Out-Null
            }
            Write-Verbose -Message "Successfully added node $($node)' to cluster '$($Name)'."
        }
    }
    finally
    {
        if ($context)
        {
            $context.Undo()
            $context.Dispose()
            CloseUserToken($newToken)
        }
    }
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

        [string[]] $Nodes
    )

    $bRet = $false

    Write-Verbose -Message "Checking if cluster '$($Name)' is present ..."
    try
    {

        $ComputerInfo = Get-WmiObject Win32_ComputerSystem
        if (($ComputerInfo -eq $null) -or ($ComputerInfo.Domain -eq $null))
        {
            Write-Verbose -Message "Can't find machine's domain name."
            $bRet = $false
        }
        else
        {
            try
            {
                ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

                $cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
                Write-Verbose -Message "Cluster $($Name)' is present."

                if ($cluster)
                {
                    Write-Verbose -Message "Checking if the expected nodes are in cluster $($Name)' ..."
                    $allNodes = Get-ClusterNode -Cluster $Name
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
            finally
            {    
                if ($context)
                {
                    $context.Undo()
                    $context.Dispose()

                    CloseUserToken($newToken)
                }
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


function Get-ImpersonateLib
{
    if ($script:ImpersonateLib)
    {
        return $script:ImpersonateLib
    }

    $sig = @'
[DllImport("advapi32.dll", SetLastError = true)]
public static extern bool LogonUser(string lpszUsername, string lpszDomain, string lpszPassword, int dwLogonType, int dwLogonProvider, ref IntPtr phToken);

[DllImport("kernel32.dll")]
public static extern Boolean CloseHandle(IntPtr hObject);
'@
   $script:ImpersonateLib = Add-Type -PassThru -Namespace 'Lib.Impersonation' -Name ImpersonationLib -MemberDefinition $sig

   return $script:ImpersonateLib
}

function ImpersonateAs([PSCredential] $cred)
{
    [IntPtr] $userToken = [Security.Principal.WindowsIdentity]::GetCurrent().Token
    $userToken
    $ImpersonateLib = Get-ImpersonateLib

    $bLogin = $ImpersonateLib::LogonUser($cred.GetNetworkCredential().UserName, $cred.GetNetworkCredential().Domain, $cred.GetNetworkCredential().Password, 
    9, 0, [ref]$userToken)

    if ($bLogin)
    {
        $Identity = New-Object Security.Principal.WindowsIdentity $userToken
        $context = $Identity.Impersonate()
    }
    else
    {
        throw "Can't log on as user '$($cred.GetNetworkCredential().UserName)'."
    }
    $context, $userToken
}

function CloseUserToken([IntPtr] $token)
{
    $ImpersonateLib = Get-ImpersonateLib

    $bLogin = $ImpersonateLib::CloseHandle($token)
    if (!$bLogin)
    {
        throw "Can't close token."
    }
}


Export-ModuleMember -Function *-TargetResource
