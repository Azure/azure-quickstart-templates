# Simple deployment of an Ubuntu VM with Docker

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FDrewm3%2Fazure-quickstart-templates%2Fmaster%2Fdocker-simple-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Built by: [coreysa](https://github.com/coreysa)

This template allows you to deploy an Ubuntu VM with Docker (using the Docker extension) and three Docker containers pulled directly from DockerHub and deployed using Docker Compose.

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| location | The location where the Virtual Machine will be deployed |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |
| ubuntuOSVersion  | The Ubuntu version for deploying the Docker containers. This will pick a fully patched image of this given Ubuntu version. Allowed values: 14.04.2-LTS, 14.04-DAILY, 15.04, 14.10. |
| dockerHubImage1  | The name of the first DockerHub image to pass through to Docker compose on the VM. |
| dockerHubImage2  | The second DockerHub image. |
| dockerHubImage3  | The third DockerHub image. |