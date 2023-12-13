@description('Name of the Recovery Services Vault')
param vaultName string

@description('Name of the Backup Policy')
param policyName string

@description('Backup Schedule will run on array of Days like, Monday, Tuesday etc. Applies in Weekly Backup Type only.')
param scheduleRunDays array

@description('Times in day when backup should be triggered. e.g. 01:00, 13:00. This will be used in LTR too for daily, weekly, monthly and yearly backup.')
param scheduleRunTimes array

@description('Any Valid timezone, for example:UTC, Pacific Standard Time. Refer: https://msdn.microsoft.com/en-us/library/gg154758.aspx')
param timeZone string

@description('Number of weeks you want to retain the backup')
param weeklyRetentionDurationCount int

@description('Array of Days for Monthly Retention (Min One or Max all values from scheduleRunDays, but not any other days which are not part of scheduleRunDays)')
param daysOfTheWeekForMontlyRetention array

@description('Array of Weeks for Monthly Retention - First, Second, Third, Fourth, Last')
param weeksOfTheMonthForMonthlyRetention array

@description('Number of months you want to retain the backup')
param monthlyRetentionDurationCount int

@description('Array of Months for Yearly Retention')
param monthsOfYear array

@description('Array of Days for Yearly Retention (Min One or Max all values from scheduleRunDays, but not any other days which are not part of scheduleRunDays)')
param daysOfTheWeekForYearlyRetention array

@description('Array of Weeks for Yearly Retention - First, Second, Third, Fourth, Last')
param weeksOfTheMonthForYearlyRetention array

@description('Number of years you want to retain the backup')
param yearlyRetentionDurationCount int

@description('Location for all resources.')
param location string = resourceGroup().location

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2020-10-01' = {
  name: vaultName
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2016-06-01' = {
  parent: recoveryServicesVault
  name: policyName
  location: location
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: 5
    schedulePolicy: {
      scheduleRunFrequency: 'Weekly'
      scheduleRunDays: scheduleRunDays
      scheduleRunTimes: scheduleRunTimes
      schedulePolicyType: 'SimpleSchedulePolicy'
    }
    retentionPolicy: {
      weeklySchedule: {
        daysOfTheWeek: scheduleRunDays
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: weeklyRetentionDurationCount
          durationType: 'Weeks'
        }
      }
      monthlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionScheduleWeekly: {
          daysOfTheWeek: daysOfTheWeekForMontlyRetention
          weeksOfTheMonth: weeksOfTheMonthForMonthlyRetention
        }
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: monthlyRetentionDurationCount
          durationType: 'Months'
        }
      }
      yearlySchedule: {
        retentionScheduleFormatType: 'Weekly'
        monthsOfYear: monthsOfYear
        retentionScheduleDaily: {
          daysOfTheMonth: [
            {
              date: 1
              isLast: false
            }
          ]
        }
        retentionScheduleWeekly: {
          daysOfTheWeek: daysOfTheWeekForYearlyRetention
          weeksOfTheMonth: weeksOfTheMonthForYearlyRetention
        }
        retentionTimes: scheduleRunTimes
        retentionDuration: {
          count: yearlyRetentionDurationCount
          durationType: 'Years'
        }
      }
      retentionPolicyType: 'LongTermRetentionPolicy'
    }
    timeZone: timeZone
  }
}
