# Eris Platform

This Microsoft Azure template deploys the Eris platform for you.

![Eris-Platform](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/eris-platform/images/eris_platform.png)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Feris-platform%2Fazuredeploy.json)

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Feris-ltd%2Fazure-quickstart-templates%2Ftest%2Feris-platform%2Fazuredeploy.json)

# Template Parameters

When you launch the installation, you need to specify the following parameters:

* `newStorageAccountNamePrefix`: make sure this is a unique identifier. Azure Storage's accounts are global so make sure you use a prefix that is unique to your account otherwise there is a good change it will clash with names already in use.
* `vmDnsName`: this is the public DNS name for the VM that you will use interact with your eris machine. You just need to specify an unique name.
* `adminUsername`: self-explanatory. This is the account you will use for connecting to your eris machine.
* `adminPassword`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number.
* `vmSize`: The type of VM that you want to use for the node. The default size is A1 (Eris, as a proof of stake chain does not require the massive resources of other blockchain designs) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to.

# Services To Start

After installing `eris` the template is able to start any of eris' [default services](https://github.com/eris-ltd/eris-services) on your behalf. These include:

* `bitcoin` -- one click bitcoin full nodes? easy peesy with eris, just add `btcd` to the field.
* `ethereum` -- one click ethereum full nodes? easy peesy with eris, just add `eth` to the field.
* `ipfs` -- one click ipfs full nodes? easy peesy with eris, just add `ipfs` to the field.

More services are available at the link above. As many services as you need you can add in a comma separated list to the `servicesToStart` field on template deployment.

**N.B.** -- If you want to run a BTC or and ETH full node then you will definitely need to increase the node size from the default.

# Chains to Start

After starting the required services, the template is capable of starting [eris:db](https://erisindustries.com/components/erisdb/) chains. Currently the following options are available:

* `simplechain` -- a single node chain useful for very simple proofs of concept. It is a scripted version of our [chain making tutorial](https://docs.erisindustries.com/tutorials/chainmaking/).

More will be coming soon.

# More About Eris

Please see our [extensive documentation](https://docs.erisindustries.com). You can skip the getting started tutorial and head straight for the [chain making tutorial](https://docs.erisindustries.com/tutorials/chainmaking/) if you like.
