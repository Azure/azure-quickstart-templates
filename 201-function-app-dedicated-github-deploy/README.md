# Provision a function app with source deployed from GitHub

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazure%2Fazure-quickstart-templates%2Fmaster%2F201-function-app-dedicated-github-deploy%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-function-app-dedicated-github-deploy%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Overview

This template deploys a Function App hosted in a new dedicated App Service Plan. The Function App has a child resource that enables continous integration and deploys the function code from a GitHub repository.

This template deploys the following resources:

- App Service plan
- Storage Account
- Function App
    - App Settings Configuration
    - Source Control Deployment

## Azure Functions

> Azure functions is a solution for easily running small pieces of code, or "functions," in the cloud. You can write just the code you need for the problem at hand, without worrying about a whole application or the infrastructure to run it. For more information about Azure Functions, see the [Azure Functions Overview](https://azure.microsoft.com/en-us/documentation/articles/functions-overview/).

## Miscellaneous

``Tags: app-service, function, github``
