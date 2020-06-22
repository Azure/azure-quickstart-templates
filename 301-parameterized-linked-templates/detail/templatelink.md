# Use Linked Template for Multiple Resources

#TODO Update Docs Once Template Passes Validation

When referring to linked templates or script files you have to point to a location where the files are accessible to the Azure infrastructure target VMs.  While it is possible to hardcode URIs to these resources, it is easier to utilize the deployment() function to get a link to the base template and then use it to construct a reference to the associated resources.

Example of using `deployment().properties.templateLink.uri` to construct links to scripts in a subfolder for use with the CustomScript extension:
```
"fileUris": [
  "[uri(deployment().properties.templateLink.uri, 'scripts/examplepostinstall1.sh')]",
  "[uri(deployment().properties.templateLink.uri, 'scripts/examplepostinstall2.sh')]"
]
```

Example of using `deployment().properties.templateLink.uri` to construct link to a template in a subfolder:
```
{
  "type": "Microsoft.Resources/deployments",
  "apiVersion": "2019-10-01",
  "name": "ParameterizedBackendVM-Loop",
  ...
  "properties": {
      "mode": "Incremental",
      "expressionEvaluationOptions": {
          "scope": "inner"
      },
      "parameters": {
          "templateUri": {
              "value": "[uri(deployment().properties.templateLink.uri, 'nested/paramvm.json')]"
          },
```

Using the above, you do not have to edit any of the links to subresources, but you will need to start the deployment by pointing to the base template: [azuredeploy.json](azuredeploy.json). The `Deploy to Azure` button in [README.md](../README.md) shows an example of this:

```
[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhallihan%2Farm-examples%2Fmain%2Fazuredeploy.json)
```

Note: If you use this method to link to nested templates, the Redeploy function available when viewing a failed deployment from the Azure Portal will not work since the new deployment will not be based on the template at your published location, but instead from a local copy that Azure allows you to modify via the UI.

[Home](../README.md)