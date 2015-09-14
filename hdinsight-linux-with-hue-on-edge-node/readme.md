# Create HDInsight Linux Cluster with Edge Node and Hue installed on that Edge Node

Create HDInsight Linux Cluster with Edge Node and Hue app installed on Edge Node -<br>
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fezubatov%2Fazure-quickstart-templates%2Fmaster%2Fhdinsight-linux-with-hue-on-edge-node%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Template creates an HDInsight Linux cluster in a virtual network with another vm as an edge node that is bootstrapped with the clusters configurations.

The edge node has the following cluster configurations located locally on the node.<br />
-Hadoop Configs including core-site.xml, hdfs-site.xml, mapred-site.xml, and yarn-site.xml located at /etc/hadoop/conf <br />
-hive-site.xml located at /etc/hive/conf

Additionally, the edge node has WebWasb, a WebHDFS implementation over the WASB Storage System. <br />
WebWasb allows you to access and execute commands against the default WASB container of the cluster using the WebHDFS interface.<br />

WebWasb can be accessed using localhost as the hostname and 50073 as the port name.
As an example, if you wanted to list all files and directories at the root of the cluster's storage account, you could execute <pre>curl http://localhost:50073/WebWasb/webhdfs/v1/?op=LISTSTATUS</pre>

Most important part of this template is that:
Hue application is being installed on the edge node VM. It listens on port 8888.
To be able to access the Hue app from outside of the vnet we recommend to use SSH tunneling to redirect traffic from client to edge node.
SSH tunneling can be established with using Putty client application.
Edge node DNS name has following schema:
<your cluster name>-huevm.<region>.cloudapp.azure.com
Where <your cluster name> is the name of the cluster provisioned using this template.
<region> is a region used during deployment (example: westus)
