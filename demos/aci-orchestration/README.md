---
description: Scaling Single-Container Azure Container Groups using PowerShell.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: aci-orchestration
languages:
- json
- bicep
- powershell
---
# Azure Container Instances - Scaling with PowerShell

This template demonstrates how you can manually scale up and down [Azure Container Groups](https://docs.microsoft.com/azure/container-instances/) by deploying an Azure Container Group with a single container and then using Powershell to add or remove Azure Container Groups hosting a replica container.

To start, you'll want to create a resource group and then deploy the bicep template first. The template will deploy an Azure Container Group with a single container running a simple web app. Once deployed, you can use the powershell script and a configuration file to scale up or down the number of replicas.

The bicep templates deploys the following resources:

- An Azure Container Group with a single container running a simple web app.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli?view=azure-cli-latest)
- [PowerShell](https://docs.microsoft.com/powershell/scripting/install/installing-powershell?view=powershell-7.1)

## Deployment steps

Deploy a resource group and bicep template using the following az cli commands:

```powershell
az group create --name 'aci-orchestration-rg' --location "Central US"
az deployment group create --name deployaci --resource-group 'aci-orchestration-rg' --template-file main.bicep --parameters param.json
```

## Usage

### Connect

Confirm deployment by visiting the ipaddress of the container group in a browser.

#### Management

1. Preview the config.json file and ensure the values match your deployment.
2. Run any of the following commands to scale up or down the number of replicas.

    ```powershell
    # Scales up or down the number of Azure Container Groups to a desired state of 2.
    .\scripts\ScaleContainerGroups.ps1 -CONFIG_PATH .\scripts\config.json -COMMAND run -DESIRED_REPLICA_COUNT 2
    ```

    ```powershell
    # Requests a view of all currently provisioned Azure Container Groups.
    .\scripts\ScaleContainerGroups.ps1 -CONFIG_PATH .\scripts\config.json -COMMAND view
    ```

    ```powershell
    # Restarts all currently provisioned Azure Container Groups with a container in a running state. Stopped containers will not be restarted.
    .\scripts\ScaleContainerGroups.ps1 -CONFIG_PATH .\scripts\config.json -COMMAND restart
    ```

    ```powershell
    # Stops all currently provisioned Azure Container Groups.
    .\scripts\ScaleContainerGroups.ps1 -CONFIG_PATH .\scripts\config.json -COMMAND stop
    ```

    ```powershell
    # Deletes all currently provisioned Azure Container Groups.
    .\scripts\ScaleContainerGroups.ps1 -CONFIG_PATH .\scripts\config.json -COMMAND delete
    ```

### Deployment Script Args

| Command Parameter | Arguments | Description | Required |
| --- | --- | --- | --- |
| `COMMAND` | "run", "view", "restart", "stop", "delete" | Specifies the command to execute. | Required |
| `CONFIG_PATH` | "path/to/config.json" | Specifies the path to the configuration file. | Required |
| `DESIRED_REPLICA_COUNT` | 5 | Specifies the desired replica count. | Optional |
| `SKIP_CONFIRMATION` | true | Skips user confirmation when replica count changes. | Optional |


`Tags: Microsoft.ContainerInstance/containerGroups, Public, Orchestration`
