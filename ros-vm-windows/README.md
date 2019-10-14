# ROS on Azure with Windows VM

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/ros-vm-windows/CredScanResult.svg" />&nbsp;

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fros-vm-windows%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fros-vm-windows%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a> 
<br> <br>

## Template Overview

The [Robot Operating System (ROS)](https://www.ros.org/) is a set of software libraries and tools that help you build robot applications.
From drivers to state-of-the-art algorithms, and with powerful developer tools, ROS has what you need for your next robotics project.
And it's all open source.

This template creates a Windows VM and installs the latest nightly build of [ROS on Windows](https://aka.ms/ros) into it using the CustomScript extension.
This VM will expose Windows Remote Management over HTTPS.
Please see the below to learn how to connect to it.

For any support related questions or issues, please go to our [GitHub repository](https://github.com/ms-iot/ROSOnWindows).

## How to connect to a Target Azure VM over WinRM HTTPS

Use the below script to connect to an azure vm post winrm configuration. Assign the exact IP address of your azure vm to `$hostIP`.
The script pops up a credential window, provide the credentials of azure vm.

```powershell
    $hostIP=<ip-of-vm>

    # Trust the remote VM host
    Set-Item wsman:\localhost\Client\TrustedHosts -value $hostIP

    # Get the credentials of the machine
    $cred = Get-Credential

    # Connect to the machine
    $soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck
    Enter-PSSession -ComputerName $hostIP -Credential $cred -SessionOption $soptions -UseSSL
```

