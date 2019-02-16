function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Name,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAccount,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Getting service application pool '$Name'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $sap = Get-SPServiceApplicationPool -Identity $params.Name `
                                            -ErrorAction SilentlyContinue
        if ($null -eq $sap) 
        {
            return @{
                Name = $params.Name
                ServiceAccount = $params.ProcessAccountName
                InstallAccount = $params.InstallAccount
                Ensure = "Absent"
            } 
        }
        return @{
            Name = $sap.Name
            ServiceAccount = $sap.ProcessAccountName
            InstallAccount = $params.InstallAccount
            Ensure = "Present"
        }
    }
    return $result
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]  
        [System.String] 
        $Name,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAccount,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Setting service application pool '$Name'"
    
    $CurrentValues = Get-TargetResource @PSBoundParameters
    
    if ($CurrentValues.Ensure -eq "Absent" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Creating Service Application Pool $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            New-SPServiceApplicationPool -Name $params.Name `
                                         -Account $params.ServiceAccount
            
            $sap = Get-SPServiceApplicationPool -Identity $params.Name `
                                                -ErrorAction SilentlyContinue
            if ($null -ne $sap) 
            {
                if ($sap.ProcessAccountName -ne $params.ServiceAccount) 
                {
                    Set-SPServiceApplicationPool -Identity $params.Name `
                                                 -Account $params.ServiceAccount
                }
            }
        }
    }
    if ($CurrentValues.Ensure -eq "Present" -and $Ensure -eq "Present") 
    {
        Write-Verbose -Message "Updating Service Application Pool $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            
            $sap = Get-SPServiceApplicationPool -Identity $params.Name `
                                                -ErrorAction SilentlyContinue
            if ($sap.ProcessAccountName -ne $params.ServiceAccount) 
            {
                Set-SPServiceApplicationPool -Identity $params.Name `
                                             -Account $params.ServiceAccount
            }
        }
    }
    if ($Ensure -eq "Absent") 
    {
        Write-Verbose -Message "Removing Service Application Pool $Name"
        Invoke-SPDSCCommand -Credential $InstallAccount `
                            -Arguments $PSBoundParameters `
                            -ScriptBlock {
            $params = $args[0]
            Remove-SPServiceApplicationPool -Identity $params.Name -Confirm:$false
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
        [System.String] 
        $Name,

        [Parameter(Mandatory = $true)]  
        [System.String] 
        $ServiceAccount,

        [Parameter()] 
        [ValidateSet("Present","Absent")] 
        [System.String] 
        $Ensure = "Present",

        [Parameter()] 
        [System.Management.Automation.PSCredential] 
        $InstallAccount
    )

    Write-Verbose -Message "Testing service application pool '$Name'"

    $PSBoundParameters.Ensure = $Ensure

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($Ensure -eq "Present") 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("ServiceAccount", "Ensure")
    } 
    else 
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @("Ensure")    
    }    
}

Export-ModuleMember -Function *-TargetResource
