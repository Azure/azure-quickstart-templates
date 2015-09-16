## Windows Server Container Host Preview (Docker Ready)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fwindows-server-containers-preview%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template will deploy and configure a Windows Server 2016 TP core VM instance with Windows Server Containers. These items are performed by the template:

- Deploy the TP3 Windows Server Container Image.
- Create inbound network security group rules for HTTP, RDP and Docker.
- Create inbound Windows Firewall rules for HTTP and Docker (custom script extensions).
- Modify the Docker Daemon configuration file to listen for incoming requests on port 2375 (custom script extension).

Windows Server 2016 TP3 and Windows Server Container are in an early preview release and are not production ready and or supported.
