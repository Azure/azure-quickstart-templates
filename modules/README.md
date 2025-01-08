# Azure Resource Manager Template Modules

This folder contains reusable templates or modules that can be used to simplify the creation of common or standard resources.  These can also be used as prereqs for samples in this repo.

A module may contain a single resource (e.g. Microsoft.Compute/galleries) or a set of resources that create an environment or workload (e.g. Active Directory Domain Controller, SQL High Availability).

## Module Readme Files

The readme for a module must contain the following sections:

### Parameters

Parameters are the inputs to a template or module, describe each which creates the contract for a module that cannot be broken with the same module version.  For example, parameters may be added, but not removed or changed (type, defaultValue, constraints).  Parameters that are not required must have a defaultValue, parameters with a defaultValue are not required.

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| param1 | string | No | Describe the use of the parameter... |
| param2 | bool | No | Some boolean parameter |
| location | string | No | The resource location of the gallery |

### Outputs

| Name | Type | Description |
| :------------- | :----------: | :------------- |
| output1 | string | Describe the output and how it might be used.

### ApiVersions

List those used by the module, may be a list of multiple are used.

```apiVersion: 2019-12-01```
