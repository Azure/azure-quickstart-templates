# Autoscale Setting for App Service Plan

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/monitor-autoscale-webappserviceplan-simplemetricbased/CredScanResult.svg" />&nbsp;

The following template deploys an App Service Plan + Autoscale Setting for App Service plan based on a single metric.

If the metric is above the upper threshold, the example autoscale setting will scale out the instance count.  If the metric is below the lower threshold, the example autoscale setting will scale in the instance count.  This sample illustrates how easy it is to automate autoscale setting configuration for App Service plan via templates.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2fmonitor-autoscale-webappserviceplan-simplemetricbased%2fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2fmonitor-autoscale-webappserviceplan-simplemetricbased%2fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

