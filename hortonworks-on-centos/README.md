# These templates are currently in testing and will be ready soon. This documentation is in progress and will change.  There may be issues deploying this template

# Deploy a Hortonworks HDP installation on CentOS virtual machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhortonworks-on-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png" />
</a>

This template creates a multi-server Hortonworks HDP 2.2 Apache Hadoop deployment on CentOS virtual machines, and configures the HDP installation across a cluster.
The template also provisions storage accounts, virtual network, availability set, network interfaces, VMs, disks and other infrastructure and runtime resources required by the installation.

The template expects the following parameters:

| Name   | Description | Default Value |
|:--- |:---|:---|
| adminUsername  | Administrator user name used when provisioning virtual machines | testuser |
| adminPassword  | Administrator password used when provisioning virtual machines | Eur32#1e |
| storageAccountPrefix | Unique namespace for the Storage Account where the Virtual Machine's disks will be placed | defaultStorageAccountPrefix |
| dnsNamePrefix | Unique public dns name where the Virtual Machines will be exposed | defaultDnsNamePrefix |
| region | Azure data center location where resources will be provisioned |  |
| storageAccountType | The type of the Storage Account to be created | Standard_LRS |
| virtualNetworkName | The name of the virtual network provisioned for the deployment | hortonworkVnet |
| subnetName | Subnet name for the virtual network where resources will be provisioned | hortonworkSubnet |
| addressPrefix | The network address space for the virtual network | 10.0.0.0/24 |
| subnetPrefix | The network address space for the virtual subnet | 10.0.0.0/24 |
| nodeAddressPrefix | The IP address prefix that will be used for constructing private IP address for each node in the cluster | 10.0.0. |
| tshirtSize | T-shirt size of the Hortonworks cluster (Eval, Small, Medium, large) | Eval |
| publicSSHCert | The base64 representation of the certificate used for SSH login. Details in Key Vault and SSH Keys section below. | Read section below |
| keyVaultResourceGroup | The resource group containing the key vault which provides the private key used for SSH login. | AzureRM-Util |
| keyVaultName | The name of the key vault which provides the private key  used for SSH login. | AzureRM-Keys |
| keyUri | The url of the private key used for SSH login. Details in Key Vault and SSH Keys section below. | Read section below |


Topology
--------

The deployment topology is comprised of a predefined number (as per t-shirt sizing) Hortonworks member nodes configured as a cluster, configured using a set number of master
and data nodes. Typical setup for Hortonworks uses anywhere from 2 to 8 master nodes with as many data nodes are needed for the size that has been choosen ranging from as
few as 3 to thousands of data nodes.  The current template will scale at the highest end to 200 data nodes when using the large t-shirt size.

The following tables outlines the deployment topology characteristics for each supported t-shirt size:

| T-Shirt Size | Number of Master Nodes | Number of Worker Nodes |
|:---|:---|:---|
| Eval | 2 | 3 |
| Small | 4 | 9 |
| Medium | 4 | 99 |

**Master Nodes**

| T-Shirt Size | Node VM Size | CPU Cores | Memory | Data Disks |
|:---|:---|:---|:---|:---|
| Eval | Standard_A3 | 4 | 7GB | 8x1TB |
| Small | Standard_A6 | 4 | 28GB | 8x1TB |
| Medium | Standard_A7 | 8 | 56GB | 16x1TB |

**Worker Nodes**

| T-Shirt Size | Node VM Size | CPU Cores | Memory | Data Disks |
|:---|:---|:---|:---|:---|
| Eval | Standard_A3 | 4 | 7GB | 8x1TB |
| Small | Standard_A7 | 8 | 56GB | 16x1TB |
| Medium | Standard_A7 | 8 | 56GB | 16x1TB |

##Connecting to the cluster
The machines are named according to a specific pattern.  The master node is named based on parameters and using the.

       [dnsNamePrefix]-mn-1.[region].cloudapp.azure.com

If the dnsNamePrefix was hortonworkstest in the West US region, the machine will be located at:

       hortonworkstest-mn-1.westus.cloudapp.azure.com

The name nodes and data nodes of the cluster use the same pattern, but with -nn and -dn extensions followed by their number.  For example:

       hortonworkstest-mn-2.westus.cloudapp.azure.com
       hortonworkstest-mn-3.westus.cloudapp.azure.com
       hortonworkstest-wn-1.westus.cloudapp.azure.com
       hortonworkstest-wn-2.westus.cloudapp.azure.com
       hortonworkstest-wn-3.westus.cloudapp.azure.com

To connect to the master node via SSH, use the .pem key in the repository if you used the provided key or your own .pem file.  See the section below for more information on SSH keys.

       ssh -i server-cert.pem testuser@[dnsNamePrefix]-mn-1.[region].cloudapp.azure.com

Once the deployment is complete, you can navigate to the Ambari portal to watch the operation and track it's status. Be aware that the portal dashboard will report alerts since the services are still being installed.

       https://[dnsNamePrefix]-mn-1.[region].cloudapp.azure.com:8443

##Notes, Known Issues & Limitations
- All nodes in the cluster have a public IP address.
- Using passwords via SSH are disabled.  Private keys should be used to access the nodes in the cluster (See notes below.)
- The deployment script is not yet idempotent and cannot handle updates (although it currently works for initial provisioning only)
- SSH key is not yet implemented and the template currently takes a password for the admin user
- If security is a concern, do not use the provided .pfx file

##Managing SSH Keys
The Hortonworks cluster uses SSH to communicate between machines during the provisioning process. A public/private key pair is used to provide authentication between the machines and must be provided at provisioning time.  A sample .pfx file is included and some steps must be taken to prepare it for use:
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

###Extracting the certificate from the pfx file
OpenSSL will extract a certificate from a .pfx and print it to the console.

       # The sample server-cert.pfx has no password
       openssl pkcs12 -in server-cert.pfx -clcerts -nokeys

The output of this command contains a base64 encoded string representing the certificate.  This string as a single line between the BEGIN CERTIFICATE and END CERTIFICATE delimiters is used for the **publicSSHCert** parameter.  If you use the provided server-cert.pfx file, the default parameter for **publicSSHCert** will work correctly.

###Extracting the private key from the pfx file
OpenSSL will also extract the private key that can be used when connecting to the machine via SSL.

       openssl pkcs12 -in server-cert.pfx -nocerts | openssl rsa -out server-cert.pem
