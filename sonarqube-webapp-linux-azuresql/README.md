# SonarQube Web App on App Server on Linux + Azure SQL DB

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsonarqube-webapp-linux-azuresql%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsonarqube-webapp-linux-azuresql%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

To deploy this template using the scripts from the root of this repo:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'sonarqube-webapp-linux-azuresql'
```

```bash
azure-group-deploy.sh -a sonarqube-webapp-linux-azuresql -l eastus
```

This template deploys **SonarQube on App Service on Linux with Azure SQL Database**.

`Tags: App Service, Linux, Docker, Container, Azure SQL DB`

## Solution overview and deployed resources

The following resources are deployed as part of the solution.

### Azure App Services

The SonarQube server is hosted as an App Service on Linux.

+ **App Service Plan**: Linux App Service plan. Defaults to a B2.
+ **Web App**: Hosts the offical [`sonarqube`][sonarqube] image from Docker Hub.

### Azure SQL

A Azure SQL DB is used for the Sonar database.

+ **SQL Server**: The Azure SQL Server
+ **SQL DB**: SQL DB named `sonar`. Defaults to the Basic tier.

## Deployment steps

Click the "deploy to Azure" button at the beginning of this document or
follow the instructions for command line deployment using the scripts in the root
of this repo.

## Usage

Once the template has been deployed, connect to the SonarQube server using the
Web App URL.

## Notes

+ The App Service provides an HTTPS reverse proxy. However the App Service will
  not automatically redirect HTTP to HTTPS.
+ Read the SonarQube [Administration guide][admin] which includes instructions on how to
  disable guest access (if required).

## More information

+ [Using a custom Docker image for Azure Web App on Linux](custom-docker)
+ [Azure App Service Web App on Linux FAQ](faq)
+ [SonarQube setup](setup)
+ [SonarQube administration guide](admin)
+ [Official sonarqube on Docker Hub](sonarqube)

[sonarqube]:https://hub.docker.com/_/sonarqube/
[admin]:https://docs.sonarqube.org/display/SONAR/Administration+Guide
[custom-docker]:https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-using-custom-docker-image
[faq]:https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-faq
[setup]:https://docs.sonarqube.org/display/SONAR/Setup+and+Upgrade
