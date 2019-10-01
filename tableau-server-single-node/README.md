# Tableau Server Single Node

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/PublicLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/PublicDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/FairfaxLastTestDate.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/FairfaxDeployment.svg" />&nbsp;

<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/BestPracticeResult.svg" />&nbsp;
<IMG SRC="https://azurequickstartsservice.blob.core.windows.net/badges/tableau-server-single-node/CredScanResult.svg" />&nbsp;
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftableau-server-single-node%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Ftableau-server-single-node%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a **Standalone Tableau Server instance on a Virtual Machine running Ubuntu, RHEL or CentOS** in its own Virtual Network.

`Tags: Tableau, Tableau Server, Business Intelligence, Analytics, Self-Service, Data Visualization`

## Overview

This ARM template allows you to quickly and easily deploy a standalone instance of Tableau Server on Azure.  The accompanying deployment guide is intended to provide guidance about the resources & processes involved in an automated deployment as well as providing resources for Tableau Server management.

Tableau Server is an online solution for sharing, distributing, and collaborating on business intelligence content created in Tableau. Tableau Server users can create workbooks and views, dashboards, and data sources in Tableau Desktop, and then publish this content to the server.  Tableau is designed to make connecting live to data of all types a simple process that doesn't require any coding or scripting. From cloud sources like Azure SQL Data Warehouse, to on-premise Hadoop clusters, to local spreadsheets, Tableau gives everyone the power to quickly start visually exploring data of any size to find new insights. 

Tableau Server site and server administrators control who has access to server content to help protect sensitive data. Administrators can set user permissions on projects, workbooks, views, and data sources. Users can see and interact with the most up-to-date server content from anywhere, whether they use a browser or a mobile device. This template is for IT infrastructure architects, administrators, and DevOps professionals who are planning to implement or extend their Tableau Server workloads on the Azure Cloud.

#### Costs & Licenses

You are responsible for the cost of the Azure services used while running this ARM template reference deployment.  There is no additional cost for using the ARM template.  The template allows you to deploy either a 14-day trial of Tableau Server or use a license you have already purchased.

As part of the deployment process you are prompted to accept the Tableau EULA.  Please enter 'Yes' in the respective parameter to indicate you have read and accepted the Tableau EULA which can be found <a href=https://mkt.tableau.com/files/tableau_eula.pdf>here</a>.  If you do not accept the Tableau EULA the template will deploy the Azure resources but will not install Tableau Server. 

#### Prerequisites

Before deploying Tableau Server we recommend that you become familiar with Azure infrastructure services (specific resources & documentation are listed below) and the <a href=https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview>Azure Resource Manager</a> which you will use to manage the resources after deployment.

You will need access to an Azure account to deploy this template.  During deployment you can choose to install a trial version of Tableau Server or bring your own license. 

## Deployment steps

There are several options available for deploying this ARM template.  Once you have submitted your deployment template it will take approximately 25 minutes for all of the resources to be initialized and configured.  The deployment relies on several files - **azuredeploy.json** deploys and configures Azure resources (listed below); **azuredeploy.parameters.json** lists the parameter inputs necessary to configure the ARM template.  You can download and modify a copy of the templates and scripts as necessary if you would like to create a customized installation.

#### Azure Resource Manager

You can deploy the template via the Azure Resource Manager UI by clicking the "Deploy to Azure" button at the top of this guide or selecting Tableau Server single node from the <a href=https://azure.microsoft.com/en-us/resources/templates/tableau-server-single-node>Azure Quickstart Templates</a> web page.

#### Command line

You can optionally deploy this template following the instructions found <a href=https://github.com/Azure/azure-quickstart-templates/tree/master/1-CONTRIBUTION-GUIDE>here</a> using your command line client of choice.

#### Partially automated

You can use the config-linux.sh script separately from the ARM template to perform a silent install of Tableau Server by running the following command.  This requires you to have already provisioned an Ubuntu, RHEL or CentOS virtual machine following Tableau's <a href=https://onlinehelp.tableau.com/current/server/en-us/server_hardware_min.htm>hardware requirements</a>.

Bash:
```bash
sh ./config-linux.sh -u <vm_username> -p <vm_password> -h <tableau_server_admin_UN> -i <tableau_server_admin_UN> -j <zip_code> -k <country> -l <city> -m <last_name> -n <industry> -o yes -q <job_title> -r <phone_number> -s <company_name> -t <state> -v <department> -w <first_name> -x <email_address> [-y <license_key>]
```

## Resources

#### Microsoft Azure

This template deploys the following Azure resources.  For information on the cost of these resources please use Azure's <a href=https://azure.microsoft.com/en-us/pricing/calculator>pricing calculator</a>.  This template is designed to automate the Tableau Server deployment process.  However if you would like to step through the process manually you can use this reference architecture and resource details to create your own environment.

<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/tableau-server-single-node/images/azure_single_node.png"/>

+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview>**Virtual Network**</a>: A virtual network located in a single Azure region that contains the deployed resources and allows them to communicate with each other.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm>**Public IP Address**</a>: IPv4 address that persists separately from the VM and includes a registered DNS name for the machine it is attached to.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface>**Network Interface**</a>: Enables an Azure VM to communicate with the internet.  Associated with a virtual machine and an IP address.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group>**Network Security Group**</a>: Enables you to filter the network traffic that can flow in and out of the virtual network subnets & network interfaces.  Default settings allow traffic inbound from within the Virtual Network the machine is deployed in - we've added these additional rules:
    + Port 80 - public TCP access to your Tableau Server.  By default this is set as open to the world, meaning anyone with the IP or DNS of the machine and Tableau Server credentials can access the deployed Tableau Server as a user.  You can limit this access to a given IP range after deployment via the Azure portal.
    + Port 223 - SSH traffic is limited to the source CIDR determined during deployment.   Best practice is to limit SSH access to the Tableau Server or machine administrator.  
    + Port 8850 - HTTPS access to Tableau Services Manager UI which allows you to perform Tableau Server administration tasks (stopping & restarting Tableau Server, adding nodes, etc.)
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview>**Virtual Machine**</a>: Standard D16 v3 (16 vCPUs, 64 GB mem) or a memory or compute optimized 16 vCPU instance running Ubuntu 16.04.0-LTS, RHEL 7.6 or CentOS 7.5 with 2 attached disks (30, 64 GiB SSD) with Tableau Server installed
    + Access to the VM is controlled by username/password authentication which you specify in the template parameters.  Please ensure you follow Azure's username and password <a href=https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq>requirements</a>
+ This template has a static GUID associated with it - allowing Azure & the template's creator to track usage and deployment statistics

#### Tableau Server

When the resource template creates the Virtual Machine listed above it executes a startup script named config-linux.sh (as root user) to perform a silent, automated install of Tableau Server.  For more information about these steps you can refer to our <a href=https://onlinehelp.tableau.com/current/server/en-us/automated_install_windows.htm>documentation</a>.   

The steps performed by the configuration script are as follows:
+ Create secrets, registration.json & config.json files to reflect the parametrized inputs from the template
+ Download the Tableau Server <a href=https://www.tableau.com/support/releases/server>installer</a> - this tempalte is currently using Linux version 2019.2.1
+ Download the automated installer script (maintained in a separate <a href=https://github.com/tableau/server-install-script-samples/tree/master/linux/automated-installer>github repo</a>) and modify permissions.
+ Execute command to perform a silent install (refer to previous bullet for additional documentation)
+ Clean up all installation & configuration files

If you would like to learn more about the steps required for a manual deplyoment (which have been automated in the script) please refer to these resources:
+ <a href=https://onlinehelp.tableau.com/current/guides/everybody-install-linux/en-us/everybody_admin_intro.htm>Tableau Server on Linux</a>
+ <a href=https://onlinehelp.tableau.com/current/server/en-us/ts_azure_welcome.htm>Tableau Server on Azure</a>

## Usage

#### Connecting

Once the deployment is completed you can access Tableau Server by navigating to 'http://[IP Address or DNS]'.  You can use the Tableau admin credentials you specified in your parameters to log in as an admin user.

You can access Tableau Services Manager to perform administrative tasks by navigating to 'https://[IP Address or DNS]:8850'.  You can use the machine credentials you specified in your parameters to log in as TSM admin.

You can access the VM itself via SSH and the machine credentials you specified in your parameters.  The majority of Tableau Server administrative tasks do not require direct access to the virtual machine and can be accomplished via the access options listed above.  The exception are tasks such as upgrading Tableau Server or using the TSM command line client.

#### Getting Started with Tableau Server
+ Getting started with <a href=https://onlinehelp.tableau.com/current/server/en-us/get_started_server.htm>Tableau Server</a>
+ Walkthrough of Tableau Server <a href=https://www.tableau.com/learn/welcome-tableau-server-trial>trial experience</a>
+ Tableau + Azure <a href=https://www.tableau.com/solutions/azure>resources</a>

#### Azure resource Management
Once these resources have been deployed they don't require significant management or updates.  There are exceptions that would require you to access the Azure Resource manager such as: adjust network security settings, change instance sizes, upgrage instances, add additional nodes/resources.  For a production or proof-of-concept environment you will want to ensure you are consistently monitoring the cost, performance & security of the resources above. Azure provides extensive <a href=https://docs.microsoft.com/en-us/azure/azure-resource-manager/manage-resources-portal>documentation</a> for all of its resources.

#### Troubleshooting & Support

+ Make sure that you entered all parameters correctly.  Passwords should conform to <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm">Azure standards</a> and source CIDR should follow official syntax (0.0.0.0/24)
+ This ARM template is made available <a href=https://www.tableau.com/support/itsupport>'as-is'</a> - please use Github or <a href=https://community.tableau.com/community/forums/content>Tableau's community forum</a> to share comments or issues you may find.

