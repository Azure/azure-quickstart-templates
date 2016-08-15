# Install a Couchbase cluster on Ubuntu Virtual Machines using Custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcouchbase-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>



This template deploys a Couchbase Server 4.5 cluster on the Ubuntu 12 virtual machines. The template provisions clusters with a storage account, virtual network, availability sets, public IP addresses and network interfaces required for high performance Couchbase Server cluster installation.

Couchbase Server Cluster Topology and Settings
----------------------------------------------
Cluster Sizes: Template allows configurable number of Couchbase Server 4.5 cluster nodes and node sizes. Cluster sizes comes in 3 options;
- Small Cluster = 3 Nodes of Standard_A2
- Medium Cluster  = 4 Nodes of Standard_A6
- Large Cluster = 5 Nodes of Standard_D14

Simple Deployment Topology: This template deploys Couchbase Server 4.5 Data Service (key based core data operations), Index Service (global secondary index) and Query Service (N1QL Query Engine) on every node. Changing you topology can be done online if you prefer a different deployment topology with services. You can find recommendations on other deployment configurations in Couchbase Server documentation [here](http://developer.couchbase.com/documentation/server/4.5/clustersetup/services-mds.html).

Settings: The index and data service grabs 50% of the recommended RAM. However if you can adjust the RAM allocation in favor of Data service or Index service. You can find more detailed sizing guidelines in the Couchbase Server documentation [here](http://developer.couchbase.com/documentation/server/4.5/install/sizing-general.html). 

Storage: Each node is configured to store data and indexes under the mounted /datadisks folder (non-ephemeral drive) using a RAID0 configuration for high performance storage. 

Jumpbox for Secure Access to Cluster
------------------------------------
The cluster nodes can be deployed with a jumpbox. The jumpbox ensures the cluster nodes are not directly accessible form the public internet. ARM Template provides two Jumpbox Options: 
- Ubuntu Linux VM accessible through SSH: Simply ssh into port 22 of the public IP address of the jumpbox. PublicIPUbuntu object under the resource group provides the public IP address to use. Once you are on the jumpbox, you can run one of the sample applications from developer.couchbase.com or jump to any one fo the cluster nodes (10.0.0.X) with ssh and run "/opt/couchbase/bin/couchbase-cli server-list -c nodePrivateIP -u $AdminUsername -p $AdminPassword" to see cluster node status. 
- Windows Server VM through RDP: RDP into the public IP address of the Windows Jumpbox (jumpbox-windows). PublicIPWin object under the resource group provides the public IP address to use. Once you are on the jumpbox, visit http://10.0.0.X:8091 private IPs of nodes to see Couchbase Server web console.

If you choose to disable the jumpbox, the template provisions public IP address for each node. Simply look up the public IP address of any one of the nodes and go to http://publicIP:8091 and log in using the  username and password you specified during the initial setup. It is important to note that exposing the Couchbase Server nodes directly to the public internet is not recommended. 

Getting Started with Couchbase Server and Samples
-------------------------------------------------
You can get started with a sample app or run a SQL Query on a sample database with Couchbase Server installation. 
- Running you first SQL Query: Simply enable the travel sample bucket (database) 
    - Visit 10.0.0.10:8091 or any privateIP of the nodes provisioned.
    - Under Web Console, enable the sample bucket (Settings Tab > Sample Buckets) bu checking beer-sample
    - Under the Web Console, go to Query Tab and run 
    
    ```SELECT * FROM `beer-sample` WHERE type="beer" LIMIT 10;``` 
    
You can find more detailed instructions on running N1QL queries [here](http://developer.couchbase.com/documentation/server/4.5/getting-started/first-n1ql-query.html#first-n1ql). OR Find the full [Getting Started](http://www.couchbase.com/get-started-developing-nosql) guide and skip **Step-1** since you will have Couchbase Server already deployed.

##Known Issues and Limitations
- The deployment scripts are not idempotent and this template should only be used for provisioning a new cluster at the moment.
- http://10.0.0.10:8091 needs to be added to IE "Trusted Sites" list to open the admin tool on the Windows VM deployed in test configuration - You can turn off EI Enhanced Security through the "Server Manager" Tool.
- For best availability and smart replica placement in production systems, Couchbase Server also needs to use Server Groups to align with UPs and FDs (upgrade and fault domain).


##References
- Couchbase Server 4.5 [Getting Started](http://developer.couchbase.com/documentation/server/4.5/getting-started/index.html)
- Couchbase Server 4.5 [Installation Guide](http://developer.couchbase.com/documentation/server/4.5/install/installation-guide-intro.html). 
- Couchbase Server 4.5 [Concepts and Architecture](http://developer.couchbase.com/documentation/server/4.5/concepts/concepts-intro.html)
- Couchbase Server 4.5 [Administraion Guide](http://developer.couchbase.com/documentation/server/4.5/admin/admin-intro.html)
- Couchbase Server 4.5 [Developer Guide](http://developer.couchbase.com/documentation/server/4.5/developer-guide/intro.html)
- Couchbase Server 4.5 [SDKs](http://developer.couchbase.com/documentation/server/4.5/sdks/intro.html)
- Couchbase Server [N1QL, SQL for JSON, Reference Guide](http://developer.couchbase.com/documentation/server/4.5/n1ql/n1ql-language-reference/index.html)
- [Security Considerations](http://developer.couchbase.com/documentation/server/4.5/install/install-security-bp.html) for Couchbase Server 4.5 Installations
- [Cluster Sizing Guidelines](http://developer.couchbase.com/documentation/server/4.5/install/sizing-general.html) for Couchbase Server 4.5

