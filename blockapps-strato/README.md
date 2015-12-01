[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblockapps-strato%2Fazuredeploy.json)

Click this button.  Once you've gone through the process, you can access the new instance via the URL

`instancename.centralus.cloudapp.azure.com`

and administrate it by logging in via SSH:

`ssh strato@<the above URL>`

with the password you chose.  You can get directly into the docker
container running STRATO by then running `docker attach strato` or,
more concisely, just logging in via

`ssh -t strato@<the above URL> docker attach strato`

(the `-t` is important, or else docker will complain about the lack of
a TTY).

# A screencap walkthrough of the process:

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
