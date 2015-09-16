# Deployment of Neo4J Container with Docker Compose

Built by: [jmspring](https://github.com/jmspring)

This template allows you to deploy an Ubuntu Server 15.04 VM with Docker (using the [Docker Extension][ext])
and starts a Neo4J instance listening on ports 7474 (non-ssl) and 7473 (ssl).  The data disk
for the Neo4J instance is an external disk mounted on the VM.  The container is created 
using the [Docker Compose][compose] capabilities of the [Azure Docker Extension][ext].

Below are the parameters that the template expects:

| Name   | Description    |
|:--- |:---|
| newStorageAccountName  | Unique DNS Name for the Storage Account where the Virtual Machine's disks will be placed. |
| vmName | The name of the VM |
| vmSize | The size of the VM |
| location | The location where the Virtual Machine will be deployed  |
| adminUsername  | Username for the Virtual Machine  |
| adminPassword  | Password for the Virtual Machine  |
| dnsNameForPublicIP  | Unique DNS Name for the Public IP used to access the Virtual Machine. |

[ext]: https://github.com/Azure/azure-docker-extension
[compose]: https://docs.docker.com/compose
