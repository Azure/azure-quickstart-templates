## Deploying MultiChain on Microsoft Azure

This Microsoft Azure template deploys MultiChain to create a new private blockchain.

Once your deployment is complete, a private blockchain named ``chain1`` will be running and you can start connecting other MultiChain nodes to the blockchain to send transactions and issue assets.

## Connect to the blockchain from another computer

Install Multichain on a second computer and run the command `multichaind <nodeaddress>`.

The ``nodeaddress`` argument was obtained after deployment and should look something like `chain1@magicunicorns.westus.cloudapp.azure.com:8333`.

More information about how to connect to a blockchain and grant permissions can be found in the [Getting Started](http://www.multichain.com/getting-started/) tutorial.

## Tips

If you want to experiment with two separate chains, create a new Resource Group, and use it to launch the template again.



