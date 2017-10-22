# Create a Standard Stream Analytics Job with Input and Output.

 <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-streamanalytics-create-with-input-output%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F101-streamanalytics-create-with-input-output%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

## The goal of this template.

1. __Read messages from an IoT Hub__. *Messages are JSON in UTF-8.*
2. __Perform a simple query__. *This example simply copies the input to the output. Update the query to meet your own requirements. In the template, the query is refered to as a __Transformation__*.
3. __Output to a PowerBI Streaming Dataset__. *Specify in the job output definition the name of the dataset and table to be created in the PowerBI workspace. You will see these appear automatically in the PBI Portal only once the first message has been sent there (i.e. they don't get created at the point the ARM template is deployed).*

## Parameters and variables

* __iotHubName__: The name of the IoTHub you want to create. Must be unique across the whole of Azure.
* __userDisplayName__: A human readable name to associate the OAuth token for connecting to the PBI Streaming Dataset. It doesn't seem to really matter what you enter here but something is required.
* __userLoginName__: The username in user@domain.com format that you want to use for authenticating against PowerBI.
* __streamAnalyticsJobName__: The name of the main job which will be created.

## Limitations

The template does __not__ perform the following actions which are not possible in ARM:

1. __Starting the job__. Once the input, query and output settings have been specified you'll have to manually start the job in the Azure Portal UI or by calling the REST API.
2. __Fully configuring the PowerBI OAuth credentials__. In order to connect to PBI and send data, the Stream Analytics job needs the correct rights. Specifically it needs an OAuth token which gives access to PBI for a given userprincipal. You can not specify this in the template because it's generated on the fly by AzureAD. You will need to *a)* deploy the ARM template, then *b)* via the Azure Portal go in to the output definition and click on "Re-authorize". This ensures the Azure Portal talks to AzureAD and obtains the OAuth token which is then stored inside the job definition. This will be used whenever the job output needs to send data to PBI.

For more information, see here:

https://blogs.msdn.microsoft.com/david/2017/07/20/building-azure-stream-analytics-resources-via-arm-templates-part-2-the-template/
