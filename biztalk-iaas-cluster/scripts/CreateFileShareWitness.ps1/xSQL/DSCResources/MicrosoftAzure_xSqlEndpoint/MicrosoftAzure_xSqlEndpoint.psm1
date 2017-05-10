#
# xSqlEndpoint: DSC resource to configure a database mirroring endpoint for use
#   with SQL Server AlwaysOn availability groups.
#


function Get-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,

        [ValidateRange(1000,9999)]
        [uint32] $PortNumber = 5022,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    $endpoint = $s.Endpoints | where { $_.Name -eq $Name }

    $bConfigured = Test-TargetResource -InstanceName $InstanceName -Name $Name -PortNumber $PortNumber -AllowedUser $AllowedUser -SqlAdministratorCredential $SqlAdministratorCredential

    $retVal = @{
        InstanceName = $InstanceName
        Name = $Name
        PortNumber = $PortNumber
        AllowedUser = $AllowedUser
        SqlAdministratorCredential = $SqlAdministratorCredential.UserName
        Configured = $bConfigured
    }

    $retVal
}

function Set-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,

        [ValidateRange(1000,9999)]
        [uint32] $PortNumber = 5022,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    try
    {
        if (-not ($s.Endpoints | where { $_.Name -eq $Name }))
        {
            # TODO: use Microsoft.SqlServer.Management.Smo.Endpoint instead of
            #   SqlPs since the PS cmdlets don't support impersonation.
            Write-Verbose -Message "Creating database mirroring endpoint for SQL AlwaysOn ..."
            $endpoint = $s | New-SqlHadrEndpoint -Name $Name -Port $PortNumber
            $endpoint | Set-SqlHadrEndpoint -State 'Started'
        }
    }
    catch
    {
        Write-Error "Error creating database mirroring endpoint."
        throw $_
    }

    if ($AllowedUser -ne ($($SqlAdministratorCredential.UserName).Split('\'))[1])
    {

        try
        {
            Write-Verbose -Message "Granting permissions to '$($AllowedUser)' ..."
            $perms = New-Object Microsoft.SqlServer.Management.Smo.ObjectPermissionSet
            $perms.Connect = $true
            $endpoint = $s.Endpoints | where { $_.Name -eq $Name }
            $endpoint.Grant($perms, $AllowedUser)
        }
        catch
        {
            Write-Error "Error granting permissions to '$($AllowedUser)'."
            throw $_
        }
    }
}

function Test-TargetResource
{
    param
    (
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,

        [ValidateRange(1000,9999)]
        [uint32] $PortNumber = 5022,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $SqlAdministratorCredential
    )

    $s = Get-SqlServer -InstanceName $InstanceName -Credential $SqlAdministratorCredential

    $endpoint = $s.Endpoints | where { $_.Name -eq $Name }
    if (-not $endpoint)
    {
        Write-Verbose -Message "Endpoint '$($Name)' does NOT exist."
        return $false
    }

    if ($AllowedUser -ne ($($SqlAdministratorCredential.UserName).Split('\'))[1])
    {
        $ops = New-Object Microsoft.SqlServer.Management.Smo.ObjectPermissionSet
        $ops.Add([Microsoft.SqlServer.Management.Smo.ObjectPermission]::Connect) | Out-Null
        $opis = $endpoint.EnumObjectPermissions($AllowedUser, $ops)
        if ($opis.Count -lt 1)
        {
            Write-Verbose -Message "Login '$($AllowedUser)' does NOT have the correct permissions for endpoint '$($Name)'."
            return $false
        }
    }

    $true
}


function Get-SqlServer([string]$InstanceName, [PSCredential]$Credential)
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
    $sc = New-Object Microsoft.SqlServer.Management.Common.ServerConnection

    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1 -and $list[1] -eq "MSSQLSERVER")
    {
        $sc.ServerInstance = $list[0]
    }
    else
    {
        $sc.ServerInstance = $InstanceName
    }

    $sc.ConnectAsUser = $true
    if ($Credential.GetNetworkCredential().Domain -and $Credential.GetNetworkCredential().Domain -ne $env:COMPUTERNAME)
    {
        $sc.ConnectAsUserName = "$($Credential.GetNetworkCredential().UserName)@$($Credential.GetNetworkCredential().Domain)"
    }
    else
    {
        $sc.ConnectAsUserName = $Credential.GetNetworkCredential().UserName
    }
    $sc.ConnectAsUserPassword = $Credential.GetNetworkCredential().Password
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
    $s = New-Object Microsoft.SqlServer.Management.Smo.Server $sc

    $s
}


Export-ModuleMember -Function *-TargetResource
