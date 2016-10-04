## Deploying MultiChain on Microsoft Azure

This Microsoft Azure template deploys MultiChain to create a new private blockchain.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmultichain-on-ubuntu%2Fazuredeploy.json)

Once your deployment is complete, a private blockchain named ``chain1`` will be running and you can start connecting other MultiChain nodes to the blockchain to send transactions and issue assets.

## Template Parameters

When you launch the installation of the VM, you need to specify the following parameters:
* `vmDnsName`: This is the public DNS name for the VM.  You need to specify an unique name.
* `adminUsername`: This is the username you will use for logging into to the VM.
* `adminPassword`: Azure requires passwords to have at least three of the following: one upper case, one lower case, a special character, or a number.
* `vmSize`: The type of VM that you want to use for the node. The default size is D1 (1 core 3.5GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to

Once the deployment of the MultiChain node has completed, you will receive the ``nodeaddress`` that can be used to connect other nodes to the new blockchain.  The blockchain's name is ``chain1`` and the network port is set to ``8333`` and the JSON-RPC port set to ``8332``.  The deployed node has the role of Administrator.

## Connect to the blockchain from another computer

Install Multichain on a second computer and run the command `multichaind <nodeaddress>`.

The ``nodeaddress`` argument was obtained after deployment and should look something like `chain1@magicunicorns.westus.cloudapp.azure.com:8333`.

More information about how to connect to a blockchain and grant permissions can be found in the [Getting Started](http://www.multichain.com/getting-started/) tutorial.

## Tips

If you want to experiment with two separate chains, create a new Resource Group, and use it to launch the template again.



