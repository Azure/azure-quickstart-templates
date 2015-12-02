# Container Service with a Swarm Orchestrator

This Microsoft Azure template creates a container service with a Docker Swarm orchestrator.

Portal Launch Button|Container Service Type
--- | --- | ---
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-swarm-full-template%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>|Swarm

**Installation Note: You will need to provide an SSH RSA public key.  Follow instructions to generate SSH RSA keys in section [SSH Key Generation](#ssh-key-generation)**

# Swarm Container Service Walkthrough

 Once your container service has been created you will have a resource group containing 2 parts:

1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master.

The following image is an example of a container service with 3 masters, and 3 agents:

 ![Image of Swarm container service on azure](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/swarm.png)

 All VMs are on the same private subnet, 10.0.0.0/18, and fully accessible to each other.

## Explore Swarm with Simple hello world
 1. After successfully deploying the template write down the two output master and agent FQDNs (Fully Qualified Domain Name).
  1. If using Powershell or CLI, the output parameters are the last values printed.
  2. If using Portal, to get the output you need to:
    1. navigate to "resource group"
    2. click on the resource group you just created
    3. then click on "Succeeded" under *last deployment*
    4. then click on the "Microsoft.Template"
    5. now you can copy the output FQDNs and sample SSH commands
    ![Image of docker scaling](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/findingoutputs.png)
 2. SSH to port 2200 of the master FQDN
 3. Type `docker -H 10.0.0.5:2375 info` to see the status of the agent nodes.
 ![Image of docker info](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/dockerinfo.png)
 4. Type `docker -H 10.0.0.5:2375 run hello-world` to see the hello-world test app run on one of the agents

## Explore Swarm with a web-based Compose Script, then scale the script to all agents
1. create the following docker-compose.yml file:
```
echo """web:
  image: \"yeasy/simple-web\"
  ports:
    - \"80:80\"
  restart: \"always\" """ > docker-compose.yml
```
2. type `export DOCKER_HOST=10.0.0.5:2375` so that docker-compose automatically hits the swarm endpoints
3. type `docker-compose up -d` to create the simple web server.  This will take a few minutes to pull the image
4. once completed, type `docker ps` to see the running image.
 ![Image of docker ps](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/dockerps.png)
5. in your web browser hit the AGENTFQDN endpoint (**not the master FQDN**) you recorded in [step #1](#explore-swarm-with-simple-hello-world)  and you should see the following page, with a counter that increases on each refresh.
 ![Image of the web page](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/swarmbrowser.png)
6. You can now scale the web application.  For example, if you have 3 agents, you can type `docker-compose scale web=**3**`, and this will scale to the rest of your agents.  Note that you can only scale up to the number of agents that you have, so if you deployed a single agent, you won't be able to scale up.  The Azure load balancer will automatically pick up the new containers.
 ![Image of docker scaling](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-swarm-full-template/images/dockercomposescale.png)

# Sample Workloads

Try the following workloads to test your new Swarm container service.  Run these on Marathon using the examples above

1. **Folding@Home** - [docker run rgardler/fah](https://hub.docker.com/r/rgardler/fah/) - Folding@Home is searching for a cure for Cancer, Alzheimers, Parkinsons and other such diseases. Donate some compute time to this fantastic effort.

2. **Mount Azure Files volume within Docker Container** - [docker run --privileged anhowe/azure-file-workload STORAGEACCOUNTNAME STORAGEACCOUNTKEY SHARENAME](https://github.com/anhowe/azure-file-workload) - From each container mount your Azure storage by using Azure files

# SSH Key Generation

When creating container services, you will need an SSH RSA key for access.  Use the following articles to create your SSH RSA Key:

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac
