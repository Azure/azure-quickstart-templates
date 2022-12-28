@description('Name of the existing Azure ARC enabled Kubernetes cluster where the Private 5G Core is running')
param connectedClusterName string

@description('Name of the resource group containing the existing Azure ARC enabled Kubernetes cluster')
param connectedClusterResourceGroup string

@description('Name of the dashboard to display in Azure portal')
param dashboardDisplayName string = 'Private 5G Core Metrics'

@description('Resource name that Azure portal uses for the dashboard')
var dashboardName = guid(connectedClusterName, connectedClusterResourceGroup)

@description('Region where the dashboard will be deployed')
param location string = resourceGroup().location

resource existingClusterResource 'Microsoft.Kubernetes/connectedClusters@2021-10-01' existing = {
  name: connectedClusterName
  scope: resourceGroup(connectedClusterResourceGroup)
}

var devicesquery = '''let Time = InsightsMetrics
    | where Namespace == "prometheus"
    | summarize by Time=TimeGenerated;
let RegisteredDevices = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amf_registered_subscribers"
    | summarize by RegisteredDevices=Val, Time=TimeGenerated;
let ProvisionedDevices = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "subscribers_count"
    | where Tags has '"type":"provisioned"'
    | summarize by ProvisionedDevices=Val, Time=TimeGenerated;
let ConnectedDevices = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amf_registered_subscribers_connected"
    | summarize by ConnectedDevices=Val, Time=TimeGenerated;
Time
    | join kind=leftouter (RegisteredDevices) on Time
    | join kind=leftouter (ProvisionedDevices) on Time
    | join kind=leftouter (ConnectedDevices) on Time
    | project Time, RegisteredDevices, ProvisionedDevices, ConnectedDevices
    | render areachart kind=unstacked
'''

var gnodequery = '''InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amf_connected_gnb"
    | extend Time=TimeGenerated
    | extend GnBs=Val
    | project GnBs, Time
    | render timechart
'''

var pdusessionsquery = '''InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "subgraph_counts"
    | summarize PduSessions=max(Val) by Time=TimeGenerated
    | render areachart kind=unstacked
'''

var userthroughputquery = '''let rate_function=(tbl: (Val: real, Time: datetime)) {
    tbl
    | sort by Time asc
    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value
    | extend cum_correction = row_cumsum(correction)
    | extend Val = Val + cum_correction
    | extend PrevTime = prev(Time), PrevVal = prev(Val)
    | extend dt = (Time - PrevTime) / 1s
    | extend dv = Val - PrevVal
    | extend rate = (dv * 8) / (dt * 1000000) // convert to Megabits per second
}
;
let BytesUpstream = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "cppe_bytes_total"
    | extend Tags = todynamic(Tags)
    | where Tags.direction == "tx"
    | where Tags.interface startswith "n6"
    | where not (Tags.interface has "kernel")
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | project BytesUpstream=rate, Time;
let BytesDownstream = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "cppe_bytes_total"
    | extend Tags = todynamic(Tags)
    | where Tags.direction == "tx"
    | where Tags.interface == "n3"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | project BytesDownstream=rate, Time;
BytesUpstream
| join kind=leftouter (BytesDownstream) on Time
| project Time, BytesUpstream, BytesDownstream
| render areachart kind=stacked title="Userplane Throughput (Mb/s)"
'''

var errorsquery = '''let rate_function=(tbl:(Val: real, Time: datetime))
{
tbl
    | sort by Time asc
    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value
    | extend cum_correction = row_cumsum(correction)
    | extend Val = Val + cum_correction
    | extend PrevTime = prev(Time), PrevVal = prev(Val)
    | extend dt = (Time-PrevTime)/1s
    | extend dv = Val-PrevVal
    | extend rate = dv/dt
};
let TimeSeries = InsightsMetrics
    | where Namespace == "prometheus"
    | summarize by Time=TimeGenerated;
let session_setup_response = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_setup_response"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend SetupResponse=rate;
let session_setup_request = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_setup_request"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend SetupRequest=rate;
let session_modify_response = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_modify_response"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend ModifyResponse=rate;
let session_modify_request = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_modify_request"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend ModifyRequest=rate;
let session_release_command = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_release_command"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend ReleaseCommand=rate;
let session_release_response = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pdu_session_resource_release_response"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend ReleaseResponse=rate;
let registration = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfcc_mm_initial_registration_failure"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend Registration=rate;
let authentication_failure = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfcc_n1_auth_failure"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend AuthenticationFailure=rate;
let authentication_rejection = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfcc_n1_auth_reject"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend AuthenticationRejection=rate;
let service_rejection = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfcc_n1_service_reject"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend Service=rate;
let request_failure = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_pathswitch_request_failure"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend PathSwitch=rate;
let handover_failure = InsightsMetrics
    | where Namespace == "prometheus"
    | where Name == "amfn2_n2_handover_failure"
    | summarize Val=sum(Val) by Time=TimeGenerated
    | invoke rate_function()
    | extend Handover=rate;
TimeSeries
    | join kind=leftouter (registration) on Time
    | join kind=leftouter (session_setup_request) on Time
    | join kind=leftouter (session_setup_response) on Time
    | join kind=leftouter (session_modify_request) on Time
    | join kind=leftouter (session_modify_response) on Time
    | join kind=leftouter (session_release_command) on Time
    | join kind=leftouter (session_release_response) on Time
    | join kind=leftouter (authentication_failure) on Time
    | join kind=leftouter (authentication_rejection) on Time
    | join kind=leftouter (service_rejection) on Time
    | join kind=leftouter (request_failure) on Time
    | join kind=leftouter (handover_failure) on Time
    | project Time, Registration, AuthenticationFailure, AuthenticationRejection, SessionEstablishment=SetupResponse-SetupRequest, SessionModification=ModifyResponse-ModifyRequest, SessionRelease=ReleaseCommand-ReleaseResponse, Service, PathSwitch, Handover
    | render areachart kind=unstacked
'''

resource exampleDashboard 'Microsoft.Portal/dashboards@2019-01-01-preview' = {
  name: dashboardName
  location: location
  tags: {
    'hidden-title': dashboardDisplayName
  }
  properties: {
    lenses: {
      '0': {
        order: 0
        parts: {
          '0': {
            position: {
              x: 0
              y: 0
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      existingClusterResource.id
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '81a647c6-1efc-413a-8839-cda9fa14aea4'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  value: {
                    scope: 'hierarchy'
                  }
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: devicesquery
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'FrameControlChart'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  value: 'UnstackedArea'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Devices'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'Private Edge Overview'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  value: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'ConnectedDevices'
                        type: 'real'
                      }
                      {
                        name: 'RegisteredDevices'
                        type: 'real'
                      }
                      {
                        name: 'ProvisionedDevices'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  value: {
                    isEnabled: true
                    position: 'Bottom'
                  }
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: devicesquery
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'UnstackedArea'
                  Dimensions: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'RegisteredDevices'
                        type: 'real'
                      }
                      {
                        name: 'ProvisionedDevices'
                        type: 'real'
                      }
                      {
                        name: 'ConnectedDevices'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                }
              }
              partHeader: {
                title: 'Devices'
                subtitle: 'Private Edge Overview'
              }
            }
          }
          '1': {
            position: {
              x: 8
              y: 0
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      existingClusterResource.id
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '1253851d-9037-4acb-8c14-44ebe1f2b94b'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  value: {
                    scope: 'hierarchy'
                  }
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: gnodequery
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'FrameControlChart'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  value: 'Line'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Analytics'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'Private Edge Overview'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  value: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'GnBs'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Max'
                  }
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  value: {
                    isEnabled: true
                    position: 'Bottom'
                  }
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: gnodequery
                  PartTitle: 'gNodeBs'
                  Dimensions: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'GnBs'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Max'
                  }
                }
              }
              partHeader: {
                title: 'gNodeBs'
                subtitle: 'Private Edge Overview'
              }
            }
          }
          '2': {
            position: {
              x: 0
              y: 4
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      existingClusterResource.id
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '1253851d-9037-4acb-8c14-44ebe1f2b94b'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  value: {
                    scope: 'hierarchy'
                  }
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: pdusessionsquery
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'FrameControlChart'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  value: 'UnstackedArea'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Pdu Sessions'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'Private Edge Overview'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  value: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'PduSessions'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  value: {
                    isEnabled: true
                    position: 'Bottom'
                  }
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: pdusessionsquery
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'UnstackedArea'
                  PartTitle: 'PDU Sessions'
                  Dimensions: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'PduSessions'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                }
              }
              partHeader: {
                title: 'Pdu Sessions'
                subtitle: 'Private Edge Overview'
              }
            }
          }
          '3': {
            position: {
              x: 8
              y: 4
              colSpan: 6
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      existingClusterResource.id
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '80821e28-5363-4aee-a2ba-0335313613e2'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  value: {
                    scope: 'hierarchy'
                  }
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: userthroughputquery
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'FrameControlChart'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  value: 'UnstackedArea'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Userplane Throughput (Mb/s)'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'Private Edge Overview'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  value: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'BytesUpstream'
                        type: 'real'
                      }
                      {
                        name: 'BytesDownstream'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  value: {
                    isEnabled: true
                    position: 'Bottom'
                  }
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: userthroughputquery
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'StackedArea'
                  PartTitle: 'Userplane Throughput (Mb/s)'
                  Dimensions: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'BytesUpstream'
                        type: 'real'
                      }
                      {
                        name: 'BytesDownstream'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                }
              }
              partHeader: {
                title: 'Userplane Throughput (Mb/s)'
                subtitle: 'Private Edge Overview'
              }
            }
          }
          '4': {
            position: {
              x: 0
              y: 8
              colSpan: 14
              rowSpan: 4
            }
            metadata: {
              inputs: [
                {
                  name: 'resourceTypeMode'
                  isOptional: true
                }
                {
                  name: 'ComponentId'
                  isOptional: true
                }
                {
                  name: 'Scope'
                  value: {
                    resourceIds: [
                      existingClusterResource.id
                    ]
                  }
                  isOptional: true
                }
                {
                  name: 'PartId'
                  value: '1253851d-9037-4acb-8c14-44ebe1f2b94b'
                  isOptional: true
                }
                {
                  name: 'Version'
                  value: '2.0'
                  isOptional: true
                }
                {
                  name: 'TimeRange'
                  value: 'P1D'
                  isOptional: true
                }
                {
                  name: 'DashboardId'
                  isOptional: true
                }
                {
                  name: 'DraftRequestParameters'
                  value: {
                    scope: 'hierarchy'
                  }
                  isOptional: true
                }
                {
                  name: 'Query'
                  value: errorsquery
                  isOptional: true
                }
                {
                  name: 'ControlType'
                  value: 'FrameControlChart'
                  isOptional: true
                }
                {
                  name: 'SpecificChart'
                  value: 'Line'
                  isOptional: true
                }
                {
                  name: 'PartTitle'
                  value: 'Errors'
                  isOptional: true
                }
                {
                  name: 'PartSubTitle'
                  value: 'Private Edge Overview'
                  isOptional: true
                }
                {
                  name: 'Dimensions'
                  value: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'Registration'
                        type: 'real'
                      }
                      {
                        name: 'AuthenticationFailure'
                        type: 'real'
                      }
                      {
                        name: 'AuthenticationRejection'
                        type: 'real'
                      }
                      {
                        name: 'SessionEstablishment'
                        type: 'real'
                      }
                      {
                        name: 'SessionModification'
                        type: 'real'
                      }
                      {
                        name: 'SessionRelease'
                        type: 'real'
                      }
                      {
                        name: 'PathSwitch'
                        type: 'real'
                      }
                      {
                        name: 'Service'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                  isOptional: true
                }
                {
                  name: 'LegendOptions'
                  value: {
                    isEnabled: true
                    position: 'Bottom'
                  }
                  isOptional: true
                }
                {
                  name: 'IsQueryContainTimeRange'
                  value: false
                  isOptional: true
                }
              ]
              type: 'Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart'
              settings: {
                content: {
                  Query: errorsquery
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'UnstackedArea'
                  PartTitle: 'Errors'
                  Dimensions: {
                    xAxis: {
                      name: 'Time'
                      type: 'datetime'
                    }
                    yAxis: [
                      {
                        name: 'Registration'
                        type: 'real'
                      }
                      {
                        name: 'AuthenticationFailure'
                        type: 'real'
                      }
                      {
                        name: 'AuthenticationRejection'
                        type: 'real'
                      }
                      {
                        name: 'SessionEstablishment'
                        type: 'real'
                      }
                      {
                        name: 'SessionModification'
                        type: 'real'
                      }
                      {
                        name: 'SessionRelease'
                        type: 'real'
                      }
                      {
                        name: 'PathSwitch'
                        type: 'real'
                      }
                      {
                        name: 'Service'
                        type: 'real'
                      }
                    ]
                    splitBy: []
                    aggregation: 'Sum'
                  }
                }
              }
              partHeader: {
                title: 'Errors'
                subtitle: 'Private Edge Overview'
              }
            }
          }
        }
      }
    }
    metadata: {
      model: {
        timeRange: {
          value: {
            relative: {
              duration: 24
              timeUnit: 1
            }
          }
          type: 'MsPortalFx.Composition.Configuration.ValueTypes.TimeRange'
        }
        filterLocale: {
          value: 'en-us'
        }
        filters: {
          value: {
            MsPortalFx_TimeRange: {
              model: {
                format: 'local'
                granularity: 'auto'
                relative: '1h'
              }
              displayCache: {
                name: 'Local Time'
                value: 'Past hour'
              }
              filteredPartIds: [
                'StartboardPart-LogsDashboardPart-93bd5b99-6d06-43e7-b59c-d1619b31218b'
                'StartboardPart-LogsDashboardPart-93bd5b99-6d06-43e7-b59c-d1619b31218d'
                'StartboardPart-LogsDashboardPart-93bd5b99-6d06-43e7-b59c-d1619b31218f'
                'StartboardPart-LogsDashboardPart-93bd5b99-6d06-43e7-b59c-d1619b312191'
                'StartboardPart-LogsDashboardPart-93bd5b99-6d06-43e7-b59c-d1619b312193'
              ]
            }
          }
        }
      }
    }
  }
}
