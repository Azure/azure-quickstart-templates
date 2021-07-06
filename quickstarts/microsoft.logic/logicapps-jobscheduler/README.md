# Logic App job scheduler

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json) 
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json)

This template deploys a **Logic App job scheduler**. The **Logic App job scheduler** provides a pair of logic apps that can instantiate timer jobs based on a provided recurrent schedule.

`Tags: LogicApps, Scheduler`

## Solution overview and deployed resources

The CreateTimerJob logic app acts as an API that will allow you to create a new timer job instance on a schedule passed in as input to the request. Each time you call CreateTimerJob it will create a new instance of a TimerJob. Each of the timer job instances will continue to run on the prescribed schedule contninuosly or until the limit (end time or count) passed in is met.

Since these are instances of a logic app, not logic apps definitions/resources, you can create as many of these timer job instances as you like.

The following resources are deployed as part of the solution:

#### Logic Apps

Logic Apps provides serverless event triggered workflows that integrate disparate services inside and outside of Azure as well as on-prem.

+ **CreateTimerJob LogicApp**: Logic App definition that acts as an API to create new timer jobs based on a provided recurring schedule.
+ **TimerJob LogicApp**: Executes the prescribed job on the schedule provided.

## Prerequisites

None.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage

To get the URL to call and create a new timer job:

+ Open the CreateTimerJob logic app
+ Expand the When a HTTP request is received trigger action
+ Click the copy button next to the HTTP POST URL

To create a new TimerJob instance, use Postman to make a POST call and send it a request body similar to the following request body.

### Request Body

```
{
   "timerjobid": "MyCorrelationId",
   "jobRecurrence":{
       "frequency":"minute",
       "interval": 5,
       "count": 2
   }
}
```

***timerjobid***

+ Correlate runs and find running jobs by this id

***startTime***

+ Optional
+ Allows a timer job to start in the future
+ Example: "2018-09-30T06:10:49.9712118Z"

***jobRecurrence***

+ Object that defines the job recurrence

***frequency***

+ Can be one of second, minute, hour, week, month

***interval***

+ Interval for given frequency

***count***

+ Optional
+ Limit property that indicates how many times this job should run

***endTime***

+ Optional
+ Limit property that indicates when this timer job should stop running
+ Example: "2018-12-31T08:08:00.000Z"
+ When both endTime and count are used the first limit criteria encountered will complete the timer job

### Headers
Since we are passing a JSON payload make sure you include the following header as part of the request:

+ Content-Type: application/json

### Customize
By default the timer job will call an HTTP endpoint. Update the timer job logic app by replacing the HTTP action in the Job scope to the action, or set of actions, you want to perform as the timer job.

+ In the TimerJob logic app change the HTTP action in the **Job** scope to be whatever you action(s) want your job to execute on the prescribed schedule.

There is also an error handler that can be called when the **Job** actions fail.

+ To configure error handling, in the TimerJob logic app, add actions to the **On Error** scope. The actions in the **On Error** scope will execute if one of the actions in the **Job** scope failed to execute.

### Management

The Logic App template Cancel Run By Correlation Id can be used in tandem with this solution to cancel running timer jobs. This template can be found in the list of templates shown when creating a new logic app.

Logic Apps has a [Log Analytics solution pack](https://docs.microsoft.com/azure/logic-apps/logic-apps-monitor-your-logic-apps-oms) that can be used to monitor and get insisghts of the logic apps runs.

## Notes

Learn more about Logic Apps

+ **[Azure Logic Apps Overview](https://docs.microsoft.com/azure/logic-apps/logic-apps-overview)**
+ See **[Scheduling in Logic Apps](https://docs.microsoft.com/azure/connectors/connectors-native-recurrence#trigger-details)** to better understand how recurrence works


