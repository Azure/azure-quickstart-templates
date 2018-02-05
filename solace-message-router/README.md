# Deploy either a standalone Solace Message Router or a three node High Availability cluster of Solace Message Routers onto Azure Linux VM(s).

The Solace Virtual Message Router (VMR) is enterprise-grade messaging middleware that meets the needs of big data, cloud migration, and internet of things initiatives, and enables microservices and event-driven architecture. Capabilities include topic-based publish/subscribe, request/reply, message queues/queueing, and data streaming for IoT devices and mobile/web apps. The VMR supports open APIs and standard protocols including AMQP, JMS, MQTT, REST, and WebSocket. The VMR can be deployed in on-premise datacenters, natively within private and public clouds, and across complex hybrid cloud environments.


How to Deploy a VMR
-------------------

VMRs can either be deployed as a three node HA cluster or a single node. For simple test environments that need to validate application functionality, a single instance will suffice.

![alt text](images/single-vmr.png "Single Node Deployment")

Note that in production or any environment where message loss can not be tolerated, an HA cluster is required.

![alt text](images/ha-cluster.png "HA Cluster Deployment")


This is a two step process:

* Go to the Solace Developer portal and request a Solace Community edition VMR or Evaluation edition VMR. This process will send you an email with a Download link. Right click "Copy Hyperlink" on the "Download the VMR for Docker" hyperlink. This URL will be needed in the following section. The link below will take you to the correct version of the VMR you require depending on whether you want a single instance or an HA Cluster.

| COMMUNITY EDITION FOR SINGLE NODE | EVALUATION EDITION FOR HA CLUSTER
| --- | --- |
<a href="http://dev.solace.com/downloads/download_vmr-ce-docker" target="_blank">
    <img src="images/register.png"/>
</a> 

<a href="http://dev.solace.com/downloads/download-vmr-evaluation-edition-docker/" target="_blank">
    <img src="images/register.png"/>
</a>


* Hit the "Deploy to Azure" button, and in the deployment template add the link to the VMR provided by Solace. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fsolace-message-router%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fsolace-message-router%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

The fields that you need to fill out are:

| Field                      | Value                                                                          |
|----------------------------|--------------------------------------------------------------------------------|
| **BASICS**                 |  |
| Resource Group             | A new group, or an existing group that will be available from the pull-down menu once "Use existing" is selected. |
| Location                   | Select region most suitable to you. |
| **SETTINGS**               |  |
| Storage Account Name       | New or existing storage account, where your VHD will be stored. |
| Admin Username             | Username for the virtual Machine(s). Do not use special characters. |
| Admin Password             | Password for the virtual Machine(s) and for the 'admin' SolOS CLI user. |
| Security Group Name        | New or existing security group, where VMR default ports will be made publicly available. |
| Workspace Name             | New or existing OMS Log Analytics workspace, where logs and diagnostics are monitored. Note that not all regions support workspaces. |
| DNS Label for LB IP        | Used for the public DNS name of the Load Balancer. |
| DNS Label for VM IP        | Used for the public DNS name of each Virtual Machine(s). |
| CentOS Version             | The CentOS version for deploying the Docker containers. Use CentOS 7.2, 7.3, or 7.4. |
| Message Routing VM Size    | The size of the VM for the Solace Message Routing Nodes. Use Standard_D2_v2, Standard_DS2_v2, Standard_D2_v3, or Standard_D2s_v3. Note that not all regions support all these VM sizes. |
| Monitor VM Size            | The size of the VM for the Solace Monitor Node. Use Standard_D2_v2, Standard_DS2_v2, Standard_D2_v3, or Standard_D2s_v3. Note that not all regions support all these VM sizes. |
| Data Disk Size             | The size of the data disk in GB for diagnostics and message spooling on the Solace Message Routing Nodes. Use 0, 20, 40, 80, or 160. |
| Solace VMR URI             | The URI link from the registration email received during Step 1 of the install process. |
| Deployment Model           | High Availability or Single Node. |

After completing the template fields and accepting the legal terms, you need to purchase the deployment. The cost will only be related to the Azure instance and storage costs.

Once the deployment has started, you can view its progress under the Resource Groups tab. Select the resource group you have deployed into, then select the correct deployment across the top. You can then scroll down and see its progress.

In this example, the resource group is `testvmr3` and the `Microsoft.Template` template is in progress. You can see the VMs `SolaceVMR0`, `SolaceVMR1`, and `SolaceVMR2` have started, the Docker Extensions have been installed on each VM, and the VMR configurations are taking place. Once the VMRs are configured, the Primary VMR validates the cluster and signals the deployment as completed. At this point, you can access the VMRs.

![alt text](images/deployment.png "deployment progress")

In addition to the above resources, the deployment creates an Azure Load Balancer that gives you management and data access to the currently AD-Active VMR.

Microsoft OMS (Operations Management Suite) Agents are also installed on each VMR using the OMS Agent Extension. They collect and send logs to a new or existing Azure Log Analytics workspace resource that aggregates logs and diagnostics from each virtual machine in the deployment.


# Gaining admin access to the VMR

If you are used to working with console access to the Solace message router, this is available with the Azure instance. The [connect] button at the upper left of the `SolaceVMR0`, `SolaceVMR1`, or `SolaceVMR2` resource view displays this information:

![alt text](images/remote_access.png "console with SolOS cli")

Use the specified "Admin Username" and "Admin Password" to log in. Once you have access to the base OS command line you can access the SolOS CLI with the following command:

```
sudo docker exec -it solace /usr/sw/loads/currentload/bin/cli -A
```

If you are unfamiliar with the Solace message router, or would prefer an administration application, the SolAdmin management application is available. For more information on SolAdmin see the [SolAdmin page](http://dev.solace.com/tech/soladmin/). To get SolAdmin, visit the Solace [download page](http://dev.solace.com/downloads/) and select the OS version desired. The Management IP would be the external Public IP associated with your Azure instance and the port would be 8080 by default.

![alt text](images/azure-soladmin.png "soladmin connection to gce")

To manage the currently AD-Active VMR, you can open a CLI SSH connection (on port 2222) or connect SolAdmin (on port 8080) to the Public IP Address associated with the Load Balancer as the 'admin' user. From the Resource Group view for your deployment on the Azure Portal, the Load Balancer is the resource named `myLB`, and its Public IP Address is the resource named `myLBPublicIPD`, which has an IP address and a DNS name that you can connect to.


# Testing data access to the VMR

To test data traffic though the newly created VMR instance, visit the Solace developer portal and and select your preferred programming language to [send and receive messages](http://dev.solace.com/get-started/send-receive-messages/). Under each language there is a Publish/Subscribe tutorial that will help you get started.

To connect to the currently AD-Active VMR for messaging, use the Public IP Address associated with the Load Balancer. From the Resource Group view for your deployment on the Azure Portal, the Load Balancer is the resource named `myLB`, and its Public IP Address is the resource named `myLBPublicIPD`, which has an IP address and a DNS name that you can connect to.

![alt text](images/solace_tutorial.png "getting started publish/subscribe")

# Troubleshouting VMR startup

All startup logs are located on the host under this path: `/var/lib/waagent/custom-script/download/0/` and are readable by root only.

Host and Container logs and diagnostics are collected and aggregated in a Azure Log Analytics workspace that can be viewed and analyzed from the Azure Portal. The Log Analytics resource can be found under the Resource Groups tab > your Resource Group or under More services > Intelligence + Analytics. The Container Monitoring Solution and the Log Search solution are installed as part of the deployment. VMR container logs are collected under the `Syslog` Type.

## Contributing

Please read [Contribution guide](https://github.com/Azure/azure-quickstart-templates#contribution-guide) for details on our code of conduct, and the process for submitting pull requests to us.

## License

This project is licensed under the Apache License, Version 2.0. - See the [LICENSE](LICENSE) file for details.

## Resources

For more information about writing Azure Resource Manager(ARM) templates and Azure quickstart templates try these resources:

- [Authoring Azure Resource Manager templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)
- [Azure Quickstart Templates](https://azure.microsoft.com/en-us/resources/templates/)

For more information about Solace technology in general please visit these resources:

- [Solace Developer Portal](http://dev.solace.com)
- [Intro Solace technology](http://dev.solace.com/tech/)
- [Solace community on Stack Overflow](http://dev.solace.com/community/).
