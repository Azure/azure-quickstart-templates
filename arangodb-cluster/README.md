<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fliupeirong%2Fazure-quickstart-templates%2Fmaster%2Farangodb-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fliupeirong%2Fazure-quickstart-templates%2Fmaster%2Farangodb-cluster%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Deploys an ArangoDB Cluster

This template deploys an ArangoDB cluster. The first 3 VMs will be running Agents. The rest of the VMs will each run a DB servers and a Coordinator.

To access the Coordinators, go to http://[dnsname][3-n].[location].azure.cloudapp.com:8529

```

License
----

MIT

