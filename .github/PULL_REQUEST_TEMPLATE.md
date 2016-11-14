### Best Practice Checklist
Check these items before submitting a PR... See the Contribution Guide for the full detail: https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/README.md 

1. uri's compatible with all clouds (Stack, China, Government)
1. Staged artifacts use _artifactsLocation & _artifactsLocationSasToken
1. Use resourceGroup().location for resource locations
1. Folder names for artifacts (nestedtemplates, scripts, DSC)
1. Use literal values for apiVersion (no variables)
1. Parameter files (GEN-UNIQUE for value generation and no "changemeplease" values
1. $schema and other uris use https
1. Use uniqueString() whenever possible to generate names for resources.  While this is not required, it's one of the most common failure points in a deployment. 
1. Update the metadata.json with the current date

For details: https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/bp-checklist.md

- [ ] - Please check this box once you've submitted the PR if you've read through the Contribution Guide and best practices checklist.

### Changelog

*
*
*

