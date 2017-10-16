$dom = [AppDomain]::CreateDomain('xSQLServerReplication')

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [ValidateSet('Local', 'Remote')]
        [System.String]
        $DistributorMode,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AdminLinkCredentials,

        [System.String]
        $DistributionDBName = 'distribution',

        [System.String]
        $RemoteDistributor,

        [parameter(Mandatory = $true)]
        [System.String]
        $WorkingDirectory,

        [System.Boolean]
        $UseTrustedConnection = $true,

        [System.Boolean]
        $UninstallWithForce = $true
    )

    $Ensure = 'Absent'

    $sqlMajorVersion = Get-SqlServerMajorVersion -InstanceName $InstanceName
    $localSqlName = Get-SqlLocalServerName -InstanceName $InstanceName

    $localServerConnection = New-ServerConnection -SqlMajorVersion $sqlMajorVersion -SqlServerName $localSqlName
    $localReplicationServer = New-ReplicationServer -SqlMajorVersion $sqlMajorVersion -ServerConnection $localServerConnection

    if($localReplicationServer.IsDistributor -eq $true)
    {
        $Ensure = 'Present'
        $DistributorMode = 'Local'
    }
    elseif($localReplicationServer.IsPublisher -eq $true)
    {
        $Ensure = 'Present'
        $DistributorMode = 'Remote'
    }

    if($Ensure -eq 'Present')
    {
        $DistributionDBName = $localReplicationServer.DistributionDatabase
        $RemoteDistributor = $localReplicationServer.DistributionServer
        $WorkingDirectory = $localReplicationServer.WorkingDirectory
    }
               
    $returnValue = @{
        InstanceName = $InstanceName
        Ensure = $Ensure
        DistributorMode = $DistributorMode
        DistributionDBName = $DistributionDBName
        RemoteDistributor = $RemoteDistributor
        WorkingDirectory = $WorkingDirectory
    }
    
    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [ValidateSet('Local', 'Remote')]
        [System.String]
        $DistributorMode,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AdminLinkCredentials,

        [System.String]
        $DistributionDBName = 'distribution',

        [System.String]
        $RemoteDistributor,

        [parameter(Mandatory = $true)]
        [System.String]
        $WorkingDirectory,

        [System.Boolean]
        $UseTrustedConnection = $true,

        [System.Boolean]
        $UninstallWithForce = $true
    )

    if(($DistributorMode -eq 'Remote') -and (-not $RemoteDistributor))
    {
        throw "RemoteDistributor parameter cannot be empty when DistributorMode = 'Remote'!"
    }

    $sqlMajorVersion = Get-SqlServerMajorVersion -InstanceName $InstanceName
    $localSqlName = Get-SqlLocalServerName -InstanceName $InstanceName

    $localServerConnection = New-ServerConnection -SqlMajorVersion $sqlMajorVersion -SqlServerName $localSqlName
    $localReplicationServer = New-ReplicationServer -SqlMajorVersion $sqlMajorVersion -ServerConnection $localServerConnection

    if($Ensure -eq 'Present')
    {
        if($DistributorMode -eq 'Local' -and $localReplicationServer.IsDistributor -eq $false)
        {
            Write-Verbose "Local distribution will be configured ..."

            $distributionDB = New-DistributionDatabase `
                -SqlMajorVersion $sqlMajorVersion `
                -DistributionDBName $DistributionDBName `
                -ServerConnection $localServerConnection

            Install-LocalDistributor `
                -ReplicationServer $localReplicationServer `
                -AdminLinkCredentials $AdminLinkCredentials `
                -DistributionDB $distributionDB

            Register-DistributorPublisher `
                -SqlMajorVersion $sqlMajorVersion `
                -PublisherName $localSqlName `
                -ServerConnection $localServerConnection `
                -DistributionDBName $DistributionDBName `
                -WorkingDirectory $WorkingDirectory `
                -UseTrustedConnection $UseTrustedConnection
        }
            
        if($DistributorMode -eq 'Remote' -and $localReplicationServer.IsPublisher -eq $false)
        {
            Write-Verbose "Remote distribution will be configured ..."

            $remoteConnection = New-ServerConnection -SqlMajorVersion $sqlMajorVersion -SqlServerName $RemoteDistributor

            Register-DistributorPublisher `
                -SqlMajorVersion $sqlMajorVersion `
                -PublisherName $localSqlName `
                -ServerConnection $remoteConnection `
                -DistributionDBName $DistributionDBName `
                -WorkingDirectory $WorkingDirectory `
                -UseTrustedConnection $UseTrustedConnection

            Install-RemoteDistributor `
                -ReplicationServer $localReplicationServer `
                -RemoteDistributor $RemoteDistributor `
                -AdminLinkCredentials $AdminLinkCredentials
        }
    }
    else #'Absent'
    {
        if($localReplicationServer.IsDistributor -eq $true -or $localReplicationServer.IsPublisher -eq $true)
        {
            Write-Verbose "Distribution will be removed ..."
            Uninstall-Distributor -ReplicationServer $localReplicationServer -UninstallWithForce $UninstallWithForce
        }
        else
        {
            Write-Verbose "Distribution is not configured on this instance."
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [ValidateSet('Local', 'Remote')]
        [System.String]
        $DistributorMode,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AdminLinkCredentials,

        [System.String]
        $DistributionDBName = 'distribution',

        [System.String]
        $RemoteDistributor,

        [parameter(Mandatory = $true)]
        [System.String]
        $WorkingDirectory,

        [System.Boolean]
        $UseTrustedConnection = $true,

        [System.Boolean]
        $UninstallWithForce = $true
    )

    $result = $false
    $state = Get-TargetResource @PSBoundParameters

    if($Ensure -eq 'Absent' -and $state.Ensure -eq 'Absent')
    {
        $result = $true
    }
    elseif($Ensure -eq 'Present' -and $state.Ensure -eq 'Present' -and $state.DistributorMode -eq $DistributorMode)
    {
        $result = $true
    }
          
    return $result
}

#region helper functions
function New-ServerConnection
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion,

        [parameter(Mandatory = $true)]
        [System.String]
        $SqlServerName
    )

    $connInfo = Get-ConnectionInfoAssembly -SqlMajorVersion $SqlMajorVersion
    $serverConnection = New-Object $connInfo.GetType('Microsoft.SqlServer.Management.Common.ServerConnection') $SqlServerName

    return $serverConnection
}

function New-ReplicationServer
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion,

        [parameter(Mandatory = $true)]
        [System.Object]
        $ServerConnection
    )

    $rmo = Get-RmoAssembly -SqlMajorVersion $SqlMajorVersion
    $localReplicationServer = New-Object $rmo.GetType('Microsoft.SqlServer.Replication.ReplicationServer') $ServerConnection

    return $localReplicationServer;
}

function New-DistributionDatabase
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion,

        [parameter(Mandatory = $true)]
        [System.String]
        $DistributionDBName,

        [parameter(Mandatory = $true)]
        [System.Object]
        $ServerConnection
    )

    $rmo = Get-RmoAssembly -SqlMajorVersion $SqlMajorVersion
    Write-Verbose "Creating DistributionDatabase object $DistributionDBName"
    $distributionDB = New-Object $rmo.GetType('Microsoft.SqlServer.Replication.DistributionDatabase') $DistributionDBName, $ServerConnection

    return $distributionDB
}

function New-DistributionPublisher
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion,

        [parameter(Mandatory = $true)]
        [System.String]
        $PublisherName,

        [parameter(Mandatory = $true)]
        [System.Object]
        $ServerConnection
    )
    
    $rmo = Get-RmoAssembly -SqlMajorVersion $SqlMajorVersion
    $distributorPublisher = New-object $rmo.GetType('Microsoft.SqlServer.Replication.DistributionPublisher') $PublisherName, $ServerConnection

    return $distributorPublisher
}

function Install-RemoteDistributor
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.Object]
        $ReplicationServer,

        [parameter(Mandatory = $true)]
        [System.String]
        $RemoteDistributor,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AdminLinkCredentials
    )

    Write-Verbose "Calling InstallDistributor with RemoteDistributor = $RemoteDistributor"
    $ReplicationServer.InstallDistributor($RemoteDistributor, $AdminLinkCredentials.Password)
}

function Install-LocalDistributor
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.Object]
        $ReplicationServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $AdminLinkCredentials,

        [parameter(Mandatory = $true)]
        [System.Object]
        $DistributionDB
    )

    Write-Verbose "Calling InstallDistributor with DistributionDB"
    $ReplicationServer.InstallDistributor($AdminLinkCredentials.Password, $DistributionDB)
}

function Uninstall-Distributor
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.Object]
        $ReplicationServer,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $UninstallWithForce
    )
    Write-Verbose 'Calling UnistallDistributor method on ReplicationServer object'
    $ReplicationServer.UninstallDistributor($UninstallWithForce)
}

function Register-DistributorPublisher
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion,

        [parameter(Mandatory = $true)]
        [System.String]
        $PublisherName,

        [parameter(Mandatory = $true)]
        [System.Object]
        $ServerConnection,

        [parameter(Mandatory = $true)]
        [System.String]
        $DistributionDBName,

        [parameter(Mandatory = $true)]
        [System.String]
        $WorkingDirectory,

        [parameter(Mandatory = $true)]
        [System.Boolean]
        $UseTrustedConnection
    )

    Write-Verbose "Creating DistributorPublisher $PublisherName on $($ServerConnection.ServerInstance)"

    $distributorPublisher = New-DistributionPublisher `
        -SqlMajorVersion $SqlMajorVersion `
        -PublisherName $PublisherName `
        -ServerConnection $ServerConnection
    
    $distributorPublisher.DistributionDatabase = $DistributionDBName
    $distributorPublisher.WorkingDirectory = $WorkingDirectory
    $distributorPublisher.PublisherSecurity.WindowsAuthentication = $UseTrustedConnection
    $distributorPublisher.Create()
}

function Get-ConnectionInfoAssembly
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion
    )

    $connInfo = $dom.Load("Microsoft.SqlServer.ConnectionInfo, Version=$SqlMajorVersion.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
    Write-Verbose "Loaded assembly: $($connInfo.FullName)"

    return $connInfo
}

function Get-RmoAssembly
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $SqlMajorVersion
    )

    $rmo = $dom.Load("Microsoft.SqlServer.Rmo, Version=$SqlMajorVersion.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91")
    Write-Verbose "Loaded assembly: $($rmo.FullName)"

    return $rmo
}

function Get-SqlServerMajorVersion
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    $instanceId = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL").$InstanceName
    $sqlVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceId\Setup").Version
    $sqlMajorVersion = $sqlVersion.Split(".")[0]
    if (-not $sqlMajorVersion)
    {
        throw "Unable to detect version for sql server instance: $InstanceName!"
    }
    return $sqlMajorVersion
}

function Get-SqlLocalServerName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $InstanceName
    )

    if($InstanceName -eq "MSSQLSERVER")
    {
        return $env:COMPUTERNAME
    }
    else
    {
        return "$($env:COMPUTERNAME)\$InstanceName"
    }
}
#endregion

Export-ModuleMember -Function *-TargetResource
