<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-drupal8-vmss-glusterfs-mysql%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F301-drupal8-vmss-glusterfs-mysql%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Drupal 8 VM scaleset (with GlusterFS and MySQL) Template

This template deploys a Drupal 8 installation using a VM scale set.  It has the following capabilities:

- Maximum and minimum number of Drupal 8 VMs in the scaleset can be configured. each of these uses Ubuntu OS
- The template also deploys a Gluster cluster, where the number of nodes is configurable. The OS used by the Gluster VMs is also ubuntu. The Drupal nodes mount the gluster volume, where the settings file and files folder are stored
- The Template can be configured to use an existing MySQL server, or create a New MySQL server (using the MySQL Replication Template)
- Deploys a load balancer in front of the Drupal VM Scaleset, so that the VMs are not directly exposed to the internet.  SSH ports on the VMs are exposed through the load balancer (Natted ports)

### How to Deploy
You can deploy the template with Azure Portal, or PowerShell, or Azure cross platform command line tools.
You can either deploy using an existing MySQL server, or by creating mysql server using the template  
* **Deployment using existing MySQL Server**
  
  ![Deployment Overview - Existing MySQL Server](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/301-drupal8-vmss-glusterfs-mysql/images/Drupal%208%20ARM%20template%20overview.jpg "Deployment Overview - Existing MySQL Server")
  
  For details of Parameter configurations when using existing MySQL server please refer https://blogs.msdn.microsoft.com/manibindra/2016/05/23/how-to-configure-your-drupal-8-arm-template-deployment-to-azure-using-existing-mysql-server/ 

* **Deployment creating a new MySQL Server**

  ![Deployment Overview - New MySQL Server](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/301-drupal8-vmss-glusterfs-mysql/images/Deployment%20with%20new%20mysql%20server.jpg "Deployment Overview - New MySQL Server")
  
  For details of Parameter configurations when creating new MySQL servers, and information on managing the newly created MySql Servers (Master and Slave)  please refer https://blogs.msdn.microsoft.com/manibindra/2016/05/30/how-to-configure-your-drupal-8-arm-template-deployment-to-azure-creating-new-mysql-servers/

### How to access the Drupal Site
* Access Drupal using the VMSS load balancer fully qualified domain name.  This will bring up the Drupal home page.  The Drupal admin user name and password which were entered during the template deployment can be used for logging in as administrator.
 ![How to Access Drupal site](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/301-drupal8-vmss-glusterfs-mysql/images/AccessingDrupalSite.jpg "Access Drupal Site")

### How to SSH into the Drupal VMs
* You can ssh into the VMs in the VM scaleset if needed, using the inbound NAT Pool ports on the load balancer. So for VM 0 ssh in to port 50000, for VM 1 ssh to port 50001 and so on. You can use https://resources.azure.com/ to see the VMs in the VM scale set. See Screen shot below:

 ![SSH into Drupal VMs](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/301-drupal8-vmss-glusterfs-mysql/images/azureResourceExplorer.png "SSH into Drupal VMs")

### Backlog of Planned Changes
* Updrade to PHP7 
* Install Drupal Console 
* Optionally supply new relic key as parameter, to send VM metrics to new relic
* Optionally adding nginx and memcache into the mix

License
----

MIT

