
Configuration DSCFromGPO
{

	Import-DSCResource -ModuleName 'PSDesiredStateConfiguration'
	Import-DSCResource -ModuleName 'AuditPolicyDSC'
	Import-DSCResource -ModuleName 'SecurityPolicyDSC'
	Node localhost
	{
         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\EnableVirtualizationBasedSecurity'
         {
              ValueName = 'EnableVirtualizationBasedSecurity'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\RequirePlatformSecurityFeatures'
         {
              ValueName = 'RequirePlatformSecurityFeatures'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\HypervisorEnforcedCodeIntegrity'
         {
              ValueName = 'HypervisorEnforcedCodeIntegrity'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\HVCIMATRequired'
         {
              ValueName = 'HVCIMATRequired'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\LsaCfgFlags'
         {
              ValueName = 'LsaCfgFlags'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard\ConfigureSystemGuardLaunch'
         {
              ValueName = 'ConfigureSystemGuardLaunch'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\FVE\UseEnhancedPin'
         {
              ValueName = 'UseEnhancedPin'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\FVE\RDVDenyCrossOrg'
         {
              ValueName = 'RDVDenyCrossOrg'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\FVE\DisableExternalDMAUnderLock'
         {
              ValueName = 'DisableExternalDMAUnderLock'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab\DCSettingIndex'
         {
              ValueName = 'DCSettingIndex'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab\ACSettingIndex'
         {
              ValueName = 'ACSettingIndex'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\abfc2519-3608-4c2a-94ea-171b0ed546ab'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceClasses'
         {
              ValueName = 'DenyDeviceClasses'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceClassesRetroactive'
         {
              ValueName = 'DenyDeviceClassesRetroactive'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs'
         {
              ValueName = 'DenyDeviceIDs'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDsRetroactive'
         {
              ValueName = 'DenyDeviceIDsRetroactive'
              ValueType = 'Dword'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceClasses\1'
         {
              ValueName = '1'
              ValueType = 'String'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceClasses'
              ValueData = '{d48179be-ec20-11d1-b6b8-00c04fa372a7}'

         }

         Registry 'Registry(POL): HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs\1'
         {
              ValueName = '1'
              ValueType = 'String'
              Key = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions\DenyDeviceIDs'
              ValueData = 'PCI\CC_0C0A'

         }

         Registry 'Registry(POL): HKLM:\System\CurrentControlSet\Policies\Microsoft\FVE\RDVDenyWriteAccess'
         {
              ValueName = 'RDVDenyWriteAccess'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Policies\Microsoft\FVE'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun'
         {
              ValueName = 'NoDriveTypeAutoRun'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
              ValueData = 255

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoAutorun'
         {
              ValueName = 'NoAutorun'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn'
         {
              ValueName = 'DisableAutomaticRestartSignOn'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters\AllowEncryptionOracle'
         {
              ValueName = 'AllowEncryptionOracle'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Biometrics\FacialFeatures\EnhancedAntiSpoofing'
         {
              ValueName = 'EnhancedAntiSpoofing'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Biometrics\FacialFeatures'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds\DisableEnclosureDownload'
         {
              ValueName = 'DisableEnclosureDownload'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Feeds'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation\AllowProtectedCreds'
         {
              ValueName = 'AllowProtectedCreds'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CredentialsDelegation'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\Application\MaxSize'
         {
              ValueName = 'MaxSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Application'
              ValueData = 32768

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security\MaxSize'
         {
              ValueName = 'MaxSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\Security'
              ValueData = 196608

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\EventLog\System\MaxSize'
         {
              ValueName = 'MaxSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\EventLog\System'
              ValueData = 32768

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Explorer\NoAutoplayfornonVolume'
         {
              ValueName = 'NoAutoplayfornonVolume'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}\NoBackgroundPolicy'
         {
              ValueName = 'NoBackgroundPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}\NoGPOListChanges'
         {
              ValueName = 'NoGPOListChanges'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Group Policy\{35378EAC-683F-11D2-A89A-00C04FBBCFA2}'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\AlwaysInstallElevated'
         {
              ValueName = 'AlwaysInstallElevated'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Installer\EnableUserControl'
         {
              ValueName = 'EnableUserControl'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Installer'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Kernel DMA Protection\DeviceEnumerationPolicy'
         {
              ValueName = 'DeviceEnumerationPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Kernel DMA Protection'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation\AllowInsecureGuestAuth'
         {
              ValueName = 'AllowInsecureGuestAuth'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\LanmanWorkstation'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths\\*\NETLOGON'
         {
              ValueName = '\\*\NETLOGON'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths'
              ValueData = 'RequireMutualAuthentication=1,RequireIntegrity=1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths\\*\SYSVOL'
         {
              ValueName = '\\*\SYSVOL'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\NetworkProvider\HardenedPaths'
              ValueData = 'RequireMutualAuthentication=1,RequireIntegrity=1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Personalization\NoLockScreenCamera'
         {
              ValueName = 'NoLockScreenCamera'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Personalization'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Personalization\NoLockScreenSlideshow'
         {
              ValueName = 'NoLockScreenSlideshow'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Personalization'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockLogging'
         {
              ValueName = 'EnableScriptBlockLogging'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
              ValueData = 1

         }

         Registry 'DEL_\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging\EnableScriptBlockInvocationLogging'
         {
              ValueName = 'EnableScriptBlockInvocationLogging'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
              ValueData = ''
              Ensure = 'Absent'

         }

         <#
         	This MultiString Value has a value of $null,
          	Some Security Policies require Registry Values to be $null
          	If you believe ' ' is the correct value for this string, you may change it here.
         #>
         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Safer\'
         {
              ValueName = ''
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Safer'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx\EnforcementMode'
         {
              ValueName = 'EnforcementMode'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx\a9e18c21-ff8f-43cf-b9fc-db40eed693ba\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Appx\a9e18c21-ff8f-43cf-b9fc-db40eed693ba'
              ValueData = '<FilePublisherRule Id="a9e18c21-ff8f-43cf-b9fc-db40eed693ba" Name="(Default Rule) All signed packaged apps" Description="Allows members of the Everyone group to run packaged apps that are signed." UserOrGroupSid="S-1-1-0" Action="Allow"><Conditions><FilePublisherCondition PublisherName="*" ProductName="*" BinaryName="*"><BinaryVersionRange LowSection="0.0.0.0" HighSection="*"/></FilePublisherCondition></Conditions></FilePublisherRule>
'

         }

         <#
         	This MultiString Value has a value of $null,
          	Some Security Policies require Registry Values to be $null
          	If you believe ' ' is the correct value for this string, you may change it here.
         #>
         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Dll\'
         {
              ValueName = ''
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Dll'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\EnforcementMode'
         {
              ValueName = 'EnforcementMode'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\5e3ec135-b5af-4961-ae4d-cde98710afc9\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\5e3ec135-b5af-4961-ae4d-cde98710afc9'
              ValueData = '<FilePublisherRule Id="5e3ec135-b5af-4961-ae4d-cde98710afc9" Name="Block Google Chrome" Description="" UserOrGroupSid="S-1-1-0" Action="Deny"><Conditions><FilePublisherCondition PublisherName="O=GOOGLE INC, L=MOUNTAIN VIEW, S=CALIFORNIA, C=US" ProductName="GOOGLE CHROME" BinaryName="CHROME.EXE"><BinaryVersionRange LowSection="*" HighSection="*"/></FilePublisherCondition></Conditions></FilePublisherRule>
'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\6db6c8f3-cf7c-4754-a438-94c95345bb53\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\6db6c8f3-cf7c-4754-a438-94c95345bb53'
              ValueData = '<FilePublisherRule Id="6db6c8f3-cf7c-4754-a438-94c95345bb53" Name="Block Mozilla Firefox" Description="" UserOrGroupSid="S-1-1-0" Action="Deny"><Conditions><FilePublisherCondition PublisherName="O=MOZILLA CORPORATION, L=MOUNTAIN VIEW, S=CA, C=US" ProductName="FIREFOX" BinaryName="FIREFOX.EXE"><BinaryVersionRange LowSection="*" HighSection="*"/></FilePublisherCondition></Conditions></FilePublisherRule>
'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\881d54fe-3848-4d6a-95fd-42d48ebe60b8\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\881d54fe-3848-4d6a-95fd-42d48ebe60b8'
              ValueData = '<FilePublisherRule Id="881d54fe-3848-4d6a-95fd-42d48ebe60b8" Name="Block Internet Explorer" Description="" UserOrGroupSid="S-1-1-0" Action="Deny"><Conditions><FilePublisherCondition PublisherName="O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US" ProductName="INTERNET EXPLORER" BinaryName="IEXPLORE.EXE"><BinaryVersionRange LowSection="*" HighSection="*"/></FilePublisherCondition></Conditions></FilePublisherRule>
'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\921cc481-6e17-4653-8f75-050b80acca20\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\921cc481-6e17-4653-8f75-050b80acca20'
              ValueData = '<FilePathRule Id="921cc481-6e17-4653-8f75-050b80acca20" Name="(Default Rule) All files located in the Program Files folder" Description="Allows members of the Everyone group to run applications that are located in the Program Files folder." UserOrGroupSid="S-1-1-0" Action="Allow"><Conditions><FilePathCondition Path="%PROGRAMFILES%\*"/></Conditions></FilePathRule>
'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\a61c8b2c-a319-4cd0-9690-d2177cad7b51\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\a61c8b2c-a319-4cd0-9690-d2177cad7b51'
              ValueData = '<FilePathRule Id="a61c8b2c-a319-4cd0-9690-d2177cad7b51" Name="(Default Rule) All files located in the Windows folder" Description="Allows members of the Everyone group to run applications that are located in the Windows folder." UserOrGroupSid="S-1-1-0" Action="Allow"><Conditions><FilePathCondition Path="%WINDIR%\*"/></Conditions></FilePathRule>
'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\fd686d83-a829-4351-8ff4-27c7de5755d2\Value'
         {
              ValueName = 'Value'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Exe\fd686d83-a829-4351-8ff4-27c7de5755d2'
              ValueData = '<FilePathRule Id="fd686d83-a829-4351-8ff4-27c7de5755d2" Name="(Default Rule) All files" Description="Allows members of the local Administrators group to run all applications." UserOrGroupSid="S-1-5-32-544" Action="Allow"><Conditions><FilePathCondition Path="*"/></Conditions></FilePathRule>
'

         }

         <#
         	This MultiString Value has a value of $null,
          	Some Security Policies require Registry Values to be $null
          	If you believe ' ' is the correct value for this string, you may change it here.
         #>
         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Msi\'
         {
              ValueName = ''
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Msi'

         }

         <#
         	This MultiString Value has a value of $null,
          	Some Security Policies require Registry Values to be $null
          	If you believe ' ' is the correct value for this string, you may change it here.
         #>
         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Script\'
         {
              ValueName = ''
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\SrpV2\Script'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\EnableSmartScreen'
         {
              ValueName = 'EnableSmartScreen'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\ShellSmartScreenLevel'
         {
              ValueName = 'ShellSmartScreenLevel'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'
              ValueData = 'Block'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Windows Search\AllowIndexingEncryptedStoresOrItems'
         {
              ValueName = 'AllowIndexingEncryptedStoresOrItems'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowBasic'
         {
              ValueName = 'AllowBasic'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowUnencryptedTraffic'
         {
              ValueName = 'AllowUnencryptedTraffic'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client\AllowDigest'
         {
              ValueName = 'AllowDigest'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Client'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\AllowBasic'
         {
              ValueName = 'AllowBasic'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\AllowUnencryptedTraffic'
         {
              ValueName = 'AllowUnencryptedTraffic'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\DisableRunAs'
         {
              ValueName = 'DisableRunAs'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient\EnableMulticast'
         {
              ValueName = 'EnableMulticast'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\DNSClient'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\DisablePasswordSaving'
         {
              ValueName = 'DisablePasswordSaving'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fDisableCdm'
         {
              ValueName = 'fDisableCdm'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fPromptForPassword'
         {
              ValueName = 'fPromptForPassword'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fEncryptRPCTraffic'
         {
              ValueName = 'fEncryptRPCTraffic'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\MinEncryptionLevel'
         {
              ValueName = 'MinEncryptionLevel'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PolicyVersion'
         {
              ValueName = 'PolicyVersion'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall'
              ValueData = 538

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\DefaultOutboundAction'
         {
              ValueName = 'DefaultOutboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\DefaultInboundAction'
         {
              ValueName = 'DefaultInboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\EnableFirewall'
         {
              ValueName = 'EnableFirewall'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\EnableFirewall'
         {
              ValueName = 'EnableFirewall'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\DefaultInboundAction'
         {
              ValueName = 'DefaultInboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\DefaultOutboundAction'
         {
              ValueName = 'DefaultOutboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\EnableFirewall'
         {
              ValueName = 'EnableFirewall'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\DefaultOutboundAction'
         {
              ValueName = 'DefaultOutboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\DefaultInboundAction'
         {
              ValueName = 'DefaultInboundAction'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace\AllowWindowsInkWorkspace'
         {
              ValueName = 'AllowWindowsInkWorkspace'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsInkWorkspace'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Control\SCMConfig\EnableSvchostMitigationPolicy'
         {
              ValueName = 'EnableSvchostMitigationPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SCMConfig'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest\UseLogonCredential'
         {
              ValueName = 'UseLogonCredential'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel\DisableExceptionChainValidation'
         {
              ValueName = 'DisableExceptionChainValidation'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch\DriverLoadPolicy'
         {
              ValueName = 'DriverLoadPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\SMB1'
         {
              ValueName = 'SMB1'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10\Start'
         {
              ValueName = 'Start'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\MrxSmb10'
              ValueData = 4

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters\NoNameReleaseOnDemand'
         {
              ValueName = 'NoNameReleaseOnDemand'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters\NodeType'
         {
              ValueName = 'NodeType'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netbt\Parameters'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\LdapEnforceChannelBinding'
         {
              ValueName = 'LdapEnforceChannelBinding'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\EnableICMPRedirect'
         {
              ValueName = 'EnableICMPRedirect'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\DisableIPSourceRouting'
         {
              ValueName = 'DisableIPSourceRouting'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisableIPSourceRouting'
         {
              ValueName = 'DisableIPSourceRouting'
              ValueType = 'Dword'
              Key = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Ext\RunThisTimeEnabled'
         {
              ValueName = 'RunThisTimeEnabled'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Ext'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Ext\VersionCheckEnabled'
         {
              ValueName = 'VersionCheckEnabled'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Ext'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Download\RunInvalidSignatures'
         {
              ValueName = 'RunInvalidSignatures'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Download'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Download\CheckExeSignatures'
         {
              ValueName = 'CheckExeSignatures'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Download'
              ValueData = 'yes'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\Isolation64Bit'
         {
              ValueName = 'Isolation64Bit'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\DisableEPMCompat'
         {
              ValueName = 'DisableEPMCompat'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\Isolation'
         {
              ValueName = 'Isolation'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main'
              ValueData = 'PMEM'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_DISABLE_MK_PROTOCOL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_HANDLING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_MIME_SNIFFING'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_ACTIVEXINSTALL'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_RESTRICT_FILEDOWNLOAD'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_SECURITYBAND'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_WINDOW_RESTRICTIONS'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION\(Reserved)'
         {
              ValueName = '(Reserved)'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION\explorer.exe'
         {
              ValueName = 'explorer.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION\iexplore.exe'
         {
              ValueName = 'iexplore.exe'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ZONE_ELEVATION'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter\PreventOverrideAppRepUnknown'
         {
              ValueName = 'PreventOverrideAppRepUnknown'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter\PreventOverride'
         {
              ValueName = 'PreventOverride'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter\EnabledV9'
         {
              ValueName = 'EnabledV9'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Restrictions\NoCrashDetection'
         {
              ValueName = 'NoCrashDetection'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Restrictions'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Security\DisableSecuritySettingsCheck'
         {
              ValueName = 'DisableSecuritySettingsCheck'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Security'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Internet Explorer\Security\ActiveX\BlockNonAdminActiveXInstall'
         {
              ValueName = 'BlockNonAdminActiveXInstall'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Internet Explorer\Security\ActiveX'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\AxInstaller\OnlyUseAXISForActiveXInstall'
         {
              ValueName = 'OnlyUseAXISForActiveXInstall'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\AxInstaller'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Security_zones_map_edit'
         {
              ValueName = 'Security_zones_map_edit'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Security_options_edit'
         {
              ValueName = 'Security_options_edit'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Security_HKLM_only'
         {
              ValueName = 'Security_HKLM_only'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\CertificateRevocation'
         {
              ValueName = 'CertificateRevocation'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\PreventIgnoreCertErrors'
         {
              ValueName = 'PreventIgnoreCertErrors'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\WarnOnBadCertRecving'
         {
              ValueName = 'WarnOnBadCertRecving'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\EnableSSL3Fallback'
         {
              ValueName = 'EnableSSL3Fallback'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\SecureProtocols'
         {
              ValueName = 'SecureProtocols'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings'
              ValueData = 2560

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\0'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\1\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\1'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\2\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\2'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\3\2301'
         {
              ValueName = '2301'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4\2301'
         {
              ValueName = '2301'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Lockdown_Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\UNCAsIntranet'
         {
              ValueName = 'UNCAsIntranet'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0\270C'
         {
              ValueName = '270C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\0'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1\270C'
         {
              ValueName = '270C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1\1201'
         {
              ValueName = '1201'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\1'
              ValueData = 65536

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2'
              ValueData = 65536

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2\270C'
         {
              ValueName = '270C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2\1201'
         {
              ValueName = '1201'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\2'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2001'
         {
              ValueName = '2001'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2102'
         {
              ValueName = '2102'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1802'
         {
              ValueName = '1802'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\160A'
         {
              ValueName = '160A'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1201'
         {
              ValueName = '1201'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1406'
         {
              ValueName = '1406'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1804'
         {
              ValueName = '1804'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2200'
         {
              ValueName = '2200'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1209'
         {
              ValueName = '1209'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1206'
         {
              ValueName = '1206'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1809'
         {
              ValueName = '1809'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2500'
         {
              ValueName = '2500'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2103'
         {
              ValueName = '2103'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1606'
         {
              ValueName = '1606'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2402'
         {
              ValueName = '2402'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2004'
         {
              ValueName = '2004'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1001'
         {
              ValueName = '1001'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1A00'
         {
              ValueName = '1A00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 65536

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2708'
         {
              ValueName = '2708'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1004'
         {
              ValueName = '1004'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\120b'
         {
              ValueName = '120b'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1407'
         {
              ValueName = '1407'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1409'
         {
              ValueName = '1409'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\270C'
         {
              ValueName = '270C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1607'
         {
              ValueName = '1607'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2709'
         {
              ValueName = '2709'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2101'
         {
              ValueName = '2101'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\2301'
         {
              ValueName = '2301'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\1806'
         {
              ValueName = '1806'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\120c'
         {
              ValueName = '120c'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3\140C'
         {
              ValueName = '140C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1608'
         {
              ValueName = '1608'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1201'
         {
              ValueName = '1201'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1001'
         {
              ValueName = '1001'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1607'
         {
              ValueName = '1607'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\120b'
         {
              ValueName = '120b'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1809'
         {
              ValueName = '1809'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1004'
         {
              ValueName = '1004'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1606'
         {
              ValueName = '1606'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1407'
         {
              ValueName = '1407'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\160A'
         {
              ValueName = '160A'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1406'
         {
              ValueName = '1406'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2102'
         {
              ValueName = '2102'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2004'
         {
              ValueName = '2004'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2200'
         {
              ValueName = '2200'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2000'
         {
              ValueName = '2000'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1402'
         {
              ValueName = '1402'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1803'
         {
              ValueName = '1803'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2402'
         {
              ValueName = '2402'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1400'
         {
              ValueName = '1400'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1A00'
         {
              ValueName = '1A00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 196608

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2001'
         {
              ValueName = '2001'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2500'
         {
              ValueName = '2500'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1409'
         {
              ValueName = '1409'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1C00'
         {
              ValueName = '1C00'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1209'
         {
              ValueName = '1209'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\270C'
         {
              ValueName = '270C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1206'
         {
              ValueName = '1206'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2708'
         {
              ValueName = '2708'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1802'
         {
              ValueName = '1802'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2103'
         {
              ValueName = '2103'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2709'
         {
              ValueName = '2709'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1405'
         {
              ValueName = '1405'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2101'
         {
              ValueName = '2101'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\2301'
         {
              ValueName = '2301'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1200'
         {
              ValueName = '1200'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1804'
         {
              ValueName = '1804'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\1806'
         {
              ValueName = '1806'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\120c'
         {
              ValueName = '120c'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4\140C'
         {
              ValueName = '140C'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\4'
              ValueData = 3

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM'
         {
              ValueName = 'AutoConnectAllowedOEM'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\WcmSvc\wifinetworkmanager\config'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\CredUI\EnumerateAdministrators'
         {
              ValueName = 'EnumerateAdministrators'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\CredUI'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoWebServices'
         {
              ValueName = 'NoWebServices'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\MSAOptional'
         {
              ValueName = 'MSAOptional'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\LocalAccountTokenFilterPolicy'
         {
              ValueName = 'LocalAccountTokenFilterPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Internet Settings\PreventCertErrorOverrides'
         {
              ValueName = 'PreventCertErrorOverrides'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Internet Settings'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main\FormSuggest Passwords'
         {
              ValueName = 'FormSuggest Passwords'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main'
              ValueData = 'no'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter\EnabledV9'
         {
              ValueName = 'EnabledV9'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter\PreventOverride'
         {
              ValueName = 'PreventOverride'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter\PreventOverrideAppRepUnknown'
         {
              ValueName = 'PreventOverrideAppRepUnknown'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\DCSettingIndex'
         {
              ValueName = 'DCSettingIndex'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51\ACSettingIndex'
         {
              ValueName = 'ACSettingIndex'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy\LetAppsActivateWithVoiceAboveLock'
         {
              ValueName = 'LetAppsActivateWithVoiceAboveLock'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\AppPrivacy'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures'
         {
              ValueName = 'DisableWindowsConsumerFeatures'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\CloudContent'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\GameDVR\AllowGameDVR'
         {
              ValueName = 'AllowGameDVR'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\GameDVR'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\Network Connections\NC_ShowSharedAccessUI'
         {
              ValueName = 'NC_ShowSharedAccessUI'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\Network Connections'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\AllowDomainPINLogon'
         {
              ValueName = 'AllowDomainPINLogon'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\System\EnumerateLocalUsers'
         {
              ValueName = 'EnumerateLocalUsers'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\System'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows\WcmSvc\GroupPolicy\fBlockNonDomain'
         {
              ValueName = 'fBlockNonDomain'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Printers\DisableWebPnPDownload'
         {
              ValueName = 'DisableWebPnPDownload'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Printers'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Rpc\RestrictRemoteClients'
         {
              ValueName = 'RestrictRemoteClients'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Rpc'
              ValueData = 1

         }

         Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\fUseMailto'
         {
              ValueName = 'fUseMailto'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = ''
              Ensure = 'Absent'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowToGetHelp'
         {
              ValueName = 'fAllowToGetHelp'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = 0

         }

         Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\fAllowFullControl'
         {
              ValueName = 'fAllowFullControl'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = ''
              Ensure = 'Absent'

         }

         Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxTicketExpiry'
         {
              ValueName = 'MaxTicketExpiry'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = ''
              Ensure = 'Absent'

         }

         Registry 'DEL_\Software\Policies\Microsoft\Windows NT\Terminal Services\MaxTicketExpiryUnits'
         {
              ValueName = 'MaxTicketExpiryUnits'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services'
              ValueData = ''
              Ensure = 'Absent'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\DisableNotifications'
         {
              ValueName = 'DisableNotifications'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging\LogDroppedPackets'
         {
              ValueName = 'LogDroppedPackets'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging\LogFileSize'
         {
              ValueName = 'LogFileSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging'
              ValueData = 16384

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging\LogSuccessfulConnections'
         {
              ValueName = 'LogSuccessfulConnections'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\DomainProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\DisableNotifications'
         {
              ValueName = 'DisableNotifications'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging\LogSuccessfulConnections'
         {
              ValueName = 'LogSuccessfulConnections'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging\LogDroppedPackets'
         {
              ValueName = 'LogDroppedPackets'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging\LogFileSize'
         {
              ValueName = 'LogFileSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PrivateProfile\Logging'
              ValueData = 16384

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\DisableNotifications'
         {
              ValueName = 'DisableNotifications'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\AllowLocalIPsecPolicyMerge'
         {
              ValueName = 'AllowLocalIPsecPolicyMerge'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\AllowLocalPolicyMerge'
         {
              ValueName = 'AllowLocalPolicyMerge'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging\LogFileSize'
         {
              ValueName = 'LogFileSize'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging'
              ValueData = 16384

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging\LogDroppedPackets'
         {
              ValueName = 'LogDroppedPackets'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging\LogSuccessfulConnections'
         {
              ValueName = 'LogSuccessfulConnections'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\WindowsFirewall\PublicProfile\Logging'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft Services\AdmPwd\AdmPwdEnabled'
         {
              ValueName = 'AdmPwdEnabled'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft Services\AdmPwd'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\PUAProtection'
         {
              ValueName = 'PUAProtection'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection\DisableBehaviorMonitoring'
         {
              ValueName = 'DisableBehaviorMonitoring'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Real-Time Protection'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Scan\DisableRemovableDriveScanning'
         {
              ValueName = 'DisableRemovableDriveScanning'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Scan'
              ValueData = 0

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet\SubmitSamplesConsent'
         {
              ValueName = 'SubmitSamplesConsent'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet\SpynetReporting'
         {
              ValueName = 'SpynetReporting'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Spynet'
              ValueData = 2

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ExploitGuard_ASR_Rules'
         {
              ValueName = 'ExploitGuard_ASR_Rules'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR'
              ValueData = 1

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84'
         {
              ValueName = '75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\3b576869-a4ec-4529-8536-b80a7769e899'
         {
              ValueName = '3b576869-a4ec-4529-8536-b80a7769e899'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\d4f940ab-401b-4efc-aadc-ad5f3c50688a'
         {
              ValueName = 'd4f940ab-401b-4efc-aadc-ad5f3c50688a'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B'
         {
              ValueName = '92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\5beb7efe-fd9a-4556-801d-275e5ffc04cc'
         {
              ValueName = '5beb7efe-fd9a-4556-801d-275e5ffc04cc'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\d3e037e1-3eb8-44c8-a917-57927947596d'
         {
              ValueName = 'd3e037e1-3eb8-44c8-a917-57927947596d'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\be9ba2d9-53ea-4cdc-84e5-9b1eeee46550'
         {
              ValueName = 'be9ba2d9-53ea-4cdc-84e5-9b1eeee46550'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2'
         {
              ValueName = '9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4'
         {
              ValueName = 'b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\26190899-1602-49e8-8b27-eb1d0a1ce869'
         {
              ValueName = '26190899-1602-49e8-8b27-eb1d0a1ce869'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules\7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c'
         {
              ValueName = '7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c'
              ValueType = 'String'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\Rules'
              ValueData = '1'

         }

         Registry 'Registry(POL): HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection\EnableNetworkProtection'
         {
              ValueName = 'EnableNetworkProtection'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection'
              ValueData = 1

         }

         AuditPolicySubcategory 'Audit Credential Validation (Success) - Inclusion'
         {
              Name = 'Credential Validation'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Credential Validation (Failure) - Inclusion'
         {
              Name = 'Credential Validation'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Kerberos Authentication Service (Success) - Inclusion'
         {
              Name = 'Kerberos Authentication Service'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Kerberos Authentication Service (Failure) - Inclusion'
         {
              Name = 'Kerberos Authentication Service'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Computer Account Management (Success) - Inclusion'
         {
              Name = 'Computer Account Management'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Computer Account Management (Failure) - Inclusion'
         {
              Name = 'Computer Account Management'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Other Account Management Events (Success) - Inclusion'
         {
              Name = 'Other Account Management Events'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Other Account Management Events (Failure) - Inclusion'
         {
              Name = 'Other Account Management Events'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Security Group Management (Success) - Inclusion'
         {
              Name = 'Security Group Management'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Security Group Management (Failure) - Inclusion'
         {
              Name = 'Security Group Management'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit User Account Management (Success) - Inclusion'
         {
              Name = 'User Account Management'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit User Account Management (Failure) - Inclusion'
         {
              Name = 'User Account Management'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit PNP Activity (Success) - Inclusion'
         {
              Name = 'Plug and Play Events'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit PNP Activity (Failure) - Inclusion'
         {
              Name = 'Plug and Play Events'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Process Creation (Success) - Inclusion'
         {
              Name = 'Process Creation'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Process Creation (Failure) - Inclusion'
         {
              Name = 'Process Creation'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Directory Service Access (Success) - Inclusion'
         {
              Name = 'Directory Service Access'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Directory Service Access (Failure) - Inclusion'
         {
              Name = 'Directory Service Access'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Directory Service Changes (Success) - Inclusion'
         {
              Name = 'Directory Service Changes'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Directory Service Changes (Failure) - Inclusion'
         {
              Name = 'Directory Service Changes'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Account Lockout (Failure) - Inclusion'
         {
              Name = 'Account Lockout'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

          AuditPolicySubcategory 'Audit Account Lockout (Success) - Inclusion'
         {
              Name = 'Account Lockout'
              Ensure = 'Absent'
              AuditFlag = 'Success'

         }

         AuditPolicySubcategory 'Audit Group Membership (Success) - Inclusion'
         {
              Name = 'Group Membership'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Group Membership (Failure) - Inclusion'
         {
              Name = 'Group Membership'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Logon (Success) - Inclusion'
         {
              Name = 'Logon'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Logon (Failure) - Inclusion'
         {
              Name = 'Logon'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Other Logon/Logoff Events (Success) - Inclusion'
         {
              Name = 'Other Logon/Logoff Events'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Other Logon/Logoff Events (Failure) - Inclusion'
         {
              Name = 'Other Logon/Logoff Events'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Special Logon (Success) - Inclusion'
         {
              Name = 'Special Logon'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Special Logon (Failure) - Inclusion'
         {
              Name = 'Special Logon'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Detailed File Share (Failure) - Inclusion'
         {
              Name = 'Detailed File Share'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

          AuditPolicySubcategory 'Audit Detailed File Share (Success) - Inclusion'
         {
              Name = 'Detailed File Share'
              Ensure = 'Absent'
              AuditFlag = 'Success'

         }

         AuditPolicySubcategory 'Audit File Share (Success) - Inclusion'
         {
              Name = 'File Share'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit File Share (Failure) - Inclusion'
         {
              Name = 'File Share'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Other Object Access Events (Success) - Inclusion'
         {
              Name = 'Other Object Access Events'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Other Object Access Events (Failure) - Inclusion'
         {
              Name = 'Other Object Access Events'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Removable Storage (Success) - Inclusion'
         {
              Name = 'Removable Storage'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Removable Storage (Failure) - Inclusion'
         {
              Name = 'Removable Storage'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Audit Policy Change (Success) - Inclusion'
         {
              Name = 'Audit Policy Change'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Audit Policy Change (Failure) - Inclusion'
         {
              Name = 'Audit Policy Change'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Authentication Policy Change (Success) - Inclusion'
         {
              Name = 'Authentication Policy Change'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Authentication Policy Change (Failure) - Inclusion'
         {
              Name = 'Authentication Policy Change'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit MPSSVC Rule-Level Policy Change (Success) - Inclusion'
         {
              Name = 'MPSSVC Rule-Level Policy Change'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit MPSSVC Rule-Level Policy Change (Failure) - Inclusion'
         {
              Name = 'MPSSVC Rule-Level Policy Change'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Other Policy Change Events (Failure) - Inclusion'
         {
              Name = 'Other Policy Change Events'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

          AuditPolicySubcategory 'Audit Other Policy Change Events (Success) - Inclusion'
         {
              Name = 'Other Policy Change Events'
              Ensure = 'Absent'
              AuditFlag = 'Success'

         }

         AuditPolicySubcategory 'Audit Sensitive Privilege Use (Success) - Inclusion'
         {
              Name = 'Sensitive Privilege Use'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Sensitive Privilege Use (Failure) - Inclusion'
         {
              Name = 'Sensitive Privilege Use'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Other System Events (Success) - Inclusion'
         {
              Name = 'Other System Events'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Other System Events (Failure) - Inclusion'
         {
              Name = 'Other System Events'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Security State Change (Success) - Inclusion'
         {
              Name = 'Security State Change'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Security State Change (Failure) - Inclusion'
         {
              Name = 'Security State Change'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit Security System Extension (Success) - Inclusion'
         {
              Name = 'Security System Extension'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit Security System Extension (Failure) - Inclusion'
         {
              Name = 'Security System Extension'
              Ensure = 'Absent'
              AuditFlag = 'Failure'

         }

         AuditPolicySubcategory 'Audit System Integrity (Success) - Inclusion'
         {
              Name = 'System Integrity'
              Ensure = 'Present'
              AuditFlag = 'Success'

         }

          AuditPolicySubcategory 'Audit System Integrity (Failure) - Inclusion'
         {
              Name = 'System Integrity'
              Ensure = 'Present'
              AuditFlag = 'Failure'

         }

         AccountPolicy 'SecuritySetting(INF): ResetLockoutCount'
         {
              Reset_account_lockout_counter_after = 15
              Name = 'Reset_account_lockout_counter_after'

         }

         AccountPolicy 'SecuritySetting(INF): LockoutBadCount'
         {
              Name = 'Account_lockout_threshold'
              Account_lockout_threshold = 10

         }

         AccountPolicy 'SecuritySetting(INF): PasswordComplexity'
         {
              Name = 'Password_must_meet_complexity_requirements'
              Password_must_meet_complexity_requirements = 'Enabled'

         }

         AccountPolicy 'SecuritySetting(INF): LockoutDuration'
         {
              Name = 'Account_lockout_duration'
              Account_lockout_duration = 15

         }

         AccountPolicy 'SecuritySetting(INF): PasswordHistorySize'
         {
              Name = 'Enforce_password_history'
              Enforce_password_history = 24

         }

         AccountPolicy 'SecuritySetting(INF): ClearTextPassword'
         {
              Name = 'Store_passwords_using_reversible_encryption'
              Store_passwords_using_reversible_encryption = 'Disabled'

         }

         AccountPolicy 'SecuritySetting(INF): MinimumPasswordLength'
         {
              Name = 'Minimum_Password_Length'
              Minimum_Password_Length = 14

         }

         Service 'Services(INF): AppIDSvc'
         {
              Name = 'AppIDSvc'
              State = 'Running'

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Debug_programs'
         {
              Policy = 'Debug_programs'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Force_shutdown_from_a_remote_system'
         {
              Policy = 'Force_shutdown_from_a_remote_system'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Lock_pages_in_memory'
         {
              Policy = 'Lock_pages_in_memory'
              Force = $True
              Identity = @('')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Access_Credential_Manager_as_a_trusted_caller'
         {
              Policy = 'Access_Credential_Manager_as_a_trusted_caller'
              Force = $True
              Identity = @('')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Back_up_files_and_directories'
         {
              Policy = 'Back_up_files_and_directories'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Load_and_unload_device_drivers'
         {
              Policy = 'Load_and_unload_device_drivers'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Impersonate_a_client_after_authentication'
         {
              Policy = 'Impersonate_a_client_after_authentication'
              Force = $True
              Identity = @('*S-1-5-20', '*S-1-5-19', '*S-1-5-6', '*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Create_a_pagefile'
         {
              Policy = 'Create_a_pagefile'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Allow_log_on_through_Remote_Desktop_Services'
         {
              Policy = 'Allow_log_on_through_Remote_Desktop_Services'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Manage_auditing_and_security_log'
         {
              Policy = 'Manage_auditing_and_security_log'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Take_ownership_of_files_or_other_objects'
         {
              Policy = 'Take_ownership_of_files_or_other_objects'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Profile_single_process'
         {
              Policy = 'Profile_single_process'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Create_global_objects'
         {
              Policy = 'Create_global_objects'
              Force = $True
              Identity = @('*S-1-5-20', '*S-1-5-19', '*S-1-5-6', '*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Act_as_part_of_the_operating_system'
         {
              Policy = 'Act_as_part_of_the_operating_system'
              Force = $True
              Identity = @('')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Restore_files_and_directories'
         {
              Policy = 'Restore_files_and_directories'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Access_this_computer_from_the_network'
         {
              Policy = 'Access_this_computer_from_the_network'
              Force = $True
              Identity = @('*S-1-5-9', '*S-1-5-11', '*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Enable_computer_and_user_accounts_to_be_trusted_for_delegation'
         {
              Policy = 'Enable_computer_and_user_accounts_to_be_trusted_for_delegation'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Create_a_token_object'
         {
              Policy = 'Create_a_token_object'
              Force = $True
              Identity = @('')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Create_permanent_shared_objects'
         {
              Policy = 'Create_permanent_shared_objects'
              Force = $True
              Identity = @('')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Allow_log_on_locally'
         {
              Policy = 'Allow_log_on_locally'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Perform_volume_maintenance_tasks'
         {
              Policy = 'Perform_volume_maintenance_tasks'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         UserRightsAssignment 'UserRightsAssignment(INF): Modify_firmware_environment_values'
         {
              Policy = 'Modify_firmware_environment_values'
              Force = $True
              Identity = @('*S-1-5-32-544')

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\EnablePlainTextPassword'
         {
              ValueName = 'EnablePlainTextPassword'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters'
              ValueData = 0

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\requiresignorseal'
         {
              ValueName = 'requiresignorseal'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\ScRemoveOption'
         {
              ValueName = 'ScRemoveOption'
              ValueType = 'String'
              Key = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
              ValueData = '1'

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableInstallerDetection'
         {
              ValueName = 'EnableInstallerDetection'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\disablepasswordchange'
         {
              ValueName = 'disablepasswordchange'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 0

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Session Manager\ProtectionMode'
         {
              ValueName = 'ProtectionMode'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Session Manager'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\NTDS\Parameters\LDAPServerIntegrity'
         {
              ValueName = 'LDAPServerIntegrity'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\NTDS\Parameters'
              ValueData = 2

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableSecureUIAPaths'
         {
              ValueName = 'EnableSecureUIAPaths'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\RestrictAnonymousSAM'
         {
              ValueName = 'RestrictAnonymousSAM'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinServerSec'
         {
              ValueName = 'NTLMMinServerSec'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
              ValueData = 537395200

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorUser'
         {
              ValueName = 'ConsentPromptBehaviorUser'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 0

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\RestrictAnonymous'
         {
              ValueName = 'RestrictAnonymous'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters\RequireSecuritySignature'
         {
              ValueName = 'RequireSecuritySignature'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\LanmanWorkstation\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\allownullsessionfallback'
         {
              ValueName = 'allownullsessionfallback'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
              ValueData = 0

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\NoLMHash'
         {
              ValueName = 'NoLMHash'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\LmCompatibilityLevel'
         {
              ValueName = 'LmCompatibilityLevel'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 5

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0\NTLMMinClientSec'
         {
              ValueName = 'NTLMMinClientSec'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa\MSV1_0'
              ValueData = 537395200

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\SCENoApplyLegacyAuditPolicy'
         {
              ValueName = 'SCENoApplyLegacyAuditPolicy'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\ConsentPromptBehaviorAdmin'
         {
              ValueName = 'ConsentPromptBehaviorAdmin'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 2

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\requiresecuritysignature'
         {
              ValueName = 'requiresecuritysignature'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\requirestrongkey'
         {
              ValueName = 'requirestrongkey'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters\RestrictNullSessAccess'
         {
              ValueName = 'RestrictNullSessAccess'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\LanManServer\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\sealsecurechannel'
         {
              ValueName = 'sealsecurechannel'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\RefusePasswordChange'
         {
              ValueName = 'RefusePasswordChange'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 0

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\LDAP\LDAPClientIntegrity'
         {
              ValueName = 'LDAPClientIntegrity'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\LDAP'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\maximumpasswordage'
         {
              ValueName = 'maximumpasswordage'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 30

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableLUA'
         {
              ValueName = 'EnableLUA'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\EnableVirtualization'
         {
              ValueName = 'EnableVirtualization'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\LimitBlankPasswordUse'
         {
              ValueName = 'LimitBlankPasswordUse'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\FilterAdministratorToken'
         {
              ValueName = 'FilterAdministratorToken'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters\signsecurechannel'
         {
              ValueName = 'signsecurechannel'
              ValueType = 'Dword'
              Key = 'HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters'
              ValueData = 1

         }

         Registry 'Registry(INF): HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\InactivityTimeoutSecs'
         {
              ValueName = 'InactivityTimeoutSecs'
              ValueType = 'Dword'
              Key = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
              ValueData = 900

         }

         SecurityOption 'SecuritySetting(INF): LSAAnonymousNameLookup'
         {
              Name = 'Network_access_Allow_anonymous_SID_Name_translation'
              Network_access_Allow_anonymous_SID_Name_translation = 'Disabled'

         }


         UserRightsAssignment 'UserRightsAssignment(INF): Deny_log_on_through_Remote_Desktop_Services'
         {
              Policy = 'Deny_log_on_through_Remote_Desktop_Services'
              Force = $True
              Identity = @('*S-1-5-113')

         }

         Registry 'Registry(INF): HKLM:\System\CurrentControlSet\Control\Lsa\RestrictRemoteSAM'
         {
              ValueName = 'RestrictRemoteSAM'
              ValueType = 'String'
              Key = 'HKLM:\System\CurrentControlSet\Control\Lsa'
              ValueData = 'O:BAG:BAD:(A;;RC;;;BA)'

         }
	}
}
DSCFromGPO -OutputPath 'C:\Temp\Output'
