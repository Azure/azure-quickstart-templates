# Azure Web App Analytics

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.web/webappazure-oms-monitoring/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebappazure-oms-monitoring%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebappazure-oms-monitoring%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebappazure-oms-monitoring%2Fazuredeploy.json)



This template deploys **Azure Web App Analytics Solution** on an Azure Log Analytics workspace. This allows you to view analytic data for metrics across all your Azure Web App resources.

`Tags: Azure Web App, OMS Log Analytics, Monitoring`

The Azure Web Apps Analytics solution provides insights into your [Azure Web Apps](https://docs.microsoft.com/en-us/azure/app-service/app-service-web-overview) by collecting different metrics across all your Azure Web App resources. With the solution, you can analyze and search for web app resource metric data.

Using the solution, you can view the:

- Top Web Apps with the highest response time
- Number of requests across your Web Apps, including successful and failed requests
- Top Web Apps with highest incoming and outgoing traffic
- Top service plans with high CPU and memory utilization
- Azure Web Apps activity log operations

## Configuration

Perform the following steps to configure the Azure Web Apps Analytics solution for your workspaces.

1. Enable the Azure Web Apps Analytics solution from<BR> [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebappazure-oms-monitoring%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.web%2Fwebappazure-oms-monitoring%2Fazuredeploy.json)

<BR>
2. [Enable Azure resource metrics logging to Log Analytics using PowerShell](https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-collect-azurepass-posh).

The Azure Web Apps Analytics solution collects two set of metrics from Azure:

- Azure Web Apps metrics
  - Average Memory Working Set
  - Average Response Time
  - Bytes Received/Sent
  - CPU Time
  - Requests
  - Memory Working Set
  - Httpxxx
- App Service Plan metrics
  - Bytes Received/Sent
  - CPU Percentage
  - Disk Queue Length
  - Http Queue Length
  - Memory Percentage

App Service Plan metrics are only collected if you are using a dedicated service plan. This doesn't apply to free or shared App Service plans.

After you configure the solution, data should start flowing to your workspace within 15 minutes.

## Using the solution

When you add the Azure Web Apps Analytics solution to your workspace, the **Azure Web Apps Analytics** tile is added to your Overview dashboard. This tile displays a count of the number of Azure Web Apps that the solution has access to in your Azure subscription.

![Azure Web Apps Analytics tile](images/azure-web-apps-analytics-tile.png)

### View Azure Web Apps Analytics information

Click the **Azure Web Apps Analytics** tile to open the **Azure Web Apps Analytics** dashboard. The dashboard includes the blades in the following table. Each blade lists up to ten items matching that blade's criteria for the specified scope and time range. You can run a log search that returns all records by clicking **See all** at the bottom of the blade or by clicking the blade header.

| Column | Description |
| --- | --- |
| Azure Webapps |   |
| Web Apps Request Trends | Shows a line chart of the Web Apps request trend for the date range that you have selected and shows a list of the top ten web requests. Click the line chart to run a log search for <code>AzureMetrics &#124; where ResourceId == "/MICROSOFT.WEB/SITES/" and (MetricName == "Requests" or MetricName startswith_cs "Http") &#124; summarize AggregatedValue = avg(Average) by MetricName, bin(TimeGenerated, 1h)</code> <br>Click a web request item to run a log search for the web request metric trend that request. |
| Web Apps Response Time | Shows a line chart of the Web Apps response time for the date range that you have selected. Also shows a list a list of the top ten Web Apps response times. Click the chart to run a log search for <code>AzureMetrics &#124; where ResourceId == "/MICROSOFT.WEB/SITES/" and MetricName == "AverageResponseTime" &#124; summarize AggregatedValue = avg(Average) by Resource, bin(TimeGenerated, 1h)</code><br> Click on a Web App to run a log search returning response times for the Web App. |
| Web Apps Traffic | Shows a line chart for Web Apps traffic, in MB and lists the top Web Apps traffic. Click the chart to run a log search for <code>AzureMetrics &#124; where ResourceId == "/MICROSOFT.WEB/SITES/" and (MetricName == "BytesSent" or MetricName == "BytesReceived") &#124; summarize AggregatedValue = sum(Average) by Resource, bin(TimeGenerated, 1h)</code><br> It shows all Web Apps with traffic for the last minute. Click a Web App to run a log search showing bytes received and sent for the Web App. |
| Azure App Service Plans |   |
| App Service Plans with CPU utilization &gt; 80% | Shows the total number of App Service Plans that have CPU utilization greater than 80% and lists the top 10 App Service Plans by CPU utilization. Click the total area to run a log search for <code>AzureMetrics &#124; where ResourceId == "/MICROSOFT.WEB/SERVERFARMS/" and MetricName == "CpuPercentage" &#124; summarize AggregatedValue = avg(Average) by Resource</code><br> It shows a list of your App Service Plans and their average CPU utilization. Click an App Service Plan to run a log search showing its average CPU utilization. |
| App Service Plans with memory utilization &gt; 80% | Shows the total number of App Service Plans that have memory utilization greater than 80% and lists the top 10 App Service Plans by memory utilization. Click the total area to run a log search for <code>AzureMetrics &#124; where ResourceId == "/MICROSOFT.WEB/SERVERFARMS/" and MetricName == "MemoryPercentage" &#124; summarize AggregatedValue = avg(Average) by Resource</code><br> It shows a list of your App Service Plans and their average memory utilization. Click an App Service Plan to run a log search showing its average memory utilization. |
| Azure Web Apps Activity Logs |   |
| Azure Web Apps Activity Audit | Shows the total number of Web Apps with [activity logs](log-analytics-activity.md) and lists the top 10 activity log operations. Click the total area to run a log search for <code>AzureActivity #124; where ResourceProvider == "Azure Web Sites" #124; summarize AggregatedValue = count() by OperationName</code><br> It shows a list of the activity log operations. Click an activity log operation to run a log search that lists the records for the operation. |

### Azure Web Apps

In the dashboard, you can drill down to get more insight into your Web Apps metrics. This first set of blades show the trend of the Web Apps requests, number of errors (for example, HTTP404), traffic, and average response time over time. It also shows a breakdown of those metrics for different Web Apps.

![Azure Webapps  blades](images/web-apps-dash01.png)

A primary reason for showing you that data is so that you can identify a Web App with high response time and investigate to find the root cause. A threshold limit is also applied to help you more easily identify the ones with issues.

- Web Apps shown in red have response time higher than 1 second.
- Web Apps shown in orange have a response time higher than 0.7 second and less than 1 second.
- Web Apps shown in green have a response time less than 0.7 second.

In the following log search example image, you can see that the *anugup3* web app had a much higher response time than the other web apps.

![log search example](images/web-app-search-example.png)

### App Service Plans

If you are using dedicated Service Plans, you can also collect metrics for your App Service Plans. In this view, you see your App Service Plans with high CPU or Memory utilization (&gt; 80%). It also shows you the top App services with high Memory or CPU utilization. Similarly, a threshold limit is applied to help you more easily identify the ones with issues.

- App Service Plans shown in red have a CPU/Memory utilization higher than 80%.
- App Service Plans shown in orange have a CPU/Memory utilization higher than 60% and lower than 80%.
- App Service Plans shown in green have a CPU/Memory utilization lower than 60%.

![Azure App Service Plans blades](images/web-apps-dash02.png)

## Azure Web Apps log searches

The **List of Popular Azure Web Apps Search queries** shows you all the related activity logs for Web Apps, which provides insights into the operations that were performed on your Web Apps resources. It also lists all the related operations and the number of times they have occurred.

Using any of the log search queries as a starting point, you can easily create an alert. For example, you might want to create an alert when a metric's average response time is greater than every 1 second.



