# Deploy a highly available MongoDB installation on Ubuntu and CentOS virtual machines

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/mongo/mongodb-high-availability/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-high-availability%2Fazuredeploy.json) 
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-high-availability%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fmongo%2Fmongodb-high-availability%2Fazuredeploy.json)

This template creates a multi-server MongoDB deployment on Ubuntu and CentOS virtual machines, and configures the MongoDB installation for high availability using a replica set.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.
In addition, and when explicitly enabled, the template can create one publicly accessible "jumpbox" VM allowing to ssh into the MongoDB nodes for diagnostics or troubleshooting purposes.

Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) MongoDB member nodes configured as a replica set, along with the optional
arbiter node. Replica sets are the preferred replication mechanism in MongoDB in small-to-medium installations. However, in a large deployment
with more than 50 nodes, a master/slave replication is required.

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Member Node VM Size | CPU Cores | Memory | Data Disks | Arbiter Node VM Size | # of Members | Arbiter | # of Storage Accounts |
|:--- |:---|:---|:---|:---|:---|:---|:---|:---|
| XSmall | Standard_D1 | 1 | 3.5 GB | 2x100 GB | Standard_A1 | 2 | Yes | 1 |
| Small | Standard_D1 | 1 | 3.5 GB | 2x100 GB | Standard_A1 | 3 | No | 1 |
| Medium | Standard_D2 | 2 | 7 GB | 4x250 GB | Standard_A1 | 4 | Yes | 2 |
| Large | Standard_D2 | 2 | 7 GB | 4x250 GB | Standard_A1 | 8 | Yes | 4 |
| XLarge | Standard_D3 | 4 | 14 GB | 8x500 GB | Standard_A1 | 8 | Yes | 4 |
| XXLarge | Standard_D3 | 4 | 14 GB | 8x500 GB | Standard_A1 | 16 | No | 8 |

An optional single arbiter node is provisioned in addition to the number of members stated above, thus increasing the total number of nodes by 1.
The size of the arbiter node is standardized as _Standard_A1_. Arbiters do not store the data, they vote in elections for primary and require just a bare minimum machine specification to perform their duties.

Each member node in the deployment will have a MongoDB daemon installed and correctly configured to participate in a replica set. All member nodes except the last one will be provisioned in parallel. During provisioning of the last node, a replica set will be initiated.
The optional arbiter joins the replica set after it is initiated. To ensure a successful deployment, this template has to serialize the provisioning of all member nodes and the arbiter node as follows:

__(1) MEMBER NODES__ (except last) >>> __(2) LAST MEMBER NODE__ >>> __(3) ARBITER__ (optional)

In the above deployment sequence, steps #1 and #2 will have to complete first before the next step kicks off. As a result, you may be seeing longer-than-desirable deployment times as member node provisioning is not fully parallelized.

##Notes, Known Issues & Limitations
- To access the individual MongoDB nodes, you need to use the publicly accessible jumpbox VM and _ssh_ from it into the individual MongoDB instances
- The minimum architecture of a replica set is comprised of 3 members. A typical 3-member replica set can have either 3 members that hold data, or 2 members that hold data and an arbiter
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user
- MongoDB version 3.0.0 and above is recommended in order to take advantage of high-scale replica sets offered by this template
- The current version of the MongoDB template is shipped with Ubuntu support only (adding support for CentOS is just a matter of creating an additional installation .sh script)


