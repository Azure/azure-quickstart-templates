# Chef Backend High-Availability Cluster

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fchef-ha-cluster%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fchef-ha-cluster%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

**This template has artifacts that need to be staged for deployment (Configuration Scripts) so use the below command with the upload flag to deploy this template or provide a storage account and SAS token when using the deploy button above.**
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script (think of this as "temp" storage for AzureRM) and reused by subsequent deployments.

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'chef-ha-cluster' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a chef-ha-cluster -l eastus -u
```

This template deploys a Chef Backend High-Availability Cluster.
`Tags: chef,cluster,ha`

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

#### Connect

Connect using ssh
To reach a frontend use port 50000,50001,50002 (FE0,1,2):
```
ssh -p 50000 chefadmin@yourhost.youregion.cloudapp.azure.com
```
To reach a backend do something like
```
ssh -o ProxyCommand="ssh -W %h:%p -p 50000 -q chefadmin@yourhost.youregion.cloudapp.azure.com" chefadmin@be0
```

#### Management

See the chef documentation at [Chef](https://docs.chef.io/)

