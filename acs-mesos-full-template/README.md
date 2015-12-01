# Clusters with Mesos Orchestrator and Marathon/Chronos Services

These Microsoft Azure templates create various cluster combinations with Mesos Orchestrator and Marathon/Chronos services.

Portal Launch Button|Cluster Type
--- | --- | ---
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-mesos-full-template%2Fazuredeploy.windowsjumpbox.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>|Mesos with windows jumpbox
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-mesos-full-template%2Fazuredeploy.linuxjumpbox.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>|Mesos with linux jumpbox
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Facs-mesos-full-template%2Fazuredeploy.nojumpbox.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>|Mesos with no jumpbox

# Mesos Cluster Walkthrough

Once your cluster has been created you will have a resource group containing 3 parts:

1. a set of 1,3,5 masters in a master specific availability set.  Each master's SSH can be accessed via the public dns address at ports 2200..2204

2. a set of agents behind in an agent specific availability set.  The agent VMs must be accessed through the master, or jumpbox

3. if chosen, a windows or linux jumpbox

The following image is an example of a cluster with 1 jumpbox, 3 masters, and 3 agents:

![Image of Mesos cluster on azure](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/mesos.png)

You can see the following parts:

1. **Mesos on port 5050** - Mesos is the distributed systems kernel that abstracts cpu, memory and other resources, and offers these to services named "frameworks" for scheduling of workloads.
2. **Marathon on port 8080** - Marathon is a scheduler for Mesos that is equivalent to init on a single linux machine: it schedules long running tasks for the whole cluster.
3. **Chronos on port 4400** - Chronos is a scheduler for Mesos that is equivalent to cron on a single linux machine: it schedules periodic tasks for the whole cluster.
4. **Docker on port 2375** - The Docker engine runs containerized workloads and each Master and Agent run the Docker engine.  Mesos runs Docker workloads, and examples on how to do this are provided in the Marathon and Chronos walkthrough sections of this readme.

All VMs are on the same private subnet, 10.0.0.0/18, and fully accessible to each other.

## Installation Notes

Here are notes for troubleshooting:
 * the installation log for the linux jumpbox, masters, and agents are in /var/log/azure/cluster-bootstrap.log
 * even though the agent VMs finish quickly Mesos can take 5-15 minutes to install, check /var/log/azure/cluster-bootstrap.log for the completion status.
 * the linux jumpbox is based on https://github.com/anhowe/ubuntu-devbox and will take 1 hour to configure.  Visit https://github.com/anhowe/ubuntu-devbox to learn how to know when setup is completed, and then how to access the desktop via VNC and an SSH tunnel.

## Template Parameters
When you launch the installation of the cluster, you need to specify the following parameters:
* `adminPassword`: self-explanatory
* `dnsNamePrefix`: this is the DNS prefix name that will be used to make up the names for the FQDN for the jumpbox, master endpoints, and the agent endpoints.
* `agentCount`: the number of Mesos Agents that you want to create in the cluster.  You are allowed to create 1 to 100 agents
* `masterCount`: Number of Masters. Currently the template supports 3 configurations: 1, 3 and 5 Masters cluster configuration.
* `agentVMSize`: The type of VM that you want to use for each node in the cluster. The default size is A1 (1 core) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `sshRSAPublicKey`: Configure all linux machines with the SSH rsa public key string.  Use 'disabled' to not configure access with SSH rsa public key.

## Marathon

This walk through is based the wonderful digital ocean tutorial: https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04

1. Get your endpoints to cluster
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 ![Image of resource groups in portal](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/portal-resourcegroups.png)

 3. then expand your resources, and copy the dns names of your jumpbox (if chosen), and your NAT public ip addresses.

 ![Image of public ip addresses in portal](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/portal-publicipaddresses.png)

2. Connect to your cluster
 1. linux jumpbox - start a VNC to the jumpbox using instructions https://github.com/anhowe/ubuntu-devbox.  The jumpbox takes an hour to configure.  If the desktop is not ready, you can tail /var/log/azure/cluster-bootstrap.log to watach installation.
 2. windows jumpbox - remote desktop to the windows jumpbox
 3. no jumpbox - SSH to port 2200 on your NAT creating a tunnel to port 5050 and port 8080.  Then use the browser of your desktop to browse these ports.

3. browse to the Mesos UI.  Internet Explorer will automatically point to the URL, but if you are on linux, the URL will be the master name, something like http://mesos-master-01234567-0:5050/
 1. linux jumpbox - in top right corner choose Applications->Internet->Chrome and browse to master URL
 2. windows jumpbox - open Internet explore and it will automatically open to the master URL
 3. no jumpbox - ensure you setup the SSH tunnels correctly to 5050, then browse to http://localhost:5050

4. Browse Mesos:
 1. scroll down the page and notice your resources of CPU and memory.  These are your agents

 ![Image of Mesos cluster on azure](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/mesos-webui.png)

 2. On top of page, click frameworks and notice your Marathon and Swarm frameworks

 ![Image of Mesos cluster frameworks on azure](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/mesos-frameworks.png)

 3. On top of page, click agents and you can see your agents.  On windows or linux jumpbox you can also drill down into the slave and see its logs.

 ![Image of Mesos agents on azure](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/mesos-agents.png)

5. browse and explore Marathon UI http://master0:8080 (or if using tunnel http://localhost:8080 )

6. start a long running job in Marathon
 1. click "+New App"
 2. type "myfirstapp" for the id
 3. type `/bin/bash -c "for i in {1..5}; do echo MyFirstApp $i; sleep 1; done` for the command
 4. scroll to bottom and click create

 ![Image of Marathon new app dialog](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/marathon-newapp.png)

7. you will notice the new app change state from not running to running

 ![Image of the new application status](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/marathon-newapp-status.png)

8. browse back to the Mesos master.  You will notice the running tasks and the completed tasks.  Click on the host of the completed tasks and also look at the sandbox.

 ![Image of Mesos completed tasks](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/mesos-completed-tasks.png)

9. All nodes are running docker, so to run a docker app browse back to Marathon, and create your first docker application by specifying Docker Image `hello-world` and Network `Host`:

 ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/marathon-docker.png)

10. The agents have a load balancer exposing port 80, 443, and 8080.  From https://portal.azure.com browse to the loadbalancer and grab its FQDN.  Next browse to your Marathon app, and create a new app specifying the fields below:

![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/marathon-simpleweb.png)

11. Once deployed you can browse to the FQDN and observe the new content on port 80:

![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/simpleweb.png)

## Chronos Walkthrough

**Note: As of Dec 1st, 2015, the Chronos UI does not show jobs in Internet Explorer.  The recommendation is to use Chrome or Firefox to run through the below examples**

1. On the Mesos UI, browse to "Frameworks" and click on the Chronos URI:

 ![Image of Chronos UI](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/chronos-url.png)

2. Click Add and fill in the following details:
 1. Name - "MyFirstApp"
 2. Command - `echo "my first app on Chronos"`
 3. Owner, and Owner Name - you can put random information Here
 4. Schedule - Set to P"T1M" in order to run this every minute

 ![Image of adding a new scheduled operation in Chronos](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/chronos.png)

3. Click Create

4. Watch the task run, and then browse back to the Mesos UI and observe the output in the completed task.

5. All nodes are running docker, so to run a docker app browse back to Chronos, and create an application to run `sudo docker run hello-world`.  Once running browse back to Mesos in a similar fashion to the above instructions to verify that it has run:

 ![Image of setting up docker application in Marathon](https://raw.githubusercontent.com/rgardler/azure-quickstart-templates/acs/acs-mesos-full-template/images/chronos-docker.png)

# Sample Workloads

Try the following workloads by creating Marathon apps to test your new mesos cluster:

1. **Folding@Home** - [docker run rgardler/fah](https://hub.docker.com/r/rgardler/fah/) - Folding@Home is searching for a cure for Cancer, Alzheimers, Parkinsons and other such diseases. Donate some compute time to this fantastic effort.

2. **Mount Azure Files volume within Docker Container** - [docker run --privileged anhowe/azure-file-workload STORAGEACCOUNTNAME STORAGEACCOUNTKEY SHARENAME](https://github.com/anhowe/azure-file-workload) - From each container mount your Azure storage by using Azure files
