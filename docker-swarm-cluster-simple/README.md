This is a sample template to create a Docker Swarm cluster on Azure. It uses Docker hub as a discovery service and requires token(cluster id) as a parameter. User needs to create a token id using command 'docker run swarm create' before the template deployment. The Swarm created is not secure, use this template to create a test swarm cluster but it is not recommended for the production.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-swarm-cluster-simple%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Once your Swarm has been created you will have a resource group containing three VMs acting as nodes and a fourth whcih is your swarm master. To connect to this swarm with Docker you need to set your environment with:

```
export DOCKER_TLS_VERIFY=
export DOCKER_HOST="tcp://YOURDNSNAMEmmaster.westus.cloudapp.azure.com:2376"
```

Note this turns off TLS (i.e. it is insecure) - do not use in production. You need to replace 'YOURDNSNAME' with the DNS name you provide in the parameters.
