<#
    Script will create Active directory parent OU and child OUs for Azure virtual desktop as a prerequisite.
    You can leverage on existing OUs if need be.

    Run this as a prerequisite and first step before deploying AVD resources.
    This script needs to be ran inside your onpremise domain controller as an administratrator.
#>

param(
    # Define parameters
    #$OUDistinguishedName = "DC=contoso,DC=com"
    [string] [Parameter(Mandatory=$true)] $DomainDistinguishedName,
    #$ParentOrganizationUnitName = "AzureVirtualDesktop"
    [string] [Parameter(Mandatory=$true)] $ParentOrganizationUnitName,
    #$StorageAccountOrganizationUnitName = "StorageAccounts"
    [string] [Parameter(Mandatory=$true)] $StorageAccountOrganizationUnitName,
    #$AVDOrganizationUnitName = "AVD-Objects"
    [string] [Parameter(Mandatory=$true)] $AVDOrganizationUnitName,
    #$AVDChildOrganizationUnitNames = @("Groups", "SessionHosts", "Users")
    [stringp[]] [Parameter(Mandatory=$true)] $AVDChildOrganizationUnitNames
)

Function Set-DomainOrganizationUnits {
    param (
        [string] [Parameter(Mandatory=$true)] $OUDistinguishedName,
        [string] [Parameter(Mandatory=$true)] $ParentOU,
        [string] [Parameter(Mandatory=$true)] $StorageAccountOUName,
        [string] [Parameter(Mandatory=$true)] $AVDOUName,
        [stringp[]] [Parameter(Mandatory=$true)] $AVDChildOUNames
    )
    

    $GetExistingOU = Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $ParentOU}
    $AVDOU = Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $AVDOUName}
    $StorageAccountOU = Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $StorageAccountOUName}
    if( $GetExistingOU ){
        Write-Host "Organization Unit $($ParentOu) already exist"
        if( ! ($AVDOU) ){
            New-ADOrganizationalUnit -Name $AVDOUName -Path $GetExistingOU.DistinguishedName -ProtectedFromAccidentalDeletion $false
            $AVDOUDistinguishedName = (Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $AVDOUName}).DistinguishedName
        }
        else{
            $AVDOUDistinguishedName = $AVDOU.DistinguishedName
        }

        if( ! ($StorageAccountOU) ){
            New-ADOrganizationalUnit -Name $StorageAccountOUName -Path $GetExistingOU.DistinguishedName -ProtectedFromAccidentalDeletion $false
        }
    }
    else {
        New-ADOrganizationalUnit -Name $ParentOU -Path $OUDistinguishedName -ProtectedFromAccidentalDeletion $false

        $ParentOODistinguishedName = (Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $ParentOU}).DistinguishedName

        New-ADOrganizationalUnit -Name $AVDOUName -Path $ParentOODistinguishedName -ProtectedFromAccidentalDeletion $false
        New-ADOrganizationalUnit -Name $StorageAccountOUName -Path $ParentOODistinguishedName -ProtectedFromAccidentalDeletion $false
        $AVDOUDistinguishedName = (Get-ADOrganizationalUnit -Filter 'Name -like "*"' -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $AVDOUName}).DistinguishedName
        
        ForEach($AVDChildOUName in $AVDChildOUNames){
            New-ADOrganizationalUnit -Name $AVDChildOUName -Path $AVDOUDistinguishedName -ProtectedFromAccidentalDeletion $false
        }
    }


    #Write-Output $AVDOUDistinguishedName
    #Write-Output $StorageAccountOUDistinguishedName
    #
    #$DeploymentScriptOutputs = @{}
    #$DeploymentScriptOutputs['AVDOUDistinguishedName'] = $AVDOUDistinguishedName
    #$DeploymentScriptOutputs['StorageAccountOUDistinguishedName'] = $StorageAccountOUDistinguishedName
}

Set-DomainOrganizationUnits `
    -OUDistinguishedName $DomainDistinguishedName `
    -ParentOU $ParentOrganizationUnitName `
    -StorageAccountOUName $StorageAccountOrganizationUnitName `
    -AVDOUName $AVDOrganizationUnitName `
    -AVDChildOUNames $AVDChildOrganizationUnitNames