// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//==============================================================================
// App metadata definition
//==============================================================================

@export()
@description('Metadata for resources created by the Cost Management Exports app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('Storage container names.')
  containers: {
    @description('Container for raw Cost Management export files.')
    msexports: string
  }
  @description('Data Factory dataset names.')
  datasets: {
    @description('JSON dataset for export manifest files.')
    msexportsManifest: string
    @description('CSV dataset for raw export files.')
    msexports: string
    @description('Gzip dataset for compressed export files.')
    msexportsGzip: string
    @description('Parquet dataset for converted export files.')
    msexportsParquet: string
  }
}
