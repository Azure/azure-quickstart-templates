# Deploy Sonarqube on a Linux web app with PostgreSQL

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-linux-sonarqube-postgresql%2Fazuredeploy.json" target="_blank">
  <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-webapp-linux-sonarqube-postgresql%2Fazuredeploy.json" target="_blank">
  <img src="http://armviz.io/visualizebutton.png"/>
</a> 

This template provides a easy way to deploy a Sonarqube docker image (alpine tag) on a Linux Web App with Azure database for PostgreSQL(Preview).

**Notice** once deployed Sonar can take a while to start due the creation of the initial empty database, it can even fail if you try to access it directly, allow to start it before accessing it or even adjust the tier for the webapp or PostgreSQL accordingly.
