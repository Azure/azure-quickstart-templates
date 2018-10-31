# Use output from a Custom Script Extension during Deployment

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-custom-script-output%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

This sample shows how to get output from a custom script extension for use in deployment.  Additionally, it shows applying the custom script a second time in the same deployment.

The flow is as follows:
- Create a VM
- Apply the Custom Script Extension to the VM and output the results of the execution of the instance
- Apply the CSE a second time with a different script that consumes that output
- Output the desired string from the deployment

This is useful to the VM's compute to perform some task during deployment that Azure Resource Manager does not provide.  The output of that compute (script) can then be leveraged elsewhere in the deployment.  This is useful if the compute resource is needed in the deployment (e.g. a jumpbox, DC, etc), a bit wasteful if it is not.

NOTE: The json output from the custom script extension differs between Windows and Linux, which adds an if() statement when trying to use a generic template like this sample.  In practice, you probably know which one you need.

The template will output the instanceView of the extension, samples are included below. The sample uses a token (#DATA#) at the beginning and the end of the output we're interested in, so it can be easily parsed from all stdout messages.

### Linux Output

```json
{
    "name": "cse-linux",
    "type": "Microsoft.Azure.Extensions.CustomScript",
    "typeHandlerVersion": "2.0.6",
    "statuses": [
        {
            "code": "ProvisioningState/succeeded",
            "level": "Info",
            "displayStatus": "Provisioning succeeded",
            "message": "Enable succeeded: \n[stdout]\n#DATA#\nthis is the droid you have been looking for\n#DATA#\n\n[stderr]\n"
        }
    ]
}
```
### Windows Output
```json
{
    "name": "cse-windows",
    "type": "Microsoft.Compute.CustomScriptExtension",
    "typeHandlerVersion": "1.9.1",
    "substatuses": [
        {
            "code": "ComponentStatus/StdOut/succeeded",
            "level": "Info",
            "displayStatus": "Provisioning succeeded",
            "message": "#DATA#\\nThis is the droid you have been looking for...\\n#DATA#"
        },
        {
            "code": "ComponentStatus/StdErr/succeeded",
            "level": "Info",
            "displayStatus": "Provisioning succeeded",
            "message": ""
        }
    ],
    "statuses": [
        {
            "code": "ProvisioningState/succeeded",
            "level": "Info",
            "displayStatus": "Provisioning succeeded",
            "message": "Finished executing command"
        }
    ]
}
```
