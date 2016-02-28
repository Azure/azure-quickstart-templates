# Spark & Cassandra on CentOS 7.x

This project configures a Spark cluster (1 master and n-slave nodes) and a single node Cassandra on Azure using CentOS 7.x.  The base image starts with CentOS 7.1 and it is updated to the latest version as part of the provisioning steps.

Please note that [Azure Resource Manager][3] is used to provision the environment.

### Software ###

| Category | Software | Version | Notes |
| --- | --- | --- | --- |
| Operating System | CentOS | 7.x | Based on CentOS 7.1 but it will be auto upgraded to the lastest point release |
| Java | OpenJDK | 1.8.0 | Installed on all servers |
| Spark | Spark | 1.6.0 with Hadoop 2.6 | The installation contains libraries needed for Hadoop 2.6 |
| Cassandra | Cassandra | 3.2 | Installed through DataStax's YUM repository |


### Defaults ###

| Component | Setting | Default | Notes |
| --- | --- | --- | --- | --- |
| Spark - Master | VM Size | Standard D1 V2 | |
| Spark - Master | Storage | Standard LRS | |
| Spark - Master | Internal IP | 10.0.0.5 | |
| Spark - Master | Service User Account | spark | Password-less access |
| | | |
| Spark - Slave | VM Size | Standard D3 V2 | |
| Spark - Slave | Storage | Standard LRS | |
| Spark - Slave | Internal IP Range | 10.0.1.5 - 10.0.1.255 | |
| Spark - Slave | # of Nodes | 2 | Maximum of 200 |
| Spark - Slave | Availability | 2 fault domains, 5 update domains | |
| Spark - Slave | Service User Account | spark | Password-less access |
| | | |
| Cassandra | VM Size | Standard D3 V2 | |
| Cassandra | Storage | Standard LRS | |
| Cassandra | Internal IP | 10.2.0.5 | |
| Cassandra | Service User Account | cassandra | Password-less access |

### Prerequisites

1.  Ensure you have an Azure subscription.  If you don't, you can [sign up here][1].
2a.  (For PowerShell) - Ensure you have Azure PowerShell Module installed.  If you don't, you can [download it][2] from here.
2b.  (For XPLAT-CLI) - Ensure you have Azure CLI installed.  If you don't, you can [download it][6] from here.
3.  Ensure you have enough available vCPU cores on your subscription.  Otherwise, you will receive an error during the process.  The number of cores can be increased through a support ticket in Azure Portal.

### Getting Started (For PowerShell)

#### Pre-Deployment

1.  Create a Resource Group and Storage Account.  This is required to stage provisioning scripts that are used to install software and tools on the servers.  In this example, the **Resource Group** is "deployments" and **StorageAccountName** is "arm-resources"
2.  Checkout the Git repository.  This folder will be known in the rest of the instructions as **CHECKOUT_DIRECTORY
3.  Upload the scripts in CustomScripts to the Storage Account
4.  [Ensure you can execute PowerShell scripts through PowerShell ISE][4].

#### Deployment

1.  Launch PowerShell ISE
2.  Execute: `Login-AzureRmAccount`
3.  Navigate to `CHECKOUT_DIRECTORY/Scripts`
4.  Execute the following commands on PowerShell ISE and fill in any prompts.  Defaults are automatically set in azuredeploy.parameters.json and can be updated as required.  To leverage Azure Storage, edit the default values for **artifactsLocation** and **artifactsLocationSasToken**.

> You can set change the **-ResourceGroupName** and **-ResourceGroupLocation** to suit your deployment needs.  In this example, it is set to "spark-on-centos" and "East US"

> Enter the values for **-StorageAccountName** and **-StorageAccountResourceGroupName** based on the storage account that was created as part of the pre-deployment steps.

```powershell
$ResourceGroupName = "spark"
$Location = "East US"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location

New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
    -TemplateFile spark-and-cassandra-on-centos/azuredeploy.json `
    -TemplateParameterFile spark-and-cassandra-on-centos/azuredeploy.parameters.json
    -Mode Incremental
```

#### Post-Deployment

1. All servers will have a public IP and SSH port enabled by default.  These can be disabled or modified using Azure Portal.  Have a look at [Network Security Groups for more information][5].
2. All servers are configured with the same username and password (as entered on the prompts).  SSH into each server and ensure connectivity.
3. Spark WebUI is running on port 8080.  Access it using MASTER_WEB_UI_PUBLIC_IP:8080 on your browser.  Public IP is available through Azure Portal.
4. Delete the Resource Group that was created to stage the provisioning scripts.



### Getting Started (For XPLAT-CLI)

#### Pre-Deployment

1.  Checkout the Git repository.  This folder will be known in the rest of the instructions as **CHECKOUT_DIRECTORY
2.  Copy the scripts located in CustomScripts folder to a publically accessible location or in Azure Storage.  Once uploaded, update **artifactsLocation** and **artifactsLocationSasToken** in azuredeploy.json accordingly.


#### Deployment

1.  Launch Command Line
2.  Navigate to CHECKOUT_DIRECTORY
3.  Execute: `azure login`
4.  Execute: `azure config mode arm`
5.  Execute: `azure group create <your_resource_name> "East US"`
6.  Execute: `azure group template validate --resource-group <your_resource_name> --template-file spark-and-cassandra-on-centos/azuredeploy.json --parameters-file spark-and-cassandra-on-centos/azuredeploy.parameters.json`
7.  Execute: `azure group deployment create --resource-group <your_resource_name> --template-file spark-and-cassandra-on-centos/azuredeploy.json --parameters-file spark-and-cassandra-on-centos/azuredeploy.parameters.json`

#### Post-Deployment

1. All servers will have a public IP and SSH port enabled by default.  These can be disabled or modified using Azure Portal.  Have a look at [Network Security Groups for more information][5].
2. All servers are configured with the same username and password (as entered on the prompts).  SSH into each server and ensure connectivity.
3. Spark WebUI is running on port 8080.  Access it using MASTER_WEB_UI_PUBLIC_IP:8080 on your browser.  Public IP is available through Azure Portal.


[1]: https://azure.microsoft.com/en-us/pricing/free-trial/
[2]: https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/
[3]: https://azure.microsoft.com/en-us/documentation/articles/powershell-azure-resource-manager/
[4]: http://stackoverflow.com/questions/9271681/how-to-run-powershell-script-even-if-set-executionpolicy-is-banned
[5]: https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/
[6]: https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/