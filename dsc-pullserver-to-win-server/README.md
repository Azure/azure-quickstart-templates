# Deploy a Powershell DSC Pull Server to a Windows Server

This example allows to you deploy a powershell desired state configuration pull server. This deployment creates a windows server and adds the dsc-service and deploys the powershell dsc pull server and configures the server. The server is not domain joined.
This example uses the xPSDesiredStateConfiguration Module available in the PowerShell DSC Resource Kit available here https://gallery.technet.microsoft.com/xPSDesiredStateConfiguratio-417dc71d.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-pullserver-to-win-server%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdsc-pullserver-to-win-server%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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
