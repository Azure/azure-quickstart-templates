// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// App metadata definition
//==============================================================================

@export()
@description('Metadata for resources created by the Cost Management Managed Exports app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('Data Factory pipeline names for public API.')
  pipelines: {
    @description('Pipeline to start the backfill process.')
    startBackfillProcess: string
    @description('Pipeline to start the export process.')
    startExportProcess: string
    @description('Pipeline to configure Cost Management exports.')
    configureExports: string
  }
}
