# Azure Resource Manager Templates - Best Practice Checklist

Use this as a quick checklist to ensure your sample meets the minimum set of guidelines for samples in this repository.  For the full set and a detailed explanation see the [**Best Practices Guide**](/1-CONTRIBUTION-GUIDE/best-practices.md#best-practices). 

These practices ensure your sample provides a consistent, reliable experience across all Azure Clouds.

## Checklist

1. All uri's should be compatible with all clouds (Stack, China, Government)
	+ See #9 in [**Best practices**](/1-CONTRIBUTION-GUIDE/best-practices.md#best-practices) 

2. For staging artifacts (scripts, templates, etc) use paramters named _artifactsLocation & _artifactsLocationSasToken - see:
	+ [**Samples that contain artifacts**](https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/best-practices.md#samples-that-contain-extra-artifacts-custom-scripts-nested-templates-etc)
	
3. Use resourceGroup().location for resource locations to be compatible with all clouds
	+ Exceptions for resources that are available on only a few locations (which is not the same as !global)
	+ If a location param is needed do not use parameters named "location", instead resourceLocation or storageLocation, etc.

4. Folder names for artifacts:
	+ nestedtemplates
	+ scripts
	+ DSC

5. Use literal values for apiVersion (do not variables so schema validation can be done)

6. Parameter files must not contain values like "changemeplease" - use default values when appropriate in the template file and leave them out of param files

7. Check whether $schema entries in templates and parameter files are the latest (2015-01-01) and using https

8. Update the metadata.json with the current date

9. Use uniqueString() whenever possible to generate names for resources.  While this is not required, it's one of the most common failure points in a deployment. 

---

### Final Note
If you're submitting a developer sample (101/201/301 level template), use the full best practice guide to ensure the full list of practices have been followed.
