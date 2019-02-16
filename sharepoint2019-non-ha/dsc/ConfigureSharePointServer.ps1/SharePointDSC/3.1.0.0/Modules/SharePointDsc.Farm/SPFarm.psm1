<#

.SYNOPSIS

Get-SPDSCConfigDBStatus is used to determine the state of a configuration database

.DESCRIPTION

Get-SPDSCConfigDBStatus will determine two things - firstly, if the config database
exists, and secondly if the user executing the script has appropriate permissions
to the instance to create the database. These values are used by the SPFarm resource
to determine what actions to take in it's set method.

.PARAMETER SQLServer

The name of the SQL server to check against

.PARAMETER Database

The name of the database to validate as the configuration database

.EXAMPLE

Get-SPDSCConfigDBStatus -SQLServer sql.contoso.com -Database SP_Config

#>
function Get-SPDSCConfigDBStatus
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [String]
        $Database
    )

    $connection = New-Object -TypeName "System.Data.SqlClient.SqlConnection"
    $connection.ConnectionString = "Server=$SQLServer;Integrated Security=SSPI;Database=Master"
    $command = New-Object -TypeName "System.Data.SqlClient.SqlCommand"

    try 
    {
        $currentUser = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name
        $connection.Open()
        $command.Connection = $connection

        $command.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = '$Database'"
        $configDBexists = ($command.ExecuteScalar() -eq 1)

        $command.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = '$($Database)_Lock'"
        $lockExists = ($command.ExecuteScalar() -eq 1)

        $serverRolesToCheck = @("dbcreator", "securityadmin")
        $hasPermissions = $true
        foreach ($serverRole in $serverRolesToCheck)
        {
            $command.CommandText = "SELECT IS_SRVROLEMEMBER('$serverRole')"
            if ($command.ExecuteScalar() -eq "0")
            {
                Write-Verbose -Message "$currentUser does not have '$serverRole' role on server '$SQLServer'"
                $hasPermissions = $false
            }
        }

        return @{
            DatabaseExists = $configDBexists
            ValidPermissions = $hasPermissions
            Locked = $lockExists
        }
    }
    finally
    {
        if ($connection.State -eq "Open") 
        {
            $connection.Close()
            $connection.Dispose()
        }
    }
}

<#

.SYNOPSIS

Get-SPDSCSQLInstanceStatus is used to determine the state of the SQL instance

.DESCRIPTION

Get-SPDSCSQLInstanceStatus will determine the state of the MaxDOP setting. This
value is used by the SPFarm resource to determine if the SQL instance is ready
for SharePoint deployment.

.PARAMETER SQLServer

The name of the SQL server to check against

.EXAMPLE

Get-SPDSCConfigDBStatus -SQLServer sql.contoso.com

#>
function Get-SPDSCSQLInstanceStatus
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $SQLServer
    )

    $connection = New-Object -TypeName "System.Data.SqlClient.SqlConnection"
    $connection.ConnectionString = "Server=$SQLServer;Integrated Security=SSPI;Database=Master"
    $command = New-Object -TypeName "System.Data.SqlClient.SqlCommand"

    try 
    {
        $currentUser = ([Security.Principal.WindowsIdentity]::GetCurrent()).Name
        $connection.Open()
        $command.Connection = $connection

        $command.CommandText = "SELECT value_in_use FROM sys.configurations WHERE name = 'max degree of parallelism'"
        $maxDOPCorrect = ($command.ExecuteScalar() -eq 1)

        return @{
            MaxDOPCorrect = $maxDOPCorrect
        }
    }
    finally
    {
        if ($connection.State -eq "Open") 
        {
            $connection.Close()
            $connection.Dispose()
        }
    }
}

<#

.SYNOPSIS

Add-SPDSCConfigDBLock is used to create a lock to tell other servers that the
config DB is currently provisioning

.DESCRIPTION

Add-SPDSCConfigDBLock will create an empty database with the same name as the
config DB but suffixed with "_Lock". The presences of this database will 
indicate to other servers that the config database is in the process of being
provisioned as the database is removed at the end of the process.

.PARAMETER SQLServer

The name of the SQL server to check against

.PARAMETER Database

The name of the database to validate as the configuration database

.EXAMPLE

Add-SPDSCConfigDBLock -SQLServer sql.contoso.com -Database SP_Config

#>
function Add-SPDSCConfigDBLock
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [String]
        $Database
    )

    Write-Verbose -Message "Creating lock database $($Database)_Lock"

    $connection = New-Object -TypeName "System.Data.SqlClient.SqlConnection"
    $connection.ConnectionString = "Server=$SQLServer;Integrated Security=SSPI;Database=Master"
    $command = New-Object -TypeName "System.Data.SqlClient.SqlCommand"

    try 
    {
        $connection.Open()
        $command.Connection = $connection

        $command.CommandText = "CREATE DATABASE [$($Database)_Lock]"
        $command.ExecuteNonQuery()
    }
    finally
    {
        if ($connection.State -eq "Open") 
        {
            $connection.Close()
            $connection.Dispose()
        }
    }
}

<#

.SYNOPSIS

Remove-SPDSCConfigDBLock is used to create a lock to tell other servers that the
config DB is currently provisioning

.DESCRIPTION

Remove-SPDSCConfigDBLock will cremove the lock database created by the
Add-SPDSCConfigDBLock command.

.PARAMETER SQLServer

The name of the SQL server to check against

.PARAMETER Database

The name of the database to validate as the configuration database

.EXAMPLE

Remove-SPDSCConfigDBLock -SQLServer sql.contoso.com -Database SP_Config

#>
function Remove-SPDSCConfigDBLock
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $SQLServer,

        [Parameter(Mandatory = $true)]
        [String]
        $Database
    )

    Write-Verbose -Message "Removing lock database $($Database)_Lock"

    $connection = New-Object -TypeName "System.Data.SqlClient.SqlConnection"
    $connection.ConnectionString = "Server=$SQLServer;Integrated Security=SSPI;Database=Master"
    $command = New-Object -TypeName "System.Data.SqlClient.SqlCommand"

    try 
    {
        $connection.Open()
        $command.Connection = $connection

        $command.CommandText = "DROP DATABASE [$($Database)_Lock]"
        $command.ExecuteNonQuery()
    }
    finally
    {
        if ($connection.State -eq "Open") 
        {
            $connection.Close()
            $connection.Dispose()
        }
    }
}

