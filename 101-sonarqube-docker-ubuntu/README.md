# SonarQube on Docker

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sonarqube-docker-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-sonarqube-docker-ubuntu%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

`Tags: SonarQube,Docker,Ubuntu`

## Summary

This template deploys a new  [SonarQube](http://www.sonarqube.org/) server. Instead of installing the software manually, it uses [SonarQube's official Docker image](https://hub.docker.com/_/sonarqube/).


## Description

The template creates a new Ubuntu VM including necessary prerequisites (e.g. storage account, NIC, VNet, etc.).

The VM gets a separate data disk that is used to store SonarQube's configuration files. Thus, you can recreate the OS disk without losing your SonarQube configuration files. The templates creates, formats and mounts the data disk using [Microsoft's *vm-disk-utils-0.1.sh*](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/shared_scripts/ubuntu/vm-disk-utils-0.1.sh) script.

The template also creates an [Azure SQL Database Server](https://azure.microsoft.com/en-us/services/sql-database/) with a database. The SonarQube Docker Container (details see below) is configured to use this database.

The template deploys [Docker](https://www.docker.com/) on the new VM using Azure's [Docker Extension](https://github.com/Azure/azure-docker-extension). It makes use of the Docker Extension's support for [Docker Compose](https://docs.docker.com/compose/) to pull the SonarQube image from Docker Hub and start a container for it.

The Network Security Group create in the template opens ports for SSH and SonarQube (9000, 9092).


## Limitation, Possible Extensions

This template should act as a starting point for you to create your own, custom SonarQube infrastructure. It is recommended to consider the following extensions for SonarQube production deployments:

1. Consider [creating a reverse proxy](http://docs.sonarqube.org/display/SONAR/Securing+the+Server+Behind+a+Proxy) for SonarQube. You could use a separate Docker Container (with e.g. *nginx*) for that.

1. Consider creating and deploying a certificate to use *https* for accessing SonarQube.

1. The template does not allow remote Docker access. If you want that, you could open Docker's port in the Network Security Group. In that case, make sure to [properly protect the Docker daemon socket](https://docs.docker.com/engine/security/https/). To enable remote access to Docker in Azure's Docker Extension, you have to make the following changes to the ARM template:
   * Add `"docker": { "port": "2376" }` to the `setting` section.
   * Add `protectedSettings` adjacent to the settings. This section has to contain Docker's CA, server and client keys.
   * Here is a complete example including opened Docker port:

```
{
    "type": "Microsoft.Compute/virtualMachines/extensions",
    "apiVersion": "2015-06-15",
    "name": "...",
    "tags": { ... },
    "location": "...",
    "dependsOn": [ ... ],
    "properties": {
        "publisher": "Microsoft.Azure.Extensions",
        "type": "DockerExtension",
        "typeHandlerVersion": "1.0",
        "autoUpgradeMinorVersion": true,
        "settings": {
            "docker": {
                "port": "2376"
            },
            "compose": { ... },
            ...
        },
        "protectedSettings": {
            "certs": {
                "ca": "[parameters('ca')]",
                "cert": "[parameters('cert')]",
                "key": "[parameters('key')]"
            }
        }
    }
}
```
