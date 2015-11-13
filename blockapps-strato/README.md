[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblockapps-strato%2Fazuredeploy.json)

These templates are currently not ready for external deployment and
will only work for users with access to BlockApps' Azure subscription.

# A screencap walkthrough of the process:

Click the deploy button

![](./readme-images/01-deploy-button.png)

Set the parameters.  Please note the resource group "blockapps".

![](./readme-images/02a-parameters.png)

Agree to the terms and conditions

![](./readme-images/03a-agreement.png)

Watch it deploy

![](./readme-images/04a-deploying.png)

Then SSH in from your terminal.  Make sure to request user "strato"

![](./readme-images/05a-ssh-live.png)

Here is the VM at work

![](./readme-images/06a-ethereum-vm.png)

The "dev" image only differs a little:

![](./readme-images/05b-ssh-dev.png)
