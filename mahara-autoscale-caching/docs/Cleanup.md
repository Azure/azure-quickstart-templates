# Cleanup All Resource

To cleanup a Mahara deployment simply delete the Resource Group that
contains it. The commands below will iterate over your workspace
directory and delete all deployments.

## Prerequisites

First we need to ensure our [environment variables](./Environment-Variables.md) are correctly configured.

## Remove each resource group

This command will delete all resources in *all* resource groups. Run
with caution.

Note, that this command will not fully delete the resource group if
you have Azure Backup enabled since the Recovery Services Vault will
not be deleted (it's got the backups of you data!).

``` bash
for filename in $MAHARA_AZURE_WORKSPACE/*; do az group delete --yes --name $(basename $filename) --no-wait; done
```
