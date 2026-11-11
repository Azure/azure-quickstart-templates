// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// App metadata definition
//==============================================================================

@export()
@description('Metadata for resources created by the Ingestion Queries app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('Metadata for query definition files.')
  queries: {
    @description('Container name for query definition files.')
    container: string
    @description('Folder path for query definition files within the container.')
    folder: string
  }
}
