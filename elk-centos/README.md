# ELK on CentOS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felk-centos%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felk-centos%2Fazuredeploy.json" target="_blank">
	<img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys an Elasticsearch cluster, Logstash and Kibana. Logstash is installed, and could be configured with a specified plugin installed. You could also pass a base64 encoded string of logstash configuration file to the parameter, to configure and start logstash. 

To ensure there are no conflicts deploy to a new resource group.

After the deployment completes you can view the log data in Kibana. To get the public IP for Kibana, visit the Azure Portal, navigate to the resource group used for the deployment and look for the Public IP address resource named "elasticsearch-kibana-pip". Then point your browser to "http://insert.kibana.ip.here:5601". 

#Notes
- This template uses the Elasticsearch template from: <a href="../elasticsearch">azure-quickstart-templates/elasticsearch/<a/>
