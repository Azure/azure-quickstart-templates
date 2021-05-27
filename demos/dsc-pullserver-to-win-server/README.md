# Deploy a Powershell DSC Pull Server to a Windows Server

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/dsc-pullserver-to-win-server/CredScanResult.svg)

This example allows to you deploy a powershell desired state configuration pull server. This deployment creates a windows server and adds the dsc-service and deploys the powershell dsc pull server and configures the server. The server is not domain joined.
This example uses the xPSDesiredStateConfiguration Module available in the PowerShell DSC Resource Kit available here https://gallery.technet.microsoft.com/xPSDesiredStateConfiguratio-417dc71d.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdsc-pullserver-to-win-server%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdsc-pullserver-to-win-server%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fdsc-pullserver-to-win-server%2Fazuredeploy.json)

*Note*: There are a few workarounds in the dsc script to make this work on the Windows Server that you need to be aware of.

1. The appcmd command is used to unlock a few entries in IIS.

2. The Pull Server and Compliance Server "dbprovider" is changed to "System.Data.OleDb".

3. The Pull Server and Compliance Server "dbconnectionstr" is changed to use the Provider "Microsoft.Jet.OLEDB.4.0" 

4. The Compliance Server authentication has been changed to anonymous as this machine is not domain joined.

After the template is deployed you can 

1. Open the Internet Explorer and browse to http://localhost:8080/PSDSCPullServer.svc to test if the deployment was successful.

2. Open another tab in Internet Explorer and browse to http://localhost:9080/PSDSCComplianceServer.svc to test if the deployment was successful.

For further information on the DSC Pull server look here:

[PowerShell DSC Resource for configuring Pull Server environment](http://blogs.msdn.com/b/powershell/archive/2013/11/21/powershell-dsc-resource-for-configuring-pull-server-environment.aspx)

[How to retrieve node information from DSC pull server](http://blogs.msdn.com/b/powershell/archive/2014/05/29/how-to-retrieve-node-information-from-pull-server.aspx)


