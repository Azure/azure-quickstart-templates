# SAP NetWeaver file server using a Marketplace image

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-file-server-md%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsap-file-server-md%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template takes a minimum amount of parameters and deploys an Linux NFS server or Windows Server 2016 Storage Spaces Direct Scale out File Server that is customized for use with SAP NetWeaver, using the latest version of the selected operating system. It deploys 2 virtual machines in an Availability Sets and a Load Balancer is added to allow HA configurations in the operating system (e.g. Windows Failover Cluster).

## Internal Load Balancer ports

* Windows specific ports 445, 5985
* Linux specific ports 2049 (TCP and UDP)

Internal Load Balancer probe port: **61000**			
