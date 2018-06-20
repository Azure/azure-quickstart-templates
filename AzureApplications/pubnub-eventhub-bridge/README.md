#  PubNub Realtime Gateway for Azure Event Hubs

## What does it do?
The PubNub Realtime Gateway for Azure provides a realtime data stream bridge between the PubNub Data Stream Network and Azure Event Hubs. -- consider it a bi-directional bridge between PubNub and Azure!

If you need to:

* Feed realtime PubNub data into Azure via an Event Hub, and then use that Event Hub as an input for other Azure cloud services
* Feed Azure Event Hub data back out to PubNub

Then this is the ARM template for you!

Tags: ``Event Hubs, Event Hub, Realtime, PubNub, PubSub, Pub/Sub, Publish/Subscribe, Node.js, Web Jobs``

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpubnub-eventhub-bridge%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>    
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpubnub-eventhub-bridge%2Fazuredeploy.json">
    <img src="https://camo.githubusercontent.com/536ab4f9bc823c2e0ce72fb610aafda57d8c6c12/687474703a2f2f61726d76697a2e696f2f76697375616c697a65627574746f6e2e706e67" data-canonical-src="http://armviz.io/visualizebutton.png" style="max-width:100%;">
</a>


## What does it deploy?
* PubNub/Azure gateway script writing in Node.js
* Web Job
* Two (Ingress and Egress) Event Hubs, each with their own SAS Policies
* US West Basic App Service Plan

##How Does it Work?

<img src="https://s3.amazonaws.com/pubnub/pubnub-eventhub-bridge/PNAzureDataFlow.png">

When all these pieces are deployed together, we're provided with an end-to-end PubNub/Azure gatway.  Here's more details on how they all work together:

### Web Job
A Web Job provides the node.js runtime needed to execute the PubNub/Azure gateway script.

### PubNub/Azure Gateway Script

The PubNub/Azure gateway script is written in Node.js, and does the following:

* Instantiates a PubNub subscriber, which receives PubNub data in realtime, and forwards it to the Ingress Event Hub.

* Instantiates a PubNub publisher, which receives Egress Event Hub data and publishes it out via PubNub.

### Event Hubs

The Ingress Event Hub is populated via PubNub subscribe data, and should serve as an "Input" to Azure Cloud services of your choice.

The Egress Event Hub should serve as an "Output" from Azure Cloud services of your choice, and all data sent to it will be published out via PubNub.


## How to Deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fpubnub-eventhub-bridge%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

1. Be sure you are logged in to <a href="https://portal.azure.com">https://portal.azure.com</a>
2. Click one of the conveniently placed "Deploy to Azure" buttons on this page.

	The template will appear with some defaults.

	<img src="https://s3.amazonaws.com/pubnub/pubnub-eventhub-bridge/deploymentGui.png">

	Going down the list...

3. Choose the *Subscription* you wish to associated this deployment with.
4. Create a new, or use an existing *Resource Group* to deploy this template to.  

	**NOTE:** It's suggested to use a unique Resource Group if it's your first time playing with this template... that way if you need to experiment with different configurations, deleting the entire Resource Group is a quick way to delete all the components so you can start over from the beginning with a clean slate.

5. For *Location*, select West US.

	**NOTE:** Some Azure services rely on all participating Azure components being located in the same region.  The way this template is currently coded, it's required to use West US for all location variables.  If this is showstopping for you, please fork the repo, and edit any hardcoded "West US" values in the template to the locations you desire, and then be sure the form values match when deploying.
	
6. For the *Event Hub Namespace*, create a unique Namespace.  It's suggested to replace the "pn-" prefix with your own unique prefix, such as your company name, and add a "-suffix" at the end, where the suffix is also unique.  
	
	**NOTE:**	For example, if your company was widgets.com: widgetscom-eventhub-1fba54e9-vegaswolfpack.  You don't need to follow this exact pattern, but be sure its completely unique!  Be sure to stick to dashes as seperators, or refer to Azure documentation for the list of legal chars in an Event Hub Namespace string.
	
7. For the *Azure Web Job Name*, create a unique Web Job Name.  Follow the same naming conventions as for Event Hub Namespaces to ensure you have a unique, legal string.

8. For the *Azure Datacenter Location*, enter westus.

	**NOTE:** Some Azure services rely on all participating Azure components being located in the same region.  The way this template is currently coded, it's required to use West US for all location variables.  If this is showstopping for you, please fork the repo, and edit any hardcoded "West US" values in the template to the locations you desire, and then be sure the form values match when deploying.
	
9. For the *PubNub Ingress Channel*, enter a channel name that the PubNub Subscriber should listen on.  If you wish for the subscriber to listen on multiple channels, enter a CSV list of channels, with no spaces.

10. For the *PubNub Egress Channel*, enter a channel name that the PubNub Publisher should publish back out on.

11. For the *PubNub Announce Channel*, enter a channel name that the PubNub Deployment script will alert on when the deployment has completed.  If you don't intend on using this, just set this value to lowercase, case-sensitive *disabled*.  See below for more information on using the Provisioning Listener and the Announce channel.

12. For the *PubNub Publish Key*, enter the PubNub Publish API Key that the PubNub component should publish against.

13. For the *PubNub Subscribe Key*, enter the PubNub Subscribe API Key that the PubNub component should subscribe against.

14. For the *Azure Service Plan*, enter USWestBasic.

	**NOTE:** Some Azure services rely on all participating Azure components being located in the same region.  The way this template is currently coded, it's required to use West US for all location variables.  If this is showstopping for you, please fork the repo, and edit any hardcoded "West US" values in the template to the locations you desire, and then be sure the form values match when deploying.
	
15. For the *Azure Ingress Event Hub Name*, enter the name you wish to give the Ingress (Input) Event Hub.  You can accept the default, as the Event Hub name needs only to be unique within a unique Event Hub Namespace.

16. For the *Azure Egress Event Hub Name*, enter the name you wish to give the Egress (Output) Event Hub.  You can accept the default, as the Event Hub name needs only to be unique within a unique Event Hub Namespace.

17. For the *Azure Ingress SAS Policy Name*, enter the name you wish to give the Ingress (Input) Event Hub SAS Policy.  You can accept the default, as the Event Hub SAS Policy name needs only to be unique within a unique Event Hub Namespace.

18. For the *Azure Egress SAS Policy Name*, enter the name you wish to give the Egress (Output) Event Hub SAS Policy.  You can accept the default, as the Event Hub SAS Policy name needs only to be unique within a unique Event Hub Namespace.

19. Check the *I agree to the terms and conditions stated above* checkbox.

20. Click *Purchase*.

## Throughput Limits
The ARM template and use case discussed in this tutorial serve to provide a “general purpose” PubNub <-> Azure bridging architecture.
The ARM template defines a **Basic 1: Small** service plan, with a
**1 Throughput Unit** Event Hub configuration.

Its an economical setup that is great to explore Azure and PubNub with, but definitely not a one-size-fits all for production.
**The default configuration should be able to handle one Megabyte per second OR one thousand messages per second**, however, there are many factors which may increase or decrease these default limits based on your specific traffic patterns, Azure service plan, use case, and overall system complexity.

For this reason, if you plan to implement this bridge for an enterprise / production environment, please contact us at support@pubnub.com so we may review your particular use case and assist with any fine tuning necessary on the PubNub and/or Microsoft side.  With proper architectural review, the PubNub and Microsoft components can be scaled to handle and process as much load as your use case demands.

## Troubleshooting

The following tools can give you a 360-degree view of your traffic as it enters the ingress and egress PubNub Channels and Event Hubs.  Together they are useful for tracing your data through the system.

### Monitoring PubNub Traffic
The PubNub Debug Console is a handy tool to use to monitor PubNub traffic.  

1. Connect to <a href="https://www.pubnub.com/console">https://www.pubnub.com/console</a>
2. Enter the PubNub Subscribe and Publish Keys
3. Enter the PubNub Ingress Channel
4. Connect
5. Repeat Steps 1-4, but on step 3, enter the PubNub Egress Channel

You can now monitor all incoming and outgoing PubNub traffic traversing through the PubNub/Azure gateway.  

You can also Publish test traffic on the "Ingress" console to send sample data through the system.

### Monitoring and Debugging Event Hub Traffic with provisioningListener.js
To gain visibility into what is being sent into the ingress and egress Event Hubs, use the provisioningListener.js script.

Run ```node provisioningListener.js``` to get general usage info:

```
gcohen@(master):~/azureSubscribeBridge/monitoring$ node provisioningListener.js

Usage: node provisioningListener.js MODE OPTIONS

MODE can be either provision or monitor
When MODE is provision, OPTIONS are the announcement channel and subscribe key to listen on.
When MODE is monitor, OPTIONS are the ingress and egress connection strings to listen on.

Examples:
node provisioningListener.js provision pnAnnounce sub-abc-123

node provisioningListener.js monitor "Endpoint=sb://foo-eventhub.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=FY8E/gU4o=;EntityPath=infromsubscriberhub"  "Endpoint=sb://bar-eventhub.servicebus.windows.net/;SharedAccessKeyName=outtopnpublisherhub;SharedAccessKey=FY8E/gU4o=;EntityPath=outtopnpublisher"
```

There are three modes of operation: provision, monitor, and disabled.

#### Provision
When you are first deploying the PubNub/Azure bridge, run the script in *provision* mode.  This will autodetect and autoconfigure listeners to the two Event Hubs (ingress and egress) that the ARM Template creates.  It will leave you with a command line to use later to reconnect to these Event Hubs from the same script (in monitor mode.)

For example, let's say we're about to provisioned with this configuration:

<img src="https://s3.amazonaws.com/pubnub/pubnub-eventhub-bridge/provdemo.png"/>

Based on what we're about to submit, our announce channel is pnAnnounce, and our subscribe key is *demo*.  Based on this information, we'd first run our provisioningListener.js script with these values:

```
node provisioningListener.js provision pnAnnounce demo
```

Then, once the provisioningListener,js script is running, begin the deployment by clicking *Purchase* in the web-based ARM Template. 

Once the deployment has completed, it will "announce" itself via the announce channel, and the provisioningListener.js script will autoconfigure based on the values sent in the announcement message:

```
gcohen@(master):~/clients/azureSubscribeBridge/monitoring$ node provisioningListener.js provision pnAnnounce demo

provision mode detected.

Subscribe Key:  demo
Announce Channel:  pnAnnounce

Setting UUID to provisioning-712.101484881714

Listening for new PN/Azure Web Job Announce...

Received auto-provisioning payload from webjob-953.5124835092574

In the future, use the below command to monitor these Event Hubs:

node provisioningListener.js monitor "Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=fECC7E0hbfZFcZggrKPasgJbq1odY7LoLB6ll6xlHcA=;EntityPath=infromsubscriberhub" "Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=outtopublisherhub;SharedAccessKey=qmQZZYr2xvM+umHX7VFbim7UwCplTM9+naSDW6QHLaA=;EntityPath=outtopnpublisher"

Ingress Event Hub Connection String:  Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=fECC7E0hbfZFcZggrKPasgJbq1odY7LoLB6ll6xlHcA=;EntityPath=infromsubscriberhub

Egress Event Hub Connection String:  Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=outtopublisherhub;SharedAccessKey=qmQZZYr2xvM+umHX7VFbim7UwCplTM9+naSDW6QHLaA=;EntityPath=outtopnpublisher

Waiting for messages to arrive via Event Hubs...

Message Received on Ingress Event Hub:   : {"guess what?":"this message arrived via PubNub into the ingress Event Hub!"}
```


In addition, a handy re-usable command line (to copy and paste later) is displayed to use to reconnect to the Event Hubs any time:

#### Monitor
To connect back to the Event Hubs anytime, just use the command line provided at provision-time:

```
gcohen@(master):~/azureSubscribeBridge/monitoring$ node provisioningListener.js monitor "Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=fECC7E0hbfZFcZggrKPasgJbq1odY7LoLB6ll6xlHcA=;EntityPath=infromsubscriberhub" "Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=outtopublisherhub;SharedAccessKey=qmQZZYr2xvM+umHX7VFbim7UwCplTM9+naSDW6QHLaA=;EntityPath=outtopnpublisher"

monitor mode detected.

Ingress Event Hub Connection String:  Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=fECC7E0hbfZFcZggrKPasgJbq1odY7LoLB6ll6xlHcA=;EntityPath=infromsubscriberhub

Egress Event Hub Connection String:  Endpoint=sb://pn-eventhub-1fba54e9545.servicebus.windows.net/;SharedAccessKeyName=outtopublisherhub;SharedAccessKey=qmQZZYr2xvM+umHX7VFbim7UwCplTM9+naSDW6QHLaA=;EntityPath=outtopnpublisher

Waiting for messages to arrive via Event Hubs...

Message Received on Ingress Event Hub:   : {"oh yeah?":"so did this one!"}
```

#### Disable Provisioning Announcements
To be sure the bridge never announces it's configuration, just enter *disabled* for the value of PubNub Announce Channel in the ARM Template web form.  With *disabled* as the value, the bridge will never broadcast it's configuration out to any channel.

## Caveats

### Provisioning Script
If you have not explicitly disabled the provisioning script, it will continue to announce it's Event Hub configuration each time the script is restarted.  A script will restart not only manually, but also if for any reason it crashes (Azure Web Jobs automatically will try to restart it.)

##### Security
For security purposes, the provisioningListener.js script should only be used in development, non-production environments.  

For production environments, set *disabled* for the PubNub Announcement Channel value to disable broadcast of the Event Hub information, and grab the connection string info manually via the Azure Portal's Web Job configuration (either by command line or web gui.)

##### Delays
Although Azure may state the deployment has completed, there may be a delay in the provisioningListener.js script announcing the configuration information.  This can be due to not only asyncronous Azure deployment processes completing, including the npm install process which must run, and install supporting Node.js libraries.


### Location
Some Azure services rely on all participating Azure components being located in the same region.  The way this template is currently coded, it's required to use West US for all location variables.  If this is showstopping for you, please fork the repo, and edit any hardcoded "West US" values in the template to the locations you desire, and then be sure the form values match when deploying.

If you have trouble figuring this out for a project, please contact us at support@pubnub.com, we'd be happy to assist.

### Using Stream Analytics as an Egress Event Hub Input
If you are using Stream Analytics as an input to the Egress Event Hub, from within the Azure Portal, when configuring the Stream Analytics output sink, there is a field for "Format". The default is "Line Separated".  Be sure to change this to "Array", otherwise you may get strange output (what appears to look like byte array output, similar to type":"Buffer","data":[123,34,116,101,120,116...) on the PubNub publisher-side.

### Support
Questions about using this ARM Template?  Contact us at support@pubnub.com!


