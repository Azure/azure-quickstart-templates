@sys.description('The name of storage task.')
@minLength(3)
@maxLength(18)
param storageTaskName string

@sys.description('A description of the storage task.')
param description string

@sys.description('The region in which to create the storage task.')
param location string = resourceGroup().location

@sys.description('Locks the file for one day.')
param lockedUntilDate string = dateTimeAdd(utcNow(), 'P1D')

resource storageTask 'Microsoft.StorageActions/storageTasks@2023-01-01' = {
  name: storageTaskName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    action: {
      if: {
        condition: '[[endsWith(Name, \'.docx\')]]'
        operations: [
         {
            name: 'SetBlobImmutabilityPolicy'
            onSuccess: 'continue'
            onFailure: 'break'
            parameters: {
              untilDate: lockedUntilDate
              mode: 'locked'
            }
         }
         {
            name: 'SetBlobTags'
            onSuccess: 'continue'
            onFailure: 'break'
            parameters: {
                tagsetImmutabilityUpdatedBy: 'StorageTaskQuickstart'
            }     
         }
        ]
      }

    }
    description: description
    enabled: true
  }
}
  
