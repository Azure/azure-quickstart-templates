# Install Elasticsearch cluster on Virtual Machines

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Felasticsearch%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys an Elasticsearch cluster on Virtual Machines and uses template linking. The template provisions 3 dedicated master and client nodes in separate availability sets and storage accounts. A load balancer is configured with a rule to route traffic on port 9200 to the client nodes, and also includes a single SSH management rule mapped to one of the client nodes.  Multiple data disks are attached (the number depends on the size of the virtual machine selected) and data is striped across them as an approach to improve disk throughput.

This template also deploys a Storage Account, Virtual Network, Availability Sets, Public IP addresses, Load Balancer, and a Network Interface.

##Notes
Warning!  The configuration allows you to enabled external load balanced endpoints on a public IP.  The endpoint is not secure and it's recommended that you keep these endpoints internal or secure them. Elasticsearch Shield product should be considered.
