#
# xSqlAvailabilityGroupListener: DSC resource that configures a SQL AlwaysOn Availability Group Listener.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $AvailabilityGroupName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DomainNameFqdn,

        [String] $ListenerIPAddress,

        [UInt32] $ListenerPortNumber = 1433,

        [UInt32] $ProbePortNumber = 59999,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $bConfigured = Test-TargetResource -Name $Name -AvailabilityGroupName $AvailabilityGroupName -DomainNameFqdn $DomainNameFqdn -ListenerPortNumber $ListenerPortNumber -ProbePortNumber $ProbePortNumber -InstanceName  $InstanceName -DomainCredential $DomainCredential -SqlAdministratorCredential $SqlAdministratorCredential

    $returnValue = @{
        Name = $Name
        AvailabilityGroupName = $AvailabilityGroupName
        DomainNameFqdn = $DomainNameFqdn
        ListenerPortNumber = $ListenerPortNumber
        InstanceName = $InstanceName
        DomainCredential = $DomainCredential.UserName
        SqlAdministratorCredential = $SqlAdministratorCredential.UserName
        Configured = $bConfigured
    }

    $returnValue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $AvailabilityGroupName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DomainNameFqdn,

        [String] $ListenerIPAddress,

        [UInt32] $ListenerPortNumber = 1433,

        [UInt32] $ProbePortNumber = 59999,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    Write-Verbose -Message "Configuring the Availability Group Listener port to '$($ListenerPortNumber)' ..."
    
    Remove-Module SQLPS -ErrorAction SilentlyContinue
    Import-Module SQLPS -MinimumVersion 14.0

    Write-Verbose -Message "Stopping cluster resource '$($AvailabilityGroupName)' ..."
    Stop-ClusterResource -Name $AvailabilityGroupName -ErrorAction SilentlyContinue | Out-Null

    if (!(Get-ClusterResource $Name -ErrorAction Ignore))
    {
        Write-Verbose -Message "Creating Network Name resource '$($Name)' ..."
        $params= @{
            Name = $Name
            DnsName = $Name
        }
        Add-ClusterResource -Name $Name -ResourceType "Network Name" -Group $AvailabilityGroupName -ErrorAction Stop |
            Set-ClusterParameter -Multiple $params -ErrorAction Stop

        Write-Verbose -Message "Setting resource dependency between '$($AvailabilityGroupName)' and '$($Name)' ..."
        Get-ClusterResource -Name $AvailabilityGroupName | Set-ClusterResourceDependency "[$Name]" -ErrorAction Stop
    }

    if (!(Get-ClusterResource "IP Address $ListenerIPAddress" -ErrorAction Ignore))
    {
        Write-Verbose -Message "Creating IP Address resource for '$($ListenerIPAddress)' ..."
        $params = @{
            Address = $ListenerIpAddress
            ProbePort = $ProbePortNumber
            SubnetMask = "255.255.255.255"
            Network = (Get-ClusterNetwork)[0].Name
            OverrideAddressMatch = 1
            EnableDhcp = 0
            }
        Add-ClusterResource -Name "IP Address $ListenerIPAddress" -ResourceType "IP Address" -Group $AvailabilityGroupName -ErrorAction Stop |
            Set-ClusterParameter -Multiple $params -ErrorAction Stop

        Write-Verbose -Message "Setting resource dependency between '$($Name)' and '$($ListenerIpAddress)' ..."
        Get-ClusterResource -Name $Name | Set-ClusterResourceDependency "[IP Address $ListenerIpAddress]" -ErrorAction Stop
    }

    Write-Verbose -Message "Starting cluster resource '$($Name)' ..."
    Start-ClusterResource -Name $Name -ErrorAction Stop | Out-Null

    Write-Verbose -Message "Starting cluster resource '$($AvailabilityGroupName)' ..."
    Start-ClusterResource -Name $AvailabilityGroupName -ErrorAction Stop | Out-Null
    
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $AvailabilityGroupName,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DomainNameFqdn,

        [String[]] $ListenerIPAddress,

        [UInt32] $ListenerPortNumber = 1433,

        [UInt32] $ProbePortNumber = 59999,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $InstanceName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $DomainCredential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    Remove-Module SQLPS -ErrorAction SilentlyContinue
    Import-Module SQLPS -MinimumVersion 14.0

    Write-Verbose -Message "Checking if SQL AG Listener '$($Name)' exists on instance '$($InstanceName)' ..."

    $instance = Get-SqlInstanceName -Node  $env:COMPUTERNAME -InstanceName $InstanceName
    $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential

    $ag = $s.AvailabilityGroups
    $agl = $ag.AvailabilityGroupListeners
    $bRet = $true

    if ($agl)
    {
        Write-Verbose -Message "SQL AG Listener '$($Name)' found."
    }
    else
    {
        Write-Verbose "SQL AG Listener '$($Name)' NOT found."
        $bRet = $false
    }

    return $bRet
}


function Get-SqlServer([string]$InstanceName, [PSCredential]$Credential)
{
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection
    $sc.ServerInstance = $InstanceName
    $sc.ConnectAsUser = $true
    if ($Credential.GetNetworkCredential().Domain -and $Credential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME)
    {
        $sc.ConnectAsUserName = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"
    }
    else
    {
        $sc.ConnectAsUserName = $Credential.GetNetworkCredential().UserName
    }
    $sc.ConnectAsUserPassword = $Credential.GetNetworkCredential().Password
    
    $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc

    $s
}

function Get-SqlInstanceName([string]$Node, [string]$InstanceName)
{
    $pureInstanceName = Get-PureSqlInstanceName -InstanceName $InstanceName
    if ("MSSQLSERVER" -eq $pureInstanceName)
    {
        $Node
    }
    else
    {
        $Node + "\" + $pureInstanceName
    }
}

function Get-PureSqlInstanceName([string]$InstanceName)
{
    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1)
    {
        $list[1]
    }
    else
    {
        "MSSQLSERVER"
    }
}

function Get-SqlAvailabilityGroup([string]$Name, [Microsoft.SqlServer.Management.Smo.Server]$Server)
{
    $s.AvailabilityGroups | where { $_.Name -eq $Name }
}

Export-ModuleMember -Function *-TargetResource
