function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    Try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $RootDSE = Get-ADRootDSE -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential
        $RecycleBinPath = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$($RootDSE.configurationNamingContext)"
        $msDSEnabledFeature = Get-ADObject -Identity "CN=Partitions,$($RootDSE.configurationNamingContext)" -Property msDS-EnabledFeature -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential |
            Select-Object -ExpandProperty msDS-EnabledFeature

        If ($msDSEnabledFeature -contains $RecycleBinPath) {
            $RecycleBinEnabled = $True
        } Else {
            $RecycleBinEnabled = $False
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception getting Recycle Bin status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
    }

    $returnValue = @{
        ForestFQDN = $ForestFQDN
        RecycleBinEnabled = $RecycleBinEnabled
        ForestMode = $RootDSE.forestFunctionality.ToString()
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )


    Try
    {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $Forest = Get-ADForest -Identity $ForestFQDN -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential

        # Check minimum forest level and throw if not
        If (($Forest.ForestMode -as [int]) -lt 4) {
            Write-Verbose -Message "Forest functionality level $($Forest.ForestMode) does not meet minimum requirement of Windows2008R2Forest or greater."
            Throw "Forest functionality level $($Forest.ForestMode) does not meet minimum requirement of Windows2008R2Forest or greater."
        }

        If ($PSCmdlet.ShouldProcess($Forest.RootDomain, "Enable Active Directory Recycle Bin")) {
            Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet `
                -Target $Forest.RootDomain -Server $Forest.DomainNamingMaster `
                -Credential $EnterpriseAdministratorCredential `
                -Verbose
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception setting Recycle Bin status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
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
        $ForestFQDN,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $EnterpriseAdministratorCredential
    )

    Try {
        # AD cmdlets generate non-terminating errors.
        $ErrorActionPreference = 'Stop'

        $RootDSE = Get-ADRootDSE -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential
        $RecycleBinPath = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,$($RootDSE.configurationNamingContext)"
        $msDSEnabledFeature = Get-ADObject -Identity "CN=Partitions,$($RootDSE.configurationNamingContext)" -Property msDS-EnabledFeature -Server $ForestFQDN -Credential $EnterpriseAdministratorCredential |
            Select-Object -ExpandProperty msDS-EnabledFeature

        If ($msDSEnabledFeature -contains $RecycleBinPath) {
            Write-Verbose "Active Directory Recycle Bin is enabled."
            Return $True
        } Else {
            Write-Verbose "Active Directory Recycle Bin is not enabled."
            Return $False
        }
    }

    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException],[Microsoft.ActiveDirectory.Management.ADServerDownException] {
        Write-Error -Message "Cannot contact forest $ForestFQDN. Check the spelling of the Forest FQDN and make sure that a domain contoller is available on the network."
        Throw $_
    }
    Catch [System.Security.Authentication.AuthenticationException] {
        Write-Error -Message "Credential error. Check the username and password used."
        Throw $_
    }
    Catch {
        Write-Error -Message "Unhandled exception testing Recycle Bin status for forest $ForestFQDN."
        Throw $_
    }

    Finally {
        $ErrorActionPreference = 'Continue'
    }


}


Export-ModuleMember -Function *-TargetResource

<#
Test syntax:

$cred = Get-Credential contoso\administrator

# Valid Domain
Get-TargetResource -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred
Test-TargetResource -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred
Set-TargetResource -ForestFQDN contoso.com -EnterpriseAdministratorCredential $cred -WhatIf

# Invalid Domain
Get-TargetResource -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred
Test-TargetResource -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred
Set-TargetResource -ForestFQDN contoso.cm -EnterpriseAdministratorCredential $cred -WhatIf
#>



