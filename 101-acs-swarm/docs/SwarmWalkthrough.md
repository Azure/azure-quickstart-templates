# Docker Swarm Container Service Walkthrough

This walkthrough assumes you have deployed an ACS cluster with a Docker Swarm orchestrator using the template from [101-acs-swarm](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-swarm). For more detailed documentation see the [Azure Container Service Documentation](https://azure.microsoft.com/en-us/documentation/articles/container-service-intro/).

Once your container service has been created you will have a resource group containing 2 parts:

1. a set of 1,3, or 5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents in a VM scale set (VMSS).  The agent VMs can be accessed through a master.  See [agent forwarding](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#key-management-and-agent-forwarding-with-windows-pageant) for an example of how to do this.

The following image shows the architecture of a container service cluster with 3 masters, and 3 agents:

 ![Image of Swarm container service on azure](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-swarm/images/swarm.png)

 All VMs are in the same VNET where the masters are on private subnet 172.16.0.0/24 and the agents are on the private subnet, 10.0.0.0/8, and fully accessible to each other.

## Explore Swarm with Simple hello world
 1. After successfully deploying the template write down the two output master and agent FQDNs (Fully Qualified Domain Name).
  1. If using Powershell or CLI, the output parameters are the last values printed.
  2. If using Portal, to get the output you need to:
    1. navigate to "resource group"
    2. click on the resource group you just created
    3. then click on "Succeeded" under *last deployment*
    4. then click on the "Microsoft.Template"
    5. now you can copy the output FQDNs and sample SSH commands

    ![Image of docker scaling](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/findingoutputs.png)

 3. SSH to port 2200 of the master FQDN. See [agent forwarding](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#key-management-and-agent-forwarding-with-windows-pageant) for an example of how to do this.

 4. Set the DOCKER_HOST environment variable (e.g. ```export DOCKER_HOST=:2375``` on Linux)

 5. Type `docker info` to see the status of the agent nodes.
 ![Image of docker info](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/dockerinfo.png)

 6. Type `docker run -it hello-world` to see the hello-world test app run on one of the agents (the '-it' switches ensure output is displayed on your client)

## Explore Swarm with a web-based Compose Script, then scale the script to all agents
1. create a docker-compose.yml file with the following contents:
```
web:
  image: "yeasy/simple-web"
  ports:
    - "80:80"
  restart: "always"
```

2. type `export DOCKER_HOST=:2375` so that docker-compose automatically hits the swarm endpoints

3. type `docker-compose up -d` to create the simple web server.  This will take a few minutes to pull the image

4. once completed, type `docker ps` to see the running image.

 ![Image of docker ps](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/dockerps.png)

5. in your web browser hit the AGENTFQDN endpoint (**not the master FQDN**) you recorded in [step #1](#explore-swarm-with-simple-hello-world)  and you should see the following page, with a counter that increases on each refresh.

 ![Image of the web page](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/swarmbrowser.png)

6. You can now scale the web application.  For example, if you have 3 agents, you can type `docker-compose scale web=**3**`, and this will scale to the rest of your agents.  Note that in this example you can only scale up to the number of agents that you have since each container requires port 80, so if you deployed a single agent, you won't be able to scale up.  The Azure load balancer will automatically pick up the new containers.

 ![Image of docker scaling](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/dockercomposescale.png)

# Sample Workloads

Try the following workloads to test your new Swarm container service.

1. **Folding@Home** - [docker run rgardler/fah](https://hub.docker.com/r/rgardler/fah/) - Folding@Home is searching for a cure for Cancer, Alzheimers, Parkinsons and other such diseases. Donate some compute time to this fantastic effort.

2. **Mount Azure Files volume within Docker Container** - [docker run --privileged anhowe/azure-file-workload STORAGEACCOUNTNAME STORAGEACCOUNTKEY SHARENAME](https://github.com/anhowe/azure-file-workload) - From each container mount your Azure storage by using Azure files

3. **Explore Docker Hub** - explore Docker Hub for 100,000+ different container workloads: https://hub.docker.com/explore/
