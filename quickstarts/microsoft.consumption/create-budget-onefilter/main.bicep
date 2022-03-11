targetScope = 'subscription'

@description('Name of the Budget. It should be unique within a resource group.')
param budgetName string = 'MyBudget'

@description('The total amount of cost or usage to track with the budget')
param amount int = 1000

@description('The time covered by a budget. Tracking of the amount will be reset based on the time grain.')
@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
param timeGrain string = 'Monthly'

@description('The start date must be first of the month in YYYY-MM-DD format. Future start date should not be more than three months. Past start date should be selected within the timegrain preiod.')
param startDate string

@description('The end date for the budget in YYYY-MM-DD format. If not provided, we default this to 10 years from the start date.')
param endDate string

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param firstThreshold int = 90

@description('Threshold value associated with a notification. Notification is sent when the cost exceeded the threshold. It is always percent and has to be between 0.01 and 1000.')
param secondThreshold int = 110

@description('The list of email addresses to send the budget notification to when the threshold is exceeded.')
param contactEmails array

@description('The set of values for the resource group filter.')
param resourceGroupFilterValues array

resource budget 'Microsoft.Consumption/budgets@2021-10-01' = {
  name: budgetName
  properties: {
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    timeGrain: timeGrain
    amount: amount
    category: 'Cost'
    notifications: {
      NotificationForExceededBudget1: {
        enabled: true
        operator: 'GreaterThan'
        threshold: firstThreshold
        contactEmails: contactEmails
      }
      NotificationForExceededBudget2: {
        enabled: true
        operator: 'GreaterThan'
        threshold: secondThreshold
        contactEmails: contactEmails
      }
    }
    filter: {
      dimensions: {
        name: 'ResourceGroupName'
        operator: 'In'
        values: resourceGroupFilterValues
      }
    }
  }
}
