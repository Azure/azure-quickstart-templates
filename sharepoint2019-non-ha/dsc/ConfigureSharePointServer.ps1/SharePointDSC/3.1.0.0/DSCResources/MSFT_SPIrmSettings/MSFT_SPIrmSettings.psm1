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

        [Parameter()]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure,

        [Parameter()]
        [System.Boolean]
        $UseADRMS,

        [Parameter()]
        [System.String]
        $RMSserver,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose "Getting SharePoint IRM Settings"

    $result = Invoke-SPDSCCommand -Credential $InstallAccount `
                                  -Arguments $PSBoundParameters `
                                  -ScriptBlock {
        $params = $args[0]

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            Write-Verbose -Message ("No local SharePoint farm was detected. IRM settings " + `
                                    "will not be applied")
            return @{
                    IsSingleInstance = "Yes"
                    Ensure = "Absent"
                    UseADRMS =  $UseADRMS
                    RMSserver = $RMSserver
                   }
        }

        # Get a reference to the Administration WebService
        $admService = Get-SPDSCContentService

        if ($admService.IrmSettings.IrmRMSEnabled)
        {
            $Ensure = "Present"
        }
        else
        {
            $Ensure = "Absent"
        }

        return @{
            IsSingleInstance = "Yes"
            Ensure = $Ensure
            UseADRMS =  $admService.IrmSettings.IrmRMSUseAD
            RMSserver = $admService.IrmSettings.IrmRMSCertServer
        }
   }
   return $Result
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

        [Parameter()]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure,

        [Parameter()]
        [System.Boolean]
        $UseADRMS,

        [Parameter()]
        [System.String]
        $RMSserver,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose "Setting SharePoint IRM Settings"

    Invoke-SPDSCCommand -Credential $InstallAccount `
                        -Arguments $PSBoundParameters `
                        -ScriptBlock {
        $params = $args[0]

        try
        {
            $spFarm = Get-SPFarm
        }
        catch
        {
            throw "No local SharePoint farm was detected. IRM settings will not be applied"
            return
        }

        $admService = Get-SPDSCContentService

        if ($params.UseADRMS -and ($null -ne $params.RMSserver))
        {
            throw "Cannot specify both an RMSserver and set UseADRMS to True"
        }

        if ($params.UseADRMS -ne $true)
        {
            $params.UseADRMS = $false
        }

        if ($params.Ensure -eq "Present")
        {
            $admService.IrmSettings.IrmRMSEnabled = $true
            $admService.IrmSettings.IrmRMSUseAD = $params.UseADRMS
            $admService.IrmSettings.IrmRMSCertServer = $params.RMSserver
        }
        else
        {
            $admService.IrmSettings.IrmRMSEnabled = $false
            $admService.IrmSettings.IrmRMSUseAD = $false
            $admService.IrmSettings.IrmRMSCertServer = $null
        }
        $admService.Update()
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

        [Parameter()]
        [System.String]
        [ValidateSet("Present","Absent")]
        $Ensure,

        [Parameter()]
        [System.Boolean]
        $UseADRMS,

        [Parameter()]
        [System.String]
        $RMSserver,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $InstallAccount
    )

    Write-Verbose "Testing SharePoint IRM settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    if ($null -eq $CurrentValues)
    {
        return $false
    }

    if ($UseADRMS -ne $true)
    {
        $PSBoundParameters.UseADRMS = $false
    }

    return Test-SPDscParameterState -CurrentValues $CurrentValues `
                                    -DesiredValues $PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
