'use strict';

var EventHubClient = require('azure-event-hubs').Client;
var Promise = require('bluebird');

var PNAnnounceChannel = "pnAnnounce";
var PNPublishKey =   "demo-36";
var PNSubscribeKey = "demo-36";

// Azure Vars

var EHInConnectionString  = "";
var EHOutConnectionString = "";

console.log("Using keys: ");
console.log(PNPublishKey);
console.log(PNSubscribeKey);

var PNAnnounceChannel = "pnAnnounce";
//console.log(process.env);

var uuid = "provisioning-" + (Math.random() * 1000);
console.log("\nSetting UUID to " + uuid);

var pubnub = require("pubnub")({
    ssl: true,
    publish_key: PNPublishKey,
    subscribe_key: PNSubscribeKey,
    uuid: uuid
});

console.log("\nListening for new PN/Azure Web Job Announce...");
pubnub.subscribe({
    uuid: uuid,
    channel: PNAnnounceChannel,
    message: function (message) {
        console.log("Received Message: ", JSON.stringify(message, null, 4));
    },
    presence: function (message) {

        if (message.action == "state-change") {

            console.log("\nReceived auto-provisioning payload from " + message.uuid + " : ");

            EHInConnectionString = message.data.EHInConnectionString;
            EHOutConnectionString = message.data.EHOutConnectionString;

            console.log("\nEHInConnectionString: ", EHInConnectionString);
            console.log("EHOutConnectionString: ", EHOutConnectionString);

            pubnub.unsubscribe({
                "channel": PNAnnounceChannel,
                "callback": fireEHListeners
            });
        }
    }
});

function fireEHListeners(){

    console.log("\nBinding EH Listeners...");

    var receiveAfterTime = Date.now() - 0;

    var printError = function (err) {
        console.log("Error: " + err.message);
    };

    function printInMessage(msg) {
        console.log("Message from Input" + ": " + JSON.stringify(msg.body));
    }

    function printOutMessage(msg) {
        console.log("Message from Output" + ": " + JSON.stringify(msg.body));
    }

    /**************                                 Create the Ingress Path                                 */

    var EHInClient = EventHubClient.fromConnectionString(EHInConnectionString);
    var EHOutClient = EventHubClient.fromConnectionString(EHOutConnectionString);

    EHOutClient.open()
        .then(EHOutClient.getPartitionIds.bind(EHOutClient))
        .then(function (partitionIds) {
            return Promise.map(partitionIds, function (partitionId) {
                return EHOutClient.createReceiver('$Default', partitionId, { 'startAfterTime' : receiveAfterTime}).then(function (receiver) {
                    receiver.on('errorReceived', printError);
                    receiver.on('message', printOutMessage);
                });
            });
        }).catch(printError);

    EHInClient.open()
        .then(EHInClient.getPartitionIds.bind(EHInClient))
        .then(function (partitionIds) {
            return Promise.map(partitionIds, function (partitionId) {
                return EHInClient.createReceiver('$Default', partitionId, { 'startAfterTime' : receiveAfterTime}).then(function (receiver) {
                    receiver.on('errorReceived', printError);
                    receiver.on('message', printInMessage);
                });
            });
        }).catch(printError);

}


