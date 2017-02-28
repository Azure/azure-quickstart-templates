# Azure Storage Analytics (Preview)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azure-storage-analytics-solution%2Fazuredeploy.json) 
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azure-storage-analytics-solution%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

>[AZURE.NOTE]This is preliminary documentation for Azure Storage Analytics, a management solution you can deploy into OMS that will provide insights and analytics of your storage accounts. The solution is currently in preview. 

 Microsoft Azure Storage is the cloud storage solution for modern applications that rely on durability, availability, and scalability to meet the needs of their customers. Azure storage provides  Blob storage, Table storage, Queue storage, and File storage services.
Azure Storage Analytics Solution collects and visualizes inventory information, capacity metrics, transaction metrics and storage errors for storage accounts in an Azure subscription. Users can easily create additional rules to monitor storage resources. This solution leverages Azure Automation, the Log Analytics Ingestion API, together with Log Analytics views to present data about all your storage accounts  in a single  workspace. 

![alt text](images/sasolution.png "Overview")

## Pre-reqs

- **Automation Account with SPN**

Before you deploy this template, you must create an Automation Account in the Azure portal with the default settings so that the SPN account will be created. If you have an existing OMS Log Analytics Workspace you would like to use for this solution, it is important that the Automation account is created into the **same Resource Group where the OMS Log Analytics Workspace is located**.

If you **dont** have an existing OMS Log Analytics Workspace, the template will create and deploy this for you.

## Deploying the Azure Storage Analytics Solution

### Follow these instructions to deploy the solution into an existing - or new Log Analytics Workspace

Log into Azure Portal (https://portal.azure.com) and ensure you are in the subscription containing the recovery vault you want to monitor

Locate your existing OMS Log Analytics Workspace and note the name of the workspace, the location of the workspace, and the Resource Group

![alt text](images/omsworkspace.png "omsws") 

Next, create a new Automation Account and click on *New* and search for 'Automation'

![alt text](images/createautomation1.png "automation")
 
Select Automation and click *Create* 

Specify the name of the Automation Account and ensure you are selecting 'Use existing' and selects the Resource Group containing the OMS Log Analytics workspace. If possible, use the same Azure Region for the Automation Account. Ensure that 'Create Azure Run As account' is set to 'Yes' and click 'Create'

![alt text](images/createautomation2.png "create")

Once the deployment has completed, you should see the Automation account and the Log Analytics workspace in the same Resource Group

![alt text](images/omsrgaa.png "Resource Group")

###You can now deploy the template   
[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Foms-azure-storage-analytics-solution%2Fazuredeploy.json) 

This will send you to the Azure Portal with some default values for the template parameters. 
Ensure that the parameters reflects your setup so that you are deploying this into the *existing* Resource Group containing the Log Analytics Workspace and the Automation account.

#### Parameters

* OMS Log Analytics Workspace Name

Specify the name of the workspace you want to deploy this solution to

* OMS Log Analytics Region

Select the Azure Region where your existing workspace is located

* OMS Automation Account Name

Specify the name of the automation account you created earlier

* OMS Automation Region

Select the Azure Region where your automation account is located


You should also change the values for the *Ingest Scheduler Guid* and *Ingest Cleanup Guid*. You can generate your own using PowerShell with the following cmdlet:


![alt text](images/knguid.png "guid")

Once you have customized all the parameters, click *Create*

![alt text](images/template.png "template")

The ingestion will start 5-10 minutes post deployment.

## Exploring the views

Once the template has successfully been deployed,  storage account inventory data ingestion should occur within 15 minutes post deployment. Metrics data requires  storage analytics minute metrics , which will be automatically  enabled  after solution is deployed. As a result, initial metrics collection might take up to 60 mins to ingest into the workspace.  If you are deploying the solution to a new workspace, it can take approximately 30 minutes before the indexing has completed for the workspace in general. 

In the Resource Group where you deployed the template, you should see the solution resource.

* AzureStorageAnalytics[workspaceName]

![alt text](images/deploymentrg.png "Solutions")

### Azure Storage Analytics 

The views for Azure Storage Analytics  will give you an overview of all the storage accounts  within your Azure Subscription. 

![alt text](images/inv1.png "Azure Storage Inventory view")

 Solution collects and visualizes ;

**Inventory Data**
	
*Storage accounts
* File Shares
* Queues
* Tables 
* VHD files 
* Managed disks for virtual machines. 

**Capacity Metrics**
* UtilizedGB
* Container Count
* Object Count

**Transaction Metrics** 
* Availability
* Total Requests , 
* Ingress KB
* Egress KB
* PercentSuccess
* PercentErrors 
* AverageE2E Latency
* Average Server Latency

**File Shares** 
*Quota 
*Usage 

**Subscription Level Storage Quota Usage**
* ARM based quota usage
* Classic quota usage 


![alt text](images/metrics.png "Azure Storage Metrics view")

Solution also includes 14 preconfigured alerts  which can be used to notify for when certain thresholds are reached.  You can view the alerts and modify thresholds  from Alerts under workspace settings.


### Troubleshooting 

Solution relies on Automation Account with Runas Accounts  configured. Both SPN and Classic Certificate is used by the Storage REST API calls.  

![alt text](images/runasaccounts.png "Azure Automation Runas Accounts")

General Troubleshooting steps ;
* Check if automation account can start  the runbooks
* Check if Runas Accounts configured properly and has permission to query subscription details and can access storage keys  
* Check if AzureStorageIngestion.......  Automation Schedules are enabled

When solution is deployed  first MinuteMetrics will be enabled on all storage accounts. Transaction and capacity metrics will be logged after these metrics are first enabled. Based on the number of the storage accounts these runbook job can take  long time to finish. If you want to speed up the process you can enable metrics by running the following cdmlet;

Set-AzureStorageServiceMetricsProperty -MetricsType Minute -ServiceType (Blob,Table,Queue,File)  -MetricsLevel ServiceAndApi -RetentionDays 1 -Context (storageaccountcontext)

Sample script to get all strorage accounts and enable metrics can be found under /Scripts/EnableMetrics.ps1