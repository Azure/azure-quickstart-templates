
### Azure Partner Quickstart Template: Continuous Integration and Delivery of microservices using Pivotal CloudFoundry - Concourse - Azure Service Broker & Apigee 
##Solution Template Overview:  Pivotal Cloud Foundry + Concourse + Apigee
Solution Templates provide customers with a highly automated process to launch enterprise ready first and 3rd party ISV solution stacks on Azure in a pre-production environment. The Solution Template effort is complimentary to the Azure Marketplace test drive program. These fully baked stacks enable customers to quickly stand up a PoC or Piloting environments and also integrate it with their systems and customization.
Customers benefit greatly from solution templates because of the ease with which they can stand up enterprise-grade, fully integrated stacks on Azure. The extensive automation and testing of these solutions will allow them to spin up pre-production environments with minimal manual steps and customization. Most importantly, customers now have the confidence to transition the solution into a fully production-ready environment with confidence.
This solution stack will allow users to quickly instantiate a Pivotal Cloud Foundry platform and bring their custom applications and deploy on cloud foundry. These are intended as pilot solutions and not production ready.
Please contact us if you need further info or support on this solution.

##Licenses & Costs
In its current state, solution templates come with licenses built-in – there may be a BYOL option included in the future. The solution template will be deployed in the Customer’s Azure subscription, and the Customer will incur Azure usage charges associated with running the solution stack.
##Target Audience
The target audience for these solution templates are:

Application Developers - Application developers seeking introductory understanding of Cloud Foundry and experience using it to deploy, manage, and scale applications.

Administrators & Operators - Administrators and Operators for those who require strong technical knowledge of the Pivotal Cloud Foundry platform and who are interested in deploying applications on Cloud Foundry and customizing the platform.

##Prerequisites
Azure user account with Contributor/Admin Role

Sufficiently high quota limits (Recommended: 100 cores) on your Azure account. Installing Pivotal Cloud Foundry® requires more than the default 20 cores. *Please see this link for instructions on requesting a core quota increase. *Install either the Azure CLI or Azure PowerShell on your machine, using the instructions here. Create an Azure Service Principal (TENANT-ID, CLIENT-ID, CLIENT-SECRET):
Use the Instructions here to generate Azure Service Principal file

Pivotal Network Account: If you do not already have an account, create one. You will need the API token located in your profile. Navigate to your name in the top right and select Edit Profile. The API token is located at the bottom of the page.

# Solution Summary


##Product Architecture
![Product Architecture](https://raw.githubusercontent.com/sysgain/pivotal/master/pivotal-P2P-Architecture.jpg)

##Solution contains the following
The diagram above provides the overall deployment architecture for this solution template.
As a part of deployment, the template launches the following:

Pivotal Cloud Foundry

Concourse Continuous Integration

Apigee Edge Gateway

Azure Meta Service Broker

###Pivotal Cloud Foundry
Pivotal cloud foundry offer developers a production-ready application container runtime and fully automated service deployments. Meanwhile, operations teams can sleep easier with the visibility and control made possible by platform-enforced policies and automated lifecycle management.
Cloud Foundry supports the full lifecycle, from initial development, through all testing stages, to deployment. It is therefore well-suited to the continuous delivery strategy. Users have access to one or more spaces, which typically correspond to a lifecycle stage. For example, an application ready for QA testing might be pushed (deployed) to its project's QA space. Different users can be restricted to different spaces with different access permissions in each.
###Concourse Continuous Integration

###RESOURCES
56 Virtual Machines
Document DB
SQL Server
3 Public IP Addresses


##Deployment Steps
You can click the “deploy to Azure” button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.
Please refer to parameter descriptions if you need more information on what needs to be provided as an input.
The deployment takes about 3 Hours.
Once it is deployed refer to the user guide to take you to step by step to use the Solution
![User Guide]()


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsysgain%2Fazurequickstarts%2Fmaster%2FPivtoalCloudFoundry-Concourse-Apigee-AzureMetaService%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fsysgain%2Fazurequickstarts%2Fmaster%2FPivtoalCloudFoundry-Concourse-Apigee-AzureMetaService%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>


This repository folder contains an Azure Resource Manager template to deploy:

-  BOSH 
- Pivotal CloudFoundry
 Concourse  https://github.com/concourse/concourse
- Azure Service Meta broker https://github.com/Azure/meta-azure-service-broker
- (Optional) Apigee Edge Gateway & Apigee Edge Service Broker [USE DIFFERET IRL] 


#### IMPORTANT: Before you deploy the template make sure you have accepted Pivotal End User License Agreement:

Elastic Runtime 1.7.15:
https://network.pivotal.io/products/elastic-runtime/releases/2134/eula

MySQL for PCF 1.7.8:
https://network.pivotal.io/products/p-mysql/releases/1770/eula

RabbitMQ for PCF 1.6.0:
https://network.pivotal.io/products/pivotal-rabbitmq-service/releases/1799/eula

Redis for PCF 1.5.15:
https://network.pivotal.io/products/p-redis/releases/1876/eula

Spring Cloud Services for PCF 1.0.9:
https://network.pivotal.io/products/p-spring-cloud-services/releases/1735/eula



- Clone this repository '**$ git clone https://github.com/cf-platform-eng/bosh-azure-template**'
- Create an Azure deployment parameters file to go with the template itself, call it '**azure-deploy-parameters.json**'. The file needs to look like this;

```
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "storageAccountNamePrefixString": {
      "value": "mystorage"
    },
   "adminSSHKey": {
      "value": "ssh-rsa XXXXxxxx"
    },
    "tenantID": {
      "value": "00000000-0000-0000-0000-000000000000"
    },
    "clientID": {
      "value": "00000000-0000-0000-0000-000000000000"
    },
    "clientSecret": {
      "value": "xxxxxxxxxxxxxxx"
    },
    "pivnetAPIToken": {
      "value": "xxxxxxxxxxxxxxx"
    }
  }
}
```

- Give each parameter a suitable value;

    - **storageAccountNamePrefixString** - this is a unique prefix name for you Azure storage account.
    - **adminSSHKey** - your rsa public key that will be trusted by the "jumpbox".
    - **tenantID** - your tenant ID for the subscription you wish to use.
    - **clientID** - the client ID associated to the subscription.
    - **clientSecret** - the clients secret (password).
    - **pivnetAPIToken** - all releases for BOSH are supported releases downloaded from Pivotal Network. Access to the network website is made available via the API token assigned to your account.


- Once that file is complete, you can deploy it like this;

```
$ azure group create -n "cf" -l "West US"
$ azure group deployment create -f azuredeploy.json -e azuredeploy.parameters.json -v cf cfdeploy
```

Once the azure CLI has returned, there should be a tmux process running on the "jumpbox", completing the rest of the install. Connect to the session like this;

```
ssh -t user@jumpboxname.westus.cloudapp.azure.com "tmux -S /tmp/shared-tmux-session attach -t shared"
```
