# Deploy OpenSIS Community Edition on Ubuntu as a cluster consisting of one or more frontend VM's and a single database backend VM.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvinhub%2Fazure-quickstart-templates%2Fmaster%2Fopensis-cluster-ubuntu%2FFazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

This template deploys OpenSIS Community Edition as a LAMP application on Ubuntu. It creates a one or more Ubuntu VM for the front end and a single VM for the backend. It does a silent install of Apache and PHP on the front end VM's and MySQL on the backend VM. Then it deploys OpenSIS Community Edition on the cluster.  After the deployment is successful, you can go to /opensis-ce to start congfiguting OpenSIS.
 
Load Balancer:
Template opens frontend 'http' port 8080 to 8084 for VM-0 to VM-4 which mapped to 8080 http port on respective VM.
It opens frontend "SSH Remote Login Protocol" port 2200 to 2204 for VM-0 to VM-4 which mapped to 22 'SSH Remote Login Protocol' port on respective VM.

Issue: 
Opensis installer has problem that there is no any way to tell it to simply reuse the existing database. So while installation of Opensis on different VM, if we targeted backend VM for mysql, everytime it force us to create new database or remove all data of existing database.
