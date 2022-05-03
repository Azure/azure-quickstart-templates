# Openshift 4.3 on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/openshift/openshift-container-platform/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopenshift%2Fopenshift-container-platform%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fopenshift%2Fopenshift-container-platform%2Fazuredeploy.json)

### Prerequisites

* Create an App Service Domain to get the DNSZone and DNSZoneRG for this deployment using the `az-group-deploy.sh` script at the root of this repo:
  ```bash
  az-group-deploy.sh -a prereqs -f prereqs/prereq.azuredeploy.json -e prereqs/prereq.azuredeploy.parameters.json -l eastus
  ```
  * Get the outputs. Both values will be used in the main deployment
  ```bash
  az group deployment show --name  AzureRMSamples -g prereqs --query properties.outputs
  ```
* [Download](https://cloud.redhat.com/openshift/install/pull-secret) a pull secret. Create a Red Hat account if you do not have one.

* [Sign up](https://www.ibm.com/account/reg/us-en/signup?formid=urx-42212) for Cloud Pak for Data Trial Key if you don't have the entitlement api key

* If you choose Portworx as your storage class, see [Portworx documentation](PORTWORX.md) for generating `portworx spec url`. 

#### Generate Azure Client ID and Secret with Contributor and User Access Administrator roles:
* Generate Service Principal
```bash
az login
scripts/createServicePrincipal.sh -r "Contributor,User Access Administrator"
```
* Save the `ClientID` and `ClientSecret` printed at the end of the script
