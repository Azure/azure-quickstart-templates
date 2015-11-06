[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblockapps-strato%2Fazuredeploy.json)

# A screencap walkthrough of the process:

Click the deploy button

![](./readme-images/01-deploy-button.png)

Set the parameters.  Please note the resource group "blockapps"; at the moment, you must have access to our Azure subscription to make this deployment.

![](./readme-images/02-deploy-live-screen.png)

You can also specify the "dev" image

![](./readme-images/03-deploy-dev-screen.png)

Confirm your deployment

![](./readme-images/04-confirm-screen.png)

Watch it deploy

![](./readme-images/05-finished-screen.png)

Then SSH in from your terminal.  Make sure to request user "strato"

![](./readme-images/05a-ssh-live.png)

Here is the VM at work

![](./readme-images/06a-ethereum-vm.png)

The "dev" image only differs a little:

![](./readme-images/05b-ssh-dev.png)
