# Create Single Instance of Perforce Helix Core server

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/perforce/perforce-helix-core-server/CredScanResult.svg)


[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fperforce%2Fperforce-helix-core-server%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fperforce%2Fperforce-helix-core-server%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fperforce%2Fperforce-helix-core-server%2Fazuredeploy.json)


This template creates a Perforce Helix Core server using best practice Server Deployment Package (SDP):

- [Perforce Helix Core Server Version Control](https://www.perforce.com/products/helix-core)
- [SDP - Server Deployment Package](https://swarm.workshop.perforce.com/projects/perforce-software-sdp)

It is a single VM instance with a single Data volume.

The parameters which can be user configured in the parameters file include:

* `OS` (default "CentOS 7.x") - one of: "CentOS 7.x" (7.8+), "RHEL 7.x" (7.8+), "Ubuntu 18.04 LTS"
* `adminUsername` (default "p4admin") - username to use with ssh to access the VM.
* `adminSSHPubKey` (default None) - For access to VM via ssh for account `adminUsername`. This is required.
* `helix_admin_password` (default None) - p4d password for above user. This is required.
* `source_CIDR` (default "0.0.0.0/0") - Source IP access list - for security we *strongly recommend* you consider only allowing specific whitelisted IP addresses to access the server
* `VMSize` (default "Standard_B2s" - suitable for testing only) - Select one of the [Azure Linux Instance types](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general) with appropriate vCPUs and RAM for your needs. We recommend Compute optimized instances for production use, e.g. Fsv2 series options such as "Standard_F4s_v2". See KB link in More Details section below for further discussion.
* `dataDiskSize` (default 50) - Size in GB of data volume where all metadata/logs/depot files are stored. Up to 2TB (2048GB) is supported.
* `p4Port` (default 1666) - P4PORT value to access p4d service. Note SSL is not optional.

# After Installation

You will be able to connect to the provisioned instance with a P4PORT of format `ssl:<IP Adress>:1666` as user `perforce` (or <helix_admin_userame> parameter) with the configured password file using a standard Helix 

You can ssh to the instance for more detailed configuration if you wish: `ssh <adminUsername>@<IP address>` 

Please see KB link below.

# P4D License Installation

The instance is unlicensed, so initially will be limited to 5 users and 20 workspaces. You can buy a license by following the instructions at the KB link below.

# More Details (KB Link)

For more details on:

* next steps, including creation of users and depots
* how to license your installation
* how to manage it generally
* how to get support

Please see:

* [The ARM Template Knowledgebase (KB) Article](https://community.perforce.com/s/article/17334) 
* or [Search the knowledgebase](https://community.perforce.com/s/global-search/azure%20arm%20template)

Tags: Perforce Helix Core, Version Control, Resource Manager, Resource Manager templates, ARM templates
