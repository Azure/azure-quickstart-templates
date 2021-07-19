# Analyze Diagnostics Data with ELK

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/elk/diagnostics-with-elk/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdiagnostics-with-elk%2Fazuredeploy.json)  
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Felk%2Fdiagnostics-with-elk%2Fazuredeploy.json)

	

This template deploys an Elasticsearch cluster, Logstash and Kibana.
You can specify a custom Logstash configuration using the encodedConfigString parameter.
To create a custom Logstash configuration visit http://codepen.io/skkandia/pen/mPjOdR.
If you don't want to enter a custom Logstash configuration and would like to use the <a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadtable">logstash-input-azurewadtable plugin to
input diagnostics data from Azure Table storage, then set the encodedConfigString parameter to 'na' and provide values for the
existingDiagnosticsStorageAccountName, existingDiagnosticsStorageAccountKey and existingDiagnosticsStorageTableNames parameters.

To ensure there are no conflicts deploy to a new resource group.

After the deployment completes you can view the diagnostics data in Kibana. To get the public IP for Kibana, visit the Azure Portal, navigate to the resource group used for the deployment and look for the Public IP address resource named "elasticsearch-kibana-pip". Then point your browser to "http://insert.kibana.ip.here:5601". Under Kibana configure an index pattern with name "wad".

#Notes
- This template uses the Elasticsearch template from: <a href="../elasticsearch">azure-quickstart-templates/elasticsearch/<a/>
- It installs the Logstash input plugin for WAD table from: <a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadtable">logstash-input-azurewadtable



