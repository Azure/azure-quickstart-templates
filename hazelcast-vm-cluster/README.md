# Deploy a Hazelcast Cluster

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhazelcast-vm-cluster%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fhazelcast-vm-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

[Hazelcast](https://hazelcast.com) is an in-memory data platform which can support a variety of data applications such as data grids, nosql data stores, caching and web session clustering.

This template will deploy any number of Ubuntu Hazelcast nodes in a vnet using the [official Hazelcast Azure Discovery Provider](https://github.com/hazelcast/hazelcast-azure). Every node is installed with Hazelcast as an [upstart service](http://upstart.ubuntu.com/) and will continue to run even after subsequent restarts. Each node will discover every other node on the network automatically so you can add and remove nodes as you see fit.

Use the **Deploy to Azure** button above to get started.

Checkout Hazelcast's [official documentation](http://hazelcast.org/documentation/) to learn more on how to use Hazelcast.

## Azure Service Prinicpal

This template deploys resources that need read access the mangaement api's for the resource group this template is deployed to.

You'll need to setup [Azure Active Directory Service Principal credentials](https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/) for your Azure Subscription for this plugin to work. With the credentials, fill in the `aadClientId`, `aadClientSecret`, and `aadTenantId` parameters.
