@description('Name of an existing General Purpose SQL managed instance in the deployment resource group. The instance must support stop and start.')
@minLength(1)
@maxLength(63)
param managedInstanceName string

@description('Windows time zone ID for the schedule, such as UTC or Pacific Standard Time. Local times follow daylight saving rules for the selected zone.')
@minLength(1)
param timeZoneId string = 'UTC'

@description('Weekday start time in 24-hour HH:mm format in the schedule time zone. Use an earlier time than stopTime, with at least one hour between successive actions.')
@minLength(5)
@maxLength(5)
param startTime string = '08:00'

@description('Weekday stop time in 24-hour HH:mm format in the schedule time zone. Leave at least one hour before the next start. Overnight intervals are not supported by this example.')
@minLength(5)
@maxLength(5)
param stopTime string = '18:00'

var weekdays = [
  'Monday'
  'Tuesday'
  'Wednesday'
  'Thursday'
  'Friday'
]

resource managedInstance 'Microsoft.Sql/managedInstances@2023-08-01' existing = {
  name: managedInstanceName
}

resource startStopSchedule 'Microsoft.Sql/managedInstances/startStopSchedules@2023-08-01' = {
  parent: managedInstance
  name: 'default'
  properties: {
    description: 'Start and stop the existing managed instance on weekdays.'
    timeZoneId: timeZoneId
    scheduleList: [for day in weekdays: {
      startDay: day
      startTime: startTime
      stopDay: day
      stopTime: stopTime
    }]
  }
}

output managedInstanceId string = managedInstance.id
output startStopScheduleId string = startStopSchedule.id
