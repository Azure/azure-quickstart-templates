# Deploy a CoreOS cluster hosting Fleet

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-with-fleet-multivm%2Fazuredeploy.json)
[![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-with-fleet-multivm%2Fazuredeploy.json)


This template allows you to create a CoreOS cluster with etcd2 and fleet deployed and started on each node. This template also deploys a Storage Account, a Virtual Network, Public IP addresses and Network Interfaces.

You will need to provide an SSH public key for authentication to the nodes, as well as a "discoveryUrl" for the etcd2 cluster.

**Linux and Mac** users can use the built-in `ssh-keygen` command line utility, which is pre-installed in OSX and most Linux distributions. Execute the following command, and when prompted save to the default location (`~/.ssh/id_rsa`):

    $ ssh-keygen -t rsa -b 4096

Your **public** key will be located in `~/.ssh/id_rsa.pub`.

**Windows** users can generate compatible keys using PuTTYgen, as shown in [this article](https://winscp.net/eng/docs/ui_puttygen). Please make sure you select "SSH-2 RSA" as type, and use 4096 bits for the size for best security.

The "discoveryUrl" is used by etcd2 for peer discovery. Each etcd2 cluster must have a unique "discoveryUrl", which can easily be obtained by visiting https://discovery.etcd.io/new?size=3 (replace "3" with the *initial* size of the cluster - the minimum number of nodes for successful bootstrap). Discovery URLs, as generated from the page above, look similar to:

    https://discovery.etcd.io/dcf78d9803b417e1a3eeb15987bdf82f

This "discoveryUrl" must be copied in its entirety into the "discoveryUrl" parameter.
