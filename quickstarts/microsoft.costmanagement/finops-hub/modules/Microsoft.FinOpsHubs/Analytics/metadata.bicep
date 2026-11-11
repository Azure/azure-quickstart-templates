// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// App metadata definition
//==============================================================================

@export()
@description('Metadata for resources created by the Analytics app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('Data Explorer cluster or Fabric endpoint properties.')
  cluster: {
    @description('Resource ID of the cluster. Empty if using Fabric.')
    id: string
    @description('Name of the cluster. Empty if using Fabric.')
    name: string
    @description('URI of the cluster or Fabric query endpoint.')
    uri: string
    @description('Object ID of the cluster system-assigned managed identity. Empty if using Fabric.')
    principalId: string
  }
  @description('Database names.')
  databases: {
    @description('Database used for data ingestion.')
    ingestion: string
    @description('Database used for queries.')
    hub: string
  }
  @description('Data Factory linked service names.')
  linkedServices: {
    @description('Linked service for Azure Data Explorer or Microsoft Fabric.')
    hubDataExplorer: string
    @description('HTTP linked service for the FinOps toolkit GitHub repository.')
    ftkRepo: string
  }
  @description('Data Factory dataset names.')
  datasets: {
    @description('Dataset for Azure Data Explorer or Microsoft Fabric.')
    hubDataExplorer: string
    @description('Dataset for FinOps toolkit release files from GitHub.')
    ftkReleaseFile: string
  }
}
