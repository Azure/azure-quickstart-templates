# OpenScholar Installation on Azure
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FOpenScholar%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2FOpenScholar%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## OpenScholar template 

This template deploys a OpenScholar to the ubuntu VM 16.04
* Deploys on a Ubuntu VM 16.04
* The template installs Drupal and MySQL


### Deployment steps

You can click the "deploy to Azure" button at the beginning of this document.

### Parameters to provide while deploying

+ **adminVMUsername**: Provide admin VM username
+ **adminVMPassword**: Provide admin VM password
+ **databaseName**: Provide database name for openscholar
+ **mysqlPassword**: Provide SMTP email for mail configuration

### Configuration of Openscholar 

* Once the script is run, we need to install the drupal from the domain we have created.
* Access the domain that is created.
* It will redirect you to domainname.com/install.php link
* It checks if the requirements are met, if yes it takes to database configuration
* Provide the database name which you have send as second parameter, mysql user is "root" and password the one you have send as first parameter.
* Go to the next step of configuring site, where you provide the site information, Name of the site, admin username and password
* Next option is to choose an environment. There are two environments production deployment and development. Choose Production deployment
* Next is Installation type - Please choose multi-tenant install. It will install the supplement modules which are required
* Once it is done, we can visit the admin section also the front end section.
* To change the admin theme, please go to domainname.com/admin/appearance and you can change the administration theme.

### How to access the OpenScholar Site
* You can access the site using the domain/host name you provide as the paramater while deploying the template. 
