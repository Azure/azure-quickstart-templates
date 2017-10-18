#
# xCluster: DSC resource to configure the quorum type for a Windows Failover
# Cluster. Note that this resource only supports configuring node and file
# share majority type.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential
    )

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
        $quorum = Get-Cluster -Name $Name | Get-ClusterQuorum
        if ($quorum.QuorumResource)
        {
            $SharePath = $quorum.QuorumResource | Get-ClusterParameter "SharePath" | Select-Object -ExpandProperty Value
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

    @{
        Name = $Name
        SharePath = $SharePath
        DomainAdministratorCredential = $DomainAdministratorCredential
    }
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential
    )

    try
    {
        Write-Verbose -Message "Setting cluster quorum for cluster '$($Name)' to node and file share majority type ..."
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
        Get-Cluster -Name $Name | Set-ClusterQuorum -NodeAndFileShareMajority $SharePath | Out-Null
        Write-Verbose -Message "Successfully configured cluster quorum for cluster '$($Name)'."
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

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential
    )

    $bRet = $false

    try
    {
        Write-Verbose -Message "Checking the cluster quorum for cluster '$($Name)' ..."
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
        $quorum = Get-Cluster -Name $Name | Get-ClusterQuorum

        if ($quorum)
        {
            if ($quorum.QuorumType -eq [Microsoft.FailoverClusters.PowerShell.ClusterQuorumType]::NodeAndFileShareMajority)
            {
                Write-Verbose -Message "Cluster quorum for cluster '$($Name)' is already set to node and file share majority type."
                $bRet = $true
            }
            else
            {
                Write-Verbose -Message "Cluster quorum for cluster '$($Name)' is NOT set to node and file share majority type."
                Write-Verbose -Message "Current setting: $($quorum.QuorumType)"
            }
        }
    }
    catch
    {
        Write-Verbose -Message "Error testing for cluster quorum for cluster '$($Name)'."
        throw $_
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
