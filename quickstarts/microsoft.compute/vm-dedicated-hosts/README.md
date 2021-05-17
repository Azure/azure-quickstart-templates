# Azure Dedicated Hosts sample template
![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/PublicLastTestDate.svg)
                        
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vm-dedicated-hosts/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-dedicated-hosts%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-dedicated-hosts%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvm-dedicated-hosts%2Fazuredeploy.json)



#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/PublicLastTestDate.svg?" />&nbsp;
#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/PublicDeployment.svg?" />

#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/FairfaxLastTestDate.svg?" />&nbsp;
#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/FairfaxDeployment.svg?" />

#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/BestPracticeResult.svg?" />&nbsp;
#<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/201-vm-dedicated-hosts/CredScanResult.svg?" />&nbsp;


## Overview

This templates provisions a dedicated environment using Azure Dedicated Hosts. You provide the number of zones, how many hosts in each zone and the rest is taken care of by the template.

Note: This is the infrastructure only, no VMs or other resources will be provisioned.

### Important Notes

* Azure Dedicated Hosts support high availability topologies by spreading your hosts across Availability Zone and Fault domains. You may select to use one, the other, or both.
* This template cover all options for achieving high availability using Azure Dedicated Hosts.
* The number of availability zones parameter determines whether the deployment will be using zones or not. Use 0 in case you do not want to use availability zones at all (e.g. in a region which does not support them).
* The template creates one host group per each zone and will spread host across the zones and fault domains provided.
* In case you are using availability zones, you will be required to provision the virtual machines and IP in the same AZ as the host group. Failing to do so will result in allocation failure.
In case you are not using availability zones (set number of AZ to 0), there is no need to provide an AZ number for your VM.

### Teardown

The easiest way to delete the created resources in this template is to simply delete the entire resource group.

Note that Azure will block an attempt to delete a dedicated host which has virtual machines deployed on. In case your hosts are used by virtual machines provisioned elsewhere (in another resource group), make sure those are deleted first before attempting to delete the host.

### Reference

References to Azure Dedicated Hosts documentation will be added once publicly available  



