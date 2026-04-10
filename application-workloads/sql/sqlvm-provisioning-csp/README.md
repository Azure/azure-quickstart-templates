---
description: Microsoft Azure has a new subscription offering, CSP Subscriptions. Some aspects of SQL VM deployment are not yet supported in CSP subscriptions. This includes the SQL IaaS Agent Extension, which is required for features such as SQL Automated Backup and SQL Automated Patching.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: sqlvm-provisioning-csp
languages:
- json
---
# SQL Provisioning CSP

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/sql/sqlvm-provisioning-csp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsqlvm-provisioning-csp%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsqlvm-provisioning-csp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsql%2Fsqlvm-provisioning-csp%2Fazuredeploy.json)

# Solution Overview

Microsoft Azure has a new subscription offering, CSP Subscriptions. Some aspects of SQL VM deployment are not yet supported in CSP subscriptions. This includes the SQL IaaS Agent Extension, which is required for features such as SQL Automated Backup and SQL Automated Patching.

## Additional Notes

+   Supported Images
    All public SQL images are supported, both OS and Platform images.
+   Public DNS IP Address
    A public DNS IP address is added to each VM created. The public DNS entry allows the remote desktop access.
+   Remote desktop
    Remote desktop will be enabled by default on all new Virtual Machines created
+   Public Endpoint
    The deployment does not create any public endpoint for any VM
+   Deploying on existing resources
    Azure CSM v2 supports existing resources by simply referencing them. Submit a request to create a resource that already exists, will result in success request. Therefore, there is no special handling. For example, if you submit info for an existing VM, but change the storage account information, this will update the existing VM to use that storage account.
+   Data Disks
    The template will not create data disks for OS images deployment. User can use the portal to add data disks after provisioning is complete. Platform images are created with preconfigured data disks.
+   Supported Deployment Locations
    This is provided as a parameter the user can provide at deployment time

## Supported Scenarios

+   New Virtual Machine Deployment Resources using OS Image
    Im this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   public DNS entry
    +   Storage
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using OS image and existing storage
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using OS Image and existing VNET / Subnet
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
    +   Storage
+   Add Virtual Machine using OS Image to existing VNET / Subnet and Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using OS image with no data disks
    +   Public DNS Entry
+   New Virtual Machine Deployment Resources using Platform Image
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry
    +   Storage
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using Platform Image and existing Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform Image
    +   Public DNS Entry
    +   Virtual Network
    +   Subnet
+   Add Virtual Machine using Platform Image and existing VNET / Subnet
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry
    +   Storage
+   Add Virtual Machine using Platform Image to existing VNET / Subnet and Storage
    In this scenario, the following resources are created:
    +   Virtual Machine using Platform image
    +   Public DNS Entry

`Tags: Microsoft.Storage/storageAccounts, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/networkInterfaces, Microsoft.Compute/virtualMachines`
