# Analyze Diagnostics Data with Event Hub and ELK

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-eventhub-elk/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdiagnostics-eventhub-elk%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdiagnostics-eventhub-elk%2Fazuredeploy.json)

	

This template deploys an Elasticsearch cluster, Logstash and Kibana. Logstash is configured using an Event Hub input plugin,
<a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadeventhub">logstash-input-azurewadeventhub, to pull diagnostics data.

To ensure there are no conflicts deploy to a new resource group.

After the deployment completes you can view the diagnostics data in Kibana. To get the public IP for Kibana, visit the Azure Portal, navigate to the resource group used for the deployment and look for the Public IP address resource named "elasticsearch-kibana-pip". Then point your browser to "http://insert.kibana.ip.here:5601". Under Kibana configure an index pattern with name "wad".

#Notes
- This template uses the Elasticsearch template from: <a href="../elasticsearch">azure-quickstart-templates/elasticsearch/<a/>
- It installs the Logstash input plugin for Event Hub from: <a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadeventhub">logstash-input-azurewadeventhub


