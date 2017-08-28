$prefix = "demo3"
$MgmtRgName = "$prefix-mgmt"
$WorkloadRgName = "$prefix-workload"
$rgLocation = "East US"

$MgmtRg = New-AzureRmResourceGroup -Name $MgmtRgName -Location $rgLocation -Verbose
$WorkloadRg = New-AzureRmResourceGroup -Name $WorkloadRgName -Location $rgLocation -Verbose

$OMSWorkspaceName = "$prefix-workspace"
$OMSWorkspaceRegion = "East US"
$OMSRecoveryVaultName = "$prefix-vault"
$OMSRecoveryVaultRegion = "East US"
$OMSAutomationName = "$prefix-auto"
$OMSAutomationRegion = "East US 2"
$Platform = "Windows"
$userName = "localadmin"
$vmNameSuffix = "$prefix"
$instanceCount = "2" 
$deploymentName = "demo-deployment" 
$templateUri = "https://raw.githubusercontent.com/MSBrett/azure-quickstart-templates/master/azmgmt-demo/azuredeploy.json"

$guid1 = [guid]::NewGuid()
$guid2 = [guid]::NewGuid()
$guid3 = [guid]::NewGuid()

New-AzureRmResourceGroupDeployment -Name $deploymentName `
                                   -ResourceGroupName $MgmtRg.ResourceGroupName `
                                   -TemplateUri $templateUri `
                                   -vmResourceGroup $WorkloadRg.ResourceGroupName `
                                   -omsRecoveryVaultName $OMSRecoveryVaultName `
                                   -omsRecoveryVaultRegion $OMSRecoveryVaultRegion `
                                   -omsWorkspaceName $OMSWorkspaceName `
                                   -omsWorkspaceRegion $OMSWorkspaceRegion `
                                   -omsAutomationAccountName $OMSAutomationName `
                                   -omsAutomationRegion $OMSAutomationRegion `
                                   -vmNameSuffix $vmNameSuffix `
                                   -userName $userName `
                                   -platform $platform `
                                   -instanceCount $instanceCount `
                                   -guid1 $guid1 `
                                   -guid2 $guid2 `
                                   -guid3 $guid3 `
                                   -verbose
                                   