/* Copyright (c) Microsoft Corporation. All rights reserved. 
  This Template deploys a Industrial AI Application
*/

/* Application Selection
  Each application must provide a Plan and a Parameter Mapping.
  */
  param apps object = {
    gamingDevVM : gamingDevVM
  }
  /* Application Plans  
    Each Managed Application requires a plan object. This may be overriden as a parameter input.
    */
    param gamingVMPlan       object = {
      name     : 'gaming-dev-vm-ama'
      product  : 'f39e77ad-ada5-4145-9291-643e6e3ce1b2'
      publisher: publisher
      version  : '0.1.4'
    }   
  /* Application Parameter Mapping 
      Each Managed Application requires a parameter mapping. 
      */
      param gamingDevVM   object = {
        plan: gamingVMPlan
        parameters: {
          location: {
            value: location
          }
          vmSize: {
            value: 'Standard_NV12s_v3'
          }
          adminName: {
            value: administratorLogin
          }
          adminPass: {
            value: passwordAdministratorLogin
          }
          osType: {
            value: osType
          }
          gameEngine: {
            value: gameEngine
          }
        }
      }         
//

// Parameters
  param jitAccessEnabled              bool   = false
  param location                      string = resourceGroup().location
  param publisher                     string = 'microsoftcorporation1602274591143' // Prod Account
  param applicationResourceName       string = '611f626e14154c0fb7f29099c2ff95a0'
  param managedResourceGroupId        string = ''

  // Datastore Parmeters
    param storageAccountNewOrExisting string = 'existing'
    param storageAccountResourceGroup string = ''
    param storageAccount              string = ''
    param dataContainer               string = 'retailidmsampledata'
    param cosmosDB                    string = ''
    param dataExplorer                string = ''

  // GamingVM Parameters
    param gameEngine                  string = 'ue_4_27'
    param osType                      string = 'win10'

  // Endpoint Parameters
    param aksAgentCount               int    = 3

  // Discrete Parameters
    @allowed([
      'gamingDevVM'
    ])
    param solution              string

    @allowed([
      'true'
      'false'
    ])
    param crossTenant           string = 'true'


  // Secure Parameters
    @secure()
    param servicePrincipalClientID  string = ''

    @secure()
    param servicePrincipalSecret    string = ''
//

// Resources
  resource solution_resource 'Microsoft.Solutions/applications@2017-09-01'  = {
    name    : solution
    location: location
    kind    : 'MarketPlace'
    plan    : apps[solution].plan
    properties: {
      managedResourceGroupId: (empty(managedResourceGroupId) ? '${subscription().id}/resourceGroups/${take('${resourceGroup().name}-mrg', 90)}' : managedResourceGroupId)
      parameters            : apps[solution].parameters
      jitAccessPolicy       : {
                                jitAccessEnabled : jitAccessEnabled
                              }
    }
  }
//
