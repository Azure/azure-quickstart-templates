# Create an SSL enabled Web server farm with VM Scale Sets

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.compute/vmss-ubuntu-web-ssl/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-web-ssl%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-web-ssl%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.compute%2Fvmss-ubuntu-web-ssl%2Fazuredeploy.json)

This template illustrates secure deployment of SSL certificates to a VM Scale Set
running apache web servers. The SSL certificates are pulled securely from [Azure 
Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) and pushed to the [VM using secure ARM deployment](https://azure.microsoft.com/en-us/documentation/articles/resource-manager-keyvault-parameter/)

This sample illustrates how to
* Store SSL certs from a 3rd party CA securely in Key Vault
* Securely deploy the certs to the VMSS using Secure ARM Deployments
* Format certs to be used by the web server
* Configure apache

In files that do the work:

* keyvault.sh - creates key vault if needed, converts certificates into pfx, stores them in the key vault and updates azuredeploy.parameters.json with the keyvault location
* deploy.sh - script to run installation. It stages the script for the CustomScript in azure storage, fixes up the parameters file and deploys the ARM template
* azuredeploy.json - ARM Template to deploy Web Server VMSS
* azuredeploy.parameters.json.template - template for the parameters file. Fixed up by keyvault.sh and deploy.sh
* configure.sh - Script called by custom script extension to install apache and configure SSL 

## Prepare for Deployments
To prepare your key vault instance, run:
```
keyvault.sh <keyvaultname> <resource group name> <location> <secretname> <certpemfile> <keypemfile> <cacertpemfile>
```
Note the thumbprints and the key vault IDs. The script already stores them in azuredeploy.parameters.json for you. Take a look at the ARM template how they are used:

The certs are pulled from keyvault with the secrests configuration:
```
"osProfile": {
  "secrets": [
    {
      "sourceVault": {
        "id": "[resourceId(parameters('vaultResourceGroup'), 'Microsoft.KeyVault/vaults', parameters('vaultName'))]"
      },
      "vaultCertificates": [
        {
	        "certificateUrl": "[parameters('httpssecretUrlWithVersion')]"
        },
        {
          "certificateUrl": "[parameters('httpssecretCaUrlWithVersion')]"
        }
      ]
    }
  ]
}
```
The thumbnails are passed to the script that configures the web server:
```
"properties": {
    "type": "CustomScript",
    "settings": {
  	  "commandToExecute": "[concat('bash ', parameters('scriptFileName'), ' ', parameters('certThumbPrint'), ' ', parameters('caCertThumbPrint'))]"
},
```

To upload azuredeploy.json to a storage account:

Create a storage account and a container for the script. You also need to configure the container to be accessible.
```
azure storage account create -l [location] --type "LRS" -g [resourcegroupname] [accountname]
azure storage container create --container [containername] -p Off -a [accountname] -k [key]
```
Now upload the script to the newly created account:
```
azure storage blob upload -f configuressl.sh  -a [accountname] -k [key] --container [containername]
```
and note Url for the uploaded blob.

## Run a Deployment
Once certificates are stored in key vault and the script is staged in Azure storage, you can deploy by running:
```
deploy.sh -p [resourceGroupName] -q [deploymentName] -l [resourceGroupLocation] -s [scriptstorageaccount]
```
## Note: 
The template configures a load balancer NAT rule to the VM's SSH port. This is to help explore the VMs after you deployed the sample. I don't recommend to have production VMs accessible via an internet facing SSH port - even when it's obscured by a non-standard port.

## What's going on in the scripts: Creating Certificates and Configurint SSL Servers
VMSS are great for scalable web workloads. [Setting up an Ubuntu VM with Apache](https://help.ubuntu.com/lts/serverguide/httpd.html) is very straight forward. 

But what about enabling SSL? You'll need certificates deployed to the VM in a secure way. You don't want your production certs to fall in the wrong hands. You'll also want to configure the web server for these certificates.

Azure Key Vault enables secure storage and workflows for the SSL certificates. The [CustomScript VM extension](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-classic-lamp-script/) can configure the VM at start up, but there are a few gotchas when you want to put the two together to deploy certificates to a Linux VM.

SSL encryption or its newer, more secure successor TLS, requires a pair of certificates and a private key on web servers to encrypt web traffic. Those certificates and the key are closely guarded because those certificates are linked to your domain and protect against man-in-the-middle attacks. Bad things can happen to your organization when a bad guy get hold of these certs.

The certs and the key are perfect examples for confidential information that should be stored in Azure Key Vault. Key Vault configures [Access Policies](https://msdn.microsoft.com/en-us/library/mt603625.aspx) to restrict access to only the entities that need access for deployment. Developers and site admins will not be able to get the certs.

ARM will pull the certs from Key Vault at deployment time and place them in `/var/lib/waagent` on your Azure VM. 

In order to do that, you store the cert in key vault first. You can [create a self-signed cert](https://www.sslshopper.com/article-how-to-create-a-self-signed-certificate.html) for testing purposes).

When you purchase a cert for your domain from a Certificate Authority (CA) you get 3 files, a cert for the domain, a private key for the domain and a cert for the CA. For example, if you request certs for myawesomeness.com from digicert.com then you'd get files like:

* myawesomeness_com.crt (the cert for the site) 
* Myawesomeness_com.key (the private key)
* DigiCertCA.crt (the CA cert)

Unfortunately, ARM currently expects a pfx file in key vault for secure deployments, not the crt/key combination. Check out the sample for [deploying certs to a windows VM](https://blogs.technet.microsoft.com/kv/2015/07/14/deploy-certificates-to-vms-from-customer-managed-key-vault/) for details. So first you have to convert the files into pfx files, one for the site and one for the CA.

```
openssl pkcs12 -export -out myawesomeness_com.pfx -inkey myawesomeness_com.key -in myawesomeness_com.crt 
```
Once you have the PFX you can store it in key vault, e.g. with the powershell snippet (bash coming soon). 

Then you add the cert deployment to the ARM template for your VM scale set (it works for Virtual Machines just the same).

```
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  
    […]

    "virtualMachineProfile": {

    […]

        "secrets": [
          {
            "sourceVault": {
              "id": "[resourceId(parameters('vaultResourceGroup'), 'Microsoft.KeyVault/vaults', parameters('vaultName'))]"
            },
            "vaultCertificates": [
              {
                "certificateUrl": "[parameters('httpssecretUrlWithVersion')]"
              },
              {
                "certificateUrl": "[parameters('httpscasecretUrlWithVersion')]"
              }
            ]
          }
        ]
```

Once the deployment finishes you'll find the certs and the key in /var/lib/waagent. The files will be named 

* [certthumbprint].crt
* [certthumbprint].prv
* [cacertthumbprint].crt

If you're testing your site with self-signed certs, then you have to remove the 2nd certificateUrl from the ARM template. The configuressl.sh script is already written to work with self-signed, but at this time, the ARM deployment engine ignores a CA  when it's packaged up in the pfx. In the future when this limitation is lifted, you'll be able to pass one or two thumbprint parameters, 2 parameters if you have a "real" production cert and 1 parameter if you only have a self-signed cert.

To test the SSL configuration on your scale set VMs without going through configuring a DNS CNAME for the load balancer, you can simply add the FQDN to your hosts file (/etc/hosts on Linux, c:\windows\system32\drivers\etc\hosts on Windows).

HTH,
Christoph



