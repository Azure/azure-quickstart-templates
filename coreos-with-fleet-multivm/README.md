# Deploy a CoreOS cluster hosting Fleet

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/coreos-with-fleet-multivm/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-with-fleet-multivm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-with-fleet-multivm%2Fazuredeploy.json)

This template allows you to create a CoreOS cluster with etcd2 and fleet deployed and started on each node. This template also deploys a Storage Account, a Virtual Network, Public IP addresses and Network Interfaces.

You will need to provide an SSH public key for authentication to the nodes, as well as a "discoveryUrl" for the etcd2 cluster.

**Linux and Mac** users can use the built-in `ssh-keygen` command line utility, which is pre-installed in OSX and most Linux distributions. Execute the following command, and when prompted save to the default location (`~/.ssh/id_rsa`):

    $ ssh-keygen -t rsa -b 4096

Your **public** key will be located in `~/.ssh/id_rsa.pub`.

**Windows** users can generate compatible keys using PuTTYgen, as shown in [this article](https://winscp.net/eng/docs/ui_puttygen). Please make sure you select "SSH-2 RSA" as type, and use 4096 bits for the size for best security.

The "discoveryUrl" is used by etcd2 for peer discovery. Each etcd2 cluster must have a unique "discoveryUrl", which can easily be obtained by visiting https://discovery.etcd.io/new?size=3 (replace "3" with the *initial* size of the cluster - the minimum number of nodes for successful bootstrap). Discovery URLs, as generated from the page above, look similar to:

    https://discovery.etcd.io/dcf78d9803b417e1a3eeb15987bdf82f

This "discoveryUrl" must be copied in its entirety into the "discoveryUrl" parameter.


