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
        [ValidateLength(1,15)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroup
    )

    try {
        $listener = Get-SQLAlwaysOnAvailabilityGroupListener -Name $Name -AvailabilityGroup $AvailabilityGroup -NodeName $NodeName -InstanceName $InstanceName
        
        if( $null -ne $listener ) {
            New-VerboseMessage -Message "Listener $Name already exist"

            $ensure = "Present"
            
            $port = [uint16]( $listener | Select-Object -ExpandProperty PortNumber )

            $presentIpAddress = $listener.AvailabilityGroupListenerIPAddresses

            $dhcp = [bool]( $presentIpAddress | Select-Object -First 1 -ExpandProperty IsDHCP )

            $ipAddress = @()
            foreach( $currentIpAddress in $presentIpAddress ) {
                $ipAddress += "$($currentIpAddress.IPAddress)/$($currentIpAddress.SubnetMask)"
            } 
        } else {
            New-VerboseMessage -Message "Listener $Name does not exist"

            $ensure = "Absent"
            $port = 0
            $dhcp = $false
            $ipAddress = $null
        }
    } catch {
        throw New-TerminatingError -ErrorType AvailabilityGroupListenerNotFound -FormatArgs @($Name) -ErrorCategory ObjectNotFound -InnerException $_.Exception
    }

    $returnValue = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        Ensure = [System.String] $ensure
        AvailabilityGroup = [System.String] $AvailabilityGroup
        IpAddress = [System.String[]] $ipAddress
        Port = [System.UInt16] $port
        DHCP = [System.Boolean] $dhcp
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
        [ValidateLength(1,15)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroup,

        [System.String[]]
        $IpAddress,

        [System.UInt16]
        $Port,

        [System.Boolean]
        $DHCP
    )
   
    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        AvailabilityGroup = [System.String] $AvailabilityGroup
    }
    
    $listenerState = Get-TargetResource @parameters 
    if( $null -ne $listenerState ) {
        if( $Ensure -ne "" -and $listenerState.Ensure -ne $Ensure ) {
            $InstanceName = Get-SQLPSInstanceName -InstanceName $InstanceName
            
            if( $Ensure -eq "Present") {
                if( ( $PSCmdlet.ShouldProcess( $Name, "Create listener on $AvailabilityGroup" ) ) ) {
                    $newListenerParams = @{
                        Name = $Name
                        Path = "SQLSERVER:\SQL\$NodeName\$InstanceName\AvailabilityGroups\$AvailabilityGroup"
                    }

                    if( $Port ) {
                        New-VerboseMessage -Message "Listener port set to $Port"
                        $newListenerParams += @{
                            Port = $Port
                        }
                    }

                    if( $DHCP -and $IpAddress.Count -gt 0 ) {
                        New-VerboseMessage -Message "Listener set to DHCP with subnet $IpAddress"
                        $newListenerParams += @{
                            DhcpSubnet = [string]$IpAddress
                        }
                    } elseif ( -not $DHCP -and $IpAddress.Count -gt 0 ) {
                        New-VerboseMessage -Message "Listener set to static IP-address(es); $($IpAddress -join ', ')"
                        $newListenerParams += @{
                            StaticIp = $IpAddress
                        }
                    } else {
                        New-VerboseMessage -Message "Listener using DHCP with server default subnet"
                    }
                                        
                    New-SqlAvailabilityGroupListener @newListenerParams -Verbose:$False | Out-Null   # Suppressing Verbose because it prints the entire T-SQL statement otherwise
                }
            } else {
                if( ( $PSCmdlet.ShouldProcess( $Name, "Remove listener from $AvailabilityGroup" ) ) ) {
                    Remove-Item "SQLSERVER:\SQL\$NodeName\$InstanceName\AvailabilityGroups\$AvailabilityGroup\AvailabilityGroupListeners\$Name"
                }
            }
        } else {
            if( $Ensure -ne "" ) { New-VerboseMessage -Message "State is already $Ensure" }
            
            if( $listenerState.Ensure -eq "Present") {
                if( -not $DHCP -and $listenerState.IpAddress.Count -lt $IpAddress.Count ) { # Only able to add a new IP-address, not change existing ones.
                    New-VerboseMessage -Message "Found at least one new IP-address."
                    $ipAddressEqual = $False
                } else {
                    # No new IP-address
                    if( $null -eq $IpAddress -or -not ( Compare-Object -ReferenceObject $IpAddress -DifferenceObject $listenerState.IpAddress ) ) { 
                       $ipAddressEqual = $True
                    } else {
                        throw New-TerminatingError -ErrorType AvailabilityGroupListenerIPChangeError -FormatArgs @($($IpAddress -join ', '),$($listenerState.IpAddress -join ', ')) -ErrorCategory InvalidOperation
                    }
                }

                if( $($PSBoundParameters.ContainsKey('DHCP')) -and $listenerState.DHCP -ne $DHCP ) {
                    throw New-TerminatingError -ErrorType AvailabilityGroupListenerDHCPChangeError -FormatArgs @( $DHCP, $($listenerState.DHCP) ) -ErrorCategory InvalidOperation
                }
                
                if( $listenerState.Port -ne $Port -or -not $ipAddressEqual ) {
                    New-VerboseMessage -Message "Listener differ in configuration."

                    if( $listenerState.Port -ne $Port ) {
                        if( ( $PSCmdlet.ShouldProcess( $Name, "Changing port configuration" ) ) ) {
                            $InstanceName = Get-SQLPSInstanceName -InstanceName $InstanceName
                            
                            $setListenerParams = @{
                                Path = "SQLSERVER:\SQL\$NodeName\$InstanceName\AvailabilityGroups\$AvailabilityGroup\AvailabilityGroupListeners\$Name"
                                Port = $Port
                            }

                            Set-SqlAvailabilityGroupListener @setListenerParams -Verbose:$False | Out-Null # Suppressing Verbose because it prints the entire T-SQL statement otherwise
                        }
                    }

                    if( -not $ipAddressEqual ) {
                        if( ( $PSCmdlet.ShouldProcess( $Name, "Adding IP-address(es)" ) ) ) {
                            $InstanceName = Get-SQLPSInstanceName -InstanceName $InstanceName
                            
                            $newIpAddress = @()
                            
                            foreach( $currentIpAddress in $IpAddress ) {
                                if( -not ( $listenerState.IpAddress -contains $currentIpAddress ) ) {
                                    $newIpAddress += $currentIpAddress
                                }
                            }
                            
                            $setListenerParams = @{
                                Path = "SQLSERVER:\SQL\$NodeName\$InstanceName\AvailabilityGroups\$AvailabilityGroup\AvailabilityGroupListeners\$Name"
                                StaticIp = $newIpAddress
                            }

                            Add-SqlAvailabilityGroupListenerStaticIp @setListenerParams -Verbose:$False | Out-Null # Suppressing Verbose because it prints the entire T-SQL statement otherwise
                        }
                    }

                } else {
                    New-VerboseMessage -Message "Listener configuration is already correct."
                }
            } else {
                throw New-TerminatingError -ErrorType AvailabilityGroupListenerNotFound -ErrorCategory ObjectNotFound
            }
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
        [ValidateLength(1,15)]
        [System.String]
        $Name,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroup,

        [System.String[]]
        $IpAddress,

        [System.UInt16]
        $Port,

        [System.Boolean]
        $DHCP
    )

    $parameters = @{
        InstanceName = [System.String] $InstanceName
        NodeName = [System.String] $NodeName
        Name = [System.String] $Name
        AvailabilityGroup = [System.String] $AvailabilityGroup
    }
    
    New-VerboseMessage -Message "Testing state of listener $Name"
    
    $listenerState = Get-TargetResource @parameters 
    if( $null -ne $listenerState ) {
        if( $null -eq $IpAddress -or ($null -ne $listenerState.IpAddress -and -not ( Compare-Object -ReferenceObject $IpAddress -DifferenceObject $listenerState.IpAddress ) ) ) { 
            $ipAddressEqual = $true
        } else {
            $ipAddressEqual = $false
        }
        
        [System.Boolean] $result = $false
        if( $listenerState.Ensure -eq $Ensure)  {
            if( $Ensure -eq 'Absent' ) {
                $result = $true
            }
        }

        if( -not $($PSBoundParameters.ContainsKey('Ensure')) -or $Ensure -eq "Present" ) { 
            if( ( $Port -eq "" -or $listenerState.Port -eq $Port) -and 
                $ipAddressEqual -and 
                ( -not $($PSBoundParameters.ContainsKey('DHCP')) -or $listenerState.DHCP -eq $DHCP ) ) 
            {
                $result = $true
            }
        }

    } else {
        throw New-TerminatingError -ErrorType UnexpectedErrorFromGet -ErrorCategory InvalidResult
    }

    return $result
}

function Get-SQLAlwaysOnAvailabilityGroupListener
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [System.String]
        $InstanceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NodeName 
    )

    $instance = Get-SQLPSInstance -InstanceName $InstanceName -NodeName $NodeName
    $Path = "$($instance.PSPath)\AvailabilityGroups\$AvailabilityGroup\AvailabilityGroupListeners"

    Write-Debug "Connecting to $Path as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
    
    [String[]] $presentListener = Get-ChildItem $Path
    if( $presentListener.Count -ne 0 -and $presentListener.Contains("[$Name]") ) {
        Write-Debug "Connecting to availability group $Name as $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)"
        $listener = Get-Item "$Path\$Name"
    } else {
        $listener = $null
    }    

    return $listener
}

Export-ModuleMember -Function *-TargetResource
