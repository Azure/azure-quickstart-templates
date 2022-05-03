# Chef Backend High-Availability Cluster

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/chef/chef-ha-cluster/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fchef-ha-cluster%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fchef-ha-cluster%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fchef%2Fchef-ha-cluster%2Fazuredeploy.json)



This template deploys a Chef High-Availability Cluster.
`Tags: chef,cluster,ha`

## Deployment steps

This template has artifacts (Configuration Scripts) which are automatically grabbed from github, or can be staged for deployment. Use the below command with the upload flag to deploy this template or provide a storage account and SAS token when using the deploy button above.

This template also uses blob storage to share secrets and configuration templates between nodes in the cluster. You must create a blob storage container for these and provide an SAS token. If you're creating a storage container for artifacts, you can use the same one for secrets storage.

## Using the command-line
 ```PowerShell
 .\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'chef-ha-cluster' UploadArtifacts
 ```
 ```bash
 azure-group-deploy.sh -a chef-ha-cluster -l eastus -u
 ```

## Using the "deploy to Azure" button
1. Provision a Standard (LRS) storage account, or use an existing one (must be Standard)
2. Provision a blob storage container underneath storage account.  Note the container URL (ie. https://mystandardstorage.blob.core.windows.net/artifactsfolder )
3. Generate a Shared Acccess Signature (SAS) token with and End date exceeding the life of your cluster.  Note the SAS token.
4.  Click the "deploy to Azure" button at the beginning of this document
5.  Enter in the required fields
  * Artifacts Location:  the container URL from step 2
  * Artifacts Location SAS Token: the SAS token from step 3
  * Chef DNS name: A unique short name (ex: mychefhacluster ) that will be prepended to `.region.cloudapp.azure.com` (ex: `mychefhacluster.westus.cloudapp.azure.com`)
  * SSH Key Data: The contents of your [SSH Public key](https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key) for SSH authentication

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


