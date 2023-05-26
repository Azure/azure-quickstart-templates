// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// Parameters
//==============================================================================

targetScope = 'resourceGroup'

@sys.description('Optional. Display name for the workbook used in the Gallery. Must be unique in the resource group.')
param displayName string = 'Cost optimization'

@sys.description('Optional. Location of the resources. Default: Same as deployment. See https://aka.ms/azureregions.')
param location string = resourceGroup().location

@sys.description('Optional. Workbook description.')
param description string = 'Reports to help you optimize your cost.'

@sys.description('Optional. Tags for all resources.')
param tags object = {}

var version = ''
var workbookJson = string(loadJsonContent('workbook.json'))

//==============================================================================
// Resources
//==============================================================================

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: guid(resourceGroup().id, 'Microsoft.Insights/workbooks', displayName)
  location: location
  tags: tags
  kind: 'shared'
  properties: {
    category: 'workbook'
    description: description
    displayName: displayName
    serializedData: workbookJson
    sourceId: 'Azure Monitor'
    version: version
  }
}

//==============================================================================
// Outputs
//==============================================================================

@sys.description('The resource ID of the workbook.')
output workbookId string = workbook.id

@sys.description('Link to the workbook in the Azure portal.')
output workbookUrl string = '${environment().portal}/#view/AppInsightsExtension/UsageNotebookBlade/ComponentId/Azure%20Monitor/ConfigurationId/${uriComponent(workbook.id)}/Type/${workbook.properties.category}/WorkbookTemplateName/${uriComponent(workbook.properties.displayName)}'
