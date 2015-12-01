# Container Service with a Swarm Orchestrator

This Microsoft Azure template creates a container service with a Docker Swarm orchestrator.

Portal Launch Button|Container Service Type
--- | --- | ---
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-swarm-full-template%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>|Swarm

# Swarm Container Service Walkthrough

 Once your container service has been created you will have a resource group containing 2 parts:

1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master.

The following image is an example of a container service with 3 masters, and 3 agents:

 ![Image of Swarm container service on azure](https://raw.githubusercontent.com/anhowe/scratch/master/mesos-marathon/images/swarm.png)

 All VMs are on the same private subnet, 10.0.0.0/18, and fully accessible to each other.

## Explore Swarm with Simple hello world
 1. After successfully deploying the template write down the two output master and agent FQDNs.
 2. SSH to port 2200 of the master FQDN
 3. Type `docker -H 10.0.0.5:2375 info` to see the status of the agent nodes.
 ![Image of docker info](https://raw.githubusercontent.com/anhowe/scratch/master/mesos-marathon/images/dockerinfo.png)
 4. Type `docker -H 10.0.0.5:2375 run hello-world` to see the hello-world test app run on one of the agents

## Explore Swarm with a web-based Compose Script, then scale the script to all agents
 1. create the following docker-compose.yml file with the following content:
```
web:
  image: "yeasy/simple-web"
  ports:
    - "80:80"
  restart: "always"
```
 3.  type `export DOCKER_HOST=10.0.0.5:2375` so that docker-compose automatically hits the swarm endpoints
 4. type `docker-compose up -d` to create the simple web server.  This will take a few minutes to pull the image
 5. once completed, type `docker ps` to see the running image.
 ![Image of docker ps](https://raw.githubusercontent.com/anhowe/scratch/master/mesos-marathon/images/dockerps.png)
 6. in your web browser hit the agent FQDN endpoint you recorded in step #1 and you should see the following page, with a counter that increases on each refresh.
 ![Image of the web page](https://raw.githubusercontent.com/anhowe/scratch/master/mesos-marathon/images/swarmbrowser.png)
 7. You can now scale the web application by typing `docker-compose scale web=3`, and this will scale to the rest of your agents.  The Azure load balancer will automatically pick up the new containers.
 ![Image of docker scaling](https://raw.githubusercontent.com/anhowe/scratch/master/mesos-marathon/images/dockercomposescale.png)

# Sample Workloads

Try the following workloads to test your new Swarm container service.  Run these on Marathon using the examples above

1. **Folding@Home** - [docker run rgardler/fah](https://hub.docker.com/r/rgardler/fah/) - Folding@Home is searching for a cure for Cancer, Alzheimers, Parkinsons and other such diseases. Donate some compute time to this fantastic effort.

2. **Mount Azure Files volume within Docker Container** - [docker run --privileged anhowe/azure-file-workload STORAGEACCOUNTNAME STORAGEACCOUNTKEY SHARENAME](https://github.com/anhowe/azure-file-workload) - From each container mount your Azure storage by using Azure files
