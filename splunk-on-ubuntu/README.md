# Create Splunk Enterprise standalone or cluster on Azure

**US Government Cloud**

[![Deploy to Azure Gov](https://azuredeploy.net/AzureGov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2Fsplunk-on-ubuntu%2Fazuredeploy-gov.json)

**NOTE regarding deployment to US Government Cloud**

The template system that deploys to US Government Cloud is largely identical to that for the public cloud. If launched using the "Deploy to Azure Gov" button above, the **standalone** and **cluster** deployment types are available but without as many configuration options in the UI as the public cloud. To gain access to the additional configuration options, tailor the templates to your needs and use the Azure CLI to launch. Deployment to the US Government Cloud requires your Azure subscription to be whitelisted for that purpose.

**Public Cloud**

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsplunk-on-ubuntu%2Fazuredeploy.json)

This template deploys Splunk Enterprise 6.4 on Azure as either **standalone** instance or distributed **cluster** (up to 20 indexers). Each instance has eight (8) 1-TB data drives in RAID0 configuration. The template also provisions a storage account, a virtual network with subnets, public IP address, and all network interfaces & security groups required.

Once the deployment is complete, Splunk Enterprise can be accessed using the configured DNS address. The DNS address will include the `domainNamePrefix` and `location` entered as parameters in the format `{domainNamePrefix}.{location}.cloudapp.azure.com`. If you created a deployment with `domainNamePrefix` parameter set to "splunk" in the West US region, then Splunk Enterprise can be accessed at `https://splunk.westus.cloudapp.azure.com`.

Below is the list of template parameters:

| Name   | Required | Description |
|:--- |:--- |:---|
| location | :heavy_check_mark: | Location where Azure resources will be created |
| storageAccountType | | Storage account type which determines data redundancy and underlying drive type. Defaults to `Standard_LRS` |
| deploymentType | | Splunk deployment type. Allowed values: `Standalone` (Default), `Cluster` |
| standaloneVmSize | | VM Size of standalone instance. Applicable for `Standalone` deployment type |
| clusterMasterVmSize | | VM Size of cluster master. Applicable for `Cluster` deployment type |
| clusterSearchheadVmSize | | VM Size of cluster search head. Applicable for `Cluster` deployment type |
| clusterIndexerVmSize | | VM Size of cluster indexer. Applicable for `Cluster` deployment type |
| clusterIndexerVmCount | | Count of indexers. Integer between 3 and 20. Defaults to 3 |
| adminUsername | :heavy_check_mark: | Admin username for the VMs |
| adminPassword | :heavy_check_mark: | Admin password for the VMs |
| splunkAdminPassword | :heavy_check_mark: | Password for Splunk admin user |
| virtualNetworkNewOrExisting | | Identifies whether to use new or existing Virtual Network. Allowed values: `new` (Default), `existing` |
| virtualNetworkExistingRGName | | Name of resource group of existing Virtual Network. Applicable if `virtualNetworkNewOrExisting=existing` |
| virtualNetworkName | :heavy_check_mark: | Name of the virtual network to be used |
| virtualNetworkAddressPrefix | | Virtual network address CIDR |
| subnet1Name | | Subnet for the Search Head |
| subnet2Name | | Subnet for the Indexers |
| subnet1Prefix | | Search Head subnet CIDR |
| subnet2Prefix | | Indexer subnet CIDR |
| subnet1StartAddress | | Search Head subnet start address |
| subnet2StartAddress | | Indexer subnet start address |
| sshFrom | | CIDR block from which SSH access is allowed. Default is ssh access from anywhere |
| forwardedDataFrom | | CIDR block from which forwarded data is allowed. Default is data can be received from anywhere |
| domainNamePrefix | :heavy_check_mark: | Prefix for domain name to access Splunk |
| publicIPName | | Name of the Search Head public IP address. Default: splunksh-publicip |


NOTE:
* This solution uses Splunk's default certificates to enable HTTPS which will create a browser warning. Please follow instructions in Splunk Docs to secure Splunk Web [with your own SSL certificates](http://docs.splunk.com/Documentation/Splunk/latest/Security/SecureSplunkWebusingasignedcertificate).

* This solution uses Splunk's 60-day Enterprise Trial license which includes only 500 MB of indexing per day. If you need to extend your license, or need more volume per day, [contact Splunk sales team online](http://www.splunk.com/index.php/ask_expert/2468/3117) or at sales@splunk.com or call +1.866.GET.SPLUNK (866.438.7758). Once you acquire a license, please follow instructions in Splunk Docs to [install the license](http://docs.splunk.com/Documentation/Splunk/latest/Admin/Installalicense) in the standalone Splunk instance, or, in case of a cluster deployment, [configure a central license master](http://docs.splunk.com/Documentation/Splunk/latest/Admin/Configurealicensemaster) to which the cluster peer nodes can be added as license slaves.

* The cluster version of this solution will mostly likely need more than 20 cores which will require an increase in your default Azure core quota for ARM. Please contact Microsoft support to increase your quota.

### Standalone Mode:
The instance has the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP to access Splunk
* 9997 for TCP receiver traffic
* 8088 for HTTP Event Collector
* 8089 for Splunkd Management open to VNet only

### Cluster Mode:
Cluster search head & cluster master have the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP to access Splunk
* 8089 for Splunkd Management open to VNet only

Cluster indexers have the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP to access Splunk
* 9997 for TCP receiver traffic
* 8088 for HTTP Event Collector
* 9887 for TCP replication traffic open to VNet only
* 8089 for Splunkd Management open to VNet only

##Known issues and limitations
- The template sets up SSH access via admin username/password, and would ideally use an SSH key.
- The template opens SSH port to the public. You can restrict it to a virtual network and/or a bastion host only.

##Third-party software credits
- VM utility shell script: MIT license
- [Opscode Chef Splunk Cookbook](https://github.com/rarsan/chef-splunk): Apache 2.0 license
