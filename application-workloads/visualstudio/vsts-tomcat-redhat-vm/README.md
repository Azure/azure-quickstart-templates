# VM-Redhat - Team Services Apache 2 Tomcat 7 installation

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/vsts-tomcat-redhat-vm/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-tomcat-redhat-vm%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-tomcat-redhat-vm%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fvsts-tomcat-redhat-vm%2Fazuredeploy.json)

This template allows you to create a RedHat VM running Apache2 and Tomcat7 and support the Visual Studio Team Services (and Team Foundation Server)
Apache Tomcat Deployment extension task, the built-in Copy Files over SSH deployment task, and the built-in FTP Upload utility task (using ftps).

To learn more about Visual Studio Team Services (VSTS) and Team Foundation Server (TFS) support for Java, check out:
http://java.visualstudio.com/

## Before you Deploy to Azure

To create the VM, you will need to:

1. Choose an admin user name and password for your VM.  This user name and password will be used as the Team Services generic endpoint User name and Password for FTPS.

2. Choose a name for your VM. 

3. Choose a Tomcat user name and password to enable the Tomcat manager UI and deployment method.  This user name and password will be used as the Team Services Apache Tomcat deployment task manager user name and password.

4. Choose a Pass phrase to use with your SSH certificate.  This pass phrase will be used as the Team Services SSH endpoint passphrase.

## After you Deploy to Azure

Once you create the VM, use an SSH client (such as the Windows command prompt SSH or a tool such as MobaXterm) to login (using the admin user name and password from above) and then examine the contents of the file 
"vsts_ssh_info" (i.e. cat vsts_ssh_info)  in the home directory to discover the SSH private key needed when using the Team Services Copy files via SSH deployment task (when setting up the SSH endpoint).




