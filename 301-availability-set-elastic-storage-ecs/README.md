# multinode dellemc ecs community edition in an azure availabilty set

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbottkars%2Fazure-quickstart-templates%2Fmaster%2F301-availability-set-elstic-storage-ecs%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fbottkars%2Fazure-quickstart-templates%2Fmaster%2F301-availability-set-elstic-storage-ecs%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo: (change the folder name below to match the folder name for this sample)

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '301-availability-set-elastic-storage-ecs'
```
```bash
azure-group-deploy.sh -a '301-availability-set-elastic-storage-ecs' -l eastus 
```

This template deploys a **multinode dellemc ecs community edition**. The **ecs community edition** is a **elastic cloud storage solution providing object storage (sr, atoms, cas)**

`Tags: arm, centos, ecs, ecs community edition`

## Solution overview and deployed resources

This is an overview of the solution

The following resources are deployed as part of the solution

#### Storage Accounts 

Storage ressources provided per vm

+ **vm storage account**: holds the os copy from image (CentOS) and up to 8 data disks per node
+ **diagnostic storage account**: storage for vm diagnostics

#### networkSecurityGroups

Firewall rules for Network
+ **Resource type 2A**: Description Resource type 2A

#### networkLoadbalancer

Public loadbalancer for ECS Nodes

+ **lbRulesA**: Load Balancing rules for ECS Ports 111,2049,9020.9021,9022,9023,9024,9025,10000

#### OSTCExtensions

Custom Script Extensions for Linux

+ **configurenode**: Used on the Node to configure installer Prerequirements, used on nodes 2-N
+ **install_ecs**: the ecs installer, run´s on node 1

## Prerequisites

The required VM Types need to have at least 4vCPU and 16GB memory.
Depending on your Subscription, you may require to increase your arm quota vor cores.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.


### visual studio example

![deploy](mages/new_rg.png "Create new deployment from Visual Studio")

#### parameters of resource group
![deploy](mages/rg_parameter.png "parameters for resource group")


#### monitor installation
#### Connect

once the template is deployed, 

#### Management

How to manage the solution

## Notes

Solution notes
