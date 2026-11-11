// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// App metadata definition
//==============================================================================

@export()
@description('Metadata for resources created by the Core app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('URL to use when connecting Power BI reports to data.')
  storageUrlForPowerBI: string
  // TODO: Review whether identity properties should be in metadata or handled differently
  @description('Object ID of the Data Factory managed identity. Needed when configuring managed exports.')
  principalId: string
  @description('Separator characters used between the ingestion ID and file name for ingested files. Used to identify uniqueness and clean up old files with old ingestion IDs.')
  ingestionIdFileNameSeparator: string
  @description('Storage container names.')
  containers: {
    @description('Configuration container for settings, queries, and schemas.')
    config: string
    @description('Ingestion container for normalized data.')
    ingestion: string
  }
  @description('Data Factory dataset names.')
  datasets: {
    @description('JSON dataset for configuration files.')
    config: string
    @description('Parquet dataset for ingested data.')
    ingestion: string
    @description('Parquet dataset for listing ingested files.')
    ingestionFiles: string
    @description('JSON dataset for ingestion manifest files.')
    ingestionManifest: string
  }
  @description('Data Factory linked service names.')
  linkedServices: {
    @description('REST linked service for Azure Resource Manager API calls.')
    azurerm: string
  }
  @description('Metadata for the hub settings file.')
  settings: {
    @description('Container name for the hub settings file.')
    container: string
    @description('File name of the hub settings file.')
    file: string
  }
}
