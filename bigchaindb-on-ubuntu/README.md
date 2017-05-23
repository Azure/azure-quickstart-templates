# Deploy a One-Machine BigchainDB Node on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbigchaindb-on-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbigchaindb-on-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a virtual machine on Azure runnnig Ubuntu 14.04 and RethinkDB. It also installs the latest BigchainDB Server (but doesn't configure or run it).


## Detailed Instructions

The BigchainDB Server docs have [detailed instructions about how to use this template](https://docs.bigchaindb.com/projects/server/en/master/appendices/azure-quickstart-template.html).


## Short Instuctions

Once the virtual machine (and other resources) are provisioned and the `init.sh` script is done running, SSH in to the virtual machine. (You can find its hostname and IP address online in the Microsoft Azure Management Portal at https://portal.azure.com).

On the virtual machine, generate a configuration file (in `~/.bigchaindb`) by doing:
```text
bigchaindb configure
```
It will ask you several questions. You can press `Enter` (or `Return`) to accept the default for all of them *except for one*. When it asks **API Server bind? (default \`localhost:9984\`):**, you should answer:
```text
API Server bind? (default `localhost:9984`): 0.0.0.0:9984
```

To run BigchainDB, do:
```text
bigchaindb start
```

`Tags: scalable, blockchain, database`
