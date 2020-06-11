# Create Single Instance of Perforce Helix Core server

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-perforce-helix-core-server%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-perforce-helix-core-server%2Fazuredeploy.json)

This template creates a Perforce Helix Core server using best practice Server Deployment Package (SDP):

- [Perforce Helix Core Server Version Control](https://www.perforce.com/products/helix-core)
- [SDP - Server Deployment Package](https://swarm.workshop.perforce.com/projects/perforce-software-sdp)

It is a single VM instance with a single Data volume.

The parameters which can be user configured in the parameters file include:

* `OS` (default "CentOS 7.5") - one of "CentOS 7.5", "RHEL 7.x" (7.8+), "Ubuntu 18.04 LTS"
* `adminUsername` (default "p4admin") - username to use with ssh to access the VM
* `adminSSHPubKey` (default None) - For access to VM via ssh.
* `helix_admin_username` (default "perforce") - pre-configured P4d superuser account
* `helix_admin_password` (default None) - p4d password for above user
* `source_CIDR` (default "0.0.0.0/0") - Source IP access list - recommended to consider whitelisting
* `VMSize` (default "Standard_B2s" - suitable for testing only) - Select one of Azure Linux Instance types with appropriate vCPUs and RAM for your needs
* `dataDiskSize` (default 50) - Size in GB of data volume where all metadata/logs/depot files are stored
* `p4Port` (default 1666) - P4PORT value to access p4d service. Note SSL required.

# After Installation

You will be able to connect to the provisioned instance with a P4PORT of format `ssl:<IP Adress>:1666` as user `perforce` (or <helix_admin_userame> parameter) with the configured password file using a standard Helix 

You can ssh to the instance for more detailed configuration if you wish: `ssh <adminUsername>@<IP address>` 

# P4D License Installation

The instance is unlicensed so initially will be limited to 5 users and 20 workspaces. You can buy a license by contacting `sales@perforce.com`. The license is normally tied to the internal IP address of the instance.

It can be installed via ssh or from a Helix client program.


Tags: Perforce Helix Core, Version Control, Resource Manager, Resource Manager templates, ARM templates

