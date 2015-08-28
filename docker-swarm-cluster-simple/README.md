This is a sample template to create a Docker Swarm cluster on Azure. It uses
Docker Hub as a discovery service and requires token (cluster id) as a parameter.

User needs to create a discovery token id using command:

    docker run --rm swarm create

before the template deployment. **The Swarm cluster created is not secure**, use
this template only to create a test cluster. It is not recommended for the
production.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-swarm-cluster-simple%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your Swarm has been created you will have a resource group containing three
VMs acting as nodes and a fourth which is your Swarm master. To connect to this
cluster with Docker, you need to set your environment variables:

```sh
export DOCKER_HOST="tcp://YOURDNSNAMEmmaster.westus.cloudapp.azure.com:2376"
docker ps
```

You need to replace 'YOURDNSNAME' with the DNS name you provide in the parameters.
