# Xfce Desktop on Ubuntu VM

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/demos/ubuntu-desktop-xfce-rdp/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-desktop-xfce-rdp%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-desktop-xfce-rdp%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdemos%2Fubuntu-desktop-xfce-rdp%2Fazuredeploy.json)

This template uses the Azure Linux CustomScript extension to deploy Xfce Desktop on the VM. It creates an Ubuntu VM, does a silent install of gnome xfce4 desktop and xrdp, allows you to connect it with Remote Desktop from a Windows machine.

We don't install ubuntu-desktop or xubuntu-desktop, because the installation will take so long time, the deployment will fail with the error "Extension installation may be taking too long", hence we install xfce4 desktop instead. 
xfce4 desktop will give you a basic desktop environment, you still can connect it with Remote Desktop from a Windows machine.

if you find out it's not enough for you, you can continue to install xubuntu-desktop after the deployment. First, use putty or other tools to connect to the VM, then execute the commands below:

sudo apt-get install xubuntu-desktop -y

sudo service xrdp restart

Then re-connect it with Remote Desktop from a Windows machine.


Please kindly note for Ubuntu 15.10, if you face the connection issue, saying "connecting to sesman ip 127.0.0.1 port 3350" then couldn't move on, this is  xrdp-sesman didn't start hence caused the issue. To fix it, please use putty to connect to the VM, execute the simple command below

sudo service xrdp restart

Then re-connect it with Remote Desktop from a Windows machine. 


