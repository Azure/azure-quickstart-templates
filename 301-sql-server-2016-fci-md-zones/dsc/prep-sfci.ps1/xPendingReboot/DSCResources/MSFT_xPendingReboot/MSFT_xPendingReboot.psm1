Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter()]
    [bool]$SkipCcmClientSDK
    )

    $ComponentBasedServicingKeys = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\').Name
    if ($ComponentBasedServicingKeys)
    {
        $ComponentBasedServicing = $ComponentBasedServicingKeys.Split("\") -contains "RebootPending"
    }
    else
    {
        $ComponentBasedServicing = $false
    }

    $WindowsUpdateKeys = (Get-ChildItem 'hklm:SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\').Name
    if ($WindowsUpdateKeys)
    {
        $WindowsUpdate = $WindowsUpdateKeys.Split("\") -contains "RebootRequired"
    }
    else
    {
        $WindowsUpdate = $false
    }

    $PendingFileRename = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\').PendingFileRenameOperations.Length -gt 0
    $ActiveComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName').ComputerName
    $PendingComputerName = (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName').ComputerName
    $PendingComputerRename = $ActiveComputerName -ne $PendingComputerName

    

    if (-not $SkipCcmClientSDK)
    {
        $CCMSplat = @{
            NameSpace='ROOT\ccm\ClientSDK'
            Class='CCM_ClientUtilities'
            Name='DetermineIfRebootPending'
            ErrorAction='Stop'
        }
        
        Try {
            $CCMClientSDK = Invoke-WmiMethod @CCMSplat
        }
        Catch
        {
            Write-Warning "Unable to query CCM_ClientUtilities: $_"
        }
    }

    $SCCMSDK = ($CCMClientSDK.ReturnValue -eq 0) -and ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)

    return @{
    Name = $Name
    ComponentBasedServicing = $ComponentBasedServicing
    WindowsUpdate = $WindowsUpdate
    PendingFileRename = $PendingFileRename
    PendingComputerRename = $PendingComputerRename
    CcmClientSDK = $SCCMSDK
    }
}

Function Set-TargetResource
{
    [CmdletBinding()]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [bool]$SkipComponentBasedServicing,
    [bool]$SkipWindowsUpdate,
    [bool]$SkipPendingFileRename,
    [bool]$SkipPendingComputerRename,
    [bool]$SkipCcmClientSDK
    )

    $global:DSCMachineStatus = 1
}

Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
     param
    (
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [bool]$SkipComponentBasedServicing,
    [bool]$SkipWindowsUpdate,
    [bool]$SkipPendingFileRename,
    [bool]$SkipPendingComputerRename,
    [bool]$SkipCcmClientSDK
    )

    $status = Get-TargetResource $Name -SkipCcmClientSDK $SkipCcmClientSDK

    if(-not $SkipComponentBasedServicing -and $status.ComponentBasedServicing)
    {
        Write-Verbose 'Pending component based servicing reboot found.'
        return $false
    }

    if(-not $SkipWindowsUpdate -and $status.WindowsUpdate)
    {
        Write-Verbose 'Pending Windows Update reboot found.'
        return $false
    }

    if(-not $SkipPendingFileRename -and $status.PendingFileRename)
    {
        Write-Verbose 'Pending file rename found.'
        return $false
    }

    if(-not $SkipPendingComputerRename -and $status.PendingComputerRename)
    {
        Write-Verbose 'Pending computer rename found.'
        return $false
    }

    Write-Verbose 'No pending reboots found.'
    return $true
}

Export-ModuleMember -Function *-TargetResource

$regRebootLocations = $null
