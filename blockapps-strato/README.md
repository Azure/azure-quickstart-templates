[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblockapps-strato%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fblockapps-strato%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

To create a STRATO deployment, use the quickstart button and provide
the requested parameters.  We request your email to provide support
and to know our users; the others are Azure-specific.  Please note
that the storage account name must be lowercase letters only and at
most 24 characters long.

Once the deployment is complete, you will have a virtual machine whose
name is the `deploymentName` you chose.  Its generic URL is
```<deploymentName>.centralus.cloudapp.azure.com``` It can be accessed
via `ssh` with username `strato` and the password you chose.  It also
hosts our web API on port 80 via http at this URL, so you may not need
to SSH in.

If you log in via ssh, you can enter the Docker container running
STRATO using the command ```docker exec -it strato /bin/bash``.  If
the container exits, you can restart it with ```docker start
strato```.  Outside the container, you can work in the VM's Ubuntu
environment, including updating your Docker image by running ```docker
pull blockapps/strato:ubuntu```.  The STRATO container can be replaced
by the new image by running ```sudo docker-compose up -d -f
/etc/docker/compose/docker-compose.yml```.  Be warned that this will
cause the loss of your entire blockchain.

Inside the container, the `strato` command is available to start,
stop, or restart the suite of processes comprising STRATO.  If any of
the processes exits other than by calling `strato stop`, the container
will exit and must be restarted with ```docker restart strato```.
Initially, STRATO runs a test blockchain using an artificial genesis
block in `/etc/strato/genesis`; if you place another one (as a
JSON-formatted file `<blockchain>.json`) there, you can restart the
blockchain with this genesis block using ```strato init
<blockchain>```.  The previous blockchain will not be recoverable,
however.