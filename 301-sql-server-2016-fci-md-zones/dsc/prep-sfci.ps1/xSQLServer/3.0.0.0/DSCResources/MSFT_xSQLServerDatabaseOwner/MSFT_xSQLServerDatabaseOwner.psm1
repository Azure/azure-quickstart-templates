$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

# DSC resource to manage SQL database roles
# NOTE: This resource requires WMF5 and PsDscRunAsCredential

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if ($sql)
    {
        # Getting Owner of Database        
        $getSqlDatabaseOwner = Get-SqlDatabaseOwner -SQL $sql -Database $Database

        if ($getSqlDatabaseOwner)
        {
            Write-Verbose "Owner for SQL Database name $Database is $getSqlDatabaseOwner"
        }
        else
        {
            $null = $getSqlDatabaseOwner
        }
    }

    $returnValue = @{
        Database = $Database
        Name = $getSqlDatabaseOwner
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if($sql)
    {
        # Setting Owner of Database
        try 
        {
            Set-SqlDatabaseOwner -SQL $sql -Name $Name -Database $Database
        }       
        catch
        {
            throw [Exception] ("Failed to setting the owner of database $Database")
        }
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
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )

    Write-Verbose -Message "Testing owner $Name of database $Database"
     
    $currentValues = Get-TargetResource @PSBoundParameters
    return Test-SQLDscParameterState -CurrentValues $CurrentValues `
                                     -DesiredValues $PSBoundParameters `
                                     -ValuesToCheck @("Name", "Database")
}

Export-ModuleMember -Function *-TargetResource
