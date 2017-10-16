#region localizeddata
if (Test-Path "${PSScriptRoot}\${PSUICulture}")
{
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xNetworkTeam.psd1 `
                         -BaseDirectory "${PSScriptRoot}\${PSUICulture}"
} 
else
{
    #fallback to en-US
    Import-LocalizedData -BindingVariable LocalizedData -filename MSFT_xNetworkTeam.psd1 `
                         -BaseDirectory "${PSScriptRoot}\en-US"
}
#endregion

Function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])] 
    Param
    (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [String[]]$TeamMembers
    )
    
    $configuration = @{
        name = $Name
        teamMembers = $TeamMembers
    }

    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLBFOTeam -Name $Name -ErrorAction SilentlyContinue

    if ($networkTeam) 
    {
        Write-Verbose -Message ($localizedData.FoundTeam -f $Name)
        if ($null -eq (Compare-Object -ReferenceObject $TeamMembers -DifferenceObject $networkTeam.Members))
        {
            Write-Verbose -Message ($localizedData.teamMembersExist -f $Name)
            $configuration.Add('loadBalancingAlgorithm', $networkTeam.loadBalancingAlgorithm)
            $configuration.Add('teamingMode', $networkTeam.teamingMode)
            $configuration.Add('ensure','Present')
        }
    }
    else
    {
        Write-Verbose -Message ($localizedData.TeamNotFound -f $Name)
        $configuration.Add('ensure','Absent')
    }
    $configuration
}

Function Set-TargetResource 
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [String[]]$TeamMembers,
    
        [Parameter()]
        [ValidateSet("SwitchIndependent", "LACP", "Static")]
        [String]$TeamingMode = "SwitchIndependent",

        [Parameter()]
        [ValidateSet("Dynamic", "HyperVPort", "IPAddresses", "MacAddresses", "TransportPorts")]
        [String]$LoadBalancingAlgorithm = "HyperVPort",

        [ValidateSet('Present', 'Absent')]
        [String]$Ensure = 'Present'
    )
    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLBFOTeam -Name $Name -ErrorAction SilentlyContinue

    if ($Ensure -eq 'Present')
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.foundTeam -f $Name)
            $setArguments = @{
                'name' = $Name
            }

            if ($networkTeam.loadBalancingAlgorithm -ne $LoadBalancingAlgorithm)
            {
                Write-Verbose -Message ($localizedData.lbAlgoDifferent -f $LoadBalancingAlgorithm)
                $SetArguments.Add('loadBalancingAlgorithm', $LoadBalancingAlgorithm)
                $isNetModifyRequired = $true
            }

            if ($networkTeam.TeamingMode -ne $TeamingMode)
            {
                Write-Verbose -Message ($localizedData.teamingModeDifferent -f $TeamingMode)
                $setArguments.Add('teamingMode', $TeamingMode)
                $isNetModifyRequired = $true
            }
            
            if ($isNetModifyRequired)
            {
                Write-Verbose -Message ($localizedData.modifyTeam -f $Name)
                Set-NetLbfoTeam @setArguments -ErrorAction Stop -Confirm:$false
            }

            $netTeamMembers = Compare-Object `
                            -ReferenceObject $TeamMembers `
                            -DifferenceObject $networkTeam.Members
            if ($null -ne $netTeamMembers)
            {
                Write-Verbose -Message ($localizedData.membersDifferent -f $Name)
                $membersToRemove = ($netTeamMembers | Where-Object {$_.SideIndicator -eq '=>'}).InputObject
                if ($membersToRemove)
                {
                    Write-Verbose -Message ($localizedData.removingMembers -f ($membersToRemove -join ','))
                    $null = Remove-NetLbfoTeamMember -Name $membersToRemove `
                                                    -Team $Name `
                                                    -ErrorAction Stop `
                                                    -Confirm:$false
                }

                $membersToAdd = ($netTeamMembers | Where-Object {$_.SideIndicator -eq '<='}).InputObject
                if ($membersToAdd)
                {
                    Write-Verbose -Message ($localizedData.addingMembers -f ($membersToAdd -join ','))
                    $null = Add-NetLbfoTeamMember -Name $membersToAdd `
                                        -Team $Name `
                                        -ErrorAction Stop `
                                        -Confirm:$false
                }
            }
            
        } 
        else 
        {
            Write-Verbose -Message ($localizedData.createTeam -f $Name)
            try
            {
                $null = New-NetLbfoTeam `
                            -Name $Name `
                            -TeamMembers $teamMembers `
                            -TeamingMode $TeamingMode `
                            -LoadBalancingAlgorithm $loadBalancingAlgorithm `
                            -ErrorAction Stop `
                            -Confirm:$false
                Write-Verbose -Message $localizedData.createdNetTeam
            }

            catch
            {
                    $errorId = 'TeamCreateError'
                    $errorCategory = [System.Management.Automation.ErrorCategory]::InvalidOperation
                    $errorMessage = $localizedData.failedToCreateTeam
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
        Write-Verbose -Message ($localizedData.removeTeam -f $Name)
        $null = Remove-NetLbfoTeam -Name $name -ErrorAction Stop -Confirm:$false
    }
}

Function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    Param
    (
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [String[]]$TeamMembers,
    
        [Parameter()]
        [ValidateSet("SwitchIndependent", "LACP", "Static")]
        [String]$TeamingMode = "SwitchIndependent",

        [Parameter()]
        [ValidateSet("Dynamic", "HyperVPort", "IPAddresses", "MacAddresses", "TransportPorts")]
        [String]$LoadBalancingAlgorithm = "HyperVPort",

        [ValidateSet('Present', 'Absent')]
        [String]$Ensure = 'Present'
    )
    
    Write-Verbose -Message ($localizedData.GetTeamInfo -f $Name)
    $networkTeam = Get-NetLbfoTeam -Name $Name -ErrorAction SilentlyContinue
    
    if ($ensure -eq 'Present')
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.foundTeam -f $Name)
            if (
                ($networkTeam.LoadBalancingAlgorithm -eq $LoadBalancingAlgorithm) -and 
                ($networkTeam.teamingMode -eq $TeamingMode) -and 
                ($null -eq (Compare-Object -ReferenceObject $TeamMembers -DifferenceObject $networkTeam.Members))
            )
            {
                Write-Verbose -Message ($localizedData.teamExistsNoAction -f $Name)
                return $true
            }
            else
            {
                Write-Verbose -Message ($localizedData.teamExistsWithDifferentConfig -f $Name)
                return $false
            }
        }
        else
        {
            Write-Verbose -Message ($localizedData.teamDoesNotExistShouldCreate -f $Name)
            return $false
        }
    }
    else
    {
        if ($networkTeam)
        {
            Write-Verbose -Message ($localizedData.teamExistsShouldRemove -f $Name)
            return $false
        }
        else
        {
            Write-Verbose -Message ($localizedData.teamDoesNotExistNoAction -f $Name)
            return $true
        }
    }
}
