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

var EHInConnectionString = process.env['CUSTOMCONNSTR_EHInConnectionString'];
var EHOutConnectionString = process.env['CUSTOMCONNSTR_EHOutConnectionString'];

if (!PNSubChannel || !PNPubChannel || !PNAnnounceChannel || !PNPublishKey || !PNSubscribeKey) {

    console.log("Error: Missing required vars!");
    dumpVars();
    process.exit();
}

function dumpVars() {
    console.log("PNSubChannel: ", PNSubChannel);
    console.log("PNPubChannel: ", PNPubChannel);
    console.log("PNPublishKey: ", PNPublishKey);
    console.log("PNSubscribeKey: ", PNSubscribeKey);
    console.log("EHInConnectionString: ", EHInConnectionString);
    console.log("EHOutConnectionString: ", EHOutConnectionString);
    console.log();
    console.log("Env Process Dump:");
    console.log();
    console.log(process.env);
}
dumpVars();

var uuid = "webjob-" + (Math.random() * 1000);
console.log("Setting UUID to " + uuid);

var pubnub = require("pubnub")({
    ssl: true,
    publish_key: PNPublishKey,
    subscribe_key: PNSubscribeKey,
    uuid: uuid
});

var PNPublish = function (ehEvent) {
    // console.log('Event Received from Egress EH, Publishing to PN: ');
    // console.log(JSON.stringify(ehEvent.body));
    // console.log("");

    if (Array.isArray(ehEvent.body)){

        ehEvent.body.forEach(function(element){

            pubnub.publish({
                channel: PNPubChannel,
                message: element,
                error: function(e) {
                    console.log("PN Array Element Publish Error: ", e);
                    console.log("Message causing error: ", element);
                }
            });
        });

    } else {

        console.log("No array detected.");
        pubnub.publish({
            channel: PNPubChannel,
            message: ehEvent.body,
            error: function(e) {
                console.log("PN Object Publish Error: ", JSON.stringify(e));
                console.log("Message causing error: ", element);
            }
        });

    }
};

var receiveAfterTime = Date.now() - 0;

var EventHubClient = require('azure-event-hubs').Client;
var Promise = require('bluebird');


var printError = function (err) {
    console.log("Event Hub Error: " + err.message);
};

/**************                                 Create the Ingress Path                                 */

var EHInClient = EventHubClient.fromConnectionString(EHInConnectionString);

// Create the EH Client
EHInClient.open()
    .then(EHInClient.getPartitionIds.bind(EHInClient))
    .catch(printError);

// Create the sender, and then, subscribe via PN, forwarding all messages to this new subscriber to the sender.

EHInClient.createSender().then(function (sender) {
    pubnub.subscribe({
        channel: PNSubChannel,
        message: function (message) {
            // console.log("Forwarding from PN Subscriber to Ingress EH: " + JSON.stringify(message, null, 4));
            sender.send(message);
        },
        error: printError
    });

    if (PNAnnounceChannel && PNAnnounceChannel != "disabled") {

        pubnub.state({
            channel: PNAnnounceChannel,
            state: {
                EHInConnectionString: EHInConnectionString,
                EHOutConnectionString: EHOutConnectionString
            }
        });

    }

});

/**************                                 Create the Egress Path                                 */

var EHOutClient = EventHubClient.fromConnectionString(EHOutConnectionString);

EHOutClient.open()
    .then(EHOutClient.getPartitionIds.bind(EHOutClient))
    .then(function (partitionIds) {
        return Promise.map(partitionIds, function (partitionId) {
            return EHOutClient.createReceiver('$Default', partitionId, {'startAfterTime': receiveAfterTime}).then(function (receiver) {
                receiver.on('errorReceived', printError);
                receiver.on('message', PNPublish);
            });
        });
    })
    .catch(printError);
