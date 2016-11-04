

# Azure Docker Datacenter

* Azure Docker DataCenter Templates for the to-be GAed Docker DataCenter with  ucp:2.0.0-Beta1 (native Swarm with Raft) and dtr:2.1.0-Beta1 initially based on the "legacy" Docker DataCenter 1.x Azure MarketPlace Gallery Templates (1.0.9). 

* For Raft, please view [Docker Orchestration: Beyond the Basics](http://events.linuxfoundation.org/sites/events/files/slides/Docker_Orchestration-Aaron_Lehmann.pdf) By Aaron Lehmann at the [ContainerCon, Europe](http://events.linuxfoundation.org/events/containercon-europe/program/slides) - Berlin, October 4-9, 2016.

* Please see the [LICENSE file](https://github.com/Azure/azure-quickstart-templates//blob/master/docker-datacenter-2.0/LICENSE) for licensing information. 
 * Docker DataCenter License as used as-is (parameterized or to be uploaded license - lic file) in this project for UCP 2.0.0 Beta1 and DTR 2.1.0 Beta1 can only be obtained presently for the private beta. Please refer to [this post](https://forums.docker.com/t/docker-datacenter-on-engine-1-12-private-beta/23232/1) in the docker forum. Please sign up [here](https://goo.gl/UTG895) for GA Waiting list.

* This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information, see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

* This project is also hosted at: https://github.com/Azure/azure-dockerdatacenter

* **This repo is initially based on the "legacy" [Docker DataCenter 1.x Azure MarketPlace Gallery Templates (1.0.9)](https://gallery.azure.com/artifact/20151001/docker.dockerdatacenterdocker-datacenter.1.0.9/Artifacts/mainTemplate.json)**

* **Uses the new public tar.gz from [here](https://packages.docker.com/caas/ucp-2.0.0-beta1_dtr-2.1.0-beta1.tar.gz) for changes using the Raft Protocol and Auto HA for private beta (to be GAed DDC) and native swarm mode orchestration on MS Azure. DDC Private Beta docs are [here](https://beta.docker.com/docs/ddc)**

* New [Go-based Linux CustomScript Extension being used](https://github.com/Azure/custom-script-extension-linux) 

* Dashboard URL
 * http://{{UCP Controller Nodes LoadBalancer Full DNS IP name}}.{{region of the Resource Group}}.cloudapp.azure.com
   * The Above is the FQDN of the LBR or Public IP for UCP Controller or Managers
 * http://{{DTR worker Nodes LoadBalancer Full DNS IP name}}.{{region of the Resource Group}}.cloudapp.azure.com
   * The Above is the FQDN of the LBR or Public IP for DTR

## Deploy and Visualize
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-datacenter-2.0%2Fazuredeploy.json" target="_blank"><img alt="Deploy to Azure" src="http://azuredeploy.net/deploybutton.png" /></a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fdocker-datacenter-2.0%2Fazuredeploy.json" target="_blank">  <img src="http://armviz.io/visualizebutton.png" /> </a> 

## Topologies

A Minimal Fresh topology with minimum 3 Worker Managers, minimum 2 worker nodes, one DTR with local storage and another as replica would look like the following

![Azure DDC Miminal Topology](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-datacenter-2.0/MinimalFresh.png)

### The Minimal Topology (Minimum 3 Worker Manager Nodes for valid Raft HA and minimum 2 worker nodes with 2 extra for DTR and Replica)
 As from https://resources.azure.com 
 
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-datacenter-2.0/MinimalTopology.png" width="416" height="800" />
 
## Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/Azure/azure-quickstart-templates/issues)

## Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.

## Pre-Req
~~Create a free account for MS Azure Operational Management Suite with workspaceID~~

:heart: ![Azure Subscription Icon](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-datacenter-2.0/Azure.png) :penguin: :whale:


