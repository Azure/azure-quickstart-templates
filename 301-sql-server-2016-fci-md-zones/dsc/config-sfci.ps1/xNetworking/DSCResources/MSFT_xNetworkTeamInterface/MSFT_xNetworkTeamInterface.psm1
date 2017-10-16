#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xNetworkTeamInterface.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xNetworkTeamInterface.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $TeamName
    )

    $configuration = @{
        name = $Name
        teamName = $TeamName
    }

    Write-Verbose -Message ($localizedData.GetTeamNicInfo -f $Name)
    $teamNic = Get-NetLbfoTeamNic -Name $Name -Team $TeamName -ErrorAction SilentlyContinue

    if ($teamNic)
    {
        Write-Verbose -Message ($localizedData.FoundTeamNic -f $Name)
        $configuration.Add("vlanID", $teamNic.VlanID)
        $configuration.Add("ensure", "Present")
    }
    else
    {
        Write-Verbose -Message ($localizedData.TeamNicNotFound -f $Name)
        $configuration.Add("ensure", "Absent")
    }

    $configuration
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $TeamName,

        [System.UInt32]
        $VlanID,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message ($LocalizedData.GetTeamNicInfo -f $Name)
    $teamNic = Get-NetLbfoTeamNic -Name $Name -Team $TeamName -ErrorAction SilentlyContinue

    if ($Ensure -eq "Present")
    {
        if ($teamNic)
        {
            Write-Verbose -Message ($LocalizedData.FoundTeamNic -f $Name)
            if ($teamNic.VlanID -ne $VlanID)
            {
                Write-Verbose -Message ($LocalizedData.TeamNicVlanMismatch -f $VlanID)
                $isNetModifyRequired = $true
            }

            if ($isNetModifyRequired)
            {
                Write-Verbose -Message ($LocalizedData.ModifyTeamNic -f $Name)
                if ($VlanID -eq 0)
                {
                    Set-NetLbfoTeamNic -Name $Name -Team $TeamName -Default `
                                       -ErrorAction Stop -Confirm:$false
                }
                else
                {
                    # Required in case of primary interface, whose name gets changed
                    # to include VLAN ID, if specified
                    Set-NetLbfoTeamNic -Name $Name -Team $TeamName -VlanID $VlanID `
                                       -ErrorAction Stop -Confirm:$false -PassThru `
                                       | Rename-NetAdapter -NewName $Name `
                                                           -ErrorAction SilentlyContinue `
                                                           -Confirm:$false
                }
            }
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.CreateTeamNic -f $Name)
            if ($VlanID -ne 0)
            {
                $null = Add-NetLbfoTeamNic -Name $Name -Team $TeamName -VlanID $VlanID `
                                           -ErrorAction Stop -Confirm:$false
                Write-Verbose -Message ($LocalizedData.CreatedNetTeamNic -f $Name)
            }
            else
            {
                $errorId = "TeamNicCreateError"
                $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                $errorMessage = $LocalizedData.FailedToCreateTeamNic
                $exception = New-Object -TypeName System.InvalidOperationException `
                                        -ArgumentList $errorMessage
                $errorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                                          -ArgumentList $exception, $errorId, $errorCategory, $null
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
        }
    }
    else
    {
        Write-Verbose -Message ($LocalizedData.RemoveTeamNic -f $Name)
        $null = Remove-NetLbfoTeamNic -Team $teamNic.Team -VlanID $teamNic.VlanID `
                                      -ErrorAction Stop -Confirm:$false
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
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $TeamName,

        [System.UInt32]
        $VlanID,

        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )

    Write-Verbose -Message ($LocalizedData.GetTeamNicInfo -f $Name)
    $teamNic = Get-NetLbfoTeamNic -Name $Name -Team $TeamName -ErrorAction SilentlyContinue

    if ($Ensure -eq "Present")
    {
        if ($teamNic)
        {
            Write-Verbose -Message ($LocalizedData.FoundTeamNic -f $Name)
            if ($teamNic.VlanID -eq $VlanID)
            {
                Write-Verbose -Message ($LocalizedData.TeamNicExistsNoAction -f $Name)
                return $true
            }
            else
            {
                Write-Verbose -Message ($LocalizedData.TeamNicExistsWithDifferentConfig -f $Name)
                return $false
            }
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.TeamNicDoesNotExistShouldCreate -f $Name)
            return $false
        }
    }
    else
    {
        if ($teamNic)
        {
            Write-Verbose -Message ($LocalizedData.TeamNicExistsShouldRemove -f $Name)
            return $false
        }
        else
        {
            Write-Verbose -Message ($LocalizedData.TeamNicExistsNoAction -f $Name)
            return $true
        }
    }
}

Export-ModuleMember -Function *-TargetResource
