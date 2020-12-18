# Deploy a logic app that can be used in Azure Identity Governance ELM custom action

 [![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-identitygovernance-entitlementmanagement-extensibility-sample-logicapp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-identitygovernance-entitlementmanagement-extensibility-sample-logicapp%2Fazuredeploy.json)

This template create a simple logic app with all the auth settings and schema of the http trigger that is needed my ELM custom action API.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| name  | Name of the Logicapp. |
| location  | Location for the Logicapp.  |
