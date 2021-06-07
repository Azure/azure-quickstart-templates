# Remote Desktop Services 2019 with High Availability

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/rds-deployment-full-ha/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Frds-deployment-full-ha%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Frds-deployment-full-ha%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Frds-deployment-full-ha%2Fazuredeploy.json)

This ARM Template sample code will deploy a **Remote Desktop Services 2019 Session Collection** lab with high availability. The goal is to deploy a fully redundant, highly available solution for Remote Desktop Services, using Windows Server 2019.

It requests valid public certificates for the deployment automatically from Let's Encrypt.

Even though multiple services are deployed, it is not using Azure best practices, since this is a LAB environment. Also, it does not integrate into existing resources, except for the Azure Public DNS Zone. Does not integrate with existing Active Directory domain and no networking connectivity with onpremises.

**WVD is the production ready environment for Remote Desktop Services** -> [Windows Virtual Desktop](https://azure.microsoft.com/en-us/services/virtual-desktop/)

## Prerequisites

To be able to request certificates and have a highly available environment, do the following:

1. Create two CNAME entries ("remoteapps" and "broker") in your external DNS domain registrar, pointing to the following:

    **projectName**lbpip.**location**.cloudapp.azure.com
    
    Example:

         Deployment parameters:
            "projectName"     -> "rds"
            "location"        -> "eastus"
            "externalDnsZone" -> "contosocorp.com"
        
        DNS CNAMEs to be created:

        "remoteapps.contosocorp.com" CNAME "rdslbpip.eastus.cloudapp.azure.com"
        "broker.contosocorp.com"     CNAME "rdslbpip.eastus.cloudapp.azure.com"

    This is required by letsencrypt's validation process, which will connect via HTTP to your websites.

2. Change the following parameters:

    Example:

    ```json
        "projectName": {
            "value": "rds"
        },
        "location": {
            "value": "eastus"
        },
        "externalDnsZone": {
            "value": "contosocorp.com"
        },
        "deployHA": {
            "value": true
        },
        "dcCount": {
            "value": 2
        },
        "rdcbCount": {
            "value": 2
        },
        "rdwgCount": {
            "value": 2
        },
        "rdshCount": {
            "value": 2
        },
        "lsfsCount": {
            "value": 2
        }
    ```

## Configuration

All of VMs are configured as Azure Spot VMs (deallocate) and Azure Hybrid Benefit. Make sure you have licenses onpremises for Windows Server 2019 Datacenter, otherwise, change VM configuration. RD Licensing servers are not registered/licensed. Must be done manually, if using on lab.

By default, this will deploy single VM of this type:

- Active Directory/Domain Controller
- Remote Desktop Services Web Access/Gateway role
- Remote Desktop Services Connection Broker role
- Remote Desktop Services Licensing role/File server for UPD (NOT IMPLEMENTED)
- Remote Desktop Services Session Host role

Additionally, it will deploy:

- Azure SQL Server
- Azure SQL Database, used by RDS Connection Brokers for High Availability configuration
- Azure Public Load Balancer for Web Access/Gateway
- Azure Internal Load Balancer for Web Access/Gateway and Connection Brokers
- Azure Storage Account for VM diagnostics
- Single Azure Network Security Group, with required rules for HTTP/HTTPs/Gateway via UDP/3391 for RDS
- Single Azure Resource Group containing all resources
- Single Azure Virtual Network
- Single Azure Virtual Subnet
- Network Interfaces and Public IP addresses
- New Active Directory single forest, single domain

Final expected configuration is:

- Fully redundant, highly available Remote Desktop Services 2019 for Session Desktops
- Azure DNS zones with CNAMEs to public load balancer dns label
- Two [Let's encrypt](https://letsencrypt.org/) certificates for RDWebAccess/RDGateway and RDRedirector/RDPublishing

## Notes

- Using this ARM Template on Visual Studio Code with ARM extension, incorrectly triggers ARM Template validation errors, due to using Nested Templates with "inner" scope option, as described on [issue 730](https://github.com/microsoft/vscode-azurearmtools/issues/730). This can be safely ignored as the template is valid.
- Uses some code from examples [301-create-ad-forest-with-subdomain](https://github.com/Azure/azure-quickstart-templates/tree/master/301-create-ad-forest-with-subdomain) and [rds-deployment-existing-ad](https://github.com/Azure/azure-quickstart-templates/tree/master/rds-deployment-existing-ad) on Azure QuickStart Templates.
- After a successful deployment, with RDS accessible via gateway, remove the rules in NSG for incoming TCP/UDP/3389 to improve lab security.
