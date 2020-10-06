# Managed Application Plan Conversion

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/101-managed-application-custom-billing/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvayada%2Fazure-quickstart-templates%2Fvayada%2FplanConversionSample0925%2F101-managed-application-plan-conversion%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fvayada%2Fazure-quickstart-templates%2Fvayada%2FplanConversionSample0925%2F101-managed-application-plan-conversion%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This function app deploys the sample plan conversion agent in publisher's tenant, which will listen for plan update notifications from AMA service. It performs additional resource deployment in customer's managed resource group. Additionaly, it creates an entry in CosmosDB for async operation mapping so that it can provide the status when AMA polls for async operation status. And, it will provide status of operation when AMA polls for status on given location uri.

## This quickstart template requires following mandatory parameters
### Current Plan
This is the "Plan ID" for the source plan. You can get this from partner center.
### New Plan
This is the "Plan ID" for the target plan. You can get this from partner center.
### Main Template Uri
This is the link to the deployment template file which you want to deploy in customer's mrg as part of plan conversion from source to target plan.
### Parameters Template Uri
This is the link to the parameters template file for providing parameters to your deployment template(Main Template Uri).

## Once you deploy this function app in publisher subscription, use following output properties as below
+ "identityPrincipalId" => "Principal ID" in "Authorizations" (In partner center, enter this principal id in authorizations of your source plan technical configuration in partner center. This step will whitelist this function app in your offer to perform any additional template deployment in customer's managed resource group.) 
+ "webhookEndpoint" => "Notification Endpoint URL" (In your target plan's technical configuration use the following template output property as notification endpoint.)

### Note
+ Offer should be published with the above information in plan technical configuration page. Existing managed application cannot use plan conversion feature if those are not deployed with the offer containing above information about "Authorizations" & "Notification Endpoint URL".

## Plan update notification schema
```json
{ 
    "applicationId": "subscriptions/<subscriptionId>/resourceGroups/<rresourceGroupName>/providers/Microsoft.Solutions/applications/<applicationName>",
    "eventTime": "2020-03-28T19:20:08.1707163Z", 
    "contentVersion": "1.0", 
    "oldPlan": { 
        "product": "offer", 
        "name": "planone", 
        "version": "1.0.0" 
    }, 
    "newPlan": { 
        "product": "offer", 
        "name": "plantwo", 
        "version": "1.0.0" 
    } 
} 
```

## AsyncOperationResult schema
```json
{ 
    "status": "SUCCEEDED",
    "error": { 
        "code": "errorCode", 
        "message": "errorMessage"
    } 
} 
```

## Notification response to AMA
Publisher can return statuscode 200(OK) or 202(ACCEPTED) with location uri set in the header.

## With the new plan conversion feature, AMA allows user to change the plan for marketplace managed application with custom billing. AMA relies on ISV for additional resources deployment for target plan.
Plan update for a marketplace managed application happens in following steps:
+ User intiates PATCH operation with target plan in patch body. (Target plan has to be from the same offer.)
+ AMA recieves the PATCH request and validates the target plan for a given offer.
+ AMA notifies ISV on given notification endpoint about plan change. (Plan update notification schema as above)
+ ISV performs additional resource deployment in customer's managed resource group.
+ ISV can return 200(OK) or 202(ACCEPTED) with location uri (async operation for additional template deployment) which can be tracked by AMA service.
+ AMA service recieves 202(ACCEPTED) from ISV and keeps polling for operation status on given location uri.
+ ISV needs to return the 200(OK) response with AsyncOperationResult containing status "RUNNING", "SUCCEEDED" or "FAILED". (AsyncOperationResult schema as above)
+ AMA converts the plan on getting status SUCCEEDED for the operation running on ISV side.

