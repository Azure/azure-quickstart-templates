# Deploy Moodle on Ubuntu as a cluster consisting of one or more frontend VM's and a single database backend VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvinhub%2Fazure-quickstart-templates%2Fmaster%2Fmoodle-cluster-ubuntu%2FFazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template deploys Moodle as a LAMP application on Ubuntu. It creates a one or more Ubuntu VM for the front end and a single VM for the backend. It does a silent install of Apache and PHP on the front end VM's and MySQL on the backend VM. Then it deploys Moodle on the cluster. It configures a load balancer for directing requests to the front end VM's. It also configures NAT rules to allow admin access to each of the VM's. It also sets up a moodledata data directory using file storage shared among the VM's. After the deployment is successful, you can go to /moodle on each frontend VM (using admin access) to start congfiguting Moodle.

Load Balancer:
template opens frontend "http" port 8080 to 8084 for VM-0 to VM-4 which mapped to 8080 http port on respective VM.
It opens frontend "SSH Remote Login Protocol" port 2200 to 2204 for VM-0 to VM-4 which mapped to 22 "SSH Remote Login Protocol" port on respective VM.

Share Data Directory:
Moodle requires a directory (/var/www/moodledata) to store all of its files (all your site's uploaded files, temporary data, cache, session data etc). The web server needs to be able to write to this directory.
Template create 'file share' in azure cloud and mounted on '/var/www/moodledata' for each VM, so that "/var/www/moodledata" directory get shared on each VM.
 
Note:
While installation of moodle, Default data directory path is "/var/www/moodledata", you don't have to change it because 'file share' in azure cloud only mounted on "/var/www/moodledata".. 
