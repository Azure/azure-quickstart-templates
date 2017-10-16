$ErrorActionPreference = "Stop"

$script:currentPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module $script:currentPath\..\..\xSQLServerHelper.psm1 -ErrorAction Stop

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
        $Principal,

        [ValidateSet('AlterAnyAvailabilityGroup','ViewServerState','AlterAnyEndPoint')]
        [System.String[]]
        $Permission
    )

    New-VerboseMessage -Message "Enumerating permissions for $Principal"

    try {
        $instance = Get-SQLPSInstance -NodeName $NodeName -InstanceName $InstanceName

        $permissionSet = Get-SQLServerPermissionSet -Permission $Permission
        $enumeratedPermission = $instance.EnumServerPermissions( $Principal, $permissionSet ) | Where-Object { $_.PermissionState -eq "Grant" }
        if( $null -ne $enumeratedPermission) {
            $grantedPermissionSet = Get-SQLServerPermissionSet -PermissionSet $enumeratedPermission.PermissionType
            if( -not ( Compare-Object -ReferenceObject $permissionSet -DifferenceObject $grantedPermissionSet -Property $Permission ) ) { 
                $ensure = "Present"
            } else {
                $ensure = "Absent"
            }

            $grantedPermission = Get-SQLPermission -ServerPermissionSet $grantedPermissionSet
        } else {
            $ensure = "Absent"
            $grantedPermission = ""
        }
    } catch {
        throw New-TerminatingError -ErrorType PermissionGetError -FormatArgs @($Principal) -ErrorCategory InvalidOperation -InnerException $_.Exception
    }

    $returnValue = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Ensure = [System.String] $ensure
        Principal = [System.String] $Principal
        Permission = [System.String[]] $grantedPermission
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
        $Principal,

        [ValidateSet('AlterAnyAvailabilityGroup','ViewServerState','AlterAnyEndPoint')]
        [System.String[]]
        $Permission
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Principal = [System.String] $Principal
        Permission = [System.String[]] $Permission
    }
    
    $permissionState = Get-TargetResource @parameters 
    if( $null -ne $permissionState ) {
        if( $Ensure -ne "" ) {
            if( $permissionState.Ensure -ne $Ensure ) {
                $instance = Get-SQLPSInstance -NodeName $NodeName -InstanceName $InstanceName
                if( $null -ne $instance ) {
                    $permissionSet = Get-SQLServerPermissionSet -Permission $Permission
                    
                    if( $Ensure -eq "Present") {
                        if( ( $PSCmdlet.ShouldProcess( $Principal, "Grant permission" ) ) ) {
                            $instance.Grant($permissionSet, $Principal )
                        }
                    } else {
                        if( ( $PSCmdlet.ShouldProcess( $Principal, "Revoke permission" ) ) ) {
                            $instance.Revoke($permissionSet, $Principal )
                        }
                    }
                } else {
                    throw New-TerminatingError -ErrorType PrincipalNotFound -FormatArgs @($Principal) -ErrorCategory ObjectNotFound
                }
            } else {
                New-VerboseMessage -Message "State is already $Ensure"
            }
        } else  {
            throw New-TerminatingError -ErrorType PermissionMissingEnsure -FormatArgs @($Principal) -ErrorCategory InvalidOperation
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
        $Principal,

        [ValidateSet('AlterAnyAvailabilityGroup','ViewServerState','AlterAnyEndPoint')]
        [System.String[]]
        $Permission
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Principal = [System.String] $Principal
        Permission = [System.String[]] $Permission
    }
    
    New-VerboseMessage -Message "Testing state of permissions for $Principal"

    $permissionState = Get-TargetResource @parameters 
    if( $null -ne $permissionState ) {
        [System.Boolean] $result = $false
        if( $permissionState.Ensure -eq $Ensure) {
            $result = $true
        }
    } else {
        throw New-TerminatingError -ErrorType UnexpectedErrorFromGet -ErrorCategory InvalidResult
    }

    return $result
}

function Get-SQLPermission
{
    [CmdletBinding()]
    [OutputType([String[]])]
    param (
        [Parameter(Mandatory,ParameterSetName="ServerPermissionSet",HelpMessage="Takes a PermissionSet which will be enumerated to return a string array.")]
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet]
        [ValidateNotNullOrEmpty()]
        $ServerPermissionSet
    )

    [String[]] $permission = @()
    
    if( $ServerPermissionSet ) {
        foreach( $Property in $($ServerPermissionSet | Get-Member -Type Property) ) {
            if( $ServerPermissionSet.$($Property.Name) ) {
                $permission += $Property.Name
            }
        }
    }
    
    return [String[]] $permission
}

function Get-SQLServerPermissionSet
{
    [CmdletBinding()]
    [OutputType([Object])] 
    param
    (
        [Parameter(Mandatory,ParameterSetName="Permission",HelpMessage="Takes an array of strings which will be concatenated to a single ServerPermissionSet.")]
        [System.String[]]
        [ValidateNotNullOrEmpty()]
        $Permission,
        
        [Parameter(Mandatory,ParameterSetName="ServerPermissionSet",HelpMessage="Takes an array of ServerPermissionSet which will be concatenated to a single ServerPermissionSet.")]
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet[]]
        [ValidateNotNullOrEmpty()]
        $PermissionSet
    )

    if( $Permission ) {
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet] $permissionSet = New-Object -TypeName Microsoft.SqlServer.Management.Smo.ServerPermissionSet

        foreach( $currentPermission in $Permission ) {
            $permissionSet.$($currentPermission) = $true
        }
    } else {
        $permissionSet = Merge-SQLPermissionSet -Object $PermissionSet 
    }
    
    return $permissionSet
}

function Merge-SQLPermissionSet {
    param (
        [Parameter(Mandatory)]
        [Microsoft.SqlServer.Management.Smo.ServerPermissionSet[]]
        [ValidateNotNullOrEmpty()]
        $Object
    )
 
    $baseObject = New-Object -TypeName ($Object[0].GetType())

    foreach ( $currentObject in $Object ) {
        foreach( $Property in $($currentObject | Get-Member -Type Property) ) {
            if( $currentObject.$($Property.Name) ) {
                $baseObject.$($Property.Name) = $currentObject.$($Property.Name)
            }
        }
    }

    return $baseObject
}

Export-ModuleMember -Function *-TargetResource
