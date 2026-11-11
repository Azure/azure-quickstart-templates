// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@export()
@description('Metadata for resources created by the Azure Resource Graph app.')
type AppMetadata = {
  @description('Fully-qualified app identifier.')
  id: string
  @description('App version.')
  version: string
  @description('Data Factory dataset names.')
  datasets: {
    @description('Dataset for Azure Resource Graph REST API.')
    azureResourceGraph: string
  }
}
