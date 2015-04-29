# Advanced Linux Ansible Template : Setup Ansible to efficiently manage N Linux VMs

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fansible-advancedlinux%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: GONZALORUIZ

This advanced template deploys N Linux VMs and it configures Ansible so you can easily manage all the VMS . Don't suffer more pain configuring and managing all your VMs , just use Ansible! Ansible is a very powerful masterless configuration management system based on SSH.

This template  creates a storage account (Standard or Premium storage), a Virtual Network, an Availability Sets (3 Fault Domains and 10 Update Domains), one private NIC per VM, one public IP ,a Load Balancer and you can specify SSH keys to access your VMS remotely from your latop.
You will need an additional certificate / public key for the Ansible configuration, before executing the template you have upload them to a Private azure storage account in a container named customscript.

The template uses two Custom Scripts  :
 * The first script configures SSH keys (public) in all the VMs for the Root user so you can manage the VMS with ansible.
 * The second script installs ansible on a A1/DS1 VM so you can use it as a controller.The script also deploys the provided certificate to /root/.ssh. Then, it will execute an ansible playbook to create a RAID with all the available disks.
 * Before you execute the script, you will need to create a PRIVATE storage account and a container named customscript, and upload your certificate and public keys for ansible/ssh, as well as the bash scripts and ansible Playbooks. 

 Once the template finishes, ssh into the AnsibleController VM (by defult the load balancer has a NAT rule using the port 64000), then you can manage your VMS with ansible and the root user. For instance : 

 ```
sudo su root
ansible all -m ping (to ping all the VMs) 
	or
ansible all -m setup (to show all VMs system info )
```

This template also ilustrates how to use Outputs and Tags.
 * The template will generate an output with the fqdn of the new public IP so you can easily connect to the Ansible VM.
 * The template will associate two tags to all the VMS : ServerRole (Webserver,database etc) and ServerEnvironment (DEV,PRE,INT, PRO etc)

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Region where you want to create all the resources |
| newStorageAccountName  | Name of the storage account , the template will also append the name of the resource group |
| storageAccountType  | Standard_LRS or Premium_LRS.For Premium use a DS VM |
| imagePublisher | Canonical (default) or OpenLogic |
| imageOffer | "UbuntuServer" (default) or CentOS |
| imageSKU | "12.04.5-LTS" (default) or 6.5 |
| vmSizeDataDisks  | Size of Data disks : By default two data disks will be created |
| vmFileSystem | ext4 or xfs (* For future versions) |
| vmSize | Size of VMs |
| serversRole | Servers role, for instance webtier, database.A tag will be created with the provided value. |
| serversPurpose | Purpose of the server, for instance DEV, TEST, INT , PRO.A tag () will be created with the provided value . |
| numberOfVms | Number of VMS |
| adminUserName | Admin User Name |
| adminPassword | Admin Password |
| sshKeyData | SSH Key data |
| customScriptConfigStorageAccountName |  Storage account name for the Private account that will contain your SSH Keys for ansible and the bash scripts ( Only use a Private storage account, as ssh keys should only be accesible by trusted users) |
| customScriptConfigStorageAccountKey | Storage account Key  |
| dnsNameLabel | DNS Name that wil be associated to the Load balancer|
| publicIPType  | Public IP Type : Dynamic or Static|

##Known Issues and Limitations
- Fixed number of data disks.This is due to a current limitation on the resource manager;this template creates 2 data disks with ReadOnly Caching
- Only the ansible controller VM will be accesible for SSH.
- Scripts are not yet idempotent and cannot handle updates.
- Current version doesn't use secured endpoints. If you are going to host confidential data make sure that you secure the VNET by using Security Groups.