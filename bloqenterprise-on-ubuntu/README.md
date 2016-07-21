![Bloq Enterprise Router on Ubuntu](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/bloqenterprise-on-ubuntu/images/bloq.png)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbloqenterprise-on-ubuntu%2Fazuredeploy.json)
[![Visualize](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbloqenterprise-on-ubuntu%2Fazuredeploy.json)

# Bloq Enterprise Router on Ubuntu

This template quickly deploys a Bloq Enterprise Router onto Microsoft Azure. After configuring
software the daemon will begin a sync with the Bitcoin network, which can take up to a full 24hr 
to sync.

This deployment downloads packages from the Bloq package repository, and has an upstart script 
that manages the starting/stopping of a Bloq Enterprise node.

## Trouble?

Ping the author at faiz@bloq.com or support@bloq.com for more information.
