# Deploy Ubuntu Desktop VM with RDP support

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ubuntu-desktop-gnome-rdp/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fubuntu-desktop-gnome-rdp%2Fazuredeploy.json" target="_blank"><img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fubuntu-desktop-gnome-rdp%2Fazuredeploy.json" target="_blank">
    <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys an Ubuntu Server VM, then uses the Linux CustomScript extension to install the Ubuntu Gnome Desktop and Remote Desktop support (via xrdp). The final provisioned Ubuntu VM support remote connections over RDP; just like you can with a Windows machine.

Once you connect remotely to the Ubuntu VM over RDP, you will see a similar experience as if you were sitting at an Ubuntu Desktop machine.

Here's a sample screenshot of an RDP session connecting to the Ubuntu VM:

![Ubuntu RDP Session](images/Ubuntu-RDP-Session.png "Ubuntu RDP Session")

When connected over RDP, the VM will prompt you a few times for the Password for the VM. If you wish to remove these prompts for future use of the VM, then follow the instructions at this link: <https://askubuntu.com/questions/675379/how-to-disable-the-password-prompts>

When connected over RDP to the VM the first time, it will prompt for password a couple times. If/when prompted for the Password for a user named `Ubuntu` this first time connecting, simply select "Cancel" and the prompt will go away. Once Ubuntu is configured and able to be used to run apps and other things, then the admin password for the VM will be the password for the `Ubuntu` user it will prompt for later.
