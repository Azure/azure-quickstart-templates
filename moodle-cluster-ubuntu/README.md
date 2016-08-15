# Deploy Moodle Cluster on Ubuntu

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmoodle-cluster-ubuntu%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fmoodle-cluster-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys Moodle as a LAMP application on Ubuntu in a clustered configuration. It creates a one or more Ubuntu VM for the front end and a single VM for the backend. It does a silent install of Apache and PHP on the front end VM's and MySQL on the backend VM. Then it deploys Moodle on the cluster. It configures a load balancer for directing requests to the front end VM's. It also configures NAT rules to allow admin access to each of the VM's. It also sets up a moodledata data directory using file storage shared among the VM's. It then installs the selected version of Moodle on all the front end VM's. If specified, it also installs the corresponding version of the  Microsoft Office 365 plugins for Moodle. After the deployment is successful, you can go to /moodle to start configuring Moodle.

# Notes

## Front End VM's:
This template can instantiate up to 5 front end VM's. This number can be increased easily by copying and pasting the related parts of the template. 

## Port Details:
The template opens HTTP port 80 for normal end user access on all the front end VM's. This port is then load-balanced using the load balancer.
It also opens ports 8080 to 8084 on the load balancer which are mapped to the port 8080 on each of the front end VM's respectively. These can be used for web admin access to individual front end VM's.
Similarly it opens ports 2200 to 2204 on the load balancer which are mapped to port 22 for SSH admin access on the respective VM's.

## Shared "moodledata" Directory:
In the clustered configuration, Moodle requires a shared directory (/var/www/moodledata) to store files such as all your site's uploaded files, temporary data, cache, session data etc. The template creates a file share in Azure for this purpose and mounts it on each of the front end VM's and maps it to '/var/www/moodledata' for each VM.
