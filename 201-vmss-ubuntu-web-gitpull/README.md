# Confgure Git Deployment to VMSS 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-ubuntu-web-gitpull%2Fazuredeploy.json" target="_blank">
<img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vmss-ubuntu-web-gitpull%2Fazuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

My team mate [Scott Semyan](http://github.com//ssemyan) and I recently worked on the web site for the [2016 DNCC](http://demconvention.com).
One of security principles we followed was to have no inbound ports to our web servers. 
To enable secure continuous deployment Scott and I put together a clever configuration of a continous pull from a private git repo using read-only [SSH deploy keys](https://gist.github.com/zhujunsan/a0becf82ade50ed06115). 

## Configure git
Git access via SSH requires a **private** key to the repo on the web server. We want to treat the key as very sensitive information and deploy securely. See note on deploying from Azure Key Vault below.
This sample keeps things simple and passes the private key to the ARM template. The key is base64 encoded before deployent to ensure special characters don't get lost in translation between the ARM template and the VM.
The template defines the ```commandToExecute``` for the Custom Script Extension inside the ```protectedProperties``` setttings.
This avoids the command line and the parameters to be logged to files on the VM.

```
"protectedSettings": {
  "commandToExecute": "[concat('bash ', parameters('scriptFileName'), ' ', base64(parameters('gitSshPrivateKey')), ' ', parameters('gitRepoName'), ' ', parameters('gitUserName'))]"
}
``` 

The script adds the private key and the git user id to ```~/.ssh/config/``` to avoid any prompts when accessing the git repo and to avoid conflicts with other SSL setups. 
One could even configure multiple git repos with different ids, one for content and one for code:
```
cat >> ~/.ssh/config << EOF
Host $host
HostName $host
User $user
IdentityFile $keyfile
EOF
```

## Confgure continuous git deployment
Continuous Deployment is configured via a simple cron job. The job periodically pulls from the git repo that was set up during deployment.

```
$:/etc# crontab -l
*/10 * * * * echo $(date) >> /var/log/cronjob.log && cd /var/www/html && git pull >> /var/log/cronjob.log 2>&1
```

## Notes
* The sample runs the cronjob under the root account to keep things simple. You would want to configure a less privileged account in your production setting. 

* Since we're deploying a **private** key to the VM, we [deployed those directly from Azure Key Vault](https://azure.microsoft.com/en-us/documentation/articles/resource-manager-keyvault-parameter/). The sample avoids the key vault setup. 
If you're looking for a sample that illustrates secure deployment of secrets. To do this you'd store the private key as a secret in Azure Key Vault and point the parameter to the key vault secret.

    The parameter definition in the ARM template would like this:
  ```
      "gitSshPrivateKey": {
        "reference": {
          "keyVault": {
            "id": "/subscriptions/[subscriptionId]/resourceGroups/[rgName]/providers/Microsoft.KeyVault/vaults/[keyVaultName]"
          },
          "secretName": "[secretName]"
        }
      }
  ```
  instead of this:

  ```
      "gitSshPrivateKey": {
        "type": "string",
        "metadata": {
          "description": "SSH Private Key to authenticate against the git repo"
        }
      }
  ```
  * The Inbound NAT rule on the load balancer is for dev purposes. Remove before deploying to production.

