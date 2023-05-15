param(
	[switch] $linux=$false
)

if ( $linux ) {

Install-Module AzureRM.NetCore -SkipPublisherCheck -Force
Import-Module AzureRM.Netcore

}else{

Install-PackageProvider -name Nuget -MinimumVersion 2.8.5.201 -Force
Install-Module AzureRM -SkipPublisherCheck -Force

Import-Module AzureRM

}
