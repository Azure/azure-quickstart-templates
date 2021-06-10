# VM Scale Set Configuration managed by Azure Automation DSC

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-automation-dsc/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-automation-dsc%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-automation-dsc%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-automation-dsc%2Fazuredeploy.json)

This repo serves to prove an ARM template to deploy a VM Scale Set where virtual machines are deployed as registered nodes in the Azure Automation Desired State Configuration service, and node configuration is guaranteed consistent after deployment, and the AADSC service components are provided in the same deployment template.

The Azure Resource Manager template includes:

- Deploy virtual machines in Scale Set with autoscale rules defined
- Distribute VHD files across 5 storage accounts
- Configure Azure Automation DSC service with configuration and modules to manage the virtual machines
  - Note that the Local Configuration Manager setting **Mode** will be set to **ApplyandAutoCorrect**
- Boostrap the virtual machines as registered nodes of the service using DSC extension
- Load balance traffic to web servers across the VM Scale Set
- NAT remote management ports across VM Scale Set

Tested scenarios:

- End to end deployment
- Modify configuration of live VM Scale Set by updating Configuration in AADSC
- Report on VM configuration consistency from AADSC
- Add and remove nodes from the VM Scale set and maintain consistency
- Deployed VM's return to configuration after a forced drift out of compliance
- VM AutoScale based on CPU % with bursted VM's remaining in consistent state through DSC

Future work:

- Add Operational Validation
- Deliver web app using Containers managed by [DSC](https://github.com/bgelens/cWindowsContainer)

## Release Notes

2019-02-20: Updated and revised entire solution to align with [101-automation-configuration](https://github.com/Azure/azure-quickstart-templates/tree/master/101-automation-configuration) example.  Also added runbook solution for tombstoning stale nodes per customer request.

## To verify the nodes are deployed and configured (manual operational validation)

The webServer configuration adds the Windows Features to support IIS and manages the Windows Firewall settings to allow access to the default site.  To verify, open the Public FQDN of the deployment in a browser and confirm the default IIS page.

## To clone the module to your local machine from Git Shell

```PowerShell
git clone https://github.com/Azure/azure-quickstart-templates/blob/master/201-vmss-automation-dsc
```

## Prior Examples

[Register an existing Azure virtual machine as a managed DSC node in Azure Automation DSC](https://github.com/Azure/azure-quickstart-templates/tree/master/dsc-extension-azure-automation-pullserver)
[Deployment of Multiple VM Scale Sets of Windows VMs](https://github.com/Azure/azure-quickstart-templates/tree/02d32850258f5b172266896e498e30e8e526080a/301-multi-vmss-windows)
[Copy a DSC Configuration to Azure Automation and compile](https://github.com/azureautomation/automation-packs/tree/master/201-Deploy-And-Compile-DSC-Configuration-Credentials)
[azure-myriad](https://github.com/gbowerman/azure-myriad) - this repo is a great resource for learning about VM Scale Sets!
