Param(
	# PowerShell 7 msi file path
	[Parameter()][string]$PowerShell7FilePath="PowerShell-7.0.2-win-x64.msi",

	# AAD Application Id to install the data gateway under: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$AppId,

	# AAD Application secret: https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$Secret,

	# AAD Tenant Id (or name): https://docs.microsoft.com/en-us/powershell/module/datagateway.profile/connect-datagatewayserviceaccount?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$TenantId,

	# Documented on the Install-DataGateway: https://docs.microsoft.com/en-us/powershell/module/datagateway/install-datagateway?view=datagateway-ps
	[Parameter()][string]$InstallerLocation="GatewayInstall.exe",

	# Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$RegionKey,

	# Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$RecoveryKey,

	# Documented on the Add-DataGatewayCluster: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewaycluster?view=datagateway-ps
	[Parameter(Mandatory = $true)][string]$GatewayName,

	# Documented on the Add-DataGatewayClusterUser: https://docs.microsoft.com/en-us/powershell/module/datagateway/add-datagatewayclusteruser?view=datagateway-ps
	[Parameter()][string]$GatewayAdminUserIds
)

# Import log utils
. .\logUtil.ps1

$logger = [TraceLog]::new("$env:SystemDrive\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\", "setup.log")

# Install PowerShell v7 if necessary
if (!(IsInstalled 'PowerShell 7-x64' $logger)) {
	$progressMsg = "Installing PowerShell v7"
	$logger.Log($progressMsg)
	Write-Output($progressMsg)
  	if (!(Test-Path -Path $PowerShell7FilePath)) {
		# Download & install PowerShell v7
		$progressMsg = "Download & install PowerShell v7 from script"
		$logger.Log($progressMsg)
		Write-Output($progressMsg)
		iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"
  	}else {
		$progressMsg = "Installing PowerShell v7 from '$PowerShell7FilePath'"
		$logger.Log($progressMsg)
		Write-Output($progressMsg)
		Install-Silent $PowerShell7FilePath $logger
  	}
}

# Install the Power BI Gateway under a PowerShell v7 shell
$progressMsg = "Installing PBI Gateway under PowerShell v7 shell"
$logger.Log($progressMsg)
Write-Output($progressMsg)

# Pass thru params into main pbi gateway installer script
$params = "-File .\pbiGatewayInstall.ps1 -AppId $AppId -Secret $Secret -TenantId $TenantId -InstallerLocation $InstallerLocation -RecoveryKey $RecoveryKey -GatewayName $GatewayName -Region $RegionKey -GatewayAdminUserIds $GatewayAdminUserIds"
$result = Invoke-Process "$env:ProgramFiles\PowerShell\7\pwsh.exe" $params $logger

# Write output to surface to CustomScriptExtension
$progressMsg = "Result=$($result['Output']) \n\rExitCode=$($result['ExitCode'])"
Write-Output($progressMsg)

# Throw any error out for CustomScriptExtension to report "Provisioning failed"
if($result['ExitCode'] -ne 0) {
	$progressMsg = "Error within pbiGateway.ps1: $($result['Error'])"
	throw $progressMsg
}else {
	$progressMsg = "Finished setup.ps1"
	$logger.Log($progressMsg)
	Write-Output($progressMsg)
}