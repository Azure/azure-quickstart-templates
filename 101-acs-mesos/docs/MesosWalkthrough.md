# Mesos Container Service Walkthrough

This walkthrough assumes you have deployed an ACS cluster with a Mesos orchestrator using the template from [101-acs-mesos](https://github.com/Azure/azure-quickstart-templates/tree/master/101-acs-mesos). For more detailed documentation see the [Azure Container Service Documentation](https://azure.microsoft.com/en-us/documentation/articles/container-service-intro/).

Once your container service has been created you will have a resource group containing 3 parts:

1. a set of 1,3, or 5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents in an Virtual Machine Scale Set (VMSS).  The agent VMs can be accessed through a master.  See [agent forwarding](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#key-management-and-agent-forwarding-with-windows-pageant) for an example of how to do this.

The following image shows the architecture of a container service cluster with 3 masters, and 3 agents:

![Image of Mesos container service on azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/mesos.png)

In the image above, you can see the following parts:

1. **Admin Router on port 80** - The admin router enables you to access all mesos services.  For example, if you create an SSH tunnel to port 80 you can access the services on the following urls:
  1. **Mesos** - <http://localhost/mesos/>
  2. **Marathon** - <http://localhost/marathon/>
  3. **Chronos** - <http://localhost/chronos/>
2. **Mesos on port 5050** - Mesos is the distributed systems kernel that abstracts cpu, memory and other resources, and offers these to services named "frameworks" for scheduling of workloads.
3. **Marathon on port 8080** - Marathon is a scheduler for Mesos that is equivalent to init on a single linux machine: it schedules long running tasks for the whole cluster.
4. **Chronos on port 4400** - Chronos is a scheduler for Mesos that is equivalent to cron on a single linux machine: it schedules periodic tasks for the whole cluster.
5. **Docker on port 2375** - The Docker engine runs containerized workloads and each Agent runs the Docker engine.  Mesos runs Docker workloads, and examples on how to do this are provided in the Marathon and Chronos walkthrough sections of this readme.

All VMs are in the same VNET where the masters are on private subnet 172.16.0.0/24 and the agents are on the private subnet, 10.0.0.0/8, and fully accessible to each other.

## Template Parameters
When you deploy the template you will need to specify the following parameters:
* `dnsNamePrefix`: this is the DNS prefix name that will be used to make up the names for the FQDN for the master and agent endpoints.
* `agentCount`: the number of Mesos Agents that you want to create in the container service.  You are allowed to create 1 to 100 agents
* `agentVMSize`: The type of VM that you want to use for each node in the container service. The default size is D2 (2 core) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `linuxAdminUsername`: this is the username to use for the linux machines.  The default username is `azureuser`.
* `masterCount`: Number of Masters. Currently the template supports 3 configurations: 1, 3 and 5 Masters container service configuration.
* `sshRSAPublicKey`: Configure all linux machines with the SSH rsa public key string.  This is required.  Refer to the following section on how to generate your key pair: [SSH Key Generation](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#ssh-key-generation)

## Marathon

This walk through is based the wonderful digital ocean tutorial: https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04

 1. After successfully deploying the template write down the two output master and agent FQDNs (Fully Qualified Domain Name).
   1. If using Powershell or CLI, the output parameters are the last values printed.
   2. If using Portal, to get the output you need to:
     1. navigate to "resource group"
     2. click on the resource group you just created
     3. then click on "Succeeded" under *last deployment*
     4. then click on the "Microsoft.Template"
     5. now you can copy the output FQDNs and sample SSH commands
     ![Image of docker scaling](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-swarm/images/findingoutputs.png)

 2. Create an [SSH tunnel to port 80](https://github.com/Azure/azure-quickstart-templates/blob/master/101-acs-mesos/docs/SSHKeyManagement.md#create-port-80-tunnel-to-the-master) on the master FQDN.

 3. browse to the Mesos UI.  <http://localhost/mesos/>

 4. Browse Mesos:
   1. scroll down the page and notice your resources of CPU and memory.  These are your agents

   ![Image of Mesos container service on azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/mesos-webui.png)

   2. On top of page, click frameworks and notice your Marathon and Chronos frameworks

   ![Image of Mesos frameworks on azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/mesos-frameworks.png)

   3. On top of page, click agents and you can see your agents.  (Note: "Agents" and "Slaves" are synonymous, and as announced in August 2015 at MesosCon, the word "Slave" will be replaced with "Agent")

   ![Image of Mesos agents on azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/mesos-agents.png)

  5. browse and explore Marathon UI <http://localhost/marathon/>.

  6. start a long running job in Marathon
    1. click "Create"
    2. type "myfirstapp" for the id
    3. type `/bin/bash -c "for i in {1..5}; do echo MyFirstApp $i; sleep 1; done"` for the command
    4. scroll to bottom and click create

    ![Image of Marathon new app dialog](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/marathon-newapp.png)

  7. you will notice the new app change state from not running to running

  ![Image of the new application status](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/marathon-newapp-status.png)

  8. browse back to the Mesos master.  You will notice the running tasks and the completed tasks.  Click on the host of the completed tasks and also look at the sandbox.

  ![Image of Mesos completed tasks](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/mesos-completed-tasks.png)

  9. All nodes are running docker, so to run a docker app browse back to Marathon, and create your first docker application by specifying Docker Image `hello-world` and Network `Host`:

  ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/marathon-docker.png)

  10. The agents have a load balancer exposing port 80, 443, and 8080.  From https://portal.azure.com browse to the loadbalancer and grab its FQDN.  Next browse to your Marathon app, and create a new app specifying the fields below:

  ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/marathon-simpleweb.png)

  11. Once deployed you can browse to the FQDN and observe the new content on port 80:

  ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/simpleweb.png)

## Chronos Walkthrough

1. On the Mesos UI, <http://localhost/mesos/>, browse to "Frameworks" and click on the Chronos URI:

 ![Image of Chronos UI](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/chronos-url.png)

2. Click Add and fill in the following details:
 1. Name - "MyFirstApp"
 2. Command - `echo "my first app on Chronos"`
 3. Owner, and Owner Name - you can put random information Here
 4. Schedule - Set to P"T1M" in order to run this every minute

 ![Image of adding a new scheduled operation in Chronos](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/chronos.png)

3. Click Create

4. Watch the task run, and then browse back to the Mesos UI and observe the output in the completed task.

5. All nodes are running docker, so to run a docker app browse back to Chronos, and create an application to run `sudo docker run hello-world`.  Once running browse back to Mesos in a similar fashion to the above instructions to verify that it has run:

 ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-acs-mesos/images/chronos-docker.png)

# Sample Workloads

Try the following workloads by creating Marathon apps to test your new Mesos container service:

1. **Folding@Home** - [docker run rgardler/fah](https://hub.docker.com/r/rgardler/fah/) - Folding@Home is searching for a cure for Cancer, Alzheimers, Parkinsons and other such diseases. Donate some compute time to this fantastic effort.

2. **Mount Azure Files volume within Docker Container** - [docker run --privileged anhowe/azure-file-workload STORAGEACCOUNTNAME STORAGEACCOUNTKEY SHARENAME](https://github.com/anhowe/azure-file-workload) - From each container mount your Azure storage by using Azure files

3. **Explore Docker Hub** - explore Docker Hub for 100,000+ different container workloads: https://hub.docker.com/explore/
