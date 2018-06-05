# OpenCanvas Installation on Windows Azure
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fgopikap%2Fazure-quickstart-templates%2Fmaster%2FOpenCanvas-LMS%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fgopikap%2Fazure-quickstart-templates%2Fmaster%2FOpenCanvas-LMS%2FLinuxVirtualMachine.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# OpenCanvas template 

This template deploys a OpenCanvas to the ubuntu VM 16.04
* Deploys on a Ubuntu VM 16.04
* The template installs postgres9.5 version and a new database is created


### How to Deploy
You can deploy the template with Azure Portal, or PowerShell, or Azure cross platform command line tools.

### Parameters to provide while deploying
* You need to provide admin username and password for the OpenCanvas admin.
* You need to provide the password for the postgres user.
* The domainname have to be provided while deploying
* The email to use for mail services(smtp services)

### Configure smtp settings in outgoing_mail.yml file

We need to configure our smtp settings in outgoing_mail.yml file

* ssh to the canvas server through GIT bash with the hostname  and credentials that are provided while deployment.
for eg: ssh username@domainname.
* Edit the outgoing_mail.yml file in config folder with your smtp server settings.
* loc: /var/canvas/config/outgoing_mail.yml

development:
  address: "smtp.example.com"
  port: "25"
  user_name: "user"
  password: "password"
  authentication: "plain" # plain, login, or cram_md5
  domain: "example.com"
  outgoing_address: "canvas@example.com"
  default_name: "Instructure Canvas"
  
production:
  address: "smtp.example.com"
  port: "25"
  user_name: "user"
  password: "password"
  authentication: "plain" # plain, login, or cram_md5
  domain: "example.com"
  outgoing_address: "canvas@example.com"
  default_name: "Instructure Canvas"

### How to access the OpenCanvas Site
* You can access the site using the domain/host name you provide as the paramater while deploying the template. 

