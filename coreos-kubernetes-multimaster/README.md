# High available Kubernetes cluster
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-kubernetes-multimaster%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fcoreos-kubernetes-multimaster%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This Microsoft Azure template creates Kubernetes cluster running on top of CoreOS. 
***
## Prerequisites
Before starting with cluster deployment you need to have valid Azure service principal. You can find more info on how to create it [here](https://azure.microsoft.com/en-us/documentation/articles/resource-group-create-service-principal-portal/)

Following information is required by kubernetes Azure cloud provider:
* `tenantID` - AAD organization identifier
* `aadClientId` - AAD client identifier
* `aadClientSecret` - service principal secret

## Deploy cluster from Azure Portal
From the root of this folder click on `Deploy to Azure` button, fill the required parameters and then click on `Purchase`. It usually takes not less than 5 minutes (depends on your cluster size) to finish the deployment.

## Deploy cluster using Azure xplat-cli
* Clone this repository to your local disk
* cd to `coreos-kubernetes-multimaster` directory
```
cd azure-quickstart-templates/coreos-kubernetes-multimaster/
```
* Adjust values in `azuredeploy.parameters.json` file
* Create new resource group
```
azure group create rg-us1-lab1-kube1 'East US'
```
* Create new deployment
```
azure group deployment create -e ./azuredeploy.parameters.json -f ./azuredeploy.json rg-us1-lab1-kube1 rg-us1-lab1-kub1-deployment
```
## Setting up kubectl
* Deployment will generate configuration file for kubectl in home directory of admin user on each master node. You can copy this file using `scp` command that will be shown as an output of deployment, copy/paste this command to your local terminal session. This will download kubeconfig yaml file to your current directory. 
* Copy this file to `~/.kube/config` or use environment variable `KUBECONFIG=/path/to/kubeconfig.yaml` to point kubectl to your config file.

Example: 
```
scp -P 22000 core@rg-us1-lab1-kube1.eastus.cloudapp.azure.com:~/rg-us1-lab1-kube1-kubeconfig.yaml .
```

### Using Azure Portal
* Select the resource group
* Click on `Deployments`
* Select last successful deployment
* Find `Outputs` section

![alt text](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/coreos-kubernetes-multimaster/images/outputs.png "Outputs")

If everything went well, you will be able to list the cluster nodes
```
kubectl get nodes
NAME             STATUS                     AGE
vm-us1-master0   Ready,SchedulingDisabled   3h
vm-us1-master1   Ready,SchedulingDisabled   3h
vm-us1-master2   Ready,SchedulingDisabled   3h
vm-us1-worker0   Ready                      3h
vm-us1-worker1   Ready                      3h
vm-us1-worker2   Ready                      3h
```
## Components
### Etcd cluster
Etcd is used as Kubernetes’ backing store. All cluster data is stored here. Proper administration of a Kubernetes cluster includes a backup plan for etcd’s data. You can customize cluster size by setting `etcdNumberOfNodes` template parameter. Allowed values are: 
* `1` - Should be used for testing purposes only as it doesn't provide cluster high availability.
* `3` - High available etcd cluster with maximum of 1 node fault tolerance.
* `5` - High available etcd cluster with maximum of 3 nodes fault tolerance

   __*Default value: `3`*__

Etcd cluster will be deployed in separate availability set which makes nodes to be spread across multiple update/fault domains to reduce the risk of loosing cluster consistency. More info about Azure availability sets is [here](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-manage-availability/)

Depends on size of your kubernetes cluster and workload you might want to use different vm sizes for etcd nodes. This can be configured by `etcdVmSize` parameter.  Allowed values are:
* `Standard_D1_v2` - 1 CPU, 3.5Gb of RAM
* `Standard_D2_v2` - 2 CPU, 7Gb of RAM
* `Standard_D3_v2` - 4 CPU, 14Gb of RAM
* `Standard_D4_v2` - 8 CPU, 28Gb of RAM

   __*Default value: `Standard_D2_v2`*__

* `etcdSubnetPrefix` - - subnet within cluster VNET range where etcd nodes NIC's are created

   __*Default value: `10.0.0.0/24`*__     

### Kubernetes masters
Master components are those that provide the cluster’s control plane. For example, master components are responsible for making global decisions about the cluster (e.g., scheduling), and detecting and responding to cluster events (e.g., starting up a new pod when a replication controller’s ‘replicas’ field is unsatisfied). In current implementation all master components running in HA mode on multiple nodes as [static pods](http://kubernetes.io/docs/admin/static-pods/). Master kubelet daemon makes sure that proper amount of pods running on every master node and if some of them failing it restarts a corresponding container. Master kubelet itself monitored by systemd daemon. Scheduling of user defined pods is disabled for master nodes.

Following parameters can be used for customizing master nodes:
* `masterNumberOfNodes` - How many master nodes to create. Allowed values are: `1`, `3` or `5` 

   __*Default value: `3`*__
* `masterVmSize` -  Size of master node. Allowed values are:
    * `Standard_D1_v2` - 1 CPU, 3.5Gb of RAM
    * `Standard_D2_v2` - 2 CPU, 7Gb of RAM
    * `Standard_D3_v2` - 4 CPU, 14Gb of RAM
    * `Standard_D4_v2` - 8 CPU, 28Gb of RAM
    
       __*Default value: `Standard_D2_v2`*__  
* `masterSubnetPrefix` - subnet within cluster VNET range where masters NIC's are created

   __*Default value: `10.1.0.0/24`*__

### Kubernetes workers
Each worker node runs kubelet and kube-proxy containers. The kubelet is the primary “node agent” it responsible for creating and destroying pods on local node. Kube-proxy is network proxy and routing daemon.

Following parameter can be used for customizing worker nodes:
* `workerNumberOfNodes` - Number of worker nodes in cluster.

   __*Minimum - 1*__

   __*Maximum - 100*__
* `workerVmSize` - size of the worker node. Allowed values are:
    * `Standard_D1_v2` - 1 CPU, 3.5Gb of RAM
    * `Standard_D2_v2` - 2 CPU, 7Gb of RAM
    * `Standard_D3_v2` - 4 CPU, 14Gb of RAM
    * `Standard_D4_v2` - 8 CPU, 28Gb of RAM
    * `Standard_D5_v2` - 16 CPU, 56Gb of RAM
    * `Standard_D11_v2` - 2 CPU, 14Gb of RAM
    * `Standard_D12_v2` - 4 CPU, 28Gb of RAM
    * `Standard_D13_v2` - 8 CPU, 56Gb of RAM
    * `Standard_D14_v2` - 16 CPU, 112Gb of RAM
    * `Standard_D15_v2` - 20 CPU, 140Gb of RAM
    * `Standard_DS1_v2` - 1 CPU, 3.5Gb of RAM, premium storage
    * `Standard_DS2_v2` - 2 CPU, 7Gb of RAM, premium storage
    * `Standard_DS3_v2` - 4 CPU, 14Gb of RAM, premium storage
    * `Standard_DS4_v2` - 8 CPU, 28Gb of RAM, premium storage
    * `Standard_DS5_v2` - 16 CPU, 56Gb of RAM, premium storage
    * `Standard_DS11_v2` - 2 CPU, 28Gb of RAM, premium storage
    * `Standard_DS12_v2` - 4 CPU, 56Gb of RAM, premium storage
    * `Standard_DS13_v2` - 8 CPU, 112Gb of RAM, premium storage
    * `Standard_DS14_v2` - 16 CPU, 224Gb of RAM, premium storage
    * `Standard_DS15_v2` - 20 CPU, 280Gb of RAM, premium storage
    
    __*Default value: `Standard_D2_v2`*__
* `workerSubnetPrefix` - subnet within cluster VNET range where masters NIC's are created

    ___*Default value: `10.254.0.0/16`*___

## Additional parameters
* `vnetAddressPrefix` - Cluster VNET network range

   ___*Default value: `10.0.0.0/8`*___
* `adminUsername` - VM administrator user name

    ___*Default value: `core`*___
* `hyperkubeVersion` - kubernetes version. **Versions prior to 1.4 are not supported**

   ___*Default value: `v1.4.4`*___
* `imageSku` - CoreOS distribution channel. Allowed values:
    * `Stable` - Stable channel        
    * `Beta` - Beta channel
    * `Alpha` - Alpha channel
    
    ___*Default value: `Stable`*___
* `sshKeyData` - admin user ssh public key 

## Known issues and limitations
* Due to ARM language specific only predefined set of etcd and master hosts can be created.
* Due to availability set [limitations](https://azure.microsoft.com/en-us/documentation/articles/azure-subscription-service-limits/) it's possible to create up to 100 VM's per cluster. Please consider to use bigger VM's or adjust the template to create multiple worker pools spread across different availability sets.
* Azure cloud provider for Kubernetes currently doesn't support Azure scaling sets. Therefore autoscaling the cluster nodes is not possible yet. If you want to scale the cluster, just increase `workerNumberOfNodes` parameter and redeploy the template.

## TODO
* Add support for multiple pools
 
## Credits
* @colemickens - For the great kubernetes Azure provider
* @edevil - For his help with resolving the networking issues
* @kelseyhightower - For the great [kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way) repo
* @cosmincojocar - For the inspiration and believe in success :)

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
