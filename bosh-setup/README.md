# Setup Bosh Deployment VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This template can help you setup the development environment to deploy [BOSH](http://bosh.io/) and [Cloud Foundry](https://www.cloudfoundry.org/) on Azure. It will create a virtual machine with a dynamic public IP address, a storage account, a virtual network, 2 subnets and 2 reserved public IP addresses.

You can follow the guide [**HERE**](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/guidance.md) to deploy Cloud Foundry on Azure. From the guide, you can also get how to set the parameters (e.g. tenantID).

After the VM is created, you can logon to the VM and see ~/install.log to check whether the installation is finished.
After the installation is finished, you can execute "./deploy_bosh.sh" in your home directory to deploy bosh and see ~/run.log to check whether bosh is deployed successfully.

If you have any question about this template or the deployment of Cloud Foundry on Azure, please feel free to give your feedback [**HERE**](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues).

We look forward to hearing your feedback and suggestions!
