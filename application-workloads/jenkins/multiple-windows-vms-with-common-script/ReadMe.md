# ARM Template for Deploying Multiple Lab VMs (Windows with Custom Script)

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/BestPracticeResult.svg)

![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/jenkins/multiple-windows-vms-with-common-script/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fmultiple-windows-vms-with-common-script%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fmultiple-windows-vms-with-common-script%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fjenkins%2Fmultiple-windows-vms-with-common-script%2Fazuredeploy.json)   

* All Windows VMs would be of SAME SIZE and would have SAME CREDENTIALS
* Number of VMs can be set using Parameter 'vmCount'
* Number of ready-to-deploy scripts included in this template:

Script filename | Packages installed
----------------|-------------------
container-lab.ps1 | Docker-Desktop, VSCode & Git
container-vs2019-lab.ps1 | Docker-desktop, VSCode, Git & Visual Studio Community 2019 (All Workloads)
jenkins-java8.ps1 | OpenJDK8, Maven 3.6, Jenkins latest, VScode, Spring ToolSuite latest, firefox latest
az-500.ps1 | Azure CLI latest, Azure Powershell 'Az' modules, VSCode, git, Visual Studio Community 2019 (All workloads), Sql Server Management Studio

