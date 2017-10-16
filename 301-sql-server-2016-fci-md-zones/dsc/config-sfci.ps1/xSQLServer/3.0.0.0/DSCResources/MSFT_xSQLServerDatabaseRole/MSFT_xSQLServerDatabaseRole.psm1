$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $currentPath"

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
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Role
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    if($SQL)
    {
        # Check database exists
        if(!($SQLDatabase = $SQL.Databases[$Database]))
        {
            throw New-TerminatingError -ErrorType NoDatabase -FormatArgs @($Database,$SQLServer,$SQLInstanceName) -ErrorCategory ObjectNotFound
        }

        # Check role exists
        if(!($SQLDatabase.Roles[$Role]))
        {
            throw New-TerminatingError -ErrorType RoleNotFound -FormatArgs @($Role,$Database,$SQLServer,$SQLInstanceName) -ErrorCategory ObjectNotFound
        }

        # Check login exists
        if(!($SQLLogin = $SQL.Logins[$Name]))
        {
            throw New-TerminatingError -ErrorType LoginNotFound -FormatArgs @($Name,$SQLServer,$SQLInstanceName) -ErrorCategory ObjectNotFound
        }

        if($SQLDatabaseUser = $SQLDatabase.Users[$Name])
        {
            if($SQLDatabaseUser.IsMember($Role))
            {
                Write-Verbose "SQL login $Name is a member of role $Role on database $Database on $SQLServer\$SQLInstanceName"
                $Ensure = "Present"
            }
            else
            {
                Write-Verbose "SQL login $Name is not a member of role $Role on database $Database on $SQLServer\$SQLInstanceName"
                $Ensure = "Absent"
            }
        }
        else
        {
            Write-Verbose "SQL login $Name is not a user of database $Database on $SQLServer\$SQLInstanceName"
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
        SQLServer = $SQLServer
        SQLInstanceName = $SQLInstanceName
        Database = $Database
        Role = $Role
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Role
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }

    if($SQL)
    {
        $SQLDatabase = $SQL.Databases[$Database]
        $SQLDatabaseRole = $SQLDatabase.Roles[$Role]
        switch($Ensure)
        {
            "Present"
            {
                if(!$SQLDatabase.Users[$Name])
                {
                    try
                    {
                        Write-Verbose "Adding SQL login $Name as a user of database $Database on $SQLServer\$SQLInstanceName"
                        $SQLDatabaseUser = New-Object Microsoft.SqlServer.Management.Smo.User $SQLDatabase,$Name
                        $SQLDatabaseUser.Login = $Name
                        $SQLDatabaseUser.Create()
                    }
                    catch
                    {
                        Write-Verbose "Failed adding SQL login $Name as a user of database $Database on $SQLServer\$SQLInstanceName"
                    }
                }
                if($SQLDatabase.Users[$Name])
                {
                    try
                    {
                        Write-Verbose "Adding SQL login $Name to role $Role on database $Database on $SQLServer\$SQLInstanceName"
                        $SQLDatabaseRole.AddMember($Name)
                    }
                    catch
                    {
                        Write-Verbose "Failed adding SQL login $Name to role $Role on database $Database on $SQLServer\$SQLInstanceName"
                    }
                }
            }
            "Absent"
            {
                try
                {
                    Write-Verbose "Removing SQL login $Name from role $Role on database $Database on $SQLServer\$SQLInstanceName"
                    $SQLDatabaseRole.DropMember($Name)
                }
                catch
                {
                    Write-Verbose "Failed removing SQL login $Name from role $Role on database $Database on $SQLServer\$SQLInstanceName"
                }
            }
        }
    }

    ### TODO update with localized helper
    if(!(Test-TargetResource @PSBoundParameters))
    {
        throw New-TerminatingError -ErrorType TestFailedAfterSet -ErrorCategory InvalidResult
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present",

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER",

        [parameter(Mandatory = $true)]
        [System.String]
        $Database,

        [parameter(Mandatory = $true)]
        [System.String]
        $Role
    )

    $result = ((Get-TargetResource @PSBoundParameters).Ensure -eq $Ensure)
    
    $result
}


Export-ModuleMember -Function *-TargetResource
