#
# xWaitForCluster: DSC Resource that will wait for the specified Cluster. It
# checks the state of the cluster for the specified interval until the cluster
# is found or the maximum number of retries is reached.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    @{
        Name = $Name
        DomainAdministratorCredential = $DomainAdministratorCredential
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
    }
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    $clusterFound = $false
    Write-Verbose -Message "Checking for cluster '$($Name)' ..."

    for ($count = 0; $count -lt $RetryCount; $count++)
    {
        try
        {
            ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential
            $ComputerInfo = Get-WmiObject Win32_ComputerSystem
            if (($ComputerInfo -eq $null) -or ($ComputerInfo.Domain -eq $null))
            {
                Write-Verbose -Message "Can't find machine's domain name."
                break;
            }

            $cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain

            if ($cluster -ne $null)
            {
                Write-Verbose -Message "Found cluster '$($Name)'."
                $clusterFound = $true

                break;
            }
            
        }
        catch
        {
            Write-Verbose -Message "Cluster '$($Name)' not found."
            Write-Verbose -Message "Retrying in $RetryIntervalSec seconds ..."
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

        Write-Verbose -Message "Cluster '$($Name)' not found."
        Write-Verbose -Message "Retrying in $RetryIntervalSec seconds ..."
        Start-Sleep -Seconds $RetryIntervalSec
    }

    if (!$clusterFound)
    {
        throw "Cluster '$($Name)' NOT found after $RetryCount attempts."
    }
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $Name,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    Write-Verbose -Message "Checking for cluster '$($Name)' ..."

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

        $ComputerInfo = Get-WmiObject Win32_ComputerSystem
        if (($ComputerInfo -eq $null) -or ($ComputerInfo.Domain -eq $null))
        {
            throw "Can't find machine's domain name."
        }

        $cluster = Get-Cluster -Name $Name -Domain $ComputerInfo.Domain
        if ($cluster -eq $null)
        {
            Write-Verbose -Message "Cluster '$($Name)' not found in domain '$($ComputerInfo.Domain)'."
            $false
        }
        else
        {
            Write-Verbose -Message "Found cluster '$($Name)'."
            $true
        }
    }
    catch
    {
        Write-Verbose -Message "Error testing cluster '$($Name)'."
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
