# Guacamole VM in existing VNet 

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/application-workloads/guacamole/guacamole-rdp-vnc-gateway-existing-vnet/CredScanResult.svg)

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fguacamole%2Fguacamole-rdp-vnc-gateway-existing-vnet%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fguacamole%2Fguacamole-rdp-vnc-gateway-existing-vnet%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fapplication-workloads%2Fguacamole%2Fguacamole-rdp-vnc-gateway-existing-vnet%2Fazuredeploy.json)

This template deploys a VM with [Guacamole](http://guac-dev.org), the open source HTML5 RDP/VNC proxy.

You will need an existing Virtual Network, and you will need the name of the VNet and a subnet in that VNet. This template deploys Guacamole and MariaDB using Docker containers, and it's based on CoreOS (channel "stable").

### SSH key

This template requires you to provide a **SSH RSA public key**.

**Linux and Mac** users can use the built-in `ssh-keygen` command line utility, which is pre-installed in OSX and most Linux distributions. Execute the following command, and when prompted save to the default location (`~/.ssh/id_rsa`):

    $ ssh-keygen -t rsa -b 4096

Your **public** key will be located in `~/.ssh/id_rsa.pub`.

**Windows** users can generate compatible keys using PuTTYgen, as shown in [this article](https://winscp.net/eng/docs/ui_puttygen). Please make sure you select "SSH-2 RSA" as type, and use 4096 bits as size for best security.

## Using Guacamole

Once the template has been deployed, wait around 5 minutes for Guacamole to be executed. Then open a web browser and point it at:

    http://VM_IP/guacamole

For example:

    http://12.34.56.78/guacamole

The default credentials are:

- **Username:** `guacadmin`
- **Password:** `guacadmin`

## Security considerations

1. Consider changing the Guacamole admin account credentials as soon as possible to restrict unauthorized access.
2. The MySQL database is configured with simple passwords (that can be seen in the scripts in this repository). However, the MariaDB (MySQL) container is not exposed on the network, so only containers directly linked to it and running on the same host can connect to the database.
3. The web server is configured to use HTTP only. You may want to configure Tomcat to use HTTPS, or put a proxy in front which does SSL/TLS offloading (for example [Azure Application Gateway](https://azure.microsoft.com/en-us/services/application-gateway/)).

## Debugging

If you're having issues starting a RDP or VNC session, you can get detailed log information by running:

    $ sudo docker logs some-guacd

