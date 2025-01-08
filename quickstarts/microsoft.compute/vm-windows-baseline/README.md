---
description: The template creates a virtual machine running Windows Server in a new virtual network, with a public IP address. Once the machine has deployed, the guest configuration extension is installed and the Azure secure baseline for Windows Server is applied. If the configuration of the machines drifts, you can re-apply the settings by deploying the template again.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: vm-windows-baseline
languages:
- json
- bicep
---
# Windows VM with Azure secure baseline.

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-baseline%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-baseline%2Fazuredeploy.json)

This template allows you to deploy a Windows VM with the Azure secure baseline applied. For details about the settings in the baseline,
review the reference documentation.

[Windows secure baseline](https://docs.microsoft.com/azure/governance/policy/samples/guest-configuration-baseline-windows)

General information about how configurations are assigned to machines in Azure is available in documentation.

[Understand the guest configuration feature of Azure Policy](https://docs.microsoft.com/azure/governance/policy/concepts/guest-configuration)

A detailed how to document about assigning configurations to machines, and how to customize configurations from ARM,
is also available.

---

**Common administration ports to log in to the VM directly, are not opened in this template.**
After deploying this machine, it is expected that you will
[deploy applications](https://docs.microsoft.com/azure/devops/pipelines/release/deployment-groups/deploying-azure-vms-deployment-groups)
using a service such as Azure DevOps.

- [Provision agents for deployment groups](https://docs.microsoft.com/azure/devops/pipelines/release/deployment-groups/howto-provision-deployment-group-agents)

To provide ongoing operations for the machine, it is expected you will use the available
Azure management services. You can also view the
[Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/manage/azure-server-management/)
for more information about best practices.

- [Azure Automanage](https://docs.microsoft.com/azure/automanage/automanage-virtual-machines)
- [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Update Management](https://docs.microsoft.com/azure/automation/update-management/overview)
- [Azure Automation inventory feature](https://docs.microsoft.com/azure/automation/change-tracking/manage-inventory-vms)
- [Azure Policy's guest configuration feature](https://docs.microsoft.com/azure/governance/policy/concepts/guest-configuration)
- [Azure Backup](https://docs.microsoft.com/azure/backup/)
- [Azure Custom Script extension for Windows](https://docs.microsoft.com/azure/virtual-machines/extensions/custom-script-windows)
- [Azure Run Commands for Windows](https://docs.microsoft.com/azure/virtual-machines/windows/run-command)

If you would prefer to open common ports, modify rules in the network security group
associated with the network adapter for the machine.

- [Network security groups](https://docs.microsoft.com/azure/virtual-network/network-security-groups-overview)

---

[How to create a guest configuration assignment using templates](https://docs.microsoft.com/azure/governance/policy/how-to/guest-configuration-create-assignment)

If you're new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/)
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Windows virtual machine using an ARM template](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-template)

`Tags: Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, ConfigurationforWindows, Microsoft.GuestConfiguration/guestConfigurationAssignments`
