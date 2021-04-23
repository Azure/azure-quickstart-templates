#
# xSqlEndPoint: DSC resouce to configure the given instance of Sql High Availability Service to listen port 5022 
# with given name, and to assign $AllowedUser to communicate the service through that endpoint.
#

#
# The Get-TargetResource cmdlet.
#
function Get-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [ValidateRange(1000,9999)]
        [Uint32] $PortNumber = 5022
    )

    $bConfigured = Test-TargetResource -InstanceName $InstanceName -AllowedUser $AllowedUser -Name $Name

    $returnValue = @{
        ServerInstance = $InstanceName
        AllowedUser = $AllowedUser
        EndPointName = $Name
        PortNumber = $PortNumber
        Configured = $bConfigured
    }

    $returnValue
}

#
# The Set-TargetResource cmdlet.
#
function Set-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [ValidateRange(1000,9999)]
        [Uint32] $PortNumber = 5022
    )

    Write-Verbose -Message "Set EndPoint $Name on instance $InstanceName ..."

    try
    {
        $endpoint = New-SqlHadrEndpoint $Name -Port $PortNumber -Path "SQLSERVER:\SQL\$InstanceName"
        Set-SqlHadrEndpoint -InputObject $endpoint -State "Started"

        OSQL -S $InstanceName -E -Q "GRANT CONNECT ON ENDPOINT::[$Name] TO [$AllowedUser]"
    }
    catch {  
        Write-Verbose -Message "Set EndPoint $Name on instance $InstanceName reached exception."
        throw $_
    }

}

#
# The Test-TargetResource cmdlet.
#
function Test-TargetResource
{
    param
    (	
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $InstanceName,
	    
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedUser,

        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [ValidateRange(1000,9999)]
        [Uint32] $PortNumber = 5022
    )

    if (!(Check-SqlInstance -InstanceName $InstanceName))
    {
        Write-Verbose -Message "Can't find Sql Server instance $InstanceName"
        return $false
    }

      
    Write-Verbose -Message "Test EndPoint $Name on instance $InstanceName ..."

	$endpoint = OSQL -S $InstanceName -E -Q "select count(*) from master.sys.endpoints where name = '$Name'" -h-1

    return ([bool] [int] $endpoint[0].Trim() )
}

function Get-PureInstanceName ($InstanceName)
{
    $list = $InstanceName.Split("\")
    if ($list.Count -gt 1)
    {
        $list[1]
    }
    else
    {
        "MSSQLSERVER"
    }
}

function Check-SqlInstance($InstanceName)
{
    $list = Get-Service -Name MSSQL*
    $retInstanceName = $null

    $pureInstanceName = Get-PureInstanceName -InstanceName $InstanceName

    if ($pureInstanceName -eq "MSSQLSERVER")
    {
        if ($list.Name -contains "MSSQLSERVER")
        {
            $retInstanceName = $InstanceName
        }
    }
    elseif ($list.Name -contains $("MSSQL$" + $pureInstanceName))
    {
        Write-Verbose -Message "SQL Instance $InstanceName is present"
        $retInstanceName = $pureInstanceName
    }

    return ($retInstanceName -ne $null)
}


Export-ModuleMember -Function *-TargetResource
