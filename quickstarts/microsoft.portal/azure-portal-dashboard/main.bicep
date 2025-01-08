@description('Name of the existing virtual machine to show in the dashboard')
param virtualMachineName string

@description('Name of the resource group that contains the virtual machine')
param virtualMachineResourceGroup string

@metadata({ Description: 'Resource name that Azure portal uses for the dashboard' })
param dashboardName string = guid(virtualMachineName, virtualMachineResourceGroup)

@description('Name of the dashboard to display in Azure portal')
param dashboardDisplayName string = 'Simple VM Dashboard'
param location string = resourceGroup().location

resource dashboard 'Microsoft.Portal/dashboards@2020-09-01-preview' = {
  name: dashboardName
  location: location
  tags: {
    'hidden-title': dashboardDisplayName
  }
  properties: {
    lenses: [
      {
        order: 0
        parts: [
          {
            position: {
              x: 0
              y: 0
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: '## Azure Virtual Machines Overview\r\nNew team members should watch this video to get familiar with Azure Virtual Machines.'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 3
              y: 0
              rowSpan: 4
              colSpan: 8
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/MarkdownPart'
              settings: {
                content: {
                  settings: {
                    content: 'This is the team dashboard for the test VM we use on our team. Here are some useful links:\r\n\r\n1. [Create a Linux virtual machine](https://docs.microsoft.com/azure/virtual-machines/linux/quick-create-portal)\r\n1. [Create a Windows virtual machine](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-portal)\r\n1. [Create a virtual machine scale set](https://docs.microsoft.com/azure/virtual-machine-scale-sets/quick-create-portal)'
                    title: 'Test VM Dashboard'
                    subtitle: 'Contoso'
                  }
                }
              }
            }
          }
          {
            position: {
              x: 0
              y: 2
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: []
              type: 'Extension/HubsExtension/PartType/VideoPart'
              settings: {
                content: {
                  settings: {
                    src: 'https://www.youtube.com/watch?v=rOiSRkxtTeU'
                    autoplay: false
                  }
                }
              }
            }
          }
          {
            position: {
              x: 0
              y: 4
              rowSpan: 3
              colSpan: 11
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                    chartType: 0
                    metrics: [
                      {
                        name: 'Percentage CPU'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          {
            position: {
              x: 0
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                    chartType: 0
                    metrics: [
                      {
                        name: 'Disk Read Operations/Sec'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                      {
                        name: 'Disk Write Operations/Sec'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          {
            position: {
              x: 3
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                    chartType: 0
                    metrics: [
                      {
                        name: 'Disk Read Bytes'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                      {
                        name: 'Disk Write Bytes'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          {
            position: {
              x: 6
              y: 7
              rowSpan: 2
              colSpan: 3
            }
            metadata: {
              inputs: [
                {
                  name: 'queryInputs'
                  value: {
                    timespan: {
                      duration: 'PT1H'
                    }
                    id: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                    chartType: 0
                    metrics: [
                      {
                        name: 'Network In Total'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                      {
                        name: 'Network Out Total'
                        resourceId: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                      }
                    ]
                  }
                }
              ]
              type: 'Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart'
            }
          }
          {
            position: {
              x: 9
              y: 7
              rowSpan: 2
              colSpan: 2
            }
            metadata: {
              inputs: [
                {
                  name: 'id'
                  value: resourceId(virtualMachineResourceGroup, 'Microsoft.Compute/virtualMachines', virtualMachineName)
                }
              ]
              type: 'Extension/Microsoft_Azure_Compute/PartType/VirtualMachinePart'
              asset: {
                idInputName: 'id'
                type: 'VirtualMachine'
              }
            }
          }
        ]
      }
    ]
  }
}
output location string = location
output name string = dashboard.name
output resourceGroupName string = resourceGroup().name
output resourceId string = dashboard.id
