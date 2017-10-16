$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,
        
        [UInt64] $RetryIntervalSec = 10,
        [UInt32] $RetryCount = 50
    )

    @{
        Name = $Name
        RetryIntervalSec = $RetryIntervalSec
        RetryCount = $RetryCount
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.UInt64]
        $RetryIntervalSec =20,

        [System.UInt32]
        $RetryCount = 6
    )

    $AGFound = $false
    New-VerboseMessage -Message "Checking for Availaibilty Group $Name ..."

    for ($count = 0; $count -lt $RetryCount; $count++)
    {
        try
        {
            $clusterGroup = Get-ClusterGroup -Name $Name -ErrorAction Ignore

            if ($clusterGroup -ne $null)
            {
                New-VerboseMessage -Message "Found Availability Group $Name"
                $AGFound = $true
                Start-Sleep -Seconds $RetryIntervalSec
                break;
            }
            
        }
        catch
        {
             New-VerboseMessage -Message "Availability Group $Name not found. Will retry again after $RetryIntervalSec sec"
        }
            
        New-VerboseMessage -Message "Availability Group $Name not found. Will retry again after $RetryIntervalSec sec"
        Start-Sleep -Seconds $RetryIntervalSec
    }

    if (! $AGFound)
    {
        throw "Availability Group $Name not found after $count attempts with $RetryIntervalSec sec interval"
        Exit
    }


}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.UInt64]
        $RetryIntervalSec = 10,

        [System.UInt32]
        $RetryCount = 50
    )

    New-VerboseMessage -Message "Checking for Availability Group $Name ..."

    try
    {

        $clusterGroup = Get-ClusterGroup -Name $Name -ErrorAction Ignore

        if ($clusterGroup -eq $null)
        {
            New-VerboseMessage -Message "Availability Group $Name not found"
            $false
        }
        else
        {
            New-VerboseMessage -Message "Found Availabilty Group $Name"
            $true
        }
    }
    catch
    {
        New-VerboseMessage -Message "Availability Group $Name not found"
        $false
    }
}


Export-ModuleMember -Function *-TargetResource

