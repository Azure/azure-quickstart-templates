<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FmaniSbindra%2Fazure-quickstart-templates%2Fmaster%2F301-drupal-8-multivm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FmaniSbindra%2Fazure-quickstart-templates%2Fmaster%2F301-drupal-8-multivm%2Fazuredeploy.json" target="_blank">
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
* Deployment using existing MySQL Server
** OVerview

* Deployment creating a new MySQL Server

### Drupal
* Access Drupal using the public DNS name.  By default, the drupal admin users name and password are parameters of the template

### How to SSH into the Drupal VMs
* MySQL health can be checked by issuing HTTP query to the MySQL probes and verify that the query returns 200 status code.  Replace the following command with your own dns name and location.
```sh

```


License
----

MIT

