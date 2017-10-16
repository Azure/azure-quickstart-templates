$script:currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Debug -Message "CurrentPath: $script:currentPath"

# Load helper functions
Import-Module $script:currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter(Mandatory)]
        [System.String]
        $Name,

        [System.Management.Automation.PSCredential]
        $LoginCredential,

        [ValidateSet('SqlLogin', 'WindowsUser', 'WindowsGroup')]
        [System.String]
        $LoginType,

        [Parameter(Mandatory)]
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [Parameter(Mandatory)]
        [System.String]
        $SQLInstanceName = 'MSSQLSERVER'
    )

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if ($sql)
    {
        Write-Verbose 'Getting SQL logins'

        $sqlLogins = $sql.Logins
        if ($sqlLogins)
        {
            if ($sqlLogins[$Name])
            {
                Write-Verbose "SQL login name $Name is present"
                $Ensure = 'Present'
                $LoginType = $sqlLogins[$Name].LoginType
                Write-Verbose "SQL login name is of type $LoginType"
            }
            else
            {
                Write-Verbose "SQL login name $Name is absent"
                $Ensure = 'Absent'
            }
        }
        else
        {
            Write-Verbose 'Failed getting SQL logins'
            $Ensure = 'Absent'
        }
    }
    else
    {
        $Ensure = 'Absent'
    }

    $returnValue = @{
        Ensure = $Ensure
        Name = $Name
        LoginType = $LoginType
        SQLServer = $SQLServer
        SQLInstanceName = $SQLInstanceName
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory)]
        [System.String]
        $Name,

        [System.Management.Automation.PSCredential]
        $LoginCredential,

        [ValidateSet('SqlLogin', 'WindowsUser', 'WindowsGroup')]
        [System.String]
        $LoginType = 'WindowsUser',

        [Parameter(Mandatory)]
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [Parameter(Mandatory)]
        [System.String]
        $SQLInstanceName = 'MSSQLSERVER'
    )

    if ( ($Ensure -eq 'Present') -and 
        ($LoginType -eq 'SqlLogin') -and 
        !$PSBoundParameters.ContainsKey('LoginCredential') )
    {
        throw New-TerminatingError -ErrorType FailedLogin
    }

    $sql = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName

    if ($sql)
    {
        switch ($Ensure)
        {
            'Present'
            {
                try
                {
                    Write-Verbose "Creating SQL login $Name of type $LoginType"

                    $sqlLogin = New-Object Microsoft.SqlServer.Management.Smo.Login $sql, $Name
                    $sqlLogin.LoginType = $LoginType
                    if ($LoginType -eq 'SqlLogin')
                    {
                        if ( ($PSCmdlet.ShouldProcess($($sqlLogin.Name), "Create login")) ) {
                            $sqlLogin.Create( $LoginCredential.GetNetworkCredential().Password )
                        }
                    }
                    else
                    {
                        if ( ($PSCmdlet.ShouldProcess($($sqlLogin.Name), "Create login")) ) {
                            $sqlLogin.Create()
                        }
                    }
                }
                catch
                {
                    Write-Verbose "Failed creating SQL login $Name of type $LoginType"
                    
                    throw $_
                }
            }
            
            'Absent'
            {
                try
                {
                    Write-Verbose "Deleting SQL login $Name"

                    $sqlLogin = $($sql.Logins[$Name])
                    if ($sqlLogin)
                    {
                        if ( ($PSCmdlet.ShouldProcess($($sqlLogin.Name), "Remove login")) ) {
                            Remove-SqlLogin -Login $sqlLogin
                        }
                    }
                }
                catch
                {
                    Write-Verbose "Failed deleting SQL login $Name"
                    
                    throw $_
                }
            }
        }
    }

    if ( !(Test-TargetResource @PSBoundParameters) )
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
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter(Mandatory)]
        [System.String]
        $Name,

        [System.Management.Automation.PSCredential]
        $LoginCredential,

        [ValidateSet('SqlLogin', 'WindowsUser', 'WindowsGroup')]
        [System.String]
        $LoginType = 'WindowsUser',

        [Parameter(Mandatory)]
        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [Parameter(Mandatory)]
        [System.String]
        $SQLInstanceName = 'MSSQLSERVER'
    )

    $sqlServerLogin = Get-TargetResource @PSBoundParameters

    $result = ($sqlServerLogin.Ensure -eq $Ensure)
    
    $result
}

<#
    .SYNOPSIS
        Removes a SQL login

    .PARAMETER Login
        A SQL login of the type Microsoft.SqlServer.Management.Smo.Login

    .EXAMPLE
        $server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server
        $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList @( $server, "MyLogin" )
        Remove-SqlLogin -Login $login
#>
function Remove-SqlLogin
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [Microsoft.SqlServer.Management.Smo.Login]
        $Login
    )

    if ( ($PSCmdlet.ShouldProcess($($sqlLogin.Name), "Drop login")) ) {
        $sqlLogin.Drop()
    }
}

Export-ModuleMember -Function *-TargetResource
