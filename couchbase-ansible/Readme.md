# Advanced Linux Template : Deploy a Multi VM Couchbase Cluster

<a href="https://azuredeploy.net/" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


This advanced template creates a Multi VM Couchbase Cluster,it also configures Ansible so you can easily manage all the VMS. 

This template  creates a new Storage Account (standard or premium) for all the Couchbase VMS , a Virtual Network, an Availability Sets (3 Fault Domains and up to 10 Update Domains), one private NIC per VM, one public IP and Load Balancer.You can specify SSH keys to access the Ansible Controller remotely. Minimun recommded VM Size is Standard_D2 and 4 data disks will be attached to each Couchbase VM and a RAID device will be created with all the disks.
You will need an additional certificate / public key for the Ansible configuration;before executing the template you have to upload them and all the scripts to a Private azure storage account in a customer named customScript.

The template uses two Custom Scripts  :
 * The first script configures SSH keys (public) in all the VMs for the Root user so you can manage the VMS with Ansible.
 * The second script installs ansible on a A1/DS1 VM so you can use it as a controller.The script also deploys the provided certificate to /root/.ssh. Then, the script will execute an ansible playbook to create a RAID with all the available disks.
 * Then, the script will install Couchbase in all the VMS using Ansible and the ansible-couchbase-server  playbook.
 * Before you execute the template, you will need to create a PRIVATE storage account and a container named customscript;then  upload your certificate, public key as well as the bash scripts and ansible Playbooks.

 Once the template finishes, ssh into the AnsibleController VM (by default the load balancer has a NAT rule using the port 64000), then you can manage your VMS with ansible as the root user. For instance : 

```
sudo su root
ansible all -m ping
```

Additionally, The Couchbase Web Admin Console will be exposed on the port 16195.In order to expose the Couchbase console securely, the Ansible Controller VM is configured as a nginx reverse proxy using https and self-signed certificates.

This template also ilustrates how to use Outputs and Tags.
 * The template will generate an output with the fqdn of the new public IP so you can easily connect to the Ansible VM.
 * The template will associate two tags to all the VMS : ServerRole (Webserver,database etc) and ServerEnvironment (DEV,PRE,INT, PRO etc)

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| location  | Region where you want to create all the resources |
| storageAccountName  | Storage account name , the template will also append the name of the resource group |
| storageAccountType  | Standard_LRS or Premium_LRS  (For Premium, use the DS VMs) |
| imagePublisher | Canonical (default) or OpenLogic |
| imageOffer | "UbuntuServer" (default) or CentOS |
| imageSKU | "12.04.5-LTS" (default) or 6.5 |
| publicIPType  | Public IP Type : Dynamic or Static|
| vmSizeDataDisks  |  Data disks size : By default 4 data disks will be created |
| linuxFileSystem | ext4 or xfs |
| vmSize |VMs size, minimun size support Standard_D2 |
| serversRole | Servers role, for instance webtier, database.A tag will be created with the provided value. |
| serversPurpose | Purpose of the server, for instance DEV, TEST, INT , PRO.A tag () will be created with the provided value . |
| numberOfVms | Number of VMS |
| adminUserName | Admin User Name |
| adminPassword | Admin Password |
| sshKeyData | SSH Key data |
| customScriptConfigStorageAccountName |  Storage account name for the Private account that will contain your SSH Keys for ansible and the bash scripts ( Only use a Private storage account, as ssh keys should only be accesible by trusted users) |
| customScriptConfigStorageAccountKey | Storage account Key  |
| dnsNameLabel | DNS Name that wil be associated to the Load balancer|


##Known Issues and Limitations
- Fixed number of data disks : This is due to a current template  limitation, this template creates 4 data disks with ReadOnly Caching.
- The Ansible Controller VM is configured as a reverse proxy for the Couchbase Admin Console,that it is exposed over https using the port 16195 and.Also, only the Ansible Controller is available for SSH using the port 6400.
- Current version uses self-signed certificates for the Couchbase Web Admin console, for production environments you should replace the self-signed certificates by your own certificates.
- Scripts are not yet idempotent and cannot handle updates (This currently works for create ONLY)
