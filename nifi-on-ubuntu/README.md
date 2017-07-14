# Apache NiFi



<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnifi-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnifi-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

### Summary
Apache NiFi is a visual flow-based environment designed for streaming data pipelines, enterprise application integration and more scenarios for data integration. Apache NiFi's visual management interface provides a friendly and rapid way to develop, monitor, and troubleshoot data flows.

Apache NiFi's data provenance tools allow detailed inspection and verification of all touchpoints with data flowing through the system for compliance, debugging, and performance analysis.

This template deploys Apache NiFi 1.1.2 on an Azure Ubuntu 16.04 VM. The main purpose is for evaluation and dev of Apache NiFi. It is a plain installation with no security or HA configurations. You should modify Source Address Prefix Variable to restrict inbound traffic. 

### Packaging
* Java Open JDK 8
* Apache NiFi 1.1.2

### Post deployment tasks
After the deployment has finished you can access NiFi via http://yourdnsname:8080/nifi/ 

Default port 8080 is used for this installation.

### Resources
* [Apache NiFi Homepage](https://nifi.apache.org/)
* [Apache NiFi Documentation](https://nifi.apache.org/docs.html)

Apache NiFi is licensed under the Apache License, Version 2.0.
