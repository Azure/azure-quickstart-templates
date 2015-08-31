## Windows Server Container Host (Docker Ready)

This template will deploy and configure a Windows Server 2016 TP core VM instance with Windows Server Containers. These items are performed by the template:

- Deploy the TP2 Windows Server Container Image.
- Create inbound network security group rules for HTTP, RDP and Docker.
- Create inbound Windows Firewall rules for HTTP and Docker (custom script extensions).
- Modify the Docker Daemon configuration file to listen for incoming requests on port 2375 (custom script extension).

Windows Server 2016 TP3 and Windows Server Container are in an early preview release and are not production ready and or supported.
