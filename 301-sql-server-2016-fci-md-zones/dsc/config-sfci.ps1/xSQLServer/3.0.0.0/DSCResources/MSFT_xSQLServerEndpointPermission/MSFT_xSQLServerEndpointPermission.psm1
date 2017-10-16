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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal
    )

    try {
        $endpoint = Get-SQLAlwaysOnEndpoint -Name $Name -NodeName $NodeName -InstanceName $InstanceName -Verbose:$VerbosePreference
        
        if( $null -ne $endpoint ) {
            New-VerboseMessage -Message "Enumerating permissions for Endpoint $Name"

            $permissionSet = New-Object -Property @{ Connect = $True } -TypeName Microsoft.SqlServer.Management.Smo.ObjectPermissionSet

            $endpointPermission = $endpoint.EnumObjectPermissions( $permissionSet ) | Where-Object { $_.PermissionState -eq "Grant" -and $_.Grantee -eq $Principal }
            if( $endpointPermission.Count -ne 0 ) {
                $Ensure = "Present"
                $Permission = "CONNECT"
            } else {
                $Ensure = "Absent"
                $Permission = ""
            }
        } else {
            throw New-TerminatingError -ErrorType EndpointNotFound -FormatArgs @($Name) -ErrorCategory ObjectNotFound
        }
    } catch {
        throw New-TerminatingError -ErrorType EndpointErrorVerifyExist -FormatArgs @($Name) -ErrorCategory ObjectNotFound -InnerException $_.Exception
    }

    $returnValue = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Ensure = [System.String] $Ensure
        Name = [System.String] $Name
        Principal = [System.String] $Principal
        Permission = [System.String] $Permission
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

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [ValidateSet("CONNECT")]
        [System.String]
        $Permission
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        Principal = [System.String] $Principal
    }
    
    $endPointPermissionState = Get-TargetResource @parameters 
    if( $null -ne $endPointPermissionState ) {
        if( $endPointPermissionState.Ensure -ne $Ensure ) {
            $endpoint = Get-SQLAlwaysOnEndpoint -Name $Name -NodeName $NodeName -InstanceName $InstanceName -Verbose:$VerbosePreference
            if( $null -ne $endpoint ) {
                $permissionSet = New-Object -Property @{ Connect = $True } -TypeName Microsoft.SqlServer.Management.Smo.ObjectPermissionSet
                
                if( $Ensure -eq "Present") {
                    if( ( $PSCmdlet.ShouldProcess( $Name, "Grant permission to $Principal on Endpoint" ) ) ) {
                        $endpoint.Grant($permissionSet, $Principal )
                    }
                } else {
                    if( ( $PSCmdlet.ShouldProcess( $Name, "Revoke permission to $Principal on Endpoint" ) ) ) {
                        $endpoint.Revoke($permissionSet, $Principal )
                    }
                }
            } else {
                throw New-TerminatingError -ErrorType EndpointNotFound -FormatArgs @($Name) -ErrorCategory ObjectNotFound
            }
        } else {
            New-VerboseMessage -Message "State is already $Ensure"
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

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Principal,

        [ValidateSet("CONNECT")]
        [System.String]
        $Permission
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        Principal = [System.String] $Principal
    }
    
    New-VerboseMessage -Message "Testing state of endpoint permission for $Principal"

    $endPointPermissionState = Get-TargetResource @parameters 
    if( $null -ne $endPointPermissionState ) {
        [System.Boolean] $result = $false
        if( $endPointPermissionState.Ensure -eq $Ensure) {
            $result = $true
        }
    } else {
        throw New-TerminatingError -ErrorType UnexpectedErrorFromGet -ErrorCategory InvalidResult
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
