<#
    Script will join FSLogix Azure storage account to active directory.
    The storage account will be mounted on the specified directory (Y:\) and set required acl permissions for AVD user and admin groups

    Run this as a post configuration and last step after deploying AVD resources.
    This script needs to be ran inside your onpremise domain controller as an administratrator.
    You must run the script below in PowerShell 5.1 on your domain controller server,
    using on-premises AD DS credentials that have permissions to create a computer account or service logon account in the target AD (such as domain admin)
#>
param(
    # Define parameters
    # $StorageAccountName is the name of an existing storage account that you want to join to AD
    # $SamAccountName is the name of the to-be-created AD object, which is used by AD as the logon name 
    # for the object. It must be 15 characters or less and has certain character restrictions.
    # Make sure that you provide the SamAccountName without the trailing '$' sign.
    # See https://learn.microsoft.com/windows/win32/adschema/a-samaccountname for more information
    # If you don't provide the OU name as an input parameter, the AD identity that represents the 
    # storage account is created under the root directory.

    # You azure tenant ID where the storage account is located.
    [string] [Parameter(Mandatory=$true)] $TenantId,
    # You azure subscription ID where the storage account is located.
    [string] [Parameter(Mandatory=$true)] $SubscriptionId,
    # Service principal with a Reader on the resource group where the target storage account is located and a Contributor on the storage account to be joined to AD DS.
    [string] [Parameter(Mandatory=$true)] $ServicePrincipalAppId,
    # Service principal secret.
    
    [string] [Parameter(Mandatory=$true)] $ServicePrincipalSecret,
    [string] [Parameter(Mandatory=$false)] $DomainAccountType  = "ComputerAccount",
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [string] [Parameter(Mandatory=$true)] $StorageAccountName,
    [string] [Parameter(Mandatory=$true)] $StorageAccountKey,
    [string] [Parameter(Mandatory=$true)] $StorageAccountFileShareName,
    [string] [Parameter(Mandatory=$true)] $SamAccountName,
    # Active directory netbios name ("contoso")
    [string] [Parameter(Mandatory=$true)] $DomainName,
    # Storage account active directory OU distinguished name ("OU=StorageAccounts,OU=AzureVirtualDesktop,DC=contoso,DC=com")
    [string] [Parameter(Mandatory=$true)] $StorageAccountOUDistinguishedName,
    # Storage account active directory admin group name ("Storage Access Admins")
    [string] [Parameter(Mandatory=$true)] $ElevatedAdminGroup,
    # Storage account active directory user group name ("Storage Access Users")
    [string] [Parameter(Mandatory=$true)] $UserGroup,
    # Session host active directory OU distinguished name ("OU=SessionHosts,OU=AVD-Objects,OU=AzureVirtualDesktop,DC=contoso,DC=com"
    [string] [Parameter(Mandatory=$true)] $SessionHostsOUDistinguishedName
)

$ErrorActionPreference = 'Stop'
$SecureStringPwd = $ServicePrincipalSecret | ConvertTo-SecureString -AsPlainText -Force
$pscredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ServicePrincipalAppId, $SecureStringPwd
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $TenantId

Select-AzSubscription -SubscriptionId $SubscriptionId

# Download and unzip the latest version of the AzFilesHybrid module
# https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.3.2/AzFilesHybrid.zip
if(Get-Command -Name 'Join-AzStorageAccount' -Module 'AzFilesHybrid' -ErrorAction SilentlyContinue){
    if(Get-AzStorageAccountADObject -ResourceGroupName $ResourceGroupName -StorageAccountName $StorageAccountName -ErrorAction SilentlyContinue){
        Write-Host "Azure Storage account is already join to Active directory domain."
    }
    else {
        # Register the target storage account with your active directory environment under the target OU 
        # (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as 
        # "OU=UserAccounts,DC=CONTOSO,DC=COM"). You can use this PowerShell cmdlet: Get-ADOrganizationalUnit 
        # to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it 
        # with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it 
        # with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify 
        # the target OU. You can choose to create the identity that represents the storage account as either a 
        # Service Logon Account or Computer Account (default parameter value), depending on your AD permissions 
        # and preference. Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.
        Join-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $StorageAccountName `
            -SamAccountName $SamAccountName `
            -DomainAccountType $DomainAccountType `
            -OrganizationalUnitDistinguishedName $StorageAccountOUDistinguishedName

        # You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration 
        # with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on 
        # the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
        Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose
    }
} 
else {
    Invoke-WebRequest -Uri 'https://github.com/Azure-Samples/azure-files-samples/releases/download/v0.3.2/AzFilesHybrid.zip' -OutFile "C:\AzFilesHybrid.zip"
    Expand-Archive -LiteralPath 'C:\AzFilesHybrid.zip' -DestinationPath 'C:\AzFilesHybrid'
    Remove-Item 'C:\AzFilesHybrid.zip'

    # Change the execution policy to unblock importing AzFilesHybrid.psm1 module
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

    # Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
    cd 'C:\AzFilesHybrid'
    
    .\CopyToPSPath.ps1 

    # Import AzFilesHybrid module
    Import-Module -Name AzFilesHybrid

    # Register the target storage account with your active directory environment under the target OU 
    # (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as 
    # "OU=UserAccounts,DC=CONTOSO,DC=COM"). You can use this PowerShell cmdlet: Get-ADOrganizationalUnit 
    # to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it 
    # with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it 
    # with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify 
    # the target OU. You can choose to create the identity that represents the storage account as either a 
    # Service Logon Account or Computer Account (default parameter value), depending on your AD permissions 
    # and preference. Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.
    Join-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -StorageAccountName $StorageAccountName `
            -SamAccountName $SamAccountName `
            -DomainAccountType $DomainAccountType `
            -OrganizationalUnitDistinguishedName $StorageAccountOUDistinguishedName

    # You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration 
    # with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on 
    # the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
    Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose
}

$Folder = "Y:\"
$UserAccesses = @(
    "$DomainName\Domain Admins;FullControl;ContainerInherit,ObjectInherit",
    "$DomainName\$ElevatedAdminGroup;FullControl;ContainerInherit,ObjectInherit",
    "$DomainName\$UserGroup;Modify,Synchronize;None"
)

$connectTestResult = Test-NetConnection -ComputerName "$StorageAccountName.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
     cmd.exe /C "cmdkey /add:`"$StorageAccountName.file.core.windows.net`" /user:`"localhost\$StorageAccountName`" /pass:`"$StorageAccountKey`""
    # Mount the drive
    New-PSDrive -Name Y -PSProvider FileSystem -Root "\\$StorageAccountName.file.core.windows.net\$StorageAccountFileShareName" -Persist

    $Acl = Get-Acl -Path $Folder
    #$Acl.Access

    Foreach($UserAccess in $UserAccesses){
        $SplitObject = $UserAccess.Split(";")
        $Access = New-Object Security.AccessControl.FileSystemAccessRule ($SplitObject[0], $SplitObject[1], $SplitObject[2],'None', 'Allow')
        $Acl.AddAccessRule($Access)
        Set-Acl -AclObject $Acl -Path $Folder
    }

}
else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}



Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile "C:\FSLogix.zip"
Expand-Archive -LiteralPath "C:\FSLogix.zip" -DestinationPath 'C:\FSLogix'
Remove-Item 'C:\FSLogix.zip'

Copy-Item "C:\FSLogix\fslogix.admx" -Destination "C:\Windows\PolicyDefinitions"
Copy-Item "C:\FSLogix\fslogix.adml" -Destination "C:\Windows\PolicyDefinitions\en-US"


New-GPO -Name "AVD-GPO" -Comment "This AVD GPO"
New-GPLink -Name "AVD-GPO" -Target $SessionHostsOUDistinguishedName -LinkEnabled Yes

Set-GPRegistryValue -Name "AVD-GPO" -ValueName "Enabled" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 1 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "DeleteLocalProfileWhenVHDShouldApply" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 1 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "FlipFlopProfileDirectoryName" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 1 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "LockedRetryCount" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 3 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "LockedRetryInterval" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 15 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "ProfileType" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 0 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "ReAttachIntervalSeconds" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 15 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "ReAttachRetryCount" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 3 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "SizeInMBs" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value 30000 -Type "DWord"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "VHDLocations" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value "\\$StorageAccountName.file.core.windows.net\$StorageAccountFileShareName" -Type "String"
Set-GPRegistryValue -Name "AVD-GPO" -ValueName "VolumeType" -Key "HKEY_LOCAL_MACHINE\SOFTWARE\FSLogix\Profiles" -Value "VHDX" -Type "String"