# Deploy a One-Machine BigchainDB Node on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbigchaindb-on-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbigchaindb-on-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template provisions a virtual machine running Ubuntu 14.04.4 LTS, plus various other Azure resources. (See the `azuredeploy.json` file for details.) It then runs the script `scripts/init.sh`, which:

1. Installs RethinkDB and runs it (with a default RethinkDB configuration file).
2. Installs BigchainDB dependencies and BigchainDB itself (i.e. the latest version on PyPI).

That script does _not_ configure or run BigchainDB. To do that, first SSH in to the virtual machine. (You can find its hostname and IP address online in the Microsoft Azure Management Portal at https://portal.azure.com).

On the virtual machine, generate a default configuration file (in `~/.bigchaindb`) by doing:
```text
bigchaindb -y configure
```

To run BigchainDB, do:
```text
bigchaindb start
```

`Tags: scalable, blockchain, database`

## Documentation

Documentation for BigchainDB is at https://bigchaindb.readthedocs.io/en/latest/index.html
