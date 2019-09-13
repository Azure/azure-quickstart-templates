# Push a certificate onto a VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-push-certificate-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-push-certificate-windows%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Push a certificate onto a VM. Pass in the URL of the secret in Key Vault.  The url must be a secret, not a certificate or key.

Use <a href="https://gist.github.com/bmoore-msft/425b79b7b7e226264554ec534b956a48">this script</a> to create a new cert and put it into the vault.  The script can be easily modified to work with an existing cert.


