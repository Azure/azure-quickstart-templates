// This file Takes a PN Input, Sends it to EH1's input.  Then, anything that arrives on EH2's output is sent back out
// via PN Publish.  User-defined magic should happen between EH1 -> EH2, such as Stream Analytics, etc.

'use strict';

// PN Vars

var PNSubChannel = process.env['CUSTOMCONNSTR_PNSubChannel'];
var PNPubChannel = process.env['CUSTOMCONNSTR_PNPubChannel'];
var PNAnnounceChannel = process.env['CUSTOMCONNSTR_PNAnnounceChannel'];
var PNPublishKey = process.env['CUSTOMCONNSTR_PNPublishKey'];
var PNSubscribeKey = process.env['CUSTOMCONNSTR_PNSubscribeKey'];

// Azure Vars

var EHInConnectionString  = process.env['CUSTOMCONNSTR_EHInConnectionString'];
var EHOutConnectionString = process.env['CUSTOMCONNSTR_EHOutConnectionString'];

if (!PNSubChannel || !PNPubChannel || !PNAnnounceChannel || !PNPublishKey || !PNSubscribeKey) {

    console.log("Error: Missing required vars!");
    console.log(process.env);

    PNSubChannel =   "pnInput";
    PNPubChannel =   "pnOutput";
    PNAnnounceChannel = "pnAnnounce";
    PNPublishKey =   "demo-36";
    PNSubscribeKey = "demo-36";

    //EHInConnectionString  = "Endpoint=sb://pn-eventhub-1fba54e9.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=czNb0gZMBkSzgZsRgO8CGcicTfaOV3FK4xdH92IaJKU=;EntityPath=infromsubscriberhub";
    //EHOutConnectionString  = "Endpoint=sb://pn-eventhub-1fba54e9.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=vKj52NwjhvO88U9CoXEbMW0O/TPw8NE5tuP0mZFzIo0=;EntityPath=infromsubscriberhub";

}

console.log(PNSubChannel);
console.log(PNPubChannel);
console.log(PNPublishKey);
console.log(PNSubscribeKey);
console.log(EHInConnectionString);
console.log(EHOutConnectionString);
//console.log(process.env);

var uuid = "webjob-" + (Math.random() * 1000);
console.log("Setting UUID to " + uuid);

var pubnub = require("pubnub")({
    ssl: true,
    publish_key: PNPublishKey,
    subscribe_key: PNSubscribeKey,
    uuid: uuid
});

var PNPublish = function(ehEvent) {
    console.log('Event Received from EHOutClient, Publishing via PubNub: ');
    console.log(JSON.stringify(ehEvent.body));
    console.log("");

    pubnub.publish({
        channel: PNPubChannel,
        message: ehEvent.body
    });
};

var receiveAfterTime = Date.now() - 0;

var EventHubClient = require('azure-event-hubs').Client;
var Promise = require('bluebird');


var printError = function (err) {
    console.log("Error: " + err.message);
};

/**************                                 Create the Ingress Path                                 */

var EHInClient = EventHubClient.fromConnectionString(EHInConnectionString);

// Create the EH Client
EHInClient.open()
    .then(EHInClient.getPartitionIds.bind(EHInClient))
    .catch(printError);

// Create the sender, and then, subscribe via PN, forwarding all messages to this new subscriber to the sender.

EHInClient.createSender().then(function(sender){
    pubnub.subscribe({
        channel: PNSubChannel,
        message: function (message) {
            console.log("Received and forwarding message: " + JSON.stringify(message, null, 4));
            sender.send(message);
        }
    });

    // In Production, you may wish to either PAM Protect the Sub Channel, or this or remove it completely. Its handy for development and demos.

    pubnub.state({
        channel: PNAnnounceChannel,
        state: {
            EHInConnectionString: EHInConnectionString,
            EHOutConnectionString: EHOutConnectionString
        }
    });


});

/**************                                 Create the Egress Path                                 */

var EHOutClient = EventHubClient.fromConnectionString(EHOutConnectionString);

EHOutClient.open()
    .then(EHOutClient.getPartitionIds.bind(EHOutClient))
    .then(function (partitionIds) {
        return Promise.map(partitionIds, function (partitionId) {
            return EHOutClient.createReceiver('$Default', partitionId, { 'startAfterTime' : receiveAfterTime}).then(function (receiver) {
                receiver.on('errorReceived', printError);
                receiver.on('message', PNPublish);
            });
        });
    })
    .catch(printError);
