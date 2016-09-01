# Azure Governance - Custom WebApp [using Ratecard,Usage and Service APIs], SQL DB, OMS Log Analytics, Azure Automation Runbooks [using OMSIngestion APIs] Composite template 001
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAvyanConsultingCorp%2Fazure-quickstart-templates%2Fmaster%2Fazure-governance-cloudwise%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAvyanConsultingCorp%2Fazure-quickstart-templates%2Fmaster%2Fazure-governance-cloudwise%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

## Solution Template Overview
***Solution Templates*** provide customers with a highly automated process to launch enterprise ready first and 3rd party ISV solution stacks on Azure in a pre-production environment. The **Solution Template** effort is complimentary to the [Azure Marketplace test drive program](https://azure.microsoft.com/en-us/marketplace/test-drives/). These fully baked stacks enable customers to quickly stand up a PoC or Piloting environments and also integrate it with their systems and customization.

Customers benefit greatly from solution templates because of the ease with which they can stand up enterprise-grade, fully integrated stacks on Azure. The extensive automation and testing of these solutions will allow them to spin up pre-production environments with minimal manual steps and customization.  Most importantly, customers now have the confidence to transition the solution into a fully production-ready environment with confidence.

**Cloud Governance Pilot Solution Template 001** 
*Disclaimer*: These are intended as pilot solutions and not production ready.
Please [contact us](mailto:azuremarketplace@avyanconsulting.com) if you need further info or support on this solution.

##Licenses & Costs
In its current state, solution templates come with licenses built-in – there may be a BYOL option included in the future. The solution template will be deployed in the Customer’s Azure subscription, and the Customer will incur Azure usage charges associated with running the solution stack.

##Target Audience
The target audience for these solution templates are IT professionals who need to stand-up and/or deploy infrastructure stacks.

## Prerequisites
* Azure Subscription - if you want to test drive individual ISV products, please check out the [Azure Marketplace Test Drive Program ](https://azure.microsoft.com/en-us/marketplace/test-drives/)
* Azure user account with Service Admin Role
* Azure Marketplace Deployment Agreements - VM Images from Azure marketplace need a registered Azure credit card for deployments to be successful. We understand that some customers (especially EA and internal MS customers) may not have this configured leading to failed deployments.   
* Operations Management Suite Account (Free Sign Up – No credit card required. Sign up for your free OMS account [here](https://www.microsoft.com/en-us/cloud-platform/operations-management-suite))
* ![](images/CreateOMSWorkspace.png))
* Create an Automation account with RunAs Service principal. Note down the resourceGroup and the AutomationAccount name
* --Capture your OMS Workspace details ![](images/CaptureWorkspaceInformation.png)
 
##Solution Summary

 
##Reference Architecture Diagram
![[](images/CloudWiseArchitecture.png)](images/CloudWiseArchitecture.png)

# OMS Web Apps Monitoring dashboard
![](images/WebAppPaaS.png)

# OMS Azure SQLDB Monitoring dashboard
![](images/SQLAzurePaaS.png)

## Deployment Steps
You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

# Post Deployment Steps
* Currently, one has to manually start the scheduleIngestion Runbook. 
** Please navigate to your automation account. Click on Runbooks
** Click open the scheduleIngestion runbook and click start to run the runbook. This step will kickstart the data ingestion to the OMS workspace specified.
![](images/StartIngestionRunbook.png)


***Please refer to parameter descriptions if you need more information on what needs to be provided as an input.***


##Usage
#### Connect


##Support
For any support-related issues or questions, please contact azuremarketplace@avyanconsulting.com for assistance.
