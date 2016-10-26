### Best Practice Checklist
Check these items before submitting a PR...

+ uri's compatible with all clouds (Stack, China, Government)
+ Staged artifacts use _artifactsLocation & _artifactsLocationSasToken
+ Use resourceGroup().location for resource locations
+ Folder names for artifacts (nestedtemplates, scripts, DSC)
+ Use literal values for apiVersion (no variables)
+ Parameter files (GEN-UNIQUE for value generation and no "changemeplease" values
+ $schema and other uris use https
+ Use uniqueString() whenever possible to generate names for resources.  While this is not required, it's one of the most common failure points in a deployment. 
+ Update the metadata.json with the current date

For details: https://github.com/Azure/azure-quickstart-templates/blob/master/1-CONTRIBUTION-GUIDE/bp-checkist.md

### Changelog
*
*
*

### Description of the change