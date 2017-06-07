# Azure Logic Apps - B2B Disaster Recovery replication

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-x12-disaster-recovery-replication%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-logic-app-x12-disaster-recovery-replication%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template demonstrates B2B Disaster Recovery replication using Logic Apps. Creates replication Logic Apps for AS2 MIC, generated and received X12 control numbers. Each Logic App's trigger points to a primary site integration account. Each Logic App's action points to a secondary site integration account. Primary and secondary sites must have prerequisite Integration Accounts deployed (Integration Accounts are not deployed as part of this template). Furthermore to see the replication happen the primary site must have Logic Apps deployed with X12 Encode and/or Decode action(s) and AS2 Encode action. (Logic Apps for X12/AS2 Encode and Decode are not deployed as part of this template).
It is recommended that the primary site and secondary site are deployed in different regions and different resource group. The replication Logic Apps should be deployed to the secondary site, region and resource group. Hence this template parameters include the resource group of the primary integration account and assume that the secondary integration account is in the same resource group as where the template is deployed.
`Tags: AS2, X12, Logic Apps, Integration Account, Enterprise Integration`

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.
You need to provide the Integration Account IDs for the prerequisite primary and secondary sites. The Integration Account ID format is /subscriptions/{subsriptionId}/resourceGroups/{ResourceGroupName}/providers/Microsoft.Logic/IntegrationAccounts/{IntegrationAccountName}

## Usage

Once the deployment is completed, you can perform below steps to test your Logic Apps:

### X12 DR Logic App ###
- Open the resource group blade in Azure Portal where you deployed all resources.
![Image of Azure resources](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-x12-disaster-recovery-replication/images/azure-resources.png "Azure resources"))
- In order for control numbers to be replicated, X12 encode and/or decode activity must happen on the primary site Logic App which X12 action uses the primary Integration Account. Send a test message to your pre-requisite Logic App. The replication Logic Apps will trigger every 3 minutes by default.
- The Receive Control Number replication Logic App demonstrates the replication scenario of X12 Decode action received control number. Open the Receive Control Number replication Logic App blade to see the trigger and run history. If the test message you sent was less than 3 minutes ago, you may click 'Run Trigger' 'When_a_generated_control_nu...' to generate an immediate run.
![Image of History for Generated Control Number replication Logic App](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-x12-disaster-recovery-replication/images/generated-replication-history.png "History for Generated Control Number replication Logic App"))
- You can look into the run history and input/output for each action for these logic apps.
![Image of Run details for Received Control Number replication Logic App](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-logic-app-x12-disaster-recovery-replication/images/received-run-details.png "Run details for Received Control Number replication Logic App"))
- To perform a disaster recovery:
  - Disable the X12 Encode-Decode Logic Apps on the primary site and the replication Logic Apps for Generated and Received control numbers.
  - Use the Azure PowerShell cmdlet Get-AzureRmIntegrationAccountGeneratedIcn and Set-AzureRmIntegrationAccountGeneratedIcn to increment the Interchange Control Number for each of your sent agreements on the secondary Integration Account. This change may take up to 15 seconds to take effect.
  - Redirect traffic to the X12 Encode-Decode Logic Apps on the secondary site. (These Logic Apps are not deployed as part of this template.)
  - Once your primary site has recovered, you need to deploy a new set of replication Logic Apps with source secondary Integration Account and target primary Integration Account. You need to wait that this new set drains the backlog of control numbers before switching traffic back to the primary site.

### AS2 DR Logic App ###
- Once the deployment is completed, MicReplication Logic App is deployed to perform the MIC content replication from primary Integration Account to the secondary site.
- MIC content is created on AS2 encode when AS2 agreement is configured for MDN. On successful encode, MIC content is created which is replicated to secondary Integration Account by the DR Logic App. To verify the replication, send a test message to the pre-requisite Logic App. View the run history of the MicReplication Logic App and verify whether trigger and action are executed successfully. Default recurring interval for DR Logic Apps is 3 minutes or can be run manually by clicking Run Trigger.
- To perform a disaster recovery:
  - Disable the Logic Apps performing AS2 Encode-Decode operations and the MicReplication Logic App (if present) on the primary site.
  - Redirect AS2 traffic to the secondary site from primary site.
  - Once the primary site has recovered from disaster, data which was processed by the secondary site must be restored in the primary site. Deploy MicReplication Logic App in the primary site wait till the data restoration is completed.

### Note: ###
  - Please note that without encode or decode activity on the primary site there will be no MIC and control number to be replicated and the replication Logic Apps' trigger history will show 'skipped' status.
  - By default the trigger frequency for the replication Logic Apps is three minutes. You can change this value in the Logic App Designer or code view.
  - The X12 triggers "When a [received/generated] control number is modified" alternate runs between a query for change until current time and a query for change five minutes or older to ensure no change is overlooked due to possible time-skew between distributed computing hosts. You will see the same control numbers change trigger once near real-time then a second time five minutes later. In the first run you will see the "Add or update a [received/generated] control number" output "updateControlNumberStatus" property have the value "ControlNumberSuccessfullyUpdated". In the second run you will see the "Add or update a [received/generated] control number" output "updateControlNumberStatus" property have the value "ControlNumberContentNotChanged". Similar behaviour is applicable for all the B2B Triggers.
  - The AS2 DR replication is applicable for AS2 encoded/decoded data processed post DR release.

## Notes

Learn more about: Azure Logic Apps
* **Azure Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-what-are-logic-apps/
* **Logic Apps Enterprise Integration Pack** - https://blogs.msdn.microsoft.com/logicapps/2016/06/30/public-preview-of-logic-apps-enteprise-integration-pack/
* **B2B Processing capabilities in Logic Apps** - https://azure.microsoft.com/documentation/articles/app-service-logic-enterprise-integration-b2b/
* **PowerShell cmdlets for X12 connector disaster recovery** - https://blogs.msdn.microsoft.com/david_burgs_blog/2017/03/09/fresh-of-the-press-new-azure-powershell-cmdlets-for-upcoming-x12-connector-disaster-recovery/
* **PowerShell cmdlets for Logic App and Integration Account on Microsoft Azure** - https://docs.microsoft.com/en-us/powershell/resourcemanager/azurerm.logicapp/v2.7.0/azurerm.logicapp
