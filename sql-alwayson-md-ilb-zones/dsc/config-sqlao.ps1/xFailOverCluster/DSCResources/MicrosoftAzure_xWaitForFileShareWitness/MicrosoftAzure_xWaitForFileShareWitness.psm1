#
# xWaitForFileShareWitness: DSC Resource that will wait for the specified
# quorum file share. It checks the availability of the file share witness for
# the specified interval until the cluster is found or the maximum number of
# retries is reached.
#

function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    @{
        SharePath = $SharePath
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
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    $fileShareFound = $false
    Write-Verbose -Message "Checking for file share '$($SharePath)' ..."

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

        for ($count = 0; $count -lt $RetryCount; $count++)
        {
            if (Test-Path $SharePath -PathType Container -ErrorAction Ignore)
            {
                Write-Verbose -Message "Found file share '$($SharePath)'."
                $fileShareFound = $true
                break;
            }

            Write-Verbose -Message "File share '$($SharePath)' not found."
            Write-Verbose -Message "Retrying in $RetryIntervalSec seconds ..."
            Start-Sleep -Seconds $RetryIntervalSec
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

    if (!$fileShareFound)
    {
        throw "File share '$($SharePath)' NOT found after $RetryCount attempts."
    }
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [string] $SharePath,

        [parameter(Mandatory)]
        [PSCredential] $DomainAdministratorCredential,

        [UInt32] $RetryIntervalSec = 10,

        [UInt32] $RetryCount = 50
    )

    Write-Verbose -Message "Checking for file share '$($SharePath)' ..."

    try
    {
        ($oldToken, $context, $newToken) = ImpersonateAs -cred $DomainAdministratorCredential

        if (Test-Path $SharePath -PathType Container -ErrorAction Ignore)
        {
            Write-Verbose -Message "Found file share '$($SharePath)'."
            $true
        }
        else
        {
            Write-Verbose -Message "File share '$($SharePath)' NOT found."
            $false
        }
    }
    catch
    {
        Write-Verbose -Message "Error testing file share '$($SharePath)'."
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
