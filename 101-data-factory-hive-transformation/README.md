# Create a pipeline to transform data by running Hive script 
This sample creates a data factory with a data pipeline that processes data by running Hive script on an Azure HDInsight (Hadoop) cluster. 

## Prerequisites
1. Complete the prerequisites mentioned in [Overview and prerequisites](https://azure.microsoft.com/documentation/articles/data-factory-build-your-first-pipeline/) article.
2. Update values for the following parameters in **azuredeploy.parameters.json** file.
    - storageAccountResourceGroupName with name of the resource group that contains your Azure storage. 
    - storageAccountName with the name of your Azure Storage account.
    - storageAccountKey with the key of your Azure Storage account.
3. For the sample to work as-it-is, keep the following values:  
    - blobContainer is the name of the blob container. For the sample, it is **adfgetstarted**. 
    - inputBlobFolder is the name of the blob folder with input files. For the sample, it is **inputdata**.
    - inputBlobName is the name of the blob or file. For the sample, it is **input.log**. 
    - outputBlobFolder is the name of the blob folder that will contain the output files. For the sample, it is **partitioneddata**.   
    - hiveScriptFolder is the name of the folder that contains the hive query (HQL) file. For the tutorial, it is **script**.  
    - hiveScriptFile is the name of the hive script file (HQL). For the sample, it is **partitionweblogs.hql**. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-hive-transformation%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-hive-transformation%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

When you deploy this Azure Resource Template, a data factory is created with the following entities: 

- Azure Storage linked service
- Azure HDInsight linked service (on-demand)
- Azure Blob input dataset
- Azure Blob output dataset
- Pipeline with a Hive activity 

In this tutorial, **inputdata** folder of the **adfgetstarted** Azure blob container contains one file named input.log. This log file has entries from three months: January, February, and March of 2016. Here are the sample rows for each month in the input file. 

	2016-01-01,02:01:09,SAMPLEWEBSITE,GET,/blogposts/mvc4/step2.png,X-ARR-LOG-ID=2ec4b8ad-3cf0-4442-93ab-837317ece6a1,80,-,1.54.23.196,Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/31.0.1650.63+Safari/537.36,-,http://weblogs.asp.net/sample/archive/2007/12/09/asp-net-mvc-framework-part-4-handling-form-edit-and-post-scenarios.aspx,\N,200,0,0,53175,871 
	2016-02-01,02:01:10,SAMPLEWEBSITE,GET,/blogposts/mvc4/step7.png,X-ARR-LOG-ID=d7472a26-431a-4a4d-99eb-c7b4fda2cf4c,80,-,1.54.23.196,Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/31.0.1650.63+Safari/537.36,-,http://weblogs.asp.net/sample/archive/2007/12/09/asp-net-mvc-framework-part-4-handling-form-edit-and-post-scenarios.aspx,\N,200,0,0,30184,871
	2016-03-01,02:01:10,SAMPLEWEBSITE,GET,/blogposts/mvc4/step7.png,X-ARR-LOG-ID=d7472a26-431a-4a4d-99eb-c7b4fda2cf4c,80,-,1.54.23.196,Mozilla/5.0+(Windows+NT+6.3;+WOW64)+AppleWebKit/537.36+(KHTML,+like+Gecko)+Chrome/31.0.1650.63+Safari/537.36,-,http://weblogs.asp.net/sample/archive/2007/12/09/asp-net-mvc-framework-part-4-handling-form-edit-and-post-scenarios.aspx,\N,200,0,0,30184,871

When the file is processed by the pipeline with HDInsight Hive Activity, the activity runs a Hive script on the HDInsight cluster that partitions input data by year and month. The script creates three output folders that contain a file with entries from each month.  

	adfgetstarted/partitioneddata/year=2016/month=1/000000_0
	adfgetstarted/partitioneddata/year=2016/month=2/000000_0
	adfgetstarted/partitioneddata/year=2016/month=3/000000_0

From the sample lines shown above, the first one (with 2016-01-01) is written to the 000000_0 file in the month=1 folder. Similarly, the second one is written to the file in the month=2 folder and the third one is written to the file in the month=3 folder.

For more information, see [Overview and prerequisites](https://azure.microsoft.com/documentation/articles/data-factory-build-your-first-pipeline/) article.

See [Tutorial: Create a pipeline using Resource Manager Template](https://azure.microsoft.com/en-us/documentation/articles/data-factory-build-your-first-pipeline-using-arm/) article for a detailed walkthrough with step-by-step instructions. 

## Deploying sample
You can deploy this sample directly through the Azure Portal or by using the scripts supplied in the root of the repository.

To deploy a sample using the Azure Portal, click the **Deploy to Azure** button at the top of the article. 

To deploy the sample via the command line (using [Azure PowerShell or the Azure CLI](https://azure.microsoft.com/en-us/downloads/)) you can use the scripts.

Simply execute the script and pass in the folder name of the sample.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactStagingDirectory 101-data-factory-hive-transformation
```
```bash
azure-group-deploy.sh -a 101-data-factory-hive-transformation -l eastus -u

