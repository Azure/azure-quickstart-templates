# Tableau Server Single Node

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/tableau/tableau-server-single-node/CredScanResult.svg)
[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftableau%2Ftableau-server-single-node%2Fazuredeploy.json)  [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Ftableau%2Ftableau-server-single-node%2Fazuredeploy.json)



This template deploys a **Tableau Server on a Virtual Machine instance** in its own Virtual Network.

`Tags: Tableau, Tableau Server, Business Intelligence, Analytics, Self-Service, Data Visualization`

## Overview

This ARM template allows you to quickly and easily deploy a standalone instance of Tableau Server on Azure.  The accompanying deployment guide is intended to provide guidance about the resources & processes involved in an automated deployment as well as providing resources for Tableau Server management.

Tableau Server is a hosted, enterprise-class platform for sharing, distributing, and collaborating on business intelligence content created in Tableau. Tableau Server users can create workbooks and views, dashboards, and data sources in Tableau Desktop, and then publish this content to the server.  Tableau is designed to make connecting live to data of all types a simple process that doesn't require any coding or scripting. From cloud sources like Azure SQL Data Warehouse, to on-premise Hadoop clusters, to local spreadsheets, Tableau gives everyone the power to quickly start visually exploring data of any size to find new insights. 

Tableau Server site and server administrators control who has access to server content to help protect sensitive data. Administrators can set user permissions on projects, workbooks, views, and data sources. Users can see and interact with the most up-to-date server content from anywhere, whether they use a browser or a mobile device. This template is for IT infrastructure architects, administrators, and DevOps professionals who are planning to implement or extend their Tableau Server workloads on the Azure Cloud.

#### Costs & Licenses

You are responsible for the cost of the Azure services used while running this ARM template reference deployment.  There is no additional cost for using the ARM template.  The template allows you to deploy either a 14-day trial of Tableau Server or use a license you have already purchased (BYOL).

As part of the deployment process you are prompted to accept the Tableau EULA.  Please enter 'Yes' in the respective parameter to indicate you have read and accepted the Tableau EULA which can be found <a href=https://mkt.tableau.com/files/tableau_eula.pdf>here</a>.  If you do not accept the Tableau EULA the template will deploy the Azure resources but will not install Tableau Server. 

#### Prerequisites

Before deploying Tableau Server we recommend that you become familiar with Azure infrastructure services (specific resources & documentation are listed below) and the <a href=https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview>Azure Resource Manager</a> which you will use to manage the resources after deployment.

You will need access to an Azure account to deploy this template.  During deployment you can choose to install a trial version of Tableau Server or bring your own license. 

## Deployment steps

There are several options available for deploying this ARM template.  Once you have submitted your deployment template it will take approximately 25 minutes for all of the resources to be initialized and configured.  The deployment relies on several files - **azuredeploy.json** deploys and configures Azure resources (listed below); **azuredeploy.parameters.json** lists the parameter inputs necessary to configure the ARM template.  You can download and modify a copy of the templates and scripts as necessary if you would like to create a customized installation.

#### Azure Resource Manager

You can deploy the template via the Azure Resource Manager UI by clicking the "Deploy to Azure" button at the top of this guide or selecting Tableau Server single node from the <a href=https://azure.microsoft.com/en-us/resources/templates/tableau-server-single-node>Azure Quickstart Templates</a> web page.

#### Command line

You can optionally deploy this template following the instructions found <a href=https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/deploy-cli>here</a> using your command line client of choice.

#### Partially automated

You can use the config-linux.sh or config-win.ps1 scripts separately from the ARM template to perform partially automated installations of Tableau Server.  This requires you to have already provisioned a virtual machine following Tableau's <a href=https://onlinehelp.tableau.com/current/server/en-us/server_hardware_min.htm>hardware requirements</a>.  You can then execute these commands directly on the virtual machine as a user with admin privileges.

Bash:
```
bash ./config-linux.sh -u <adminUsername> -p <adminPassword> -h <tableau_admin_username> -e <tableau_version> -i <tableau_admin_password> -j <registration_zip> -k <registration_country> -l <registration_city> -m <registration_last_name> -n <registration_industry> -o yes -q <registration_title'-r <registration_phone'-s <registration_company> -t <registration_state> -x <registration_email> -v <registration_department> -g, <installscripturi> -y <license_key> -f <OS> -w <registration_first_name>
```

Powershell:
```
powershell -ExecutionPolicy Unrestricted -File <winscriptfile> -local_admin_user <adminUsername> -local_admin_pass <adminPassword> -ts_admin_un <tableau_admin_username> -ts_admin_pass <tableau_admin_password> -reg_zip <registration_zip> -reg_country <registration_country> -reg_city <registration_city> -reg_last_name <registration_last_name> -reg_industry <registration_industry> -eula <accept_eula> -reg_title <registration_title> -reg_phone <registration_phone> -reg_company <registration_company> -reg_state <registration_state> -reg_email <registration_email> -reg_department <registration_department> -install_script_url <winscripturi> -license_key <license_key> -reg_first_name <registration_first_name> -ts_build <tableau_version>
```

This template is freely available on Github - you can download and customize your own version to modify its functionality.  This allows for options such as: expanding parameter options, batch-executing the template, adding additional scripting elements to install drivers, etc.  You can then execute the parameter locally using a CLI of your choice.

## Resources

#### Microsoft Azure

This template deploys the following Azure resources.  For information on the cost of these resources please use Azure's <a href=https://azure.microsoft.com/en-us/pricing/calculator>pricing calculator</a>.  This template is designed to automate the Tableau Server deployment process.  However if you would like to step through the process manually you can use this reference architecture and resource details to create your own environment.

<img src="images/azure_single_node.png"/>

+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview>**Virtual Network**</a>: A virtual network located in a single Azure region that contains the deployed resources and allows them to communicate with each other.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-ip-addresses-overview-arm>**Public IP Address**</a>: IPv4 address that persists separately from the VM and includes a registered DNS name for the machine it is attached to.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface>**Network Interface**</a>: Enables an Azure VM to communicate with the internet.  Associated with a virtual machine and an IP address.
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group>**Network Security Group**</a>: Enables you to filter the network traffic that can flow in and out of the virtual network subnets & network interfaces.  Default settings allow traffic inbound from within the Virtual Network the machine is deployed in - we've added these additional rules:
    + Port 80 - public TCP access to your Tableau Server.  By default this is set as open to the world, meaning anyone with the IP or DNS of the machine and Tableau Server credentials can access the deployed Tableau Server as a user.  You can limit this access to a given IP range after deployment via the Azure portal.
    + Port 223 - SSH traffic is limited to the source CIDR determined during deployment.   Best practice is to limit SSH access to the Tableau Server or machine administrator.  
    + Port 3389 - RDP traffic is limited to the source CIDR determined during deployment.   Best practice is to limit RDP access to the Tableau Server or machine administrator.  
    + Port 8850 - HTTPS access to Tableau Services Manager UI which allows you to perform Tableau Server administration tasks (stopping & restarting Tableau Server, adding nodes, etc.)
+ <a href=https://docs.microsoft.com/en-us/azure/virtual-machines/linux/overview>**Virtual Machine**</a>: A compute instance with Tableau Server installed - size and OS can be customized using the input parameters.  For more info on sizing please refer to <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes">Azure's documentation</a>.
    + Access to the VM is controlled by username/password authentication which you specify in the template parameters.  Please ensure you follow Azure's username and password <a href=https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq>requirements</a>
    + Please note that this template using a vanilla machine image.  If you would like to perform patching, upgrades, etc. you will have to do so manually once the deployment is complete.
    + During configuration - rules are added to firewalls to allow public access to ports 80 and 8850.  The NSG limits external access to the CIDR address you specify upon deployment.
+ This template has a static GUID associated with it - allowing Azure & the template's creator to track usage and deployment statistics

#### Tableau Server

When the resource template creates the Virtual Machine listed above it executes a startup script to install Tableau Server.  Windows machines will use the config-win.ps1 script and Linux machines will use the config-linux.sh script to perform a silent, automated install of Tableau Server.  For more information about these steps you can refer to our <a href=https://onlinehelp.tableau.com/current/server/en-us/automated_install_windows.htm>documentation</a>.

If you would like to learn more about the steps required for a manual deplyoment (which have been automated in the script) please refer to these resources:
+ <a href=https://onlinehelp.tableau.com/current/guides/everybody-install-linux/en-us/everybody_admin_intro.htm>Tableau Server on Linux</a>
+ <a href=https://help.tableau.com/current/guides/everybody-install/en-us/everybody_admin_intro.htm>Tableau Server on Windows</a>
+ <a href=https://onlinehelp.tableau.com/current/server/en-us/ts_azure_welcome.htm>Tableau Server on Azure</a>

This template offers a choice of which Tableau Server version to deploy.  In general Tableau recommends using hte most recent version (highest number) to access our most recent feature additions.  This template will be periodically updated to offer the most recent Tableau Server releases.  Older releases are available with the most recent maintenance release.

## Usage

#### Connecting
Once the deployment is completed you can access Tableau Server by navigating to 'http://[IP Address or DNS]'.  You can use the Tableau admin credentials you specified in your parameters to log in as an admin user.

You can access Tableau Services Manager to perform administrative tasks by navigating to 'https://[IP Address or DNS]:8850'.  You can use the machine credentials you specified in your parameters to log in as TSM admin.

You can access the VM itself via SSH/RDP and the machine credentials you specified in your parameters.  The majority of Tableau Server administrative tasks do not require direct access to the virtual machine and can be accomplished via the access options listed above.  The exception are tasks such as upgrading Tableau Server or using the TSM command line client.

#### Tableau Server Management
Please note that this deployment *may not conform to the security practices required by your organization* (for example, it relies on public IP addresses, offers open access on port 80 and uses a public subnet).  We recommend you leverage this deployment template option as you test out Tableau Server - to make installation easier and explore options for hosting on Azure.  As you transition to a production Tableau Server deployment please ensure you update configurations to meet established security standards.  You can refer to the resources below for additional guidance.

+ Getting started with <a href=https://onlinehelp.tableau.com/current/server/en-us/get_started_server.htm>Tableau Server</a>
+ Walkthrough of Tableau Server <a href=https://www.tableau.com/learn/welcome-tableau-server-trial>trial experience</a>
+ Tableau + Azure <a href=https://www.tableau.com/solutions/azure>resources</a>
+ Tableau Server on Azure <a href="https://www.tableau.com/learn/whitepapers/next-generation-cloud-bi-tableau-server-hosted-microsoft-azure">Whitepaper</a>

#### Azure Resource Management
Once these resources have been deployed they don't require significant management or updates.  There are exceptions that would require you to access the Azure Resource manager such as: adjust network security settings, change instance sizes, upgrage instances, add additional nodes/resources.  For a production or proof-of-concept environment you will want to ensure you are consistently monitoring the cost, performance & security of the resources above. Azure provides extensive <a href=https://docs.microsoft.com/en-us/azure/azure-resource-manager/manage-resources-portal>documentation</a> for all of its resources.

#### Troubleshooting & Support 
In the Azure portal you will be able to monitor the state of your deplyoment.  If any parts of the deployment are successful it will be indicated in the portal (in the top left of the Overview blade for your resource group).  If parts of the deployment failed you can typically explore those error messages directly in the UI.  Please ensure that you followed instructions to correctly enter your parameters.  Passwords should conform to <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm">Azure standards</a> and source CIDR should follow official syntax (0.0.0.0/24)  Also, please consult <a href="https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/common-deployment-errors">Azure's documentation</a> for additional troubleshooting tips.

If all of the services deployed successfully but you were unable to access Tableau Server from a browser then you can SSH/RDP into the host machine ('tableau1') and explore logs to solve the problem.  On Linux machines, log files can be accessed by the root user in the /tmp/ folder (server_install.log and install.txt).  On Windows machines, log files can be found in the c:\tab\ folder (install.log, event.log).  You can use these logs to manually fix the installation using <a href="https://www.tableau.com/support/help">Tableau's documentation</a>  If necessary you can delete the resource group and re-start the deployment. 

This ARM template is made available <a href=https://www.tableau.com/support/itsupport>'as-is'</a> - please use Github or <a href=https://community.tableau.com/community/forums/content>Tableau's community forum</a> to share comments or issues you may find.
