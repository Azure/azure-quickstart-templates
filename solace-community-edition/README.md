# Install a Solace Message Router onto a Linux Virtual Machine using Docker and Custom Extensions

The Solace Virtual Message Router (VMR) provides enterprise-grade messaging capabilities deployable in any computing environment. The VMR provides the same rich feature set as Solace’s proven hardware appliances, with the same open protocol support, APIs and common management. The VMR can be deployed in the datacenter or natively within all popular private and public clouds. 

How to Deploy a VMR
-------------------
This is a 2 step process:

* Go to the Solace Developer portal and request a Solace Comunity edition VMR. This process will return an email with a Download link.

<a href="http://dev.solace.com/downloads/download_vmr-ce_hyper-v/" target="_blank">
    <img src="https://raw.githubusercontent.com/KenBarr/Solace_ARM_Quickstart_Template/master/register.png"/>
</a>

* Hit the "Deploy to Azure" button and in the dployment template add in the link to the VMR provided by Solace. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FKenBarr%2FSolace_ARM_Quickstart_Template%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FKenBarr%2FSolace_ARM_Quickstart_Template%2Fmaster2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

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
