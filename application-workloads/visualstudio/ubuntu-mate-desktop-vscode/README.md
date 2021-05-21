# Deploy an Ubuntu Mate Desktop VM with VSCode

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/visualstudio/ubuntu-mate-desktop-vscode/CredScanResult.svg)

This template creates a Linux developer workstation as follows:

- Create a VM based on the Ubuntu 18.04 image with Mate Desktop installed
- Installs Azure CLI v2
- Install Visual Studio Code editor
- Opens the RDP port for users to connect using remote desktop

This template creates a new Ubuntu VM with Mate desktop enabled. Mate desktop is light weight and has a simple UI. In addition to a nice GUI, this template also installs developer tools like Azure CLI and Visual Studio Code for editing files. Users can connect to the Desktop UI using remote destop.

To connect, run "mstsc" from windows desktop and connect to the fqdn/public ip of the VM.
 
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fubuntu-mate-desktop-vscode%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fubuntu-mate-desktop-vscode%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fvisualstudio%2Fubuntu-mate-desktop-vscode%2Fazuredeploy.json)

# Running at terminal 

To open a terminal with Ctrl + Alt + t

# Running VSCode

### Manage IDE from the Command Line
The vscode IDE includes a command line tool called code which can use to manage the IDE directly from the Ubuntu terminal.

### To open a new file, Execute:
code file_name

### To open a folder with vscode, Type:
code dir_name

### You can also use command line to add new extensions.For example, Following command will add eslint JavaScript extension to the vscode:
code --install-extension dbaeumer.vscode-eslint

### To list installed extensions, Type:
code --list-extensions

### Getting Started with VS Code

Visual Studio Code is a lightweight but powerful source code editor which runs on your desktop and is available for Windows, macOS and Linux. It comes with built-in support for JavaScript, TypeScript and Node.js and has a rich ecosystem of extensions for other languages (such as C++, C#, Java, Python, PHP, Go) and runtimes (such as .NET and Unity). 

Begin your journey with VS Code with these [introductory videos](https://code.visualstudio.com/docs/introvideos/overview)

[Visual Studio Code - Getting Started documents](https://code.visualstudio.com/docs)

### Microsoft Learn - Learning Modules

[Visual Studio Code](https://docs.microsoft.com/en-us/learn/browse/?term=Visual%20Studio%20Code)
[Linux Virtual Machines on Azure](https://docs.microsoft.com/en-us/learn/browse/?term=Linux%20Virtual%20Machine)
[Azure CLI](https://docs.microsoft.com/en-us/learn/browse/?term=Azure%20CLI)


