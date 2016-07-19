<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fliupeirong%2Fazure-quickstart-templates%2Fmaster%2Farangodb-cluster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fliupeirong%2Fazure-quickstart-templates%2Fmaster%2Farangodb-cluster%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Deploys an ArangoDB Cluster

This template deploys an ArangoDB cluster with N DB servers, each also runs a Coordinator.  It also deploys 3 Agencies in the cluster.

To access the Coordinators, go to http://[dnsname][n].[location].azure.cloudapp.com:8529
To access the DB servers, go to http://[dnsname][n].[location].azure.cloudapp.com:8629

```

License
----

MIT

