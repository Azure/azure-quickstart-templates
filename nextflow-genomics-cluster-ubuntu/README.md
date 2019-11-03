<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnextflow-genomics-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fnextflow-genomics-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>


# Nextflow on Azure

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/nextflow-genomics-cluster-ubuntu/CredScanResult.svg" />&nbsp;

## What is Nextflow?
[Nextflow enables scalable and reproducible](http://nextflow.io) scientific workflows using software containers. It allows the adaptation of pipelines written in the most common scripting languages.

Its fluent DSL simplifies the implementation and the deployment of complex parallel and reactive workflows on clouds and clusters.

## What is the Purpose of this Template?
To enable the deployment of a nextflow cluster using Ignite Executor on [Azure Scalable VMSS Machines](https://docs.microsoft.com/en-us/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-overview)

## Details
This Azure Resource Manager template and the accompanying script deploys an Azure Virtual Machine Scale Set hosting Docker and Nextflow for running scientific pipelines. 

The cluster consists of one jumpbox VM (master node) plus 1-100 (limit can be lifted by raising a support ticket) slave nodes in a Scale Set, using a combination of Azure Files and NFS as shared storage. Users can submit Nextflow workstreams to the master node for execution on the slave nodes.

## Solution Breakdown
* azuredeploy.json:
    * Creates a new resource group, to which it deploys:
        * Storage account
        * VNet and subnet
        * Jumpbox VM with Premium Data disk for NFS storage
        * N slave VMs in a Scale Set
    * All VMs are then configured to run Nextflow via script (see below for details)
* Scripts/init.sh
    * Installs CIFS and JQ
    * Tries to create an Azure File Share in the new storage account (this will only succeed once, subsequent attempts will silently fail without causing an error)
    * Mounts this as a shared disk for Nextflow. This is used to share details between nodes for the cluster discovery. 
    * Create an NFS share on the Jumpbox and mount this on all nodes for sharing Nextflow work and assets folders. (This is required as full POSIX support is required on the filesystem for Nextflow)
    * Installs OpenJDK
    * Installs Nextflow and configure it to start at boot on all nodes using systemd service called `nextflow.service`.
    
## Deploying 

> ** WARNING! **
> If you are deploying a cluster for a production environment it is recommended that you stage a copy of the script resources to avoid future updates to this repository causing issues with your deployment. See the [Uploading Artifacts](/README.MD#uploading-artifacts) guide to use Azure Storage or, alternatively, you can upload the resources to another location and set the `_artifact*` parameters manually to specify the url for the files.
>
> `_artifactsLocation` + `_artifactsNextflowFolder` must point to your copy of the `/init.sh` script file stored under `/nextflow-genomics-cluster-ubuntu/Scripts/init.sh` in this repository.
>
> `_artifactsLocation` + `_artifactsSharedFolder` must point to your copy of the `vm-disk-utils-0.1.sh` script file stored under `/shared_scripts/ubuntu/afs-utils-0.1.sh` in this repository.
>
> For example: `https://mylocation` (`_artifactsLocation`) + `/scripts` (`artifactsNextflowFolder`) will request the file from `https://mylocation/scripts/vm-disk-utils-0.1.sh`

### GUI

Click the 'Deploy to Azure' button and follow the instructions provided. 
On step 3, once the resources are deployed, you'll see a 'Manage your resources' button. 
Click this button then select 'Deployments', click the deployment and you'll see the connection details and an example command in the 'Output' section. 

[Connection process video](https://1drv.ms/v/s!AgO58DGl6B7Rqu9y1ahnXrLlSn0M_g)

Once deployed you can scale the cluster by selecting the VM Scale set and changing the instance count. 

[Scaling video](https://1drv.ms/v/s!AgO58DGl6B7Rqu9wVAqAD5RnJRYSDg)

### Azure CLI

Update the `variables` section and the details in `azuredeploy.parameters.json` then run it in [Windows Subsystem for Linux](https://msdn.microsoft.com/en-us/commandline/wsl/install-win10?f=255&MSPPError=-2147217396) or Bash. The script will show the deployment output which contains the ssh connection string for the jumpbox and some example nextflow commands configured to use the cluster.

``` text
#Variables
RESOURCE_GROUP=$your_resource_group_name_here
LOCATION=westus2

#Deployment
az group create -l $LOCATION -g $RESOURCE_GROUP
cp ./azuredeploy.parameters.json ./azuredeploy.parameters.$RESOURCE_GROUP.json
az group deployment create --verbose -g $RESOURCE_GROUP --template-file ./azuredeploy.json --parameters @./azuredeploy.parameters.json
echo "Done: Here are details for connecting to the jumpbox and running pipelines"
az group deployment show -g $RESOURCE_GROUP -n azuredeploy --query properties.outputs
```

Example output:

``` json
Done: Here are details for connecting and running pipelines
{
  "exampleNextflowCommand": {
    "type": "string",
    "value": "nextflow run hello -process.executor ignite -cluster.join path:/datadisks/disk1/cifs/cluster -with-timeline runtimeline.html -with-trace -cluster.maxCpus 0"
  },
  "exampleNextflowCommandWithDocker": {
    "type": "string",
    "value": "nextflow run nextflow-io/rnatoy -with-docker -process.executor ignite -cluster.join path:/datadisks/disk1/cifs/cluster -with-timeline runtimeline.html -with-trace -cluster.maxCpus 0"
  },
  "jumpboxConnectionString": {
    "type": "string",
    "value": "ssh nextflow@jumpboxvmaddress.westus2.cloudapp.azure.com"
  }
}
```

## Debugging Cluster

The cluster is created as a 'Deployment' under a resource group. If issues occur, the deployment will provide logs and error details. This can be accessed in the portal as follows:

[Debugging cluster video](https://1drv.ms/f/s!AgO58DGl6B7Rg-NyegXiV8cBhdxgKw)

In most cases a good first step is to delete the resource group and redeploy to rule out transient issues.

In addition to this, logs are created during the setup of the nodes and master. These are stored in the storage account created for the cluster. You easily access these by installing [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/) and browsing the content under `[ResourceGroupUsed]/nfstoragexxxxxxx/File Shares/sharedstorage/logs`. Here is an example:

[Cluster logs video](https://1drv.ms/v/s!AgO58DGl6B7Rqu9xp6uN8Nufc5mJiA)

## Custom Image 

The template supports using a `Ubuntu 16 LTS` based custom image for the master and nodes.

Once you have created your image retrieve it's `id` using the `azcli`. For example run this command, it will list the IDs of your custom images:

 `az image list --query [].id`

Set the image ID as follows in your parameters file.

``` json
    "vmImageReference": {
      "value": {
        "id": "yourManagedImageId - 'az image list' then take id from output"
      }
    }
```

You can then deploy your Nextflow cluster as follows:

 `az group deployment create -g [your_resource_group_here] --template-file ./azuredeploy.json --parameters @azuredeploy.customimage.parameters.json`

