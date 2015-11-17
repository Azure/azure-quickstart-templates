This template creates is intended to be your starting point to
creating new templates that configure an Azure Container Service.


Mesos with Linux jumpbox: <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Frgardler%2Fazure-quickstart-templates%2Facs%2Fcservice%2Fazuredeploy.json" target="_blank"><img src="http://azuredeploy.net/deploybutton.png"/></a>

# Creating your own template from this base template

All configuration values are set as variables with sensible defaults
provided. The bare minimum of these are exposed as parameters to the
user. To modify this template for your own use simply copy this
template and change appropriate variable values and/or add parameters
to enable users to customize those values.

For example:

If you want to change the DNS name postfix for the management interface from the default "man" to "manage" find the line `"managementEndpointDNSNamePrefix": "[concat(parameters('DNSNamePrefix', 'man'))]"` and replace it with     "managementEndpointDNSNamePrefix": "[concat(parameters('DNSNamePrefix', 'manage'))]"`.

If you would prefer a Windows Jumpbox rather than a Linux one then change `"jumpboxOS": "Linux"` to `"jumpboxOS": "Windows"`

If you would like users to select the jumpbox OS then `"jumpboxOS": "Linux"` to `"jumpboxOS": "[parameters('jumpboxOS')]` and add the following code to the parameters section of the template:

```
    "jumpboxOS": {
      "type": "string",
      "defaultValue": "Windows",
      "allowedValues": [
        "Windows",
        "Linux"
      ],
      "metadata": {
        "description": "The preferred operating system for the Jumpbox."
      }
    },
```

