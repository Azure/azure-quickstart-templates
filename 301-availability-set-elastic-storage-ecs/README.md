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

#### networkLoadbalancer
Public loadbalancer for ECS Nodes
+ **lbRulesA**: Load Balancing rules for ECS Ports 111,2049,9020.9021,9022,9023,9024,9025,10000
+ **inboundNatRules**: ports 220x are forwarded to port 22 on NodeX

#### OSTCExtensions
Custom Script Extensions for Linux
The deployment utilizes the custom script extension 
+ **configurenode**: Used on the Node to configure installer Prerequirements, used on nodes 2-N
+ **install_ecs**: the ecs installer, run´s on node 1

## Prerequisites
The required VM Types need to have at least 4vCPU and 16GB memory.
Depending on your Subscription, you may require to increase your arm quota vor cores.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

Also, you can use Visual Studio. SImply create a new ressource group deployment from azure-quickstart-templates


### visual studio example

![deploy](images/new_rg.png "Create new deployment from Visual Studio")

#### parameters of resource group
![deploy](images/rg_parameter.png "parameters for resource group")

once the resource group deployment has finished, the ecs installer will be stgarted from
[ecs.sh](emcecs/ecs.sh)

#### monitor installation
ssh into the first node (use the external dns name ), port 2201
```bash
sudo su
tail -f /root/install.log
```
![log](images/log.png "parameters for resource group")
the system will do a reboot after package installation.
the reboot´s will be controlled by a systemd service [ecs-installer.service](emcecs/ecs-installer.service)

after the reboot, the CES ansible installer starts withn step1 and step2  
the progress is also logged 
```bash
sudo su
tail -f /root/install.log
```
![log](images/ansible.png "parameters for resource group")

#### Connect

once the template is deployed, 

#### Management

For more information, see
[DellEMC ECS Community Edition Documentation](http://ecsce.readthedocs.io/en/latest/installation/ECS-Installation.html)

How to manage the solution

## Notes

future improvement´s
+ feedback of installation logs to arm
+ ubntu based install
+ singlenode from same deployment
