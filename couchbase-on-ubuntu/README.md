# Install a Couchbase cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fcihanb%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fcihanb%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Couchbase Server 4.1 cluster on the Ubuntu 12 virtual machines. The template provisions clusters with a storage account, virtual network, availability sets, public IP addresses and network interfaces required by the installation.

Topology
--------

This template deploys Couchbase Server 4.1 Data Service (key based core data operations), Index Service (global secondary index) and Query Service (n1ql) on every node. You can find recommendations on other deployment configurations in Couchbase Server documentation [here].(http://developer.couchbase.com/documentation/server/4.1/clustersetup/services-mds.html) 

Template allows configurable number of Couchbase Server 4.1 cluster nodes and node sizes. Cluster sizes comes in 3 options;
- Small Cluster = 3 Nodes of Standard_A2
- Medium Cluster  = 4 Nodes of Standard_A6
- Large Cluster = 5 Nodes of Standard_D14

The cluster nodes are internal and only accessible on the internal virtual network. The cluster can be accessed through a jumpbox. ARM Template provides two Jumpbox Options: 
- Ubuntu Linux VM accessible through SSH: Simply ssh into port 22 of any one fo the nodes 10.0.0.X and run "/opt/couchbase/bin/couchbase-cli server-list -c nodePrivateIP -u $AdminUsername -p $AdminPassword" to see cluster node status.
- Windows Server VM through RDP: Simply visit http://10.0.0.X:8091 private IPs of nodes to see Couchbase Server web console.

Jumpbox comes with a public IP that allows access from the outside world. The assumption for the deployment is, the cluster is going to be provisioned as the back end of a service, and never be exposed to internet directly. If you have chosen not to have a jumpbox, you may need to get to the web console through the public internet. This isn't the best practice but for simple tests, simply poke a hole with a direct PublicIP to get to port 8091 on any one of the Couchbase Server nodes for the web console to get started. 

The index and data service grabs 50% of the recommended RAM. However if you can adjust the RAM allocation in favor of Data service or Index service. You can find more detailed sizing guidelines in the Couchbase Server documentation [here](http://developer.couchbase.com/documentation/server/4.1/install/sizing-general.html). 

##Known Issues and Limitations
- The deployment scripts are not currently idempotent and this template should only be used for provisioning a new cluster at the moment.
- http://10.0.0.10:8091 needs to be added to IE "Trusted Sites" list to open the admin tool on the Windows VM deployed in test configuration

##References
- Couchbase Server 4.1 [Installation Guide](http://developer.couchbase.com/documentation/server/4.1/install/installation-guide-intro.html). 
- Couchbase Server 4.1 [Concepts and Architecture](http://developer.couchbase.com/documentation/server/4.1/concepts/concepts-architecture-intro.html)
- Couchbase Server 4.1 [Administraion Guide](http://developer.couchbase.com/documentation/server/4.1/admin/admin-intro.html)
- Couchbase Server 4.1 [Developer Guide](http://developer.couchbase.com/documentation/server/4.1/developer-guide/intro.html)
- Couchbase Server 4.1 [SDKs](http://developer.couchbase.com/documentation/server/4.1/sdks/intro.html)
- Couchbase Server [N1QL Reference Guide](http://developer.couchbase.com/documentation/server/4.1/n1ql/index.html) (SQL-like Query Language for JSON)
- [Security Considerations](http://developer.couchbase.com/documentation/server/4.1/install/install-security-bp.html) for Couchbase Server 4.1 Installations
- [Cluster Sizing Guidelines](http://developer.couchbase.com/documentation/server/4.1/install/sizing-general.html) for Couchbase Server 4.1

