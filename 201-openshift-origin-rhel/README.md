# OpenShift Origin with Azure Active Directory

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fanweiss%2Fazure-quickstart-templates%2Fopenshift-origin-rhel%2Fopenshift-origin-rhel%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fanweiss%2Fazure-quickstart-templates%2Fopenshift-origin-rhel%2Fopenshift-origin-rhel%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template deploys OpenShift Origin and configures Azure Active Directory as the primary authentication provider. It includes the following resources:

|Resource           |Properties                                                                                                                          |
|-------------------|------------------------------------------------------------------------------------------------------------------------------------|
|Key Vault          |Secret for storing SSH private key                                                                                                  |
|Virtual Network    |**Address prefix:** 10.0.0.0/16<br />**Master subnet:** 10.0.0.0/24<br />**Node subnet:** 10.0.1.0/24                               |
|Load Balancer      |2 probes and two rules for TCP 80 and TCP 443                                                                                       |
|Public IP Addresses|OpenShift Master public IP<br />OpenShift Router public IP attached to Load Balancer                                                |
|Storage Accounts   |2 Storage Accounts                                                                                                                  |
|Virtual Machines   |Single master<br />User-defined number of nodes<br />All VMs include a single attached data disk for Docker thin pool logical volume|

## Prerequisites

### Create Azure AD Application

An Azure AD application must be created before deploying this template. This can be accomplished via the following steps:

1. Login to [https://manage.windowsazure.com](https://manage.windowsazure.com)
2. Select the **Active Directory** button from the available services list
3. Click on the name of the directory from which users will be granted access to OpenShift
4. Click on the **APPLICATIONS** tab
5. Click on the **ADD** button at the bottom
6. Select the *Add an application my organization is developing* link [If you are not presented with this screen, you can ignore this step.]
7. Provide a name for the application (note that this name should be all one word as it will be used later as part of the reply URL)
8. Select the *Web Application And/Or Web API* radio button
9. On the next page, enter the fully-qualified sign-on URL for your application. This should be in the following format: [https://[openshift_master_public_ip_dns_name]pip.[region].cloudapp.azure.com:8443/console](). The App ID URI can be set to the same value as the sign-on URL
11. Click the checkmark to create the application
12. Select the **CONFIGURE** tab
13. Make note of the *Client ID* as you will need this when deploying the template
14. Under the *Keys* section, click on the dural dropdown list and choose an appropriate duration 
15. Under the *Single Sign-On* section and in the *Reply URL* box, enter the following URL: [https://[openshift_master_public_ip_dns_name]pip.[region].cloudapp.azure.com:8443/oauth2callback/[azure_ad_app_name]]()
16. Click the **SAVE** button at the bottom to save the configuration settings and generate a client secret
17. Make note of the secret key that is generated as you will need this when deploying the template

### Generate SSH Keys

You'll need to generate a pair of SSH keys in order to provision this template. Ensure that you do not include a passcode with the private key.

### Gather additional information for deployment

1. You will need the Azure AD Tenant ID.  This can be retrieved by executing the following PowerShell cmdlet </br>
     get-AzureAccount

2. You will also need your Azure AD Object ID.  This can be retrieved by executing the following PowerShell cmdlet </br>
     Get-AzureRmADUser -UserPrincipalName user@azuread.com [where user@azuread.com is your Azure AD email address] </br>
	
	Alternatively, the CLI command is: </br>
		azure ad user show upn --user@azuread.com [where user@azuread.com is your Azure AD email address]

## Deploy Template

Once you have collected all of the prerequisites for the template, you can deploy the template using the **Deploy to Azure** button at the top or by populating the *azuredeploy.parameters.json* file and executing Resource Manager deployment commands with PowerShell or the xplat CLI.

### NOTE

> The `azureAdLogoutRedirectUri` parameter should be set to the following: [https://[openshift_master_public_ip_dns_name]pip.[region].cloudapp.azure.com:8443/]().
<hr />
Since JSON does not support multiline strings, you must replace line breaks with `\n` when adding your SSH private key to the `sshPrivateKey` parameter. 
<hr />
The OpenShift Ansible playbook does take a while to run when using VMs backed by Standard Storage. The template can be modified to use DS/GS-series VMs backed by Premium Storage for a faster deployment and subsequent pod instantiations. If you choose to do this, you should also ensure that the attached `docker-pool` data disk is backed by Premium Storage.
<hr />
Be sure to follow the OpenShift instructions to create the ncessary DNS entry for the OpenShift Router for access to applications.

## Post-Deployment Operations

This template deploys a [containerized installation](https://docs.openshift.org/latest/install_config/install/rpm_vs_containerized.html) of OpenShift which results in the creation of a CLI wrapper script on the Master node. By default, the admin user provisioned by the template is logged in as the `system:admin` system user which has access to everything. It is advised that you bind the `cluster-admin` policy to a user from your Azure AD tenant as follows:

1. SSH in to master node
2. Execute the following command:

   ```sh
   sudo oadm policy add-cluster-role-to-user cluster-admin <user>@<azure_ad_domain>
   ```

3. Attempt to login to OpenShift with the Azure AD user as follows:

   ```sh
   sudo oc login -u <user>@<azure_ad_domain>
   ```
   
   To obtain a token, you will need access to a browser in order to complete the authentication steps as prompted.
 
## Additional OpenShift Configuration Options
 
You can configure additional settings per the official [OpenShift Origin Documentation](https://docs.openshift.org/latest/welcome/index.html).
