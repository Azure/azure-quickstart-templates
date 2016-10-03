# Windows Server 2016 Technical Preview - Containers

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fwindows-server-containers-preview%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fwindows-server-containers-preview%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The template will deploy a Windows Server 2016 Technical Preview virtual machine with Windows containers. 

The following actions are completed:

- Deploy the Windows Server 2016 Technical Preview system.
- Enable the Windows containers role.
- Download and install the Windows Server Core container base OS image.
- Download and configure Docker.

Once the template has been deployed, the virtual machine will be rebooted. At first logon, a second configuration script will be run to complete the process. Due to a large download, this configuration can take quite some time.

Windows Server 2016 TP5 and Windows Containers are in an early preview release and are not production ready or supported.

> Microsoft Azure does not support Hyper-V containers. To complete Hyper-V Container exercises, you need an on-premises container host.    
