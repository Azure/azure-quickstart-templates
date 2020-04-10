# Setting Up Your Own CI/CD Pipeline in Azure DevOps

A bit terse for now, but if you want to set up your own AzDO pipeline here are the steps.  Please update this file if you find something missing or unclear.

## After Exporting the Pipeline

You can skip this section if you just need to import a pipeline.

- remove "options" property (if present)
- remove "_links" property
- set "badgeEnabled" property to false (doesn't make sense for this repo)
- remove the "queue" property

## Before Importing the Pipeline

Before importing the JSON file do the following:

- Set the project.id property to the guid of the project the pipeline is being imported into - the easiest way to get that is to create an empty pipeline, export it and look for the project.id property value
- If you forget to do this, the error message in AzDO will also show your project.id but you have to start the import over to fix it

## Importing the Pipeline

After importing, and before saving the pipeline you'll need to do the following:

- Change the name of the pipeline as needed
- Set the agent pool (currently we use Windows Containers)
- Set the repo to run the pipeline on (we use the master branch)
- Remove debug tasks if you don't want them
- Update the "Download Template Toolkit Release" task (should be the first one) to use the correct connection (and repo if needed)
- Set variable values, you need ids and secrets for the Service Principals, the others that need updating will have placeholder text
- Set the appropriate triggers, but default this runs on PRs to master and shares secrets.  The secrets cannot be exposed unless you do something to expose them.
