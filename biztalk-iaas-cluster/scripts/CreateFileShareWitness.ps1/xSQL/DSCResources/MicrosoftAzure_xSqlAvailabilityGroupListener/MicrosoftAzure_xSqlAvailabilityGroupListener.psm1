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
        ProbePortNumber = $ProbePortNumber
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

    $instance = Get-SqlInstanceName -Node  $env:COMPUTERNAME -InstanceName $InstanceName
    $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential

    $Stoploop = $false
    $Retrycount = 0

    if ($ListenerIPAddress) {

        Write-Verbose -Message "The assigned Listener public IP address is '$($ListenerIPAddress)'"

        $publicIpAddress = $ListenerIPAddress
        
    }
    else {

        do {
            try {
                $publicIpAddress = ([System.Net.DNS]::GetHostAddresses($DomainNameFqdn)).IPAddressToString
                Write-Verbose -Message "Got Listener public IP address ..'$($publicIpAddress)'"
                $Stoploop = $true
            }
            catch {
                if ($Retrycount -gt 20){
                    Write-Host "Could not Get Host Addresses after 20 retrys."
                    $Stoploop = $true
                }
                else {
                    Write-Host "Could not Get Host Addresses retrying in 60 seconds..."
                    Start-Sleep -Seconds 60
                    $Retrycount = $Retrycount + 1
                }
            }
        }
        While ($Stoploop -eq $false)

    }

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainCredential

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

        if (!(Get-ClusterResource "IP Address $publicIpAddress" -ErrorAction Ignore))
        {
            Write-Verbose -Message "Creating IP Address resource for '$($publicIpAddress)' ..."
            $params = @{
                Address = $publicIpAddress
                ProbePort = $ProbePortNumber
                SubnetMask = "255.255.255.255"
                Network = (Get-ClusterNetwork)[0].Name
                OverrideAddressMatch = 1
                EnableDhcp = 0
                }
            Add-ClusterResource -Name "IP Address $publicIpAddress" -ResourceType "IP Address" -Group $AvailabilityGroupName -ErrorAction Stop |
                Set-ClusterParameter -Multiple $params -ErrorAction Stop

            Write-Verbose -Message "Setting resource dependency between '$($Name)' and '$($publicIpAddress)' ..."
            Get-ClusterResource -Name $Name | Set-ClusterResourceDependency "[IP Address $publicIpAddress]" -ErrorAction Stop
        }

        Write-Verbose -Message "Starting cluster resource '$($Name)' ..."
        Start-ClusterResource -Name $Name -ErrorAction Stop | Out-Null

        Write-Verbose -Message "Starting cluster resource '$($AvailabilityGroupName)' ..."
        Start-ClusterResource -Name $AvailabilityGroupName -ErrorAction Stop | Out-Null
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

    Write-Verbose -Message "Setting the Availability Group Listener port to '$($ListenerPortNumber)' ..."
    $ag = Get-SqlAvailabilityGroup -Name $AvailabilityGroupName -Server $s
    $agListener = $ag.AvailabilityGroupListeners | where { $_.Name -eq $Name }
    $agListener.PortNumber = $ListenerPortNumber
    $agListener.Alter()
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

    Write-Verbose -Message "Checking if SQL AG '$($AvailabilityGroupName)' exists on instance '$($InstanceName)' ..."

    $instance = Get-SqlInstanceName -Node  $env:COMPUTERNAME -InstanceName $InstanceName
    $s = Get-SqlServer -InstanceName $instance -Credential $SqlAdministratorCredential

    $ag = Get-SqlAvailabilityGroup -Name $AvailabilityGroupName -Server $s
    if ($ag)
    {
        Write-Verbose -Message "SQL AG '$($AvailabilityGroupName)' found."
    }
    else
    {
        throw "SQL GA '$($AvailabilityGroupName)' NOT found."
    }

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainCredential

        Write-Verbose -Message "Checking if Network Name resource '$($Name)' exists ..."
        if (Get-ClusterResource $Name -ErrorAction Ignore)
        {
            Write-Verbose -Message "Network Name resource '$($Name)' found."
        }
        else
        {
            Write-Verbose -Message "Network Name resource '$($Name)' NOT found."
            return $false
        }

        $publicIpAddress = ([System.Net.DNS]::GetHostAddresses($DomainNameFqdn)).IPAddressToString
        Write-Verbose -Message "Checking if IP Address resource for '$($publicIpAddress)' exists ..."
        if (Get-ClusterResource "IP Address $publicIpAddress" -ErrorAction Ignore)
        {
            Write-Verbose -Message "IP Address resource 'IP Address $($publicIpAddress)' found."
        }
        else
        {
            Write-Verbose -Message "IP Address resource 'IP Address $($publicIpAddress)' NOT found."
            return $false
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

    return $true
}


function Get-SqlServer([string]$InstanceName, [PSCredential]$Credential)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
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
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
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
