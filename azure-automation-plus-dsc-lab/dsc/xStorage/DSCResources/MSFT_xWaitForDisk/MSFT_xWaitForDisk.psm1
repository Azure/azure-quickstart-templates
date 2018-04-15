#
# xWaitForDisk: DSC resource to wait for a disk to be available
#

function Get-TargetResource
{
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,        

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 60
    )

    $returnValue = @{
        DiskNumber = $DiskNumber
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
    }
    $returnValue
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,        

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 60
    )

    $diskFound = $false
    Write-Verbose -Message "Checking for disk '$($DiskNumber)' ..."

    for ($count = 0; $count -lt $RetryCount; $count++)
    {
        $disk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue
        if (!!$disk)
        {
            Write-Verbose -Message "Found disk '$($disk.FriendlyName)'."
            $diskFound = $true
            break;
        }
        else
        {
            Write-Verbose -Message "Disk '$($DiskNumber)' NOT found."
            Write-Verbose -Message "Retrying in $RetryIntervalSec seconds ..."
            Start-Sleep -Seconds $RetryIntervalSec
        }
    }

    if (!$diskFound)
    {
        throw "Disk '$($DiskNumber)' NOT found after $RetryCount attempts."
    }
}

function Test-TargetResource
{
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [uint32] $DiskNumber,        

        [UInt64]$RetryIntervalSec = 10,

        [UInt32]$RetryCount = 60
    )

    Write-Verbose -Message "Checking for disk '$($DiskNumber)' ..."
    $disk = Get-Disk -Number $DiskNumber -ErrorAction SilentlyContinue
    if (!!$disk)
    {
        Write-Verbose -Message "Found disk '$($disk.FriendlyName)'."
        $true
    }
    else
    {
        Write-Verbose -Message "Disk '$($DiskNumber)' NOT found."
        $false
    }
}


Export-ModuleMember -Function *-TargetResource

