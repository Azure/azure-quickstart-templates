# Azure Application Gateway Demo Setup

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/application-gateway-demo-setup/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-demo-setup%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-demo-setup%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fapplication-gateway-demo-setup%2Fazuredeploy.json)

This template allows you to quickly deploy Azure Application Gateway demo to test load-balancing with or without cookie-based affinity.

## To Deploy Demo Setup:

1. Push Deploy to Azure button.
2. Choose admin credentials for the backend Web servers.
3. If needed change size, capacity, cookie-based affinity mode (you can re-configure later).
4. Start template deployment.

## After Deployment

Once your demo setup is deployed use DNS name of your Azure Application Gateway that was generated for you automatically to test how it works.
To get your Azure Application Gateway DNS name you can open Azure Application Gateway's Public IP address properties in Azure Portal:

![alt text](images/appgwdnsname.png "Demo Application Gateway FQDN in Azure Portal")

## Testing Your Setup

In order to try your test setup in action you can re-send your requests, bring down/up the VMs/Web servers created as a part of the deployment, change Azure Application Gateway settings.

When your HTTP request hits backend server, you should be able to see a page like the one below:

![alt text](images/serverhit.png "Backend server response")




