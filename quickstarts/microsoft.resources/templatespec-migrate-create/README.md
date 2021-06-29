# Create TemplateSpecs from Template Gallery Templates

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.resources/templatespec-migrate-create/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-migrate-create%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-migrate-create%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.resources%2Ftemplatespec-migrate-create%2Fazuredeploy.json)

This sample shows how to create templatesSpecs from a template.  The sample also contains a script that can export templates from the Template Gallery in the Azure Portal.

The azuredeploy.json file in the repo simply creates a templateSpec from a linked templates in the repo.  The Migrate-GalleryItems.ps1 script will export templates from the Microsoft.Gallery RP can create templateSpecs or provide templates that create templateSpecs from the templates stored in the Gallery.  See the [Migration](#Migrating-from-Template-Gallery-to-TemplateSpecs) section for more detail.

## TemplateSpecs

See the [templateSpec documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-specs) for more information on how to use templateSpecs in Azure.

## azuredeploy.json

This sample template will deploy a list of linked templates and is generic for that purpose.  The parameter file associated will contain the relative paths of the nested templates to be deployed.  This pattern is the pattern used by the migration script and should scale to hundreds of templates.

## Migrating from Template Gallery to TemplateSpecs

This sample also contains a PowerShell script that can be used to migrate or copy templates from the [Template Gallery in the Azure portal](https://portal.azure.com/#blade/HubsExtension/BrowseResourceBlade/resourceType/Microsoft.Gallery%2Fmyareas%2Fgalleryitems) to templateSpec resources in Azure.  TemplateSpecs will replace the Azure portal's Template Gallery that currently stores templates from the gallery.

The migration script can create ARM Templates that will create the templateSpecs or directly create templateSpecs.  Additionally permissions can be set on the newly created templateSpecs or added the the ARM Templates.  Templates are not removed from the gallery and you can easily delete and create the files or templateSpecs that are created by simply removing the files or the resourceGroup.  

When the script exports the templates to a file that will create a templateSpec, the azuredeploy.parameters.json file will be populated with the relative path of each file that's created, so they can easily be deployed as a group using azuredeploy.json.

The following parameters or options are available on the script.  Note that there are no required parameters, if none are provided, the script will only list the templates found available to the current user context.

| Name | Type | Required | Description |
| :------------- | :----------: | :----------: | :------------- |
| ItemsToExport | string | No | Specifies the set of templates to migrate. ```MyGalleryItems``` will migrate only the items in the current user's gallery, not all items the user may have access to. ```AllGalleryItems``` will migrate all of the items the user has access to.
| ExportToFile | switch | No | Specifies whether to create an ARM template that will create a templateSpec from the template in the gallery.  If provided, one template will be created for each item in the gallery.  azuredeploy.parameters.json will also be updated with the relative path of each file that is created.|
| MigrateRBAC | switch | No | Specifies whether to migrate permissions that exist on the current gallery items to the templateSpec.  When ```ExportToFile``` is provided, the roleAssignemnts will be added to the template file.  When templateSpecs are created, the roleAssignments will be applied to the templateSpecs as they are created.  In addition, when templateSpecs are created, any roleAssignments on the gallery itself will be applied to the resourceGroup that contains the templateSpecs.  roleAssignments at the gallery level are not included in the exported files.|
| ResourceGroupName | string | No | When provided, templateSpecs will be created during script execution.  The resourceGroup will be created if it does not already exist.  The ```location``` parameter is required when the ResourceGroupName is provided.|
| Location | string | No | Required when ```ResourceGroupName``` is provided, specifies the location for all templateSpecs.  If the resourceGroup does not exist it will also be created in this location.|

### Notes

A few notes to help with usage and understanding of the script and migration process.

* When exporting AllGalleryItems, specifically for items in galleries not owned by the current user context, note the following:
  * Naming collisions can occur when creating templateSpecs since all templateSpecs will reside in the same resourceGroup.  A single attempt will be made to change the name to avoid the collision using the origin galleryName, which is the objectId of the owner of the gallery.
  * The current user context may not have permission to query roleAssignments for shared items, i.e. items not in the gallery owned by the user, and if so, roleAssignments will not be migrated for those items.

* The script does not have an option to simply export the galleryItem as an ARM Template (only a templateSpec) but the template object is available in the $templateJSON variable.  If for some reason you just want to export the ARM Template and not migrate to a templateSpec the script can be easily modified.

* If there are a large number of items in the gallery, the API response will be paged - this script does not follow the link to the next page so will only export from the first page.

* Currently when templateSpecs are created from the script, the sort order of the template properties is changed by conversion to JSON so the source code in the resource itself may not look familiar.  To work around this, export the galleryItems to a file and manually deploy the templateSpecs from that file using the azuredeploy.json template in the sample.  The azuredeploy.parameters.json file created by this script can be used with azuredeploy.json to deploy all exported templates.
