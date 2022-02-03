# Emercoin Instance

This Microsoft Azure template deploys a single Emercoin client which will connect to the public Emercoin network.

Once your deployment is complete you will be able to connect to the Emercoin public network.

![Emercoin-Azure](../images/emercoin.png)

# Emercoin Deployment Walkthrough
1. Get your node's IP
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 3. then expand your resources, and public ip address of your node.

2. Connect to your node
 1. SSH to the public ip of your node as the user you specified for `adminUsername`, enter your `adminPassword`
 2. Try to use the cli-client by `emc help` or `emc getinfo`
 3. Point your browser to the public ip of your node, sign in with `adminUsername` and `adminPassword` specified before (note that browser may show you a warning of bad certificate - it's OK, you may replace the self-signed certificates by yours at /etc/ssl/emc/emcweb*)
