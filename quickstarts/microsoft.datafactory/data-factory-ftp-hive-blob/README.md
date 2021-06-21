# Create a pipeline to transform data by running Hive script

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.datafactory/data-factory-ftp-hive-blob/CredScanResult.svg)
This sample creates a data factory with a data pipeline with three activities in it.

Pipeline: Copy Activity -> HDInsight Activity -> Copy Activity

1. The first **Copy Activity** copies the input file from an FTP server to an Azure blob.
2. The **HDInsight Activity** processes the data from input file by running a Hive script on an Azure HDInsight cluster to produce an output file in Azure Blob Storage. The script combines first names and last names from the input file and create an output file with full names.
3. The second **Copy Activity** copies the output from Hive processing to a table in an Azure SQL database.

## Prerequisites

1. An Azure subscription.
1. [Create an Azure Storage account](https://docs.microsoft.com/azure/storage/storage-create-storage-account#create-a-storage-account).
1. Upload the **combinefirstandlast.hql** file to a folder named **Script** in the Azure blob storage in a container named **adftutorial**.
1. [Create an Azure SQL database](https://docs.microsoft.com/azure/sql-database/sql-database-get-started).
1. Use the **createemployeestable.sql** from the script folder to create a table named **Employees** in your Azure SQL database.
1. [Create an Azure Virtual Machine](https://docs.microsoft.com/azure/virtual-machines/virtual-machines-windows-hero-tutorial) and configure it to be an FTP server. See [this article](http://itq.nl/walkthrough-hosting-ftp-on-iis-7-5-a-windows-azure-vm-2/) for details. You can use your FTP server instead.
1. Upload **input.txt** file from the script folder to a folder named **incomingfiles** on the FTP server.
1. Add parameters to the azuredeploy.parameters.json** file and specify values for them.  
      	
			"ftpHost": {
	      		"value": "<your FTP server name or IP address>"
    		},
	    	"ftpUser": {
	      		"value": "<FTP user name>"
    		},
	    	"ftpPassword": {
	      		"value": "<FTP password>"
	    	},
	    	"ftpFolderName": {
	      		"value": "incomingfiles"
	    	},
	    	"ftpFileName": {
	      		"value": "input.txt"
    		},    
	    	"storageAccountResourceGroupName": {
	      		"value": "<Resource group of your Azure Storae account>"
	    	},
	    	"storageAccountName": {
	      		"<Azure Storage account name>": ""
	    	},
	    	"storageAccountKey": {
	      		"value": "<Azure Storage access key>"
	    	},
	    	"blobContainer": {
	      		"value": "adftutorial"
	    	},
	    	"inputBlobFolder": {
	      		"value": "inputdata"
	    	},
	    	"inputBlobName": {
	    	  	"value": "input.txt"
		    },
	    	"outputBlobFolder": {
	      		"value": "outputdata"
	    	},
	    	"hiveScriptFolder": {
	      		"value": "script"
	    	},
	    	"hiveScriptFile": {
	      		"value": "combinefirstandlast.hql"
	    	},
    		"sqlServerName": {
	      		"value": "<Name of Azure SQL server>"
	    	},
	    	"sqlDatabaseName": {
	      		"value": "<Name of Azure SQL database>"
	    	},
	    	"sqlServerUserName": {
	      		"value": "<Name of user who has access to the SQL server>"
	    	},
	    	"sqlServerPassword": {
	      		"value": "<Password for Azuer SQL user>"
	    	},
	    	"targetSQLTable": {
	      		"value": "Employees"
	    	}
	  
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-ftp-hive-blob%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-ftp-hive-blob%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.datafactory%2Fdata-factory-ftp-hive-blob%2Fazuredeploy.json)

When you deploy this Azure Resource Template, a data factory is created with the following entities:

- Linked services
  - FTP
  - Azure Storage
  - Azure HDInsight
  - Azure SQL Database
- Datasets
  - FTP (FileShare)
  - Azure Blob (2 of them)
  - Azure SQL
- Pipeline with three activities: Copy, HDInsight Hive, and another Copy.  

In this tutorial, the input file in FTP server has the following data:  

	Doe, John
	Doe, Jane
	Gates, Bill
	Allen, Paul

This file is copied from the FTP server to inputdata folder in Azure Blob container. The HDInsight Hive activity processes this file and create an output file like this:

	John Doe
	Jane Doe
	Bill Gates
	Paul Allen

The second Copy Activity copies this data to Employees table in the Azure SQL database.

	FullName
	--------
	 John Doe
	 Jane Doe
	 Bill Gates
	 Paul Allen

For more information, see [Overview and prerequisites](https://azure.microsoft.com/documentation/articles/data-factory-build-your-first-pipeline/) article.

See [Tutorial: Create a pipeline using Resource Manager Template](https://azure.microsoft.com/documentation/articles/data-factory-build-your-first-pipeline-using-arm/) article for a detailed walkthrough with step-by-step instructions.
