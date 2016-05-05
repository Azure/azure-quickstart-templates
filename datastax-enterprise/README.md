# Install a Datastax Enterprise cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdatastax-enterprise%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdatastax-enterprise%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Datastax Enterprise cluster on the Ubuntu virtual machines. The template also provisions a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

A configurable number of cluster nodes of a configurable size are created and prepared with prerequisites for operations center. The cluster nodes IPs are statically assigned and only accessible on the internal virtual network.  After the cluster nodes are created, a single operations center instance is then provisioned, which is responsible for provisioning and managing the cluster nodes.

Once the deployment is complete you can access the Datastax Operations Center machine instance using the configured DNS address. The Datastax operations center has SSH port 22 enabled as well as port 8888 for HTTP and 8443 for HTTPS.  The DNS address for the operations center will include the dnsName and region entered as parameters when creating a deployment based on this template in the format `{dnsName}.{region}.cloudapp.azure.com`. If you created a deployment with the dnsName parameter set to datastax in the West US region you could access the Datastax Operations Center virtual machine for the deployment at `http://datastax.westus.cloudapp.azure.com:8443`.

NOTE: The certificate used in the deployment is a self signed certificate that will create a browser warning.  You can follow the process on the Datastax web site for replacing the certificate with your own SSL certificate.

##Known Issues and Limitations
- The template uses username/password for provisioning cluster nodes in the cluster, and would ideally use an SSH key
- The template deploys cassandra data nodes configured to use ephemeral storage and attaches a data disk that can be used for data backups in the event of a cluster failure resulting in the loss of the data on the ephemeral disks.
