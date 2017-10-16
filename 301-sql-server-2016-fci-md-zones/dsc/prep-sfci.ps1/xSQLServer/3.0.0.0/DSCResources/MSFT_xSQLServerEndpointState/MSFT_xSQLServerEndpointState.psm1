$ErrorActionPreference = "Stop"

$script:currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module $currentPath\..\..\xSQLServerHelper.psm1 -ErrorAction Stop

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName = "DEFAULT",

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    New-VerboseMessage -Message "Getting state of endpoint $Name"
    
    try {
        $endpoint = Get-SQLAlwaysOnEndpoint -Name $Name -NodeName $NodeName -InstanceName $InstanceName -Verbose:$VerbosePreference
        
        if( $null -ne $endpoint ) {
            $state = $endpoint.EndpointState
        } else {
            throw New-TerminatingError -ErrorType EndpointNotFound -FormatArgs @($Name) -ErrorCategory ObjectNotFound
        }
    } catch {
        throw New-TerminatingError -ErrorType EndpointErrorVerifyExist -FormatArgs @($Name) -ErrorCategory ObjectNotFound -InnerException $_.Exception
    }

    $returnValue = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        State = [System.String] $state
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName = "DEFAULT",

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Started","Stopped","Disabled")]
        [System.String]
        $State
    )
  
    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
    }
    
    $endPointState = Get-TargetResource @parameters 
    if( $null -ne $endPointState ) {
        if( $endPointState.State -ne $State ) {
            if( ( $PSCmdlet.ShouldProcess( $Name, "Changing state of Endpoint" ) ) ) {
                $endpoint = Get-SQLAlwaysOnEndpoint -Name $Name -NodeName $NodeName -InstanceName $InstanceName -Verbose:$VerbosePreference
                $InstanceName = Get-SQLPSInstanceName -InstanceName $InstanceName
    
                $setEndPointParams = @{
                    Path = "SQLSERVER:\SQL\$NodeName\$InstanceName\Endpoints\$Name"
                    Port = $endpoint.Protocol.Tcp.ListenerPort
                    IpAddress = $endpoint.Protocol.Tcp.ListenerIPAddress.IPAddressToString
                    State = $State
                }
                
                Set-SqlHADREndpoint @setEndPointParams -Verbose:$False | Out-Null # Suppressing Verbose because it prints the entire T-SQL statement otherwise
            }
        } else {
            New-VerboseMessage -Message "Endpoint configuration is already correct."
        }
    } else {
        throw New-TerminatingError -ErrorType UnexpectedErrorFromGet -ErrorCategory InvalidResult
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
        $InstanceName = "DEFAULT",

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateSet("Started","Stopped","Disabled")]
        [System.String]
        $State
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
    }

    New-VerboseMessage -Message "Testing state $State on endpoint $Name"
    
    $endPointState = Get-TargetResource @parameters 
    if( $null -ne $endPointState ) {
        [System.Boolean] $result = $false
        if( $endPointState.State -eq $State ) {
            $result = $true
        }
    } else {
        throw New-TerminatingError -ErrorType UnexpectedErrorFromGet -ErrorCategory InvalidResult
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
