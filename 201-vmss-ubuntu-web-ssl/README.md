# Create an SSL enabled Web server farm with VM Scale Sets

This template illustrates secure deployment of SSL certificates to a VM Scale Set running apache web servers.
The SSL certificates are pulled securely from Azure Key Vault and pushed to the VM using secure ARM deployment (LINK)

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fzookeeper-cluster-ubuntu-vm%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

In this folder you find:

* SetupKeyVault.ps1 - Store SSL certs in pfx format in key vault
* setupkeyvault.sh - Convert certs to pfx and store in key vault.
* azuredeploy.json - Deploy Web Server VMSS
* configure.sh - Script called by custom script extension to configure apache

## Prepare for Deployments

To prepare your key vault instance, run:
```
configure.sh PARAMETERS
```
To upload azuredeploy.json to a storage account:

Create a storage account and a container for the script
```
azure storage account create -l <location> --type "LRS" -g <resourcegroupname> <accountname>
```
Note the thumbprint. You'll need it to update the parameters file.
Now upload the script to the newly created account:
```
azure storage blob upload -f configuressl.sh  -a <accountname> -k <key>
```
and note Url for the uploaded blob.

WHAT ABOUT THE ACCESS POLICY?

Now update the parameters.json with the certificate thumbprint and the location of the storage account:
```
```

## Run a Deployment
Once certificates are stored in key vault and the script is staged in Azure storage, you can deploy by running:
```
deploy.sh
```

## Background: Creating Certificates and Configurint SSL Servers
VMSS are great for scalable web workloads. Setting up an Ubuntu VM with Apache  is very straight forward, too. 

But what about enabling SSL? You'll need certificates deployed to the VM in a secure way. You don't want your production certs to fall in the wrong hands. You'll also want to configure the web server for these certificates.

Azure Key Vault enables secure storage and workflows for the SSL certificates. The CustomScriptForLinux VM extension can configure the VM at start up, but there are a few gotchas when you want to put the two together to deploy certificates to a Linux VM.

In this repo you find an example how to
* Store SSL certs from a 3rd party CA securely in Key Vault using Powershell (Bash coming soon)
* Securely deploy the certs to the VMSS using Secure ARM Deployments
* Format certs to be used by the web server
* Configure apache

SSL encryption or its newer, more secure successor TLS, requires a pair of certificates and a private key on web servers to encrypt web traffic. Those certificates and the key are closely guarded because those certificates are linked to your domain and protect against man-in-the-middle attacks. Bad things can happen to your organization when a bad guy get hold of these certs.

The certs and the key are perfect examples for confidential information that should be stored in Azure Key Vault. Key Vault configures Access Policies to restrict access to only the entities that need access for deployment. Developers and site admins will not be able to get the certs.

ARM will pull the certs from Key Vault at deployment time and place them in `/var/lib/waagent` on your Azure VM. 

In order to do that, you store the cert in key vault first. (You can create a self-signed cert for testing purposes).

When you purchase a cert for your domain from a Certificate Authority (CA) you get 3 files, a cert for the domain, a private key for the domain and a cert for the CA. For example, if you request certs for myawesomeness.com from digicert.com then you'd get files like:

* myawesomeness_com.crt (the cert for the site) 
* Myawesomeness_com.key (the private key)
* DigiCertCA.crt (the CA cert)

Unfortunately, ARM currently expects a pfx file in key vault for secure deployments, not the crt/key combination. Check out the sample for deploying certs to a windows VM for details. So first you have to convert the files into pfx files, one for the site and one for the CA.

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

* <certthumbprint>.crt
* <certthumbprint>.prv
* <cacertthumbprint>.crt

If you're testing your site with self-signed certs, then you have to remove the 2nd certificateUrl from the ARM template. The configuressl.sh script is already written to work with self-signed, but at this time, the ARM deployment engine ignores a CA  when it's packaged up in the pfx. In the future when this limitation is lifted, you'll be able to pass one or two thumbprint parameters, 2 if you have a "real" production cert and 1 if you only have a self-signed cert.

To test the SSL configuration on your scale set VMs without going through configuring a DNS CNAME for the load balancer, you can simply add the FQDN to your hosts file (/etc/hosts on Linux, c:\windows\system32\drivers\etc\hosts on Windows).

HTH,
Christoph


