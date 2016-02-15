# Deploy a Node js service connected to a highly available MongoDB installation on Ubuntu virtual machine

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-nodejs-high-availability%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmongodb-nodejs-high-availability%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a configuration of a Node.js front-end server that interacts with a MongoDB cluster. The template is a merge
of 2 templates - <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/mongodb-high-availability">azure-quickstart-templates/mongodb-high-availability</a> and <a href="https://github.com/Azure/azure-quickstart-templates/tree/master/101-simple-linux-vm">101-simple-linux-vm</a>.

The template creates a multi-server MongoDB deployment on Ubuntu and CentOS virtual machines, and configures the MongoDB installation for high availability using a replica set.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.
In addition, and when explicitly enabled, the template can create one publicly accessible "jumpbox" VM allowing to ssh into the MongoDB nodes for diagnostics or troubleshooting purposes.

The template also creates a Linux VM, using a few different options for the Ubuntu Linux version, in the same virtual network and location as the MongoDB cluster. The VM size is D1.
A Node.js (Express) service is installed on it, exposes a REST GET endpoint that connects to the MongoDB and then deletes, inserts and retrieves 3 tasks from a Tasks database.
SSH into the Ubuntu VM (using Putty www.putty.org), navigate to /opt/app.js and modify the workload as needed.

Credentials -
The adminUsername and adminPassword are administrators of all the VM's, the MongoDB database and the Tasks database.
These credentials are hard coded in the connection string in the Node js server, in /opt/app.js. Modify according to adminUsername:adminPassword you entered in the parameters.
Please do not use a question mark in the adminUsername and/or the adminPassword.

Navigate to /opt and run sudo nodejs app.js.
Open a browser with the public IP of the MyUbuntuVM machine from the Azure portal, on port 8080. You should get a JSON response with 3 tasks.

MongoDB Topology
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