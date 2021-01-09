# Create TemplateSpecs from Template Gallery Templates

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/201-templatespec-migrate-create/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-templatespec-migrate-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-templatespec-migrate-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-templatespec-migrate-create%2Fazuredeploy.json)

This sample shows how to create templatesSpecs from a template and optionally create templates from templates stored in the Azure Portal aka the Microsoft.Gallery RP.

The azuredeploy.json file in the repo simply creates a templateSpec from a linked templates in the repo.  The Migrate-GalleryItems.ps1 script will export templates from the Microsoft.Gallery RP can create templateSpecs or templates that create templateSpecs for those templates.  See the [Migration](#Migrating-from-Template-Gallery-to-TemplateSpecs) section for more detail.

## TemplateSpecs

See the [templateSpec documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs) for more information on how to use templateSpecs in Azure.

## azuredeploy.json

This sample template will deploy a list of linked template and is generic for that purpose.  The parameter file associated will contain the relative paths of the nested templates to be deployed.  This pattern is the pattern used by the migration script and should scale to hundreds of templates.

## Migrating from Template Gallery to TemplateSpecs

This sample contains a PowerShell script that can be used to migrate or copy templates from the [Template Gallery in the Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.Gallery%2Fmyareas%2Fgalleryitems) to templateSpec resources in Azure.  TemplateSpecs will replace the Microsoft.Gallery resource provider that currently stores templates from the gallery.

The migration script can export to file or directly create templateSpecs and also set equivalent permissions on the newly created templateSpecs.  Templates are not removed from the gallery and you can easily delete and create the files or templateSpecs that are created by simply removing the files or the resourceGroup.  

When the script exports the templates to a file that will create the templateSpec, the azuredeploy.parameters.json file will be populated with the relative path of each file that's created, so they can easily be deployed as a group using azuredeploy.json.

The following parameters or options are available on the script.  Note that there are no required parameters, if none are provided, the script will only list the templates found available to the current user context.

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| ItemsToExport | string | No | Specifies the set of templates to migrate. ```MyGalleryItems``` will migrate only the items in the current user's gallery, not all items the user may have access to. ```AllGalleryItems``` will migrate all of the items the user has access to.
| ExportToFile | switch | No | Specifies whether to create an ARM template that will create a templateSpec from the template in the gallery.  If provided, one template will be created for each item in the gallery.  azuredeploy.parameters.json will also be updated with the relative path of each file that is created.|
| MigrateRBAC | switch | No | Specifies whether to migrate permissions that exist on the current gallery items to the templateSpec.  When ```ExportToFile``` is provided, the roleAssignemnts will be added to the template file.  When templateSpecs are created, the roleAssignments will be applied to the templateSpecs as they are created.  In addition, when templateSpecs are created, any roleAssignments on the gallery itself will be applied to the resourceGroup that contains the templateSpecs.  roleAssignments at the gallery level are not included in the exported files.|
| ResourceGroupName | string | No | When provided, templateSpecs will be created during script execution.  The resourceGroup will be created if it does not already exist.  The ```location``` parameter is required when the ResourceGroupName is provided.|
| Location | string | No | Required when ```ResourceGroupName``` is provided, specifies the location for all templateSpecs.  If the resourceGroup does not exist it will also be created in this location.|
