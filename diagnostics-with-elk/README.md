# Analyze Diagnostics Data with ELK

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/diagnostics-with-elk/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdiagnostics-with-elk%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdiagnostics-with-elk%2Fazuredeploy.json" target="_blank">
	<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an Elasticsearch cluster, Logstash and Kibana.
You can specify a custom Logstash configuration using the encodedConfigString parameter.
To create a custom Logstash configuration visit http://codepen.io/skkandia/pen/mPjOdR.
If you don't want to enter a custom Logstash configuration and would like to use the <a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadtable">logstash-input-azurewadtable</a> plugin to
input diagnostics data from Azure Table storage, then set the encodedConfigString parameter to 'na' and provide values for the
existingDiagnosticsStorageAccountName, existingDiagnosticsStorageAccountKey and existingDiagnosticsStorageTableNames parameters.

To ensure there are no conflicts deploy to a new resource group.

After the deployment completes you can view the diagnostics data in Kibana. To get the public IP for Kibana, visit the Azure Portal, navigate to the resource group used for the deployment and look for the Public IP address resource named "elasticsearch-kibana-pip". Then point your browser to "http://insert.kibana.ip.here:5601". Under Kibana configure an index pattern with name "wad".

#Notes
- This template uses the Elasticsearch template from: <a href="../elasticsearch">azure-quickstart-templates/elasticsearch/<a/>
- It installs the Logstash input plugin for WAD table from: <a href="https://github.com/Azure/azure-diagnostics-tools/tree/master/Logstash/logstash-input-azurewadtable">logstash-input-azurewadtable</a>


