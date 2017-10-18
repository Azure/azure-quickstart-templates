# Safewalk IAM solution

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Faltipeak%2Fazure-quickstart-templates%2Fsafewalk2-platform-beta-dev%2Fsafewalk2-platform%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Faltipeak%2Fazure-quickstart-templates%2Fsafewalk2-platform-beta-dev%2Fsafewalk2-platform%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys the **Safewalk platform** in your Azure subscription.

`Tags: Safewalk , Altipeak, Authentication, 2Factor, TOTP, OATH2, Identity, Strong, Secure, IAM`

## Solution overview and deployed resources

**Safewalk** is an **Identity and Access Management (IAM) solution** with focus on (2FA) Strong authentication.

This document includes a general overview and quick installation instructions for a single topology that is the most commonly used. For more advanced configuration, administration and maintenance of the system as well as known issues and troubleshooting please refer to the full user manual.

The following resources are deployed as part of the solution

### Virtual Network Layout
The virtual network will consists on three subnets:
* DMZ subnet - This subnet is accesible from the Internet using a Public static IP. It contains the Gateway VM which is regulated with the DMZ Network Security Group.
* LAN subnet - This subnet only allows internal access and only permitted ports are accesible from the DMZ subnet.
* Gateway Subnet - This subnet is a well known predefined Azure one and can be used to create virtual network connections like **vNet<->vNet** or **Point<->Site** VPN connections.

#### Safewalk server VM
The Safewalk server VM is installed inside the LAN subnet. It's recommended to access it using a VPN. If cluster is enabled, 2 VMs will be created in the same Availability Set (different physical machines).

* Super-Admin Console
A web based interface that provides access to the general configuration of the system, like LDAP/AD connectivity to users or groups, import of new licenses, creating RADIUS clients and more. The main idea of this interface is to provide access for the highest authority to perform tasks that are not needed on a day to day basis and require a relatively high level of knowledge with the system and the organization architecture.

* Management Console
A web based interface that provides access to manage users, their authentication settings, view transactions and more. The main idea of this interface is to provide access for helpdesk personnel or system administrators to perform tasks that are needed frequently but has no system-wide impact.

* Self-Service Portal
A web based interface that provides access to end users to register their authentication device.

* RADIUS Server
Remote Authentication Dial In User Service (RADIUS) is a networking protocol that provides centralized Authentication, Authorization, and Accounting (AAA) management for users that connect and use a network service. The Remote Access Server, the Virtual Private Network server, the Network switch with port-based authentication, and the Network Access Server (NAS), are all gateways that control access to the network, and all have a RADIUS client component that communicates with the RADIUS server. RADIUS is often the backend of choice for 802.1X authentication as well (see http://en.wikipedia.org/wiki/RADIUS for more details).

#### Safewalk Gateway VM
Safewalk-Gateway is a complementary component to the Safewalk Server with the purpose of providing additional services like Single sign-on (SSO) that improves the accessibility and integration capabilities with the Safewalk platform as well as to serve as a platform for any additional applications that can be derived from the Safewalk platform.
The Gateway VM will be created at the DMZ subnet.

The main components of the Safewalk Gateway consists of:

* SSO (SAML IdP v2)
Provides Single Sign-On (SSO) and integration with third party web-based applications over the SAML v2 standard protocol.

Single Single sign-on (SSO) is provided across all the SAML applications that are integrated with the same Safewalk Gateway.

Benefits of using single sign-on include:

* Mitigate risk for access to 3rd-party sites (user passwords not stored or managed externally)
* Reducing password fatigue from different user name and password combinations
* Reducing time spent re-entering passwords for the same identity
* Reducing IT costs due to lower number of IT help desk calls about passwords

General SAML authentication flow
1. User generates a code (be it its static password, One-Time-Password from a mobile app/email/sms or from
a physical device);
2. User browses to the the application (that is enabled as a SAML SP);
3. The application redirects the user to its configured SAML IdP (i.e. the Safewalk Gateway) where the user
is prompted to enter its credentials;
4. The credentials supplied by the user are checked on the Safewalk server;
5. The Safewalk server validates the code and reply with the authentication result (one of AccessAccept/Access-Reject/Access-Challenge);
6. Assuming that the credentials have been verified successfully (i.e. Access-Accept) the user is granted access
to the application;

* Registration-Gateway
For facilitating the over-the-air registration method of mobile applications.

* Safewalk server authentication api
A proxy to the Safewalk server authentication api for external applications that do not support standard authentication protocols.

General authentication flow
1. User generates a code (be it its static password, One-Time-Password from a mobile app/email/sms or from
a physical device);
2. User browses to the address of the organization NAS (that is equipped with a RADIUS client), where he is
prompted to enter its credentials;
3. The credentials supplied by the user are checked on the Safewalk server;
4. The Safewalk server validates the code and return a reply to the NAS (one of Access-Accept/AccessReject/Access-Challenge);
5. Assuming that the credentials have been verified successfully (i.e. Access-Accept) the user is granted access
to the relevant application;

## Prerequisites
To get use this Safewalk2 platform you'll need to copy or upload the VM's VHD images to your storage account.

### Uploading the Safewalk Server and Safewalk Gateway VHD images

The first thing you will need to do before you can deploy Safewalk using the ARM template is to copy or upload the Safewalk Server and Safewalk Gateway VHD images to your Azure subscription by following the steps below:

Login into the Azure portal (https://portal.azure.com)

Create or select a blob storage account on the **same region** where you plan to deploy the Safewalk2 framework. It's recommended that the VHD Images live in a separate resource group in case you need to delete/move the system components and keep the images for future deployments.
Then add a container to upload the VHD images into.

Download the images to your local drive from:
<a href="https://safewalk2.blob.core.windows.net/images/Safewalk.vhd">Safewalk VHD image</a>
<a href="https://safewalk2.blob.core.windows.net/images/Gateway2.vhd">Gateway VHD image</a>
and Upload it manually as a Page Blob into your storage account container.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

### Template form parameters

* Subscription - Set to the name of the subcription where you would like to deploy Safewalk.
* Resource group - Select Use existing and select the same resource group you used to upload the
Safewalk’s VHD images.
* Location - Set to the location where you would like to deploy Safewalk. It should be the same as where the VHD images are stored
* Safewalk VHD Image URL - Set to the URL of the Safewalk VHD image you have uploaded earlier.
* Safewalk Gateway VHD Image URL - Set to the URL of the Safewalk Gateway VHD image you
have uploaded earlier.
* Vnet Name - A name for the VNet that will be created.
Use the default parameter or manually set a name for a new VNet that
will be created during the deployment.
* Subnet LAN Name - A name for a subnet that will be used to serve the
Safewalk server.
Use the provided default value or manually set a name for a new subnet
that will be created during the deployment.
* Subnet DMZ Name - A name for an Internet facing subnet that will be used
to serve the Safewalk Gateway.
Use the provided default value or manually set a name for a new subnet
that will be created during the deployment.
* Vnet Address Space - The address space of the specified VNet (either new or existing).
If Create Vnet was set to true, use the provided default value or set a different VNet address space
according to your preferences (e.g. 10.0.0.0/16).
If Create Vnet was set to false specify here the address space of the VNet that was provided.
* Subnet LAN Address Space - The address space of the specified LAN subnet (either new or existing).
If Create Vnet was set to true, use the provided default value or set a different subnet address space
according to your preferences (e.g. 10.1.1.0/24).
If Create Vnet was set to false specify here the address space of the subnet that was provided.
* Subnet DMZ Address Space - The address space of the specified DMZ subnet (either new or existing).
If Create Vnet was set to true, use the provided default value or set a different subnet address space
according to your preferences (e.g. 10.1.2.0/24).
If Create Vnet was set to false specify here the address space of the subnet that was provided.
* Gateway Subnet Address Space - An address space for an Azure reserved GatewaytSubnet that can
be used at a later step to create a secured VPN connections between the different subnets.
* Safewalk Gateway IP - Set to the address that will be assigned to the Safewalk Gateway within the
DMZ subnet (e.g. 10.1.2.4).
* Number Of Safewalk Instances - Set the number of Safewalk server nodes that will be
created. The deployment procedure will automatically configure the multimaster topology between all the nodes.
* Vm Username - A username for a privileged account that will be created in the Safewalk servers and
in the Safewalk Gateway operating system.
* Vm Password - The password for the corresponding privileged user account for the Safewalk servers
and the Safewalk Gateway operating system.
* Safewalk Server Vm Size - The azure VM size that will be used for the Safewalk server.
Note: The same size will be assigned to all the Safewalk servers that will participate in the cluster.
* Safewalk Gateway Vm Size - The azure VM size that will be used for the Safewalk Gateway.
* Safewalk Server Root Password - The password to set for the root account of the Safewalk server.
Note: The same root password will be set to all the Safewalk servers that will participate in the
cluster.
* Safewalk Server Admin Password - The password to set for the Safewalk server admin account.
* Safewalk Gateway Root Password - The password to set for the root account of the Safewalk Gateway.
* _artifactsLocation - Azure reserved parameter. Keep it with the default value.
* _artifactsLocationSasToken - Azure reserved parameter. Keep it empty.

## Usage

### How to connect

You might need to setup a VPN connection to the VNet in order to gain access to the machines.

For more information about Virtual network gateway and how to setup a Point-to-Site connection please refer to
https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-point-to-site-resource-manager-portal.

Safewalk servers will be accesible this url: https://[safewalk_ip]:8443

Safewalk servers are accesible from SSH using the specified credentials through a VPN connection.

The Gateway SSH is only accesible from the Safewalk nodes. Only web services are accesible from the Internet at port 443

### Post installation setup

**Initial configuration on the superadmin console**

* Connect to the super-admin
1. Open a browser and enter the address of the super-admin console (i.e.
https://SAFEWALK_ADDRESS:8443).
2. Enter the credentials of the admin account (username: admin and the choosed password).

* Change the email address of the admin account
1. In Internal users & groups box click Users.
2. Click the admin user.
3. Update the Email address field and click Save.

* Update the organization identity
1. You can set your organization name in the Name field.
2. You can set your organization logo in the Logo field.

* Setup the following items
1. Follow the Import Server License link in the Import licenses box to import a server license.
2. Import token licenses by following the Import Licenses from the Import licenses box.
Attention: If you intend to setup multiple Safewalk servers in your environment (i.e. using either
the multimaster topology or the clustering with load-balancing) it is recommended first to join all
the servers to one cluster and only then to perform the import of the tokens licenses.
3. In the Organization settings box follow the Add link to set your LDAP configuration.
4. Create new RADIUS clients that will be used to authenticate to the server from your Firewall,
SSL/VPN, etc. by following the Add link in the RADIUS settings box.
5. Follow the Add link in the Messages delivery gateways box to create a new message delivery provider
that will be used to send registration codes, One-Time-Passwords and backup tokens to your users.
For more information about the super-admin console please refer to the chapter /Super_admin_console
6 Accessing the management console to view, manage and test
users authentication

Once the system has been configured you will be able to log into the management console to view and manage
your users.

* Using the management console 
1. Open a browser and enter the address of the management console as it was given in the final screen of the
installation (i.e. https://SAFEWALK_ADDRESS/admin).
2. Enter the credentials of the admin account (username: admin and the password you selected for the administrator
account during the installation).
Note: You will be able to set other users to serve as administrators of the system (including
LDAP users) after you sign-in.
3. After you sign in click the Users tab and search for users in the system, you will be presented with a list of
users that are relevant for your search.
4. Select one of the users and you will be able to view the selected user settings.
5. Select the user’s Tokens tab and assign it with a token for testing.
6. If the token assigned is marked as Registered (i.e. value Yes) you will be able to use the token for authentication.
7. Click the Radius Test link to attempt an authentication for the user.
For more information about the management console please refer to the chapter /Management_console

### Software Licenses
Please contact us at order@altipeak.com in order to buy licenses to get Safewalk ready to use.
