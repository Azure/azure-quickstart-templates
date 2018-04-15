# Localized messages
data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
        RoleNotFoundError        = Please ensure that the PowerShell module for role '{0}' is installed
        RetrievingOU             = Retrieving OU '{0}'.
        UpdatingOU               = Updating OU '{0}'
        DeletingOU               = Deleting OU '{0}'
        CreatingOU               = Creating OU '{0}'
        OUInDesiredState         = OU '{0}' exists and is in the desired state
        OUNotInDesiredState      = OU '{0}' exists but is not in the desired state
        OUExistsButShouldNot     = OU '{0}' exists when it should not exist
        OUDoesNotExistButShould  = OU '{0}' does not exist when it should exist
'@
}

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (    
        [parameter(Mandatory)] 
        [System.String] $Name,

        [parameter(Mandatory)] 
        [System.String] $Path
    )
    
    Assert-Module -ModuleName 'ActiveDirectory';
    Write-Verbose ($LocalizedData.RetrievingOU -f $Name)
    $ou = Get-ADOrganizationalUnit -Filter { Name -eq $Name } -SearchBase $Path -SearchScope OneLevel -Properties ProtectedFromAccidentalDeletion, Description

    $targetResource = @{
        Name = $Name
        Path = $Path
        Ensure = if ($null -eq $ou) { 'Absent' } else { 'Present' }
        ProtectedFromAccidentalDeletion = $ou.ProtectedFromAccidentalDeletion
        Description = $ou.Description
    }
    return $targetResource

} # end function Get-TargetResource

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [parameter(Mandatory)] 
        [System.String] $Name,

        [parameter(Mandatory)] 
        [System.String] $Path,
        
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNull()]
        [System.Boolean] $ProtectedFromAccidentalDeletion = $true,

        [ValidateNotNull()]
        [System.String] $Description = ''
    )

    $targetResource = Get-TargetResource -Name $Name -Path $Path
    
    if ($targetResource.Ensure -eq 'Present')
    {
        if ($Ensure -eq 'Present')
        {
            ## Organizational unit exists
            if ([System.String]::IsNullOrEmpty($Description)) {
                $isCompliant = (($targetResource.Name -eq $Name) -and
                                    ($targetResource.Path -eq $Path) -and
                                        ($targetResource.ProtectedFromAccidentalDeletion -eq $ProtectedFromAccidentalDeletion))
            }
            else {
                $isCompliant = (($targetResource.Name -eq $Name) -and
                                    ($targetResource.Path -eq $Path) -and
                                        ($targetResource.ProtectedFromAccidentalDeletion -eq $ProtectedFromAccidentalDeletion) -and
                                            ($targetResource.Description -eq $Description))
            }

            if ($isCompliant)
            {
                Write-Verbose ($LocalizedData.OUInDesiredState -f $targetResource.Name)
            }
            else
            {
                Write-Verbose ($LocalizedData.OUNotInDesiredState -f $targetResource.Name)
            }
        }
        else
        {
            $isCompliant = $false
            Write-Verbose ($LocalizedData.OUExistsButShouldNot -f $targetResource.Name)
        }
    }
    else
    {
        ## Organizational unit does not exist
        if ($Ensure -eq 'Present')
        {
            $isCompliant = $false
            Write-Verbose ($LocalizedData.OUDoesNotExistButShould -f $targetResource.Name)
        }
        else
        {
            $isCompliant = $true
            Write-Verbose ($LocalizedData.OUInDesiredState -f $targetResource.Name)
        }
    }

    return $isCompliant

} #end function Test-TargetResource

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (    
        [parameter(Mandatory)] 
        [System.String] $Name,

        [parameter(Mandatory)] 
        [System.String] $Path,
        
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.CredentialAttribute()]
        $Credential,

        [ValidateNotNull()]
        [System.Boolean] $ProtectedFromAccidentalDeletion = $true,

        [ValidateNotNull()]
        [System.String] $Description = ''
    )

    Assert-Module -ModuleName 'ActiveDirectory';
    $targetResource = Get-TargetResource -Name $Name -Path $Path
    
    if ($targetResource.Ensure -eq 'Present')
    {
        $ou = Get-ADOrganizationalUnit -Filter { Name -eq $Name } -SearchBase $Path -SearchScope OneLevel
        if ($Ensure -eq 'Present')
        {
            Write-Verbose ($LocalizedData.UpdatingOU -f $targetResource.Name)
            $setADOrganizationalUnitParams = @{
                Identity = $ou
                Description = $Description
                ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
            }
            if ($Credential)
            {
                $setADOrganizationalUnitParams['Credential'] = $Credential
            }
            Set-ADOrganizationalUnit @setADOrganizationalUnitParams
        }
        else
        {
            Write-Verbose ($LocalizedData.DeletingOU -f $targetResource.Name)
            if ($targetResource.ProtectedFromAccidentalDeletion)
            {
                $setADOrganizationalUnitParams = @{
                    Identity = $ou
                    ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
                }
                if ($Credential)
                {
                    $setADOrganizationalUnitParams['Credential'] = $Credential
                }
                Set-ADOrganizationalUnit @setADOrganizationalUnitParams
            }

            $removeADOrganizationalUnitParams = @{
                Identity = $ou
            }
            if ($Credential)
            {
                $removeADOrganizationalUnitParams['Credential'] = $Credential
            }
            Remove-ADOrganizationalUnit @removeADOrganizationalUnitParams
        }
    }
    else
    {
        Write-Verbose ($LocalizedData.CreatingOU -f $targetResource.Name)
        $newADOrganizationalUnitParams = @{
            Name = $Name
            Path = $Path
            Description = $Description
            ProtectedFromAccidentalDeletion = $ProtectedFromAccidentalDeletion
        }
        if ($Credential) {
            $newADOrganizationalUnitParams['Credential'] = $Credential
        }
        New-ADOrganizationalUnit @newADOrganizationalUnitParams
    }

} #end function Set-TargetResource

## Import the common AD functions
$adCommonFunctions = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath '\MSFT_xADCommon\MSFT_xADCommon.ps1';
. $adCommonFunctions;

Export-ModuleMember -Function *-TargetResource
