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
                  value: 'let RegisteredDevices = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amf_registered_subscribers"\n    | extend RegisteredDevices=Val, Time=TimeGenerated;\nlet ProvisionedDevices = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "subscribers_count"\n    | where Tags has \'"type":"provisioned"\'\n    | extend ProvisionedDevices=Val, Time=TimeGenerated;\nlet ConnectedDevices = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "amf_registered_subscribers_connected"\n    | extend ConnectedDevices=Val, Time=TimeGenerated;\nRegisteredDevices\n| join (ProvisionedDevices) on Time\n| join (ConnectedDevices) on Time\n| project ConnectedDevices, RegisteredDevices, ProvisionedDevices, Time\n\n'
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
                  Query: 'let Time = InsightsMetrics\n    | where Namespace == "prometheus"\n    | summarize by Time=TimeGenerated;\nlet RegisteredDevices = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amf_registered_subscribers"\n    | summarize by RegisteredDevices=Val, Time=TimeGenerated;\nlet ProvisionedDevices = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "subscribers_count"\n    | where Tags has \'"type":"provisioned"\'\n    | summarize by ProvisionedDevices=Val, Time=TimeGenerated;\nlet ConnectedDevices = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "amf_registered_subscribers_connected"\n    | summarize by ConnectedDevices=Val, Time=TimeGenerated;\nTime\n    | join kind=leftouter (RegisteredDevices) on Time\n    | join kind=leftouter (ProvisionedDevices) on Time\n    | join kind=leftouter (ConnectedDevices) on Time\n    | project Time, RegisteredDevices, ProvisionedDevices, ConnectedDevices\n    | render areachart kind=unstacked\n\n'
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
                  value: 'InsightsMetrics\n| where Namespace == "prometheus"\n| where Name == "amf_connected_gnb"\n| extend Time=TimeGenerated\n| extend GnBs=Val\n| project GnBs, Time\n| render timechart \n\n'
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
                  Query: 'InsightsMetrics\n| where Namespace == "prometheus"\n| where Name == "amf_connected_gnb"\n| extend Time=TimeGenerated\n| extend GnBs=Val\n| project GnBs, Time\n| render timechart \n\n'
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
                  value: 'InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "subgraph_counts"\n    | summarize PduSessions=max(Val) by Time=TimeGenerated\n    | render areachart kind=unstacked\n\n'
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
                  Query: 'InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "subgraph_counts"\n    | summarize PduSessions=max(Val) by Time=TimeGenerated\n    | render areachart kind=unstacked\n\n'
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
                        name: 'Pdu Sessions'
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
                  value: 'let rate_function=(tbl:(Val: real, Time: datetime))\n{\ntbl\n    | sort by Time asc\n    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value\n    | extend cum_correction = row_cumsum(correction)\n    | extend Val = Val + cum_correction\n    | extend PrevTime = prev(Time), PrevVal = prev(Val)\n    | extend dt = (Time-PrevTime)/1s\n    | extend dv = Val-PrevVal\n    | extend rate = dv/dt\n}\n    ;\nlet BytesTotal = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesTotal=rate, Time;\nlet BytesUpstream = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | where Tags has \'"interface":"n3"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesUpstream=rate, Time;\nlet BytesDownstream = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | where Tags has \'"interface":"n6"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesDownstream=rate, Time;\nBytesTotal\n| join kind=leftouter (BytesUpstream) on Time\n| join kind=leftouter (BytesDownstream) on Time\n| project Time, BytesTotal, BytesUpstream, BytesDownstream\n| render areachart kind=unstacked \n'
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
                  value: 'Userplane Throughput'
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
                        name: 'BytesTotal'
                        type: 'real'
                      }
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
                  Query: 'let rate_function=(tbl:(Val: real, Time: datetime))\n{\ntbl\n    | sort by Time asc\n    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value\n    | extend cum_correction = row_cumsum(correction)\n    | extend Val = Val + cum_correction\n    | extend PrevTime = prev(Time), PrevVal = prev(Val)\n    | extend dt = (Time-PrevTime)/1s\n    | extend dv = Val-PrevVal\n    | extend rate = dv/dt\n}\n    ;\nlet BytesTotal = InsightsMetrics\n    | where Namespace == "prometheus"\n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesTotal=rate, Time;\nlet BytesUpstream = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | where Tags has \'"interface":"n3"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesUpstream=rate, Time;\nlet BytesDownstream = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "cppe_bytes_total"\n    | where Tags has \'"direction":"rx"\'\n    | where Tags has \'"interface":"n6"\'\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | project BytesDownstream=rate, Time;\nBytesTotal\n| join kind=leftouter (BytesUpstream) on Time\n| join kind=leftouter (BytesDownstream) on Time\n| project Time, BytesTotal, BytesUpstream, BytesDownstream\n| render areachart kind=unstacked \n'
                  ControlType: 'FrameControlChart'
                  SpecificChart: 'UnstackedArea'
                  PartTitle: 'Userplane Throughput'
                }
              }
              partHeader: {
                title: 'Userplane Throughput'
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
                  value: 'let rate_function=(tbl:(Val: real, Time: datetime))\n{\ntbl\n    | sort by Time asc\n    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value\n    | extend cum_correction = row_cumsum(correction)\n    | extend Val = Val + cum_correction\n    | extend PrevTime = prev(Time), PrevVal = prev(Val)\n    | extend dt = (Time-PrevTime)/1s\n    | extend dv = Val-PrevVal\n    | extend rate = dv/dt\n}\n    ;\nlet TimeSeries = InsightsMetrics\n    | where Namespace == "prometheus"\n    | summarize by Time=TimeGenerated;\nlet session_setup_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_setup_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend SetupResponse=rate;\nlet session_setup_request = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_setup_request"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend SetupRequest=rate;\nlet session_modify_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_modify_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ModifyResponse=rate;\nlet session_modify_request = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_modify_request"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ModifyRequest=rate;\nlet session_release_command = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_release_command"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ReleaseCommand=rate;\nlet session_release_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_release_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ReleaseResponse=rate;\nlet registration = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_mm_initial_registration_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Registration=rate;\nlet authentication_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_auth_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend AuthenticationFailure=rate;\nlet authentication_rejection = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_auth_reject"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend AuthenticationRejection=rate;\nlet service_rejection = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_service_reject"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Service=rate;\nlet request_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pathswitch_request_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend PathSwitch=rate;\nlet handover_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_handover_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Handover=rate;\nTimeSeries\n    | join kind=leftouter (registration) on Time\n    | join kind=leftouter (session_setup_request) on Time\n    | join kind=leftouter (session_setup_response) on Time\n    | join kind=leftouter (session_modify_request) on Time\n    | join kind=leftouter (session_modify_response) on Time\n    | join kind=leftouter (session_release_command) on Time\n    | join kind=leftouter (session_release_response) on Time\n    | join kind=leftouter (authentication_failure) on Time\n    | join kind=leftouter (authentication_rejection) on Time\n    | join kind=leftouter (service_rejection) on Time\n    | join kind=leftouter (request_failure) on Time\n    | join kind=leftouter (handover_failure) on Time\n    | project Time, Registration, AuthenticationFailure, AuthenticationRejection, SessionEstablishment=SetupResponse-SetupRequest, SessionModification=ModifyResponse-ModifyRequest, SessionRelease=ReleaseCommand-ReleaseResponse, Service, PathSwitch, Handover\n    | render areachart kind=unstacked \n\n'
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
                  Query: 'let rate_function=(tbl:(Val: real, Time: datetime))\n{\ntbl\n    | sort by Time asc\n    | extend correction = iff(Val < prev(Val), prev(Val), 0.0)    // if the value decreases we assume it was reset to 0, so add last value\n    | extend cum_correction = row_cumsum(correction)\n    | extend Val = Val + cum_correction\n    | extend PrevTime = prev(Time), PrevVal = prev(Val)\n    | extend dt = (Time-PrevTime)/1s\n    | extend dv = Val-PrevVal\n    | extend rate = dv/dt\n}\n    ;\nlet TimeSeries = InsightsMetrics\n    | where Namespace == "prometheus"\n    | summarize by Time=TimeGenerated;\nlet session_setup_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_setup_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend SetupResponse=rate;\nlet session_setup_request = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_setup_request"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend SetupRequest=rate;\nlet session_modify_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_modify_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ModifyResponse=rate;\nlet session_modify_request = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_modify_request"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ModifyRequest=rate;\nlet session_release_command = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_release_command"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ReleaseCommand=rate;\nlet session_release_response = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pdu_session_resource_release_response"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend ReleaseResponse=rate;\nlet registration = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_mm_initial_registration_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Registration=rate;\nlet authentication_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_auth_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend AuthenticationFailure=rate;\nlet authentication_rejection = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_auth_reject"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend AuthenticationRejection=rate;\nlet service_rejection = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfcc_n1_service_reject"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Service=rate;\nlet request_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_pathswitch_request_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend PathSwitch=rate;\nlet handover_failure = InsightsMetrics\n    | where Namespace == "prometheus" \n    | where Name == "amfn2_n2_handover_failure"\n    | summarize Val=sum(Val) by Time=TimeGenerated\n    | invoke rate_function()\n    | extend Handover=rate;\nTimeSeries\n    | join kind=leftouter (registration) on Time\n    | join kind=leftouter (session_setup_request) on Time\n    | join kind=leftouter (session_setup_response) on Time\n    | join kind=leftouter (session_modify_request) on Time\n    | join kind=leftouter (session_modify_response) on Time\n    | join kind=leftouter (session_release_command) on Time\n    | join kind=leftouter (session_release_response) on Time\n    | join kind=leftouter (authentication_failure) on Time\n    | join kind=leftouter (authentication_rejection) on Time\n    | join kind=leftouter (service_rejection) on Time\n    | join kind=leftouter (request_failure) on Time\n    | join kind=leftouter (handover_failure) on Time\n    | project Time, Registration, AuthenticationFailure, AuthenticationRejection, SessionEstablishment=SetupResponse-SetupRequest, SessionModification=ModifyResponse-ModifyRequest, SessionRelease=ReleaseCommand-ReleaseResponse, Service, PathSwitch, Handover\n    | render areachart kind=unstacked \n\n'
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
