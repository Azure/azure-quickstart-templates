function Get-TargetResource()
{
    [CmdletBinding()]
    [OutputType([System.Collections.HashTable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter()]
        [System.String]
        $Value,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Looking for SPWebApplication property '$Key'"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        $spWebApp = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($null -eq $spWebApp)
        {
            $currentValue = $null
            $localEnsure = 'Absent'
        }
        else
        {
            if ($spWebApp.Properties)
            {
                if ($spWebApp.Properties.Contains($params.Key) -eq $true)
                {
                    $localEnsure = "Present"
                    $currentValue = $spWebApp.Properties[$params.Key]
                }
                else
                {
                    $localEnsure = "Absent"
                    $currentValue = $null
                }
            }
        }

        return @{
            WebAppUrl = $params.WebAppUrl
            Key = $params.Key
            Value = $currentValue
            Ensure = $localEnsure
        }
    }
    return $result
}

function Set-TargetResource()
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter()]
        [System.String]
        $Value,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Setting SPWebApplication property '$Key'"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        $spWebApp = Get-SPWebApplication -Identity $params.WebAppUrl -ErrorAction SilentlyContinue

        if ($params.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Adding property '$($params.Key)'='$($params.value)' to SPWebApplication.Properties"
            $spWebApp.Properties[$params.Key] = $params.Value
            $spWebApp.Update()
        }
        else
        {
            Write-Verbose -Message "Removing property '$($params.Key)' from SPWebApplication.Properties"
            $spWebApp.Properties.Remove($params.Key)
            $spWebApp.Update()
        }
    }
}

function Test-TargetResource()
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [Parameter()]
        [System.String]
        $Value,

        [Parameter()]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose -Message "Testing SPWebApplication property '$Key'"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if($Ensure -eq 'Present')
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @('Ensure','Key', 'Value')
    }
    else
    {
        return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                        -DesiredValues $PSBoundParameters `
                                        -ValuesToCheck @('Ensure','Key')

    }

}

Export-ModuleMember -Function *-TargetResource
