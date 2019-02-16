function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Compliant","NonCompliant")]
        [System.String]
        $State,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Getting MinRole compliance for the current farm"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($installedVersion.FileMajorPart -ne 16)
    {
        throw [Exception] "MinRole is only supported in SharePoint 2016 and 2019."
    }

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $nonCompliantServices = Get-SPService | Where-Object -FilterScript {
            $_.CompliantWithMinRole -eq $false
        }

        if ($null -eq $nonCompliantServices)
        {
            return @{
                IsSingleInstance = "Yes"
                State            = "Compliant"
                InstallAccount   = $params.InstallAccount
            }
        }
        else
        {
            return @{
                IsSingleInstance = "Yes"
                State            = "NonCompliant"
                InstallAccount   = $params.InstallAccount
            }
        }
    }
    return $result
}

function Get-SPDscRoleTestMethod
{
    $assembly = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
    $type = $assembly.GetType("Microsoft.SharePoint.Administration.SPServerRoleManager")
    $flags = [Reflection.BindingFlags] "NonPublic,Static"
    return $type.GetMethod("IsCompliantWithMinRole",$flags)
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Compliant","NonCompliant")]
        [System.String]
        $State,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting MinRole compliance for the current farm"

    $installedVersion = Get-SPDSCInstalledProductVersion
    if ($installedVersion.FileMajorPart -ne 16)
    {
        throw [Exception] "MinRole is only supported in SharePoint 2016 and 2019."
    }

    if ($State -eq "NonCompliant")
    {
        throw ("State can only be configured to 'Compliant'. The 'NonCompliant' value is only " + `
               "used to report when the farm is not compliant")
    }

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $method = Get-SPDscRoleTestMethod

        Get-SPService | Where-Object -FilterScript {
            $_.CompliantWithMinRole -eq $false
        } | ForEach-Object -Process {
            $_.Instances | ForEach-Object -Process {
                $isCompliant = $method.Invoke($null, $_)

                if ($isCompliant -eq $false)
                {
                    if ($_.Status -eq "Disabled")
                    {
                        Write-Verbose -Message "Starting service '$($_.TypeName)' on '$($_.Server.Name)'"
                        Start-SPServiceInstance -Identity $_.Id | Out-Null
                    }
                    if ($_.Status -eq "Online")
                    {
                        Write-Verbose -Message "Stopping service '$($_.TypeName)' on '$($_.Server.Name)'"
                        Stop-SPServiceInstance -Identity $_.Id -Confirm:$false | Out-Null
                    }
                }
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Compliant","NonCompliant")]
        [System.String]
        $State,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing MinRole compliance for the current farm"

    if ($State -eq "NonCompliant")
    {
        throw ("State can only be configured to 'Compliant'. The 'NonCompliant' value is only " + `
               "used to report when the farm is not compliant")
    }

    $CurrentValues = Get-TargetResource @PSBoundParameters

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters `
                                    -ValuesToCheck @("State")
}

Export-ModuleMember -Function Get-TargetResource, `
                              Test-TargetResource, `
                              Set-TargetResource, `
                              Get-SPDscRoleTestMethod
