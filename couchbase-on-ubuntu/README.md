# Install a Couchbase cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys a Couchbase Server 4.1 cluster on the Ubuntu 12 virtual machines. The template provisions clusters with a storage account, virtual network, availability sets, public IP addresses and network interfaces required for high performance Couchbase Server cluster installation.

Couchbase Server Cluster Topology and Settings
----------------------------------------------
Cluster Sizes: Template allows configurable number of Couchbase Server 4.1 cluster nodes and node sizes. Cluster sizes comes in 3 options;
- Small Cluster = 3 Nodes of Standard_A2
- Medium Cluster  = 4 Nodes of Standard_A6
- Large Cluster = 5 Nodes of Standard_D14

Simple Deployment Topology: This template deploys Couchbase Server 4.1 Data Service (key based core data operations), Index Service (global secondary index) and Query Service (n1ql) on every node. Changing you topology can be done online if  you prefer a different deployment topology with services. You can find recommendations on other deployment configurations in Couchbase Server documentation [here].(http://developer.couchbase.com/documentation/server/4.1/clustersetup/services-mds.html) 

Settings: The index and data service grabs 50% of the recommended RAM. However if you can adjust the RAM allocation in favor of Data service or Index service. You can find more detailed sizing guidelines in the Couchbase Server documentation [here](http://developer.couchbase.com/documentation/server/4.1/install/sizing-general.html). 

Storage: Each node is configured to store data and indexes under the mounted /datadisks folder (non-ephemeral drive)  using a RAID0 configuration for high performance storage. 

Jumpbox for Secure Access to Cluster
------------------------------------
The cluster nodes are internal and only accessible on the internal virtual network. The cluster can be accessed through a jumpbox. ARM Template provides two Jumpbox Options: 
- Ubuntu Linux VM accessible through SSH: Simply ssh into port 22 of any one fo the nodes 10.0.0.X and run "/opt/couchbase/bin/couchbase-cli server-list -c nodePrivateIP -u $AdminUsername -p $AdminPassword" to see cluster node status.
- Windows Server VM through RDP: Simply visit http://10.0.0.X:8091 private IPs of nodes to see Couchbase Server web console.

Jumpbox comes with a public IP that allows access from the outside world. The assumption for the deployment is, the cluster is provisioned as the back end of a service, and never be exposed to internet directly. If you have chosen not to have a jumpbox, you may need to get to the web console through the public internet. This isn't the best practice but for simple tests, simply poke a hole with a direct PublicIP to get to port 8091 on any one of the Couchbase Server nodes for the web console to get started. 

Getting Started with Couchbase Server Samples
---------------------------------------------
You can get started with a sample app or run a SQL Query on a sample database with Couchbase Server installation. 
- Running you first SQL Query: Simply enable the travel sample bucket (database) 
    - Visit 10.0.0.10:8091 or any one of the nodes provisioned.
    - Under Web Console, enable the sample bucket (Settings Tab > Sample Buckets) bu checking beer-sample
    - Under the Web Console, go to Query Tab and run "SELECT * FROM `beer-sample` WHERE type="beer" LIMIT 10;". You can find more detailed instructions [here](http://developer.couchbase.com/documentation/server/4.1/getting-started/first-n1ql-query.html#first-n1ql)
- Full Getting Started Guide with SDKs: Skip Step1 here in the [Getting Started](http://www.couchbase.com/get-started-developing-nosql) guide since you will have Couchbase Server already deployed.

##Known Issues and Limitations
- The deployment scripts are not idempotent and this template should only be used for provisioning a new cluster at the moment.
- http://10.0.0.10:8091 needs to be added to IE "Trusted Sites" list to open the admin tool on the Windows VM deployed in test configuration - You can turn off EI Enhanced Security through the "Server Manager" Tool.
- For best availability and smart replica placement in production systems, Couchbase Server also needs to use Server Groups to align with UPs and FDs (upgrade and fault domain).


##References
- Couchbase Server 4.1 [Installation Guide](http://developer.couchbase.com/documentation/server/4.1/install/installation-guide-intro.html). 
- Couchbase Server 4.1 [Concepts and Architecture](http://developer.couchbase.com/documentation/server/4.1/concepts/concepts-architecture-intro.html)
- Couchbase Server 4.1 [Administraion Guide](http://developer.couchbase.com/documentation/server/4.1/admin/admin-intro.html)
- Couchbase Server 4.1 [Developer Guide](http://developer.couchbase.com/documentation/server/4.1/developer-guide/intro.html)
- Couchbase Server 4.1 [SDKs](http://developer.couchbase.com/documentation/server/4.1/sdks/intro.html)
- Couchbase Server [N1QL Reference Guide](http://developer.couchbase.com/documentation/server/4.1/n1ql/index.html) (SQL-like Query Language for JSON)
- [Security Considerations](http://developer.couchbase.com/documentation/server/4.1/install/install-security-bp.html) for Couchbase Server 4.1 Installations
- [Cluster Sizing Guidelines](http://developer.couchbase.com/documentation/server/4.1/install/sizing-general.html) for Couchbase Server 4.1

