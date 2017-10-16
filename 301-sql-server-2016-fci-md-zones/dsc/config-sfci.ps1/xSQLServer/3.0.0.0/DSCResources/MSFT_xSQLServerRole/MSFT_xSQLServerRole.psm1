$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

# DSC resource to manage SQL logins in server role
# NOTE: This resource requires WMF5 and PsDscRunAsCredential

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateSet("bulkadmin","dbcreator","diskadmin","processadmin","public","securityadmin","serveradmin","setupadmin","sysadmin")]
        [System.String[]]
        $ServerRole,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if ($sql)
    {
        Write-Verbose "Getting SQL Server roles for $Name on SQL Server $SQLServer."
        $confirmSqlServerRole = Confirm-SqlServerRole -SQL $sql -LoginName $Name -ServerRole $ServerRole
        if ($confirmSqlServerRole)
        {
            $Ensure = "Present"
        }
        else
        {
            $Ensure = "Absent"
        }
    }
    else
    {
        $Ensure = "Absent"
    }

    $returnValue = @{
        Ensure = $Ensure
        Name = $Name
        ServerRole = $ServerRole
        SQLServer = $SQLServer
        SQLInstanceName = $SQLInstanceName
    }
    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateSet("bulkadmin","dbcreator","diskadmin","processadmin","public","securityadmin","serveradmin","setupadmin","sysadmin")]
        [System.String[]]
        $ServerRole,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if ($sql)
    {
        if ($Ensure -eq "Present")
        {
            Add-SqlServerRole -SQL $sql -LoginName $Name -ServerRole $ServerRole
            New-VerboseMessage -Message "SQL Roles for $Name, successfullly added"
        }
        else
        {
            Remove-SqlServerRole -SQL $sql -LoginName $Name -ServerRole $ServerRole
            New-VerboseMessage -Message "SQL Roles for $Name, successfullly removed"
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [ValidateSet("bulkadmin","dbcreator","diskadmin","processadmin","public","securityadmin","serveradmin","setupadmin","sysadmin")]
        [System.String[]]
        $ServerRole,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SQLInstanceName
    )

    Write-Verbose -Message "Testing SQL roles for login $Name"
    $currentValues = Get-TargetResource @PSBoundParameters
    
    $result = ($currentValues.Ensure -eq $Ensure) -and ($currentValues.ServerRole -eq $ServerRole) -and ($currentValues.Name -eq $Name)
    $result    
}

Export-ModuleMember -Function *-TargetResource

