# VM-Ubuntu - Tomcat and Open JDK installation 

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template allows you to create a Ubuntu VM with OpenJDK and Tomcat. Currently custom script file is pulled temporarily from https://raw.githubusercontent.com/snallami/templates/master/ubuntu/java-tomcat-install.sh.

Once the VM is successfully provisioned, tomcat installation can be verified by accessing the link http://<FQDN name or public IP>:8080/ 

TODO: Define load balancer rule to route traffic on port 80 to 8080.   

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| javaPackageName  | Name of the apt-get java package  |
| tomcatPackageName  | Name of the apt-get tomcat package  |
| customScriptURL  | Download URL of custom script - it can be raw Github URL or any other publicly accessible link.  |
| commandToExecuteCustomScript  | Command to execute custom script e.g. sh java-tomcat-install.sh  |
| location  | Location where to deploy the resource  |
| newStorageAccountName    | Name of the storage account to create    |
| adminUsername | Admin username for the VM |
| adminPassword | Admin password for the VM |
| subscriptionId | Your Azure Subscription Id |
| vmSourceImageName | Any version of Ubuntu |
| vmName | Name of virtual machine |
| virtualNetworkName | Name of new virtual network |
| dnsName | DNS Name |
| publicIPAddressName | Public IP address |
| nicName | NIC Name |