# Azure template for SharePoint 2019 / 2016 / 2013

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/sharepoint-adfs/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-adfs%2Fazuredeploy.json)

This template deploys SharePoint 2019, 2016 or 2013 with the following configuration:

* 1 web application created with 2 zones: Windows NTLM on Default zone and ADFS on Intranet zone.
* ADFS is installed on the DC, and SAML trust is configured in SharePoint.
* A certificate authority (ADCS) is provisioned on the DC and issues all certificates needed for ADFS and SharePoint.
* A couple of site collections are created, including [host-named site collections](https://docs.microsoft.com/en-us/SharePoint/administration/host-named-site-collection-architecture-and-deployment) that are configured for both zones.
* User Profiles Application service is provisioned and personal sites are configured as [host-named site collections](https://docs.microsoft.com/en-us/SharePoint/administration/host-named-site-collection-architecture-and-deployment).
* Add-ins service application is provisioned and an app catalog is created.
* 2 app domains are set (1 for for each zone of the web application) and corresponding DNS zones are created.
* Latest version of claims provider [LDAPCP](https://ldapcp.com/) is installed and configured.
* A 2nd SharePoint server can optionally be added to the farm.

All subnets are protected by a Network Security Group with rules that restrict network access. You can connect to virtual machines using:

* [Azure Bastion](https://azure.microsoft.com/en-us/services/azure-bastion/) if you set parameter addAzureBastion to 'Yes'.
* RDP protocol if you set parameter addPublicIPToVMs to 'Yes'. Each machine will have a public IP, a DNS name, and the TCP port 3389 will be allowed from Internet.

By default, virtual machines use standard storage and are sized with a good balance between cost and performance:

* Virtual machine size for DC: [Standard_DS2_v2](https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series): 2 CPU / 7 GiB RAM with HDD ($183.96/month in West US as of 2020-08-12)
* Virtual machine size for SQL Server: [Standard_E2ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/edv4-edsv4-series): 2 CPU / 16 GiB RAM with HDD ($185.42/month in West US as of 2020-08-12)
* Virtual machine size for SharePoint: [Standard_E2ds_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/edv4-edsv4-series): 2 CPU / 16 GiB RAM with HDD ($185.42/month in West US as of 2020-08-12)

If you need a boost in performance, you may consider the following sizes / storage account types:

* Virtual machine size for DC: [Standard_DS2_v2](https://docs.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series): 2 CPU / 7 GiB RAM with HDD ($183.96/month in West US as of 2020-08-12)
* Virtual machine size for SQL Server: [Standard_E2as_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/eav4-easv4-series): 2 CPU / 16 GiB RAM with SSD ($169.36/month in West US as of 2020-08-12)
* Virtual machine size for SharePoint: [Standard_E4as_v4](https://docs.microsoft.com/en-us/azure/virtual-machines/eav4-easv4-series): 4 CPU / 32 GiB RAM with SSD ($338.72/month in West US as of 2020-08-12)

> **Notes:**  
> I strongly recommend to update SharePoint to a recent build just after the provisioning is complete.  
> With the default setting for virtual machines, provisioning of the template takes about 1h to complete.  
> The password complexity check in the form is not accurate and may validate a password that will be rejected by Azure when it provisions the VMs. Make sure to **use at least 2 special characters for the passwords**.
