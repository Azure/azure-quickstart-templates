# Install Splunk Enterprise on Ubuntu VM using custom Script Linux Extension

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsplunk-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template deploys Splunk Enterprise on Azure as either **standalone** instance or a 5-node **cluster**. Each instance has eight (8) 1-TB data drives in RAID0 configuration. The template also provisions a storage account, a virtual network with subnets, public IP address, and all network interfaces & security groups required.

Once the deployment is complete, Splunk Enterprise can be accessed using the configured DNS address. The DNS address will include the `domainNamePrefix` and `location` entered as parameters in the format `{domainNamePrefix}.{location}.cloudapp.azure.com`. If you created a deployment with `domainNamePrefix` parameter set to "splunk" in the West US region, then Splunk Enterprise can be accessed at `https://splunk.westus.cloudapp.azure.com`.

NOTE:
* This solution uses Splunk's default certificates to enable HTTPS which will create a browser warning. Please follow instructions in Splunk Docs to secure Splunk Web [with your own SSL certificates](http://docs.splunk.com/Documentation/Splunk/latest/Security/SecureSplunkWebusingasignedcertificate).

* This solution uses Splunk's 60-day Enterprise Trial license which includes only 500 MB of indexing per day. If you need to extend your license, or need more volume per day, [contact Splunk sales team online](http://www.splunk.com/index.php/ask_expert/2468/3117) or at sales@splunk.com or call +1.866.GET.SPLUNK (866.438.7758). Once you acquire a license, please follow instructions in Splunk Docs to [install the license](http://docs.splunk.com/Documentation/Splunk/latest/Admin/Installalicense) in the standalone Splunk instance, or, in case of a cluster deployment, [configure a central license master](http://docs.splunk.com/Documentation/Splunk/latest/Admin/Configurealicensemaster) to which the cluster peer nodes can be added as license slaves.

* The cluster version of this solution will mostly likely need more than 20 cores which will require an increase in your default Azure core quota for ARM. Please contact Microsoft support to increase your quota.

### Standalone Mode:
The instance has the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP
* 9997 for TCP receiver traffic
* 8089 for Splunkd Management open to VNet only

### Cluster Mode:
Cluster search head & cluster master have the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP
* 8089 for Splunkd Management open to VNet only

Cluster peer nodes have the following ports open:
* 22 for SSH
* 443 and 8000 for HTTPS & HTTP
* 9997 for TCP receiver traffic
* 9887 for TCP replication traffic open to VNet only
* 8089 for Splunkd Management open to VNet only

##Known issues and limitations
- The template sets up SSH access via admin username/password, and would ideally use an SSH key.
- The template opens SSH port to the public. You can restrict it to a virtual network and/or a bastion host only.

##Third-party software credits
- VM utility shell script: MIT license
- [Opscode Chef Splunk Cookbook](https://github.com/rarsan/chef-splunk): Apache 2.0 license
