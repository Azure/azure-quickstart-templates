# Install a Solace Message Router onto a Linux Virtual Machine using Docker and Custom Extensions

The Solace Virtual Message Router (VMR) provides enterprise-grade messaging capabilities deployable in any computing environment. The VMR provides the same rich feature set as Solace’s proven hardware appliances, with the same open protocol support, APIs and common management. The VMR can be deployed in the datacenter or natively within all popular private and public clouds. 

How to Deploy a VMR
-------------------
This is a 2 step process:

* Go to the Solace Developer portal and request a Solace Comunity edition VMR. This process will return an email with a Download link.

<a href="http://dev.solace.com/downloads/download_vmr-ce-docker" target="_blank">
    <img src="https://raw.githubusercontent.com/SolaceLabs/solace-azure-quickstart-template/master/register.png"/>
</a>

* Hit the "Deploy to Azure" button and in the dployment template add in the link to the VMR provided by Solace. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FSolaceLabs%2Fsolace-azure-quickstart-template%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FSolaceLabs%2Fsolace-azure-quickstart-template%2Fmaster2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

# Gaining admin access to the VMR

For persons used to working with Solace message router console access, this is still available with the google compute engine instance.  Access the web ssh terminal window by clicking the [ssh] button next to your VMR instance,  then launch a SolOS cli session:

![alt text](https://raw.githubusercontent.com/SolaceLabs/solace-gcp-quickstart/master/images/azure_console.png "console with SolOS cli")

For persons who are unfamiliar with the Solace mesage router or would prefer an administration application the SolAdmin managmanent application is available.  For more information on SolAdmin see the [SolAdmin page](http://dev.solace.com/tech/soladmin/).  To get SolAdmin, visit the Solace [download page](http://dev.solace.com/downloads/) and select OS version desired.  Access IP will be the External IP accosiated with youe GCE instance and port will be 8080 by default.

![alt text](https://raw.githubusercontent.com/SolaceLabs/solace-gcp-quickstart/master/images/azure-soladmin.png "soladmin connection to gce")

# Testing data access to the VMR

To test data traffic though the newly created VMR instance, visit the Solace developer portal and and select your prefered programming langauge to [send and receive messages](http://dev.solace.com/get-started/send-receive-messages/). Under each language there is a Publish/Subscribe tutorial that will help you get started.

![alt text](https://raw.githubusercontent.com/SolaceLabs/solace-gcp-quickstart/master/images/solace_tutorial.png "getting started publish/subscribe")

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

See the list of [contributors](https://github.com/azure-quickstart-templates/solace-community-edition/graphs/contributors) who participated in this project.

## License

This project is licensed under the Apache License, Version 2.0. - See the [LICENSE](LICENSE) file for details.

## Resources

For more information about writing Azure Resource Manager(ARM) templates and Azure quickstart templates try these resources:

- [Authoring Azure Resource Manager templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authoring-templates)
- [Azure Quickstart Templates](https://azure.microsoft.com/en-us/resources/templates/)

For more information about Solace technology in general please visit these resources:

- The Solace Developer Portal website at: http://dev.solace.com
- Understanding [Solace technology.](http://dev.solace.com/tech/)
- Ask the [Solace community](http://dev.solace.com/community/).
