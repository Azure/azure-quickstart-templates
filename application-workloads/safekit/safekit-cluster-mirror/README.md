# Evidian SafeKit - High Availability Cluster with Synchronous Real-Time Replication and Failover in Azure - Mirror Module

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/safekit/safekit-cluster-mirror/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsafekit%2Fsafekit-cluster-mirror%2Fazuredeploy.json)  
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)]( https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsafekit%2Fsafekit-cluster-mirror%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fsafekit%2Fsafekit-cluster-mirror%2Fazuredeploy.json)

*   [Description](#description)
*   [Deployed resources](#resources)
*   [How to use](#use)
*   [More information](#more)

## <a name="description">Description

![How the Evidian SafeKit mirror cluster implements real-time replication and failover in Azure?](images/mirrorarch.png)

On the previous figure,

*   the critical application is running on the PRIM server
*   users are connected to a primary/secondary virtual IP address which is configured in the Azure load balancer
*   SafeKit brings a generic health probe for the load balancer. On the PRIM server, the health probe returns OK to the load balancer and NOK on the SECOND server.
*   in each server, SafeKit monitors the critical application with process checkers and custom checkers
*   SafeKit restarts automatically the critical application when there is a **software failure** or a **hardware failure** thanks to restart scripts
*   SafeKit makes synchronous real-time replication of files containing critical data
*   a connector for the SafeKit web console is installed in each server. Thus, the high availability cluster can be managed in a very simple way to avoid **human errors**

## <a name="resources">Deployed resources

In term of VMs, this template deploys:

*   2 VMs (Windows or Linux) spanning 2 availability zones
*   each VM has a public IP address
*   the SafeKit free trial is installed in both VMs
*   a SafeKit mirror module is configured in both VMs

In term of load balancer, this template deploys:

*   a public load balancer (standard SKU)
*   a public IP (Standard SKU) is associated with the public load balancer and plays the role of the virtual IP
*   both VMs are in the backend pool of the load balancer
*   a health probe checks the mirror module state on both VMs
*   a load balancing rule for external port 9453 / internal port 9453 is set to test the primary/secondary virtual IP

## <a name="use">How to use

Click the "Deploy to Azure" button at the beginning of this document to deploy the high availability cluster. Please create a new resource group.

After deployment, go to the resource groups's deployment ('Microsoft.Template') output panel and:

*   visit the credential url to install the client and CA certificates in your web browser
*   after certificates installation, start the web console of the cluster
*   test the primary/secondary virtual IP address with the test URL in the output

## <a name="more">More information on **Evidian SafeKit** in Azure

*   [Azure: The Simplest Load Balancing Cluster with Failover](https://www.evidian.com/products/high-availability-software-for-application-clustering/azure-load-balancing-cluster-failover/)
*   [Azure: The Simplest High Availability Cluster with Synchronous Replication and Failover](https://www.evidian.com/products/high-availability-software-for-application-clustering/azure-high-availability-cluster-synchronous-replication-failover/)

`Tags: high availability, cluster, replication, real-time replication, synchronous replication, failover, business continuity, disaster recovery, evidian, safekit, mirror`



