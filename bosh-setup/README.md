# Setup Bosh Deployment VM

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fbosh-setup%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template can help you setup the development environment to deploy [BOSH](http://bosh.io/) and [Cloud Foundry](https://www.cloudfoundry.org/) on Azure.

You can follow the guide [**HERE**](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/blob/master/docs/guidance.md) to deploy Cloud Foundry on Azure.

If you have any question about this template or the deployment of Cloud Foundry on Azure, please feel free to give your feedback [**HERE**](https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release/issues).

We look forward to hearing your feedback and suggestions!

```
Template Changelog

# v1.3.0 (2016-04-01)
- Does not bind network security groups to subnets but bind network security groups to VMs.
- Upgrade versions
  - Upgrade Azure CPI version to v9. Please see new features in https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release

# v1.2.0 (2016-03-28)
- Add a subnet for Diego
- Create network security groups for all subnets
- Upgrade versions
  - Upgrade Azure CPI version to v8. Please see new features in https://github.com/cloudfoundry-incubator/bosh-azure-cpi-release

# v1.1.3 (2016-03-08)
- Upgrade versions
  - Upgrade bosh version to 255.3
  - Upgrade cf version to 231

# v1.1.2 (2016-03-01)
- Change the default value of "autoDeployBosh" to "enabled"
- Run "apt-get update" at the beginning of "setup_env"

# v1.1.1 (2016-02-23)
- Upgrade versions
  - Upgrade bosh version to 255.1

# v1.1 (2016-02-13)
- New features
  - Support deploying Bosh automatically
- Parameters and Variables
  - Remove the parameter "newStorageAccountName" and generate it by uniqueString()
  - Create the dev-box with SSH Keys
  - Make service principal parameters required and fixed-length
  - Move the parameter "vmSize" into a variable
  - Move the parameters about vnet & subnet to variables
  - Change the CIDR of the subnet for Cloud Foundry to /20
- Render the manifest of Bosh
  - Autofill the service principal
- Render the manifest of Cloud Foundry
  - Autofill the virtual network name, the subnet name and so on.
- Upgrade versions
  - Upgrade bosh_cli version to 1.3169.0
  - Upgrade bosh-init version to 0.0.81
  - Upgrade API version to the latest 2015-06-15
  - Upgrade to Ubuntu Server 14.04.3 LTS
  - Upgrade the default "storageAccountType" into Standard_RAGRS
  - Upgrade the version of CustomScript Extension to 1.4
    - Download the scripts and manifests via fileUris
    - Put commandToExecute into protectedSettings to protect users' credentials
- Add CI pipeline to test bosh-setup deployment

# v1.0 (2015-11-02) - GA Version

# Preview II Version (2015-08-25)

# Preview Version (2015-05-29)
```
