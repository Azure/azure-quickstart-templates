# Qlik Sense Enterprise

Qlik Sense Enterprise deployed on Microsoft Azure enables customers to take advantage of a revolutionary, enterprise-level visual analytics platform while leveraging an existing license investment. Now customers can harness the power of Qlik’s visual analytics platform on best-of-breed cloud infrastructure for greater scalability, agility and security and rapid time to value.

## ARM Template

This template will deploy two new Virtual Machines which will be part of a newly created Qlik Sense Enterprise site.

The following versions of Qlik Sense can be provisioned:

| Qlik Sense Version |
|--------------------|
| Qlik Sense November 2017 Patch 1 |
| Qlik Sense November 2017 |
| Qlik Sense September 2017 Patch 1 |
| Qlik Sense September 2017|
| Qlik Sense June 2017 Patch 3 |
| Qlik Sense June 2017 Patch 2 |
| Qlik Sense June 2017 Patch 1 |
| Qlik Sense June 2017  |
| Qlik Sense 3.2 SR5 |
| Qlik Sense 3.2 SR4 |
| Qlik Sense 3.2 SR3 |

## Parameters
The template expects the following parameters

| Name | Description | Default Value |
|------|-------------|---------------|
|_artifactsLocation|The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.|https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/qlik-sense-enterprise-multinode|
|_artifactsLocationSasToken|The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.|
|adminUsername|User account to be created as the administrator.|qlik
|adminPassword|Password for administrator account. Standard Azure password complexity applies.
|centralVmName| The Windows hostname of the virtual machine that will be the Qlik Sense Cental Node.|qlik-sense-cn|
|rimVmName| The Windows hostname of the virtual machine that will be the Qlik Sense Rim Node.|qlik-sense-rn|
|qlikSenseVersion|The Version of Qlik Sense Enterprise to install.|November 2017 Patch 1|
|qlikSenseServiceAccount|The Windows account to be created and used for the Qlik Sense Services|Qservice|
|qlikSenseServiceAccountPassword|The password for the Qlik Sense Service Account.|
|qlikSenseRepositoryPassword|The password for the Qlik Sense repository user (PostgreSQL)|
|qlikSenseSerial|The Serial number of the Qlik Sense license.  If this is left as defaultValue the Qlik Sense site will not be licensed during provisioning| defaultValue|
|qlikSenseControl|The Control number of the Qlik Sense license.|defaultValue|
|qlikSenseOrganization|The Organization owning the Qlik Sense license.|defaultValue|
|qlikSenseName|The Name owning the Qlik Sense license.|defaultValue|
|virtualMachineSize|The size of the virtual machine to be provisioned. Ensure the size chosen exists in the resource location being provisioned into|Standard_DS3_v2|
|windowsOSVersion|The Operating System for the Virtual Machine|2016-Datacenter|

## Deployment

Click the button below to deploy:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fqlik-sense-enterprise-multinode%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fqlik-sense-enterprise-multinode%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## Help

For help please review [Qlik Sense Help](http://help.qlik.com)

Getting started [Qlik Sense Community](http://community.qlik.com)

Qlik Branch [Qlik Branch](http://branch.qlik.com)

Qlik [Main site](http://www.qlik.com)

Support [Qlik Support](http://support.qlik.com)


#### The deployment of Qlik Sense Enterprise can take up to 15 minutes.
