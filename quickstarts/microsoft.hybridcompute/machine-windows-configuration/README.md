# Windows VM with Azure secure baseline

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/CredScanResult.svg)

![Bicep Version](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-windows-baseline/BicepVersion.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-baseline%2Fazuredeploy.json)

[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-windows-baseline%2Fazuredeploy.json)

This template allows you to deploy a Windows VM with a custom configuration assignment. General information about how configurations are assigned to machines in Azure is available in documentation.
[Understand the guest configuration feature of Azure Policy](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/guest-configuration)

After the initial application of baseline settings, Guest Configuration will continue to monitor for changes in the server configuration and report compliance back to Azure but will not prevent or correct any changes.

A detailed how to document about assigning configurations to machines, and how to customize
configurations from ARM, is also available.

## Required prerequisites

Before testing this quickstart template, you must create a Windows machine
(virtual or physical) outside of Azure and install the Arc agent
to project it into Azure.

Options to simplify building and connecting a server:
- Follow the docs page for Azure Arc-enabled servers.<br>
  [Enable Arc-enabled servers agent](https://docs.microsoft.com/en-us/azure/azure-arc/servers/learn/quick-enable-hybrid-vm)
- Follow the jumpstart exercise.<br>
  [Deploy a Windows Azure Virtual Machine and connect it to Azure Arc using an ARM Template](https://azurearcjumpstart.io/azure_arc_jumpstart/azure_arc_servers/azure/azure_arm_template_win/)

After you have an Arc-enabled server ready, you can deploy this sample
in to the same resource group and use the "machineName" parameter to specify
the machine where the configuration will be applied.


---

To provide ongoing operations for the machine, it is expected you will use the available
Azure management services. You can also view the
[Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/manage/azure-server-management/)
for more information about best practices.

- [Azure Automanage](https://docs.microsoft.com/azure/automanage/automanage-virtual-machines)
- [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
- [Azure Update Management](https://docs.microsoft.com/azure/automation/update-management/overview)
- [Azure Automation inventory feature](https://docs.microsoft.com/azure/automation/change-tracking/manage-inventory-vms)
- [Azure Policy's guest configuration feature](https://docs.microsoft.com/azure/governance/policy/concepts/guest-configuration)
- [Azure Custom Script extension for Windows](https://docs.microsoft.com/azure/virtual-machines/extensions/custom-script-windows)

---

[How to create a guest configuration assignment using templates](https://docs.microsoft.com/en-us/azure/governance/policy/how-to/guest-configuration-create-assignment)

If you're new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/)
- [Azure Linux Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/linux/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Windows virtual machine using an ARM template](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-template)
