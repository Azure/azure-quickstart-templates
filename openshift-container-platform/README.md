# Openshift 4.3 on Azure

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/openshift-container-platform/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenshift-container-platform%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenshift-container-platform%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fopenshift-container-platform%2Fazuredeploy.json)

### Before you deploy

* Create [App Service Domain](https://portal.azure.com/#create/Microsoft.Domain)
  * This will also create a DNS Zone needed for this deployment.
  * Note the DNS Zone name.

* [Download](https://cloud.redhat.com/openshift/install/pull-secret) a pull secret. Create a Red Hat account if you do not have one.

* [Sign up](https://www.ibm.com/account/reg/us-en/signup?formid=urx-42212) for Cloud Pak for Data Trial Key if you don't have the entitlement api key

* If you choose Portworx as your storage class, see [Portworx documentation](PORTWORX.md) for generating `portworx spec url`. 

#### Retrieve Azure Client ID and Secret:

* Create Azure Service Principal with `Owner`, `Contributor` and `User Access Administrator` roles.
  * Create Service Principal, using your Azure Subscription ID, and save the returned json:
    ```bash
    az login
    az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/<subscription_id>"
    ```
  * Get `Object ID`, using the AppId from the Service Principal just created:
    ```bash
    az ad sp list --filter "appId eq '<app_id>'"
    ```
  * Assign `Contributor` and `User Access Administrator` roles, using the `Object Id`.
    ```bash
    az role assignment create --role "User Access Administrator" --assignee-object-id "<object_id>"
    az role assignment create --role "Contributor" --assignee-object-id "<object_id>"
    ```
**NOTE** `appId` is the AAD Client ID and `password` is the AAD Client Secret.
