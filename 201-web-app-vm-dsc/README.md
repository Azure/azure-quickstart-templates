# VM-DSC-Extension-IIS-Server

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-vm-dsc%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-web-app-vm-dsc%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

<p>
This template allows you to deploy a Web application a VM. It also configures the Web Application to set the SQL Azure database server.
In order to run the template, please make sure:
</p>

1. Sign-in PowerShell session using your Azure account by running Add-AzureAccount
2. select a current storage account for the current subscription. Please see Set-AzureSubscription online help for how to set a default storage account: https://msdn.microsoft.com/en-us/library/dn495189.aspx
3. Upload your web deploy package somewhere accessible from the target node. In this example the web deploy package is uploaded to github as specified in azuredeploy.param.json file:

<p>
   "webdeploypkg": {
            "value": "https://github.com/CawaMS/FileShare/releases/download/releasetag/WebApplication3.zip"
        }
</P>
