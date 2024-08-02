---
description: Creates a pair of logic app workflows that let you create scheduled timer job instances.
page_type: sample
products:
- azure
- azure-resource-manager
urlFragment: logicapps-jobscheduler
languages:
- json
---

# Run timer jobs that execute on a schedule using Azure Logic Apps

![Azure Public Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/PublicLastTestDate.svg)
![Azure Public Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/PublicDeployment.svg)

![Azure US Gov Last Test Date](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/FairfaxLastTestDate.svg)
![Azure US Gov Last Test Result](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/FairfaxDeployment.svg)

![Best Practice Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/BestPracticeResult.svg)
![Cred Scan Check](https://azurequickstartsservice.blob.core.windows.net/badges/quickstarts/microsoft.logic/logicapps-jobscheduler/CredScanResult.svg)

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fquickstarts%2Fmicrosoft.logic%2Flogicapps-jobscheduler%2Fazuredeploy.json)

This template deploys a pair of logic apps that implement a job scheduler by instantiating timer jobs based on a provided recurring schedule. Azure Logic Apps provides serverless event-triggered workflows that integrate disparate services inside and outside of Azure as well as on premises.

## Solution overview and deployed resources

The **CreateTimerJob** logic app acts as an API that lets you create a new timer job instance on a schedule that you pass in as input to the request. Each time that you call the **CreateTimerJob** logic app workflow, Azure Logic Apps creates a new instance of a **TimerJob**. Each timer job instance continues to run on the prescribed schedule or until the passed in limit (end time or count) is met. You can create as many timer job instances as you want because these are logic app workflow instances, not logic app resources or workflow definitions.

The following resources are deployed as part of the solution:

- **CreateTimerJob** logic app: A logic app workflow definition that acts as an API to create new timer jobs based on a provided recurring schedule.
- **TimerJob** logic app: Executes the prescribed job on the provided schedule.

## Prerequisites

None.

## Deployment steps

You can select **Deploy to Azure** at the top of this document or follow the instructions for command line deployment using the scripts at the root of this repo.

## Usage

To get the URL to call and create a new timer job:

1. Open the **CreateTimerJob** logic app.

2. Expand the **Request** trigger named **When a HTTP request is received**.

3. Next to the HTTP POST URL value, select **Copy**.

4. To create a new **TimerJob** instance, send a POST request to the endpoint URL that you copied by using a tool that can send HTTP requests, for example:

   - [Visual Studio Code](https://code.visualstudio.com/download) with an extension from [Visual Studio Marketplace](https://marketplace.visualstudio.com/vscode)
   - [PowerShell Invoke-RestMethod](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/invoke-restmethod)
   - [Microsoft Edge - Network Console tool](https://learn.microsoft.com/microsoft-edge/devtools-guide-chromium/network-console/network-console-tool)
   - [Bruno](https://www.usebruno.com/)
   - [Curl](https://curl.se/)

   > [!CAUTION]
   > 
   > For scenarios where you have sensitive data, such as credentials, secrets, access tokens, API keys,
   > and other similar information, make sure to use a tool that protects your data with the necessary
   > security features, works offline or locally, doesn't sync your data to the cloud, and doesn't require
   > that you sign in to an online account. This way, you reduce the risk around exposing sensitive data to the public.

5. In the request body, the message that you send should use the following format:

   ```
   {
       "timerJobId": "MyCorrelationId",
       "jobRecurrence": {
           "frequency": "minute",
           "interval": 5,
           "count": 2
       }
   }
   ```

   The following table provides more information about the included properties:

   | Property | Description |
   |----------|-------------|
   | **timerJobId** | Correlate runs and find running jobs based on this ID. |
   | **startTime** | Optional. Allows a timer job to start in the future. <p><p>Example: "2018-09-30T06:10:49.9712118Z" |
   | **jobRecurrence** | An object that defines the job recurrence. |
   | **frequency** | Can be the following: `second`, `minute`, `hour`, `week`, `month`. |
   | **interval** | The interval for given frequency. |
   | **count** | Optional. The limit that indicates how many times this job should run. |
   | **endTime** | Optional. The limit that indicates when this timer job should stop running. <p><p>Example: "2018-12-31T08:08:00.000Z" |

   When you use both **count** and **endTime**, first limit encountered completes the timer job.

### Headers

When you pass a JSON payload, make sure to include the following header with the request: **Content-Type: application/json**

### Customize

By default, the timer job calls an HTTP endpoint. Make sure to update the **TimerJob** logic app workflow by replacing the HTTP action in the **Job** scope with the action or actions that you want to run as the timer job.

- In the **TimerJob** logic app workflow, change the **HTTP** action in the **Job** scope to whatever actions you want to run on the specified schedule.

The logic app workflow includes a placeholder for an error handler that can run if the **Job** actions fail.

- To configure error handling, in the **TimerJob** logic app workflow, add actions to the **On Error** scope. These actions run if any action in the **Job** scope fails to execute.

### Management

Azure Logic Apps includes [Log Analytics capability](https://learn.microsoft.com/azure/logic-apps/monitor-workflows-collect-diagnostic-data) that you can use to collect diagnostic data and get insisghts for your logic app workflow runs.

## More information

Learn more about Azure Logic Apps:

+ [What is Azure Logic Apps?](https://learn.microsoft.com/azure/logic-apps/logic-apps-overview)
+ [Schedule and run recurring workflows in Azure Logic Apps](https://learn.microsoft.com/azure/connectors/connectors-native-recurrence)

`Tags: LogicApps, Scheduler, Microsoft.Logic/workflows, Request, object, integer, string, If, Scope, Terminate, Response, Workflow, InitializeVariable, Microsoft.Resources/deployments, Wait, IncrementVariable, Http`
