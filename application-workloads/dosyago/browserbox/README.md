---
description: Deploy BrowserBox remote browser isolation on an Azure virtual machine.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: browserbox
languages:
- json
---
# BrowserBox Azure Edition

[BrowserBox](https://browserbox.io/?utm_source=azure_quickstart&utm_medium=listing&utm_campaign=browserbox) is self-hosted remote browser isolation. It runs a browser on infrastructure you control and streams an interactive view to a modern browser.

This template deploys an Ubuntu 22.04 VM, a public IP address and network security group, then installs and starts BrowserBox using the [public installer](https://docs.browserbox.io/installation/). Azure infrastructure charges and BrowserBox licensing are separate.

## Before deploying

- Obtain a valid BrowserBox license key, including for evaluation. See the [evaluation options](https://browserbox.io/evaluate).
- Supply an email address, an administrator username and an SSH public key. The email is used by the installer for terms agreement and certificate setup; by deploying you accept the [BrowserBox terms](https://dosaygo.com/terms.txt) and the applicable Let's Encrypt terms.
- Enter the license key in the secure `licenseKey` parameter. Treat any parameter file containing it as a secret. The key is not included in the template outputs.
- The default VM size is Standard B2s. Review Azure pricing and restrict inbound access to trusted networks as appropriate. The template permits inbound SSH, HTTP and BrowserBox ports 8078–8082.

## Connect

After the deployment succeeds, use the `azureHostname` output and your SSH key to connect as the administrator. On the VM, obtain the login link with:

```bash
cat ~/.config/dosaygo/bbpro/login.link
```

Open that link in a browser. Treat the link as a secret: anyone who has it may be able to connect to the session. For configuration, certificate and troubleshooting guidance, see the [customer guide](https://docs.browserbox.io/installation/) and [setup documentation](https://docs.browserbox.io/setup/).

`Tags: Microsoft.Compute/virtualMachines, Microsoft.Compute/virtualMachines/extensions, Microsoft.Network/networkSecurityGroups, Microsoft.Network/virtualNetworks, Microsoft.Network/publicIPAddresses, Microsoft.Network/networkInterfaces, CustomScriptExtension`
