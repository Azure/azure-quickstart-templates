$currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Verbose -Message "CurrentPath: $currentPath"

# Load Common Code
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -Verbose:$false -ErrorAction Stop

# DSC resource to manage SQL Endpoint

# NOTE: This resource requires WMF5 and PsDscRunAsCredential

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $EndPointName,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.UInt32]
        $Port,

        [System.String]
        $AuthorizedUser,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )
     
    $vConfigured = Test-TargetResource -EndPointName $EndPointName -Ensure $Ensure -Port $Port -AuthorizedUser $AuthorizedUser
    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }
    
    $returnValue = @{
    EndPointName = $EndPointName
    Ensure = $vConfigured
    Port = $sql.Endpoints[$EndPointName].Protocol.Tcp.ListenerPort
    AuthorizedUser = $sql.Endpoints[$EndPointName].EnumObjectPermissions().grantee
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
        $EndPointName,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.UInt32]
        $Port,

        [System.String]
        $AuthorizedUser,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }
Write-Verbose "Connected to Server"

    if($Ensure -eq "Present")
    {
        Write-Verbose "Check to see login $AuthorizedUser exist on the server"

        if(!$SQL.Logins.Contains($AuthorizedUser))
        {
            throw New-TerminatingError -ErrorType NoAuthorizedUser -FormatArgs @($AuthorizedUser,$SQLServer,$SQLInstanceName) -ErrorCategory InvalidResult
        }
        $Endpoint = New-Object -typename Microsoft.SqlServer.Management.Smo.Endpoint -ArgumentList $Sql,$EndpointName
        $Endpoint.EndpointType = [Microsoft.SqlServer.Management.Smo.EndpointType]::DatabaseMirroring
        $Endpoint.ProtocolType = [Microsoft.SqlServer.Management.Smo.ProtocolType]::Tcp
        $Endpoint.Protocol.Tcp.ListenerPort = $Port
        $Endpoint.Payload.DatabaseMirroring.ServerMirroringRole = [Microsoft.SqlServer.Management.Smo.ServerMirroringRole]::All
        $Endpoint.Payload.DatabaseMirroring.EndpointEncryption = [Microsoft.SqlServer.Management.Smo.EndpointEncryption]::Required
        $Endpoint.Payload.DatabaseMirroring.EndpointEncryptionAlgorithm = [Microsoft.SqlServer.Management.Smo.EndpointEncryptionAlgorithm]::Aes 
        $Endpoint.Create()
        $Endpoint.Start()
        $ConnectPerm = New-Object -TypeName Microsoft.SqlServer.Management.SMO.ObjectPermissionSet
        $ConnectPerm.Connect= $true
        $Endpoint.Grant($ConnectPerm,$AuthorizedUser)
    }
    elseif($Ensure -eq "Absent")
    {
        Write-Verbose "Drop $EndPointName"
        $SQL.Endpoints[$EndPointName].Drop()
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
        $EndPointName,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.UInt32]
        $Port,

        [System.String]
        $AuthorizedUser,

        [System.String]
        $SQLServer = $env:COMPUTERNAME,

        [System.String]
        $SQLInstanceName = "MSSQLSERVER"
    )

    if(!$SQL)
    {
        $SQL = Connect-SQL -SQLServer $SQLServer -SQLInstanceName $SQLInstanceName
    }
    
    $result = [System.Boolean]


    if(($sql.Endpoints[$EndPointName].Name -eq $EndPointName)-and($ensure -eq "Present") )
    {
        $Result = $true
    }
    else
    {$result = $false}

    $result
}


Export-ModuleMember -Function *-TargetResource

