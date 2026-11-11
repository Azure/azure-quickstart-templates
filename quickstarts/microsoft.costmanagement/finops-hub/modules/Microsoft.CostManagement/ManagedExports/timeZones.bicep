@description('Optional. The location to use for the managed identity and deployment script to auto-start triggers. Default = (resource group location).')
param location string = resourceGroup().location

// Maps Azure region names to Windows time zone IDs accepted by Data Factory schedule triggers.
// The timeZone field requires a Windows time zone ID (e.g. 'UTC'), not the display name
// (e.g. 'Universal Coordinated Time'). An invalid value causes trigger activation to fail with:
//   ErrorCode=InvalidWorkflowTriggerRecurrence, ErrorMessage=The recurrence of trigger has an invalid time zone '...'.
// See: https://learn.microsoft.com/azure/data-factory/how-to-create-schedule-trigger#time-zone-option
param timezoneobject object = {
  australiaeast: 'AUS Eastern Standard Time'
  australiacentral: 'AUS Eastern Standard Time'
  australiacentral2: 'AUS Eastern Standard Time'
  australiasoutheast: 'AUS Eastern Standard Time'
  brazilsouth: 'E. South America Standard Time'
  canadacentral: 'Central Standard Time'
  canadaeast: 'Eastern Standard Time'
  centralindia: 'India Standard Time'
  centralus: 'Central Standard Time'
  eastasia: 'China Standard Time'
  eastus: 'Eastern Standard Time'
  eastus2: 'Eastern Standard Time'
  francecentral: 'W. Europe Standard Time'
  germanynorth: 'W. Europe Standard Time'
  germanywestcentral: 'W. Europe Standard Time'
  japaneast: 'Tokyo Standard Time'
  japanwest: 'Tokyo Standard Time'
  koreacentral: 'Korea Standard Time'
  koreasouth: 'Korea Standard Time'
  northcentralus: 'Central Standard Time'
  northeurope: 'GMT Standard Time'
  norwayeast: 'W. Europe Standard Time'
  norwaywest: 'W. Europe Standard Time'
  southcentralus: 'Central Standard Time'
  southindia: 'India Standard Time'
  southeastasia: 'Singapore Standard Time'
  switzerlandnorth: 'W. Europe Standard Time'
  switzerlandwest: 'W. Europe Standard Time'
  uksouth: 'GMT Standard Time'
  ukwest: 'GMT Standard Time'
  // US Government cloud regions. USGov Arizona does not observe DST — use 'US Mountain Standard Time'.
  usdodcentral: 'Central Standard Time'
  usdodeast: 'Eastern Standard Time'
  usgovvirginia: 'Eastern Standard Time'
  usgovtexas: 'Central Standard Time'
  usgovarizona: 'US Mountain Standard Time'
  usgoviowa: 'Central Standard Time'
  westcentralus: 'Central Standard Time'
  westeurope: 'W. Europe Standard Time'
  westindia: 'India Standard Time'
  westus: 'Pacific Standard Time'
  westus2: 'Pacific Standard Time'
}

param utchrs string = utcNow('hh')
param utcmins string = utcNow('mm')
param utcsecs string = utcNow('ss')

var loc = toLower(replace(location, ' ', ''))

// Fallback to 'UTC' — the valid Windows time zone ID. The display name 'Universal Coordinated Time'
// is rejected by Data Factory trigger validation.
// See: https://learn.microsoft.com/azure/data-factory/how-to-create-schedule-trigger#time-zone-option
var timezone = timezoneobject[?loc] ?? 'UTC'

output AzureRegion string = location

output Timezone string = timezone

output UtcHours string = utchrs

output UtcMinutes string = utcmins

output UtcSeconds string = utcsecs

