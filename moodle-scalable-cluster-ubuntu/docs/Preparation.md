# Environment Preparation

This document describes how to ensure your environment is configured
for working with Moodle on Azure.

## Prerequisites

In order to configure our deployment and tools we'll set up some
[environment variables](./Environment-Variables.md) to ensure consistency.

## Required software

We'll use a number of tools when working with Moodle on Azure. Let's
ensure they are all installed:

``` shell
sudo apt-get update
sudo apt-get install wget -y
sudo apt-get openssh-client -y
```

The [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest) is also important:

```bash
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli
```

## Ensure we have a valid SSH key pair

We use SSH for secure communication with our hosts. The following line
will check there is a valid SSH key available and, if not, create one.

```
if [ ! -f "$MOODLE_SSH_KEY_FILENAME" ]; then ssh-keygen -t rsa -N "" -f $MOODLE_SSH_KEY_FILENAME; fi
```
## Checkout the Moodle ARM Template

The Moodle Azure Resource Manager template is hosted on GitHub. We'll
checkout the template into our workspace.

```
git clone git@github.com:Azure/Moodle.git $MOODLE_AZURE_WORKSPACE/arm_template
```

# Validation

After completing these steps we should have, amonst other things, a
complete checkout of the Moodle templates from GitHub:

``` bash
ls $MOODLE_AZURE_WORKSPACE/arm_template
```

Results:

``` expected_similarity=0.4
azuredeploy.json  azuredeploy.parameters.json  CONTRIBUTE.md  docs  env.json  etc  images  LICENSE  LICENSE-DOCS  metadata.json  nested
README.md
```

We should also have a number of applications installed, such as the Azure CLI:

``` bash
if hash az 2>/dev/null; then echo "Azure CLI Installed"; else echo "Missing dependency: Azure CLI"; fi
```

```
AzureCLI Installed
```
