# These templates are currently in testing and will be ready soon. There may be issues deploying this template

# Deploy a Cloudera CDH installation on CentOS virtual machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcloudera-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

This template creates a multi-server Cloudera CDH 5.3.3 Apache Hadoop deployment on CentOS virtual machines, and configures the CDH installation for a high availability cluster.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.

Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) Cloudera member nodes configured as a cluster, configured using a set number of manager,
name and data nodes. Typical setup for Cloudera uses one manager node and 2 name nodes with as many data nodes are needed for the size that has been choosen ranging from as
few as 3 to thousands of data nodes.  The current template will scale at the highest end to 200 data nodes when using the large t-shirt size.

The following table outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Member Node VM Size | CPU Cores | Memory | Data Disks | # of Manager Node VMs | # of Name Node VMs |
|:--- |:---|:---|:---|:---|:---|:---|:---|
| Eval | Standard_D14 | 16 | 112 GB | 16x1000 GB | 1 | 1 primary, 1 secondary (non-HA) |
| Prod | Standard_D14 | 16 | 112 GB | 16x1000 GB | 1 | 1 primary, 1 standby (HA) |

##Connecting to the cluster
The machines are named according to a specific pattern.  The manager node is named based on parameters and using the.

	[dnsNamePrefix]-nn0.[region].cloudapp.azure.com

If the dnsNamePrefix was clouderatest in the West US region, the machine will be located at:

	clouderatest-nn0.westus.cloudapp.azure.com

The rest of the name nodes and data nodes of the cluster use the same pattern, with -nn and -dn extensions followed by their number.  For example:

	clouderatest-nn1.westus.cloudapp.azure.com
	clouderatest-nn2.westus.cloudapp.azure.com
	clouderatest-dn0.westus.cloudapp.azure.com
	clouderatest-dn1.westus.cloudapp.azure.com
	clouderatest-dn2.westus.cloudapp.azure.com

To connect to the manager node via SSH, use the .pem key in the repository if you used the provided key or your own .pem file.  See the section below for more information on SSH keys.

	ssh -i server-cert.pem testuser@[dnsNamePrefix]-nn0.[region].cloudapp.azure.com

Once the deployment is complete, you can navigate to the Cloudera portal to watch the operation and track it's status. Be aware that the portal dashboard will report alerts since the services are still being installed.

	http://[dnsNamePrefix]-nn0.[region].cloudapp.azure.com:7180

##Notes, Known Issues & Limitations
- All nodes in the cluster have a public IP address.
- Using passwords via SSH are disabled.  Private keys should be used to access the nodes in the cluster (See notes below.)
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user
- If security is a concern, do not use the provided .pfx file

##Managing SSH Keys
The Cloudera cluster uses SSH to communicate between machines during the provisioning process. A public/private key pair is used to provide authentication between the machines and must be provided at provisioning time.  A sample .pfx file is included and some steps must be taken to prepare it for use:
- The pfx file must be uploaded to a key vault
- The certificate must be extracted and provided as a parameter to the deployment
- The private key can be extracted and used to connect to the cluster via SSH

###Uploading the .pfx to the Key Vault
Creating the Key Vault and uploading the .pfx is done using a set of PowerShell scripts available [here](https://gallery.technet.microsoft.com/scriptcenter/Azure-Key-Vault-Powershell-1349b091).  Download these scripts and load them into a PowerShell instance using the following script.

	import-module .\KeyVaultManager

Now execute the [upload-keys.ps1](upload-keys.ps1) script found in this repository with the following parameters.

	# resourceGroupName - the name of the resource group that will hold the key
	# region - Must be the same resource the cluster will be on
	# keyVaultName - A unique key vault name between 3-24 alpha-numeric characters
	# keyName - The name used to identify the key
	# pfxFile - The pfx file containing the certificate and private key

	.\upload-keys.ps1 "TestKeyGroup" "East Asia" "TestKeyVault" "TestKey"
	  .\server-cert.pfx

The output of the script will contain a URL that is used for the **keyUri** parameter.  The rest of the the **resourceGroupName** and **keyVaultName** used in the script above will be used for the **keyVaultResourceGroup** and **keyVaultName**.

###Extracting the private key from the pfx file
OpenSSL will also extract the private key that can be used when connecting to the machine via SSL.

	 openssl pkcs12 -in server-cert.pfx -nocerts | openssl rsa -out server-cert.pem
