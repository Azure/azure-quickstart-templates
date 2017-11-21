### Autoscale Setting for Cloud Service ###

The following template deploys an Autoscale Setting for Cloud Service role based on a single metric.

The sample autoscale setting targets a specific role within the Cloud Service running in the production deployment slot. If the metric is above the upper threshold, the example autoscale setting will scale out the Cloud Service instance count.  If the metric is below the lower threshold, the example autoscale setting will scale in the Cloud Service instance count.  This sample illustrates how easy it is to automate autoscale setting configuration for Cloud Service via templates.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2fmonitor-autoscale-cloudservice-simplemetricbased%2fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3a%2f%2fraw.githubusercontent.com%2fAzure%2fazure-quickstart-templates%2fmaster%2fmonitor-autoscale-cloudservice-simplemetricbased%2fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
