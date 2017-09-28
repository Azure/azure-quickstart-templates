# Copy data from one folder to another folder in an Azure Blob Storage
This template creates a data factory of version 2 with a pipeline that copies data from one folder to another in an Azure Blob Storage. 

Here are a few important points about the template: 

- The prerequisites for this template are mentioned in the [Quickstart: Create a data factory by using Azure PowerShell](https://docs.microsoft.com/azure/data-factory/quickstart-create-data-factory-powershell#prerequisites) article.
- Note that currently data factories of version 2 can only be created in **East US** and **East US 2** regions. 


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-blob-to-blob-copy%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-data-factory-v2-blob-to-blob-copy" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

When you deploy this Azure Resource Manager template, a data factory of version 2 is created with the following entities: 

- Azure Storage linked service
- Azure Blob datasets (input and output)
- Pipeline with a copy activity

## To get the name of the data factory
1. Click the **Deployment succeeded** message.
2. Click **Go to resource group**.
3. Search for **ADFTutorialResourceGroup0927&lt;unique string&gt;**

The following sections provide steps for running and monitoring the pipeline. For more information, see [Quickstart: Create a data factory by using Azure PowerShell](https://docs.microsoft.com/azure/data-factory/quickstart-create-data-factory-powershell).

## Run the pipeline
The copy activity in the pipeline copies data from one folder to another folder in the same Azure Blob Storage. After you deploy the template, to run the pipeline and see the data being copied from source to destination, run the following PowerShell command (specify your data factory name and resource group name):

```powershell
$runId = Invoke-AzureRmDataFactoryV2Pipeline -DataFactoryName <your data factory name> -ResourceGroupName <resource group name> -PipelineName "ArmtemplateSampleCopyPipeline" 
```

## Monitor the pipeline,

1. Run the following script to continuously check the pipeline run status until it finishes copying the data. Replace `<Resource group name>` with the name of your resource group. Replace `<Data factory name>` with the name of your data factory.  

    ```powershell
    while ($True) {
        $run = Get-AzureRmDataFactoryV2PipelineRun -ResourceGroupName <Resource group name> -DataFactoryName <Data factory name> -PipelineRunId $runId

        if ($run) {
            if ($run.Status -ne 'InProgress') {
                Write-Host "Pipeline run finished. The status is: " $run.Status -foregroundcolor "Yellow"
                $run
                break
            }
            Write-Host  "Pipeline is running...status: InProgress" -foregroundcolor "Yellow"
        }

        Start-Sleep -Seconds 30
    }
    ```
2. Run the following script to retrieve copy activity run details, for example, size of the data read/written. Replace `<Data factory name>` with the name of your data factory. Replace `<Resource group name>` with the name of your resource group. 

    ```powershell
    Write-Host "Activity run details:" -foregroundcolor "Yellow"
    $result = Get-AzureRmDataFactoryV2ActivityRun -DataFactoryName <Data factory name> -ResourceGroupName <Resource group name> -PipelineRunId $runId -RunStartedAfter (Get-Date).AddMinutes(-30) -RunStartedBefore (Get-Date).AddMinutes(30)
    $result
    
    Write-Host "Activity 'Output' section:" -foregroundcolor "Yellow"
    $result.Output -join "`r`n"
    
    Write-Host "\nActivity 'Error' section:" -foregroundcolor "Yellow"
    $result.Error -join "`r`n"
    ```
3. Confirm that the file is copied to the destination folder.  

 
