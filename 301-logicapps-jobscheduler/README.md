# Logic App job scheduler

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F100-blank-template%2Fazuredeploy.json" target="_blank">
<img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.png"/>
</a>

This template deploys a **Logic App job scheduler**. The **Logic App job scheduler** provides a pair of logic app that can instantiate timer jobs based on a provided recurrent schedule.

`Tags: LogicApps, Scheduler`

## Solution overview and deployed resources

The CreateTimerJob logic app acts as an API that will allow you to create a new timer job instance on a schedule passed in as input to the request. If you call CreateTimeJob again, that can be with a different schedule, it will create a new instance of TimerJob. 

You can use Postman (or another Logic App) to try calling CreateTimerJob and send it a payload similar to the following:
{
   "timerjobid": "MyCorrelationId", // Correlate runs and find running jobs by this id
   "startTime": "2018-09-30T06:10:49.9712118Z", // Optional. Allows a timer job to start in the future.
   "jobRecurrence":{
       "frequency":"minute", // Can be one of second, minute, hour, week, month
       "interval": 1, // Interval for provided frequency
       "count": 2, // Optional. Limit property that indicates how many times this job should run
       "endTime": "2018-12-31T08:08:00.000Z" //Optional. Limit property that indicates when this timer job should stop running
   }
}

Each of the timer job instances will continue to run on the prescribed schedule contninuosly or until the limit (end time or count) passed in is met.
Since these are instances, not logic apps definitions/resources, then you can create as many of these timer job instances as you like.

In the TimerJob logic app change the HTTP action to be whatever you action want your job to execute on the prescribed schedule.

The following resources are deployed as part of the solution

#### Logic Apps

Logic Apps provides serverless event triggered workflows that integrate disparate services inside and outside of Azure as well as on-prem.

+ **CreateTimerJobLogicApp**: Logic App definition that acts as an API to create new timer jobs based on a provided recurring schedule.
+ **TimerJobLogicApp**: Executes the prescribed job on the schedule provided.

## Prerequisites

By default the timer job will call an HTTP endpoint. Update the timer job logic app by replacing the HTTP action in the Job scope to the action, or set of actions, you want to perform as the timer job.

## Deployment steps

You can click the "deploy to Azure" button at the beginning of this document or follow the instructions for command line deployment using the scripts in the root of this repo.

## Usage


#### Management

The Logic App template Cancel Run By Correlation Id can be used in tandem with this solution to cancel running timer jobs.

## Notes

Solution notes