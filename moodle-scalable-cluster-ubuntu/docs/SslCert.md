# SSL Certificate Management

A valid SSL (TLS) certificate should be used with your domain name for the Moodle
site to be deployed using the templates. By default, the templates will configure
the HTTPS server with a self-signed SSL server certificate/private key, which can
be manually changed with your own valid SSL server certificate/private key after
the deployment.

If you'd like to configure the Moodle cluster (to be deployed) with your own domain
and your valid SSL server certificate/private key, then you can do so by utilizing
[Azure Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) and
configuring the related template parameters as described below. This support is
based on [another similar work](https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-ubuntu-web-ssl)
and adapted to our situation.

## Initial deployment

To configure the Moodle cluster (to be deployed) with your purchased SSL certificate,
currently the related files should be stored in an Azure Key Vault as secrets, so that
Azure Resource Manager can reference when it deploys VMs as specified in templates.

You can create your own Azure Key Vault and store your purchased SSL certificate (called
'import' in Azure Key Vault terminology) by following related documentation like
[this](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-manage-with-cli2).
However, the related files must be stored in a specific format, so we created a
shell script (`keyvault.sh`) that will perform all necessary steps for this purpose.
To use this script, you'll first need to upload your SSL certificate/private key files
(.pem) to your deployment environment you set up by following the [preparation document](Preparation.md)
(a Linux command line). The .pem files should be as follows:

- `cert.pem`: The SSL certificate only in PEM format
- `key.pem`: The private key for the SSL certificate only in PEM format
- `chain.pem`: This is optional in case your server certificate is signed by an intermediate CA (Certificate Authority) certificate, instead of a root CA certificate. Currently only one intermediate CA certificate is supported by the script.

Once you updloaded the files to your deployment environment, you can run the following command
to create an Azure Key Vault on your subscription and store your SSL certificate, private key, and optionally
the intermediate CA certificate:

``` bash
$ bash $MOODLE_AZURE_WORKSPACE/arm_template/etc/keyvault.sh <key_vault_name> <resource_group_name> <azure_region> <secret_name> cert.pem key.pem chain.pem
```

Make sure to set `<azure_region>` the same as the Azure region you'll be using to deploy the Moodle template.
Assign desired names for `<key_vault_name>`, `<resource_group_name>` (you can use an existing resource group) and `<secret_name>`.
`<secret_name>` is not very important in our deployment. Then you'll get outputs as follows:

```
...
Specified SSL cert/key .pem files are now stored in your Azure Key Vault and ready to be used by the template.
Use the following values for the related template parameters:

- keyVaultResourceId: /subscriptions/206c66fc-a48c-480d-ad06-0d429e82c586/resourceGroups/keyvault/providers/Microsoft.KeyVault/vaults/mdl-kv
- sslCertKeyVaultURL: https://mdl-kv.vault.azure.net/secrets/mymoodlesitecert/4c88452fe72b4d469253af48348f4944
- sslCertThumbprint:  56478E4F9555662476E2763D909F50B3DD26FF84
- caCertKeyVaultURL:  https://mdl-kv.vault.azure.net/secrets/camymoodlesitecert/684efab1f2124e71a2c809457d10808b
- caCertThumbprint:   E6A3B45B062D509B3382282D196EFE97D5956CCB
Done
```

This example outputs assumes `"keyvault"` is used for `<resource_group_name>`, `"mdl-kv"` for `<key_vault_name>`,
and `"mymoodlesitecert"` for `<secret_name>`. Note that `caCertKeyVaultURL` and `caCertThumbprint` will be empty
if you didn't specify `chain.pem`. Then you can copy these outputs to the template's corresponding parameters,
and Azure Resource Manager will install the certificate and the private key on the deployed VMs and the deployed
HTTPS server will use this certificate and private key.

## Certificate rotation

Another important benefit of using Azure Key Vault is to handle certificate expiration/rotation automatically.
Unfortunately, the current implementation doesn't support the auto-rotation. So when it becomes near your SSL
certificate's expiry, you'll need to manually update the deployed certificate and private key files
(it's in `/moodle/certs/nginx.{crt,key}` on the controller VM) and restart all the web frontend VM instances.
We'll improve our implementation to support auto-rotation in the future.