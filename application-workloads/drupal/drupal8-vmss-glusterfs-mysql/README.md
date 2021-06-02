# Drupal 8 VM scaleset (with Azure Files and MySQL) Template

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/drupal/drupal8-vmss-glusterfs-mysql/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdrupal%2Fdrupal8-vmss-glusterfs-mysql%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdrupal%2Fdrupal8-vmss-glusterfs-mysql%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fdrupal%2Fdrupal8-vmss-glusterfs-mysql%2Fazuredeploy.json)

This template deploys a Drupal 8 installation using a VM scale set.  It has the following capabilities:

- Maximum and minimum number of Drupal 8 VMs in the scaleset can be configured - each of these uses Ubuntu OS
- The template also deploys an Azure file share. The Drupal nodes mount the file share, where the settings file and files folder are stored
- The Template can be configured to use an existing MySQL server, or create a New MySQL server (using the MySQL Replication Template)
- Deploys a load balancer in front of the Drupal VM Scaleset, so that the VMs are not directly exposed to the internet. SSH ports on the VMs are exposed through the load balancer (NAT ports)

## How to access the Drupal Site

- Access Drupal using the VMSS load balancer fully qualified domain name.  This will bring up the Drupal home page.  The Drupal admin user name and password which were entered during the template deployment can be used for logging in as administrator.
 ![How to Access Drupal site](images/AccessingDrupalSite.jpg"Access Drupal Site")

## How to SSH into the Drupal VMs

- You can ssh into the VMs in the VM scaleset if needed, using the inbound NAT Pool ports on the load balancer. So for VM 0 ssh in to port 50000, for VM 1 ssh to port 50001 and so on. You can use [Resource Explorer](https://resources.azure.com/) to see the VMs in the VM scale set. See screenshot below:

 ![SSH into Drupal VMs](images/azureResourceExplorer.png"SSH into Drupal VMs")

## Backlog of Planned Changes

- Updrade to PHP7
- Install Drupal Console
- Optionally supply new relic key as parameter, to send VM metrics to new relic
- Optionally adding nginx and memcache into the mix
