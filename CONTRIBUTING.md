# Contributing guide

This is a repo that contains all the currently available Azure Resource Manager templates contributed by the community. We'll soon allow a way for these templates to be indexed on [Azure.com](http://azure.microsoft.com) and be discoverable from there.

To make sure your template is added to Azure.com index, please follow these guidelines. Any templates that are out of compliance will be added to the **blacklist.json** file and not be indexed on Azure.com

1.	Every template must be contained in its own **folder**. Name this folder something that describes what your template does
2.	The template file must be named **azuredeploy.json**
3.	The template folder must host the **scripts** that are needed for successful template execution
4.	The template folder must contain a **metadata.json** file to allow the template to be indexed on [Azure.com](http://azure.microsoft.com)
  *	Guidelines on the metadata file below
5.	Every parameter in the template must have the **description** specified using the metadata property. See the starter template is provided [here](https://github.com/azurermtemplates/azurermtemplates/tree/master/100-starter-template-with-validation) on how to do this
6.	OPTIONAL: The folder may contain a **Readme.md** file for any additional information about the template

## metadata.json file

Here are the required parameters for a valid metadata.json file

To be more consistent with the Visual Studio and Gallery experience we're updating the metadata.json file structure. The new structure looks like below

    {
      "itemDisplayName": "",
      "description": "",
      "summary": "",
      "githubUsername": "",
      "dateUpdated": "<e.g. 2015-12-20>"
    }

The metadata.json file will be validated using these rules

**itemDisplayName**
*	Cannot be more than 60 characters

**description**
*	Cannot be more than 1000 characters
*	Cannot contain HTML

**summary**
*	Cannot be more than 200 characters

**githubUsername**
*	Username must be the same as the username of the author submitting the Pull Request

**dateUpdated**
*	Must be in yyyy-mm-dd format.
*	The date must not be in the future to the date of the pull request

## Starter template

A starter template is provided [here](https://github.com/azurermtemplates/azurermtemplates/tree/master/100-starter-template-with-validation) for you to follow
