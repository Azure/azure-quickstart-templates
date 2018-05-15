# Environment Preparation

This document describes how to ensure your environment is configured
for working with Mahara on Azure.

## Prerequisites

In order to configure our deployment and tools we'll set up some
[environment variables](./Environment-Variables.md) to ensure consistency.

## Required software

We'll use a number of tools when working with Mahara on Azure. Let's
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
if [ ! -f "$MAHARA_SSH_KEY_FILENAME" ]; then ssh-keygen -t rsa -N "" -f $MAHARA_SSH_KEY_FILENAME; fi
```

## Create Workspace

Ensure the workspace for this particular deployment exists:

```
mkdir -p $MAHARA_AZURE_WORKSPACE/$MAHARA_RG_NAME
```

## Checkout the Mahara ARM Template

The Mahara Azure Resource Manager template is hosted on GitHub. We'll
checkout the template into our workspace.

```
git clone git@github.com:Azure/Mahara.git $MAHARA_AZURE_WORKSPACE/arm_template
```
