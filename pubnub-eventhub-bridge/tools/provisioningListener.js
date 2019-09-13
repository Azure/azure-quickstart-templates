'use strict';

var EventHubClient = require('azure-event-hubs').Client;
var Promise = require('bluebird');

// PN Vars
var PNAnnounceChannel = "pnAnnounce";
var PNSubscribeKey = "";

// Azure Vars
var EHInConnectionString = "";
var EHOutConnectionString = "";

function usage() {
    console.log();
    console.log("Usage: node provisioningListener.js MODE OPTIONS");
    console.log("");
    console.log("MODE can be either provision or monitor");
    console.log("When MODE is provision, OPTIONS are the announcement channel and subscribe key to listen on.");
    console.log("When MODE is monitor, OPTIONS are the ingress and egress connection strings to listen on.");
    console.log("");
    console.log("Examples:");
    console.log("node provisioningListener.js provision pnAnnounce sub-abc-123");
    console.log("");
    console.log('node provisioningListener.js monitor "Endpoint=sb://foo-eventhub.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=FY8E/gU4o=;EntityPath=infromsubscriberhub"  "Endpoint=sb://bar-eventhub.servicebus.windows.net/;SharedAccessKeyName=outtopnpublisherhub;SharedAccessKey=FY8E/gU4o=;EntityPath=outtopnpublisher"');
    console.log("");
    process.exit();
}

function listenForAnnounce() {

    console.log("Subscribe Key: ", PNSubscribeKey);
    console.log("Announce Channel: ", PNAnnounceChannel);

    var uuid = "provisioning-" + (Math.random() * 1000);
    console.log("\nSetting UUID to " + uuid);

    var pubnub = require("pubnub")({
        ssl: true,
        subscribeKey: PNSubscribeKey,
        uuid: uuid
    });

    pubnub.addListener({
        status: function(message) {
            // optionally, handle status events here
        },
        message: function(message) {
            console.log("Received Message: ", JSON.stringify(message, null, 4));
        },
        presence: function(message) {
            if (message.action == "state-change") {
                console.log("\nReceived auto-provisioning payload from " + message.uuid);

                EHInConnectionString = message.data.EHInConnectionString;
                EHOutConnectionString = message.data.EHOutConnectionString;

                //console.log("EHInConnectionString: ", EHInConnectionString);
                //console.log();
                //console.log("EHOutConnectionString: ", EHOutConnectionString);
                console.log();
                console.log("In the future, use the below command to monitor these Event Hubs: ");
                console.log();
                console.log("node provisioningListener.js monitor " + '"' + EHInConnectionString + '" "' + EHOutConnectionString + '"');
                console.log();

                pubnub.unsubscribe({
                    "channel": PNAnnounceChannel,
                    // "callback": fireEHListeners
                });
                // 'callback' is no longer supported in 'unsubscribe'
                // so it might be desirable to use a 'await' to call this next line
                fireEHListeners();
            }
        }
    });

    console.log("\nListening for new PN/Azure Web Job Announce...");
    pubnub.subscribe({
        channels: [PNAnnounceChannel]
    });
}

function fireEHListeners() {

    console.log("Ingress Event Hub Connection String: ", EHInConnectionString);
    console.log("");
    console.log("Egress Event Hub Connection String: ",  EHOutConnectionString);

    console.log();
    console.log("Waiting for messages to arrive via Event Hubs...");
    console.log();

    var receiveAfterTime = Date.now() - 0;

    var printError = function (err) {
        console.log("Error: " + err.message);
    };

    function printInMessage(msg) {
        console.log("Message Received on Ingress Event Hub:   " + ": " + JSON.stringify(msg.body));
        console.log();
    }


    function printOutMessage(msg) {
        console.log("Message Received on Egress Event Hub:   " + ": " + JSON.stringify(msg.body));
        console.log();
    }

    /**************                                 Create the Ingress Path                                 */

    var EHInClient = EventHubClient.fromConnectionString(EHInConnectionString);
    var EHOutClient = EventHubClient.fromConnectionString(EHOutConnectionString);

    EHOutClient.open()
        .then(EHOutClient.getPartitionIds.bind(EHOutClient))
        .then(function (partitionIds) {
            return Promise.map(partitionIds, function (partitionId) {
                return EHOutClient.createReceiver('$Default', partitionId, {'startAfterTime': receiveAfterTime}).then(function (receiver) {
                    receiver.on('errorReceived', printError);
                    receiver.on('message', printOutMessage);
                });
            });
        }).catch(printError);

    EHInClient.open()
        .then(EHInClient.getPartitionIds.bind(EHInClient))
        .then(function (partitionIds) {
            return Promise.map(partitionIds, function (partitionId) {
                return EHInClient.createReceiver('$Default', partitionId, {'startAfterTime': receiveAfterTime}).then(function (receiver) {
                    receiver.on('errorReceived', printError);
                    receiver.on('message', printInMessage);
                });
            });
        }).catch(printError);
}

// Take in cli
if (!process.argv[2]) {
    usage();
}

// Handle Provision Mode
if (process.argv[2] == "provision") {

    console.log();
    console.log("provision mode detected.");
    console.log();

    if (!process.argv[3] && !process.argv[4]) {
        console.log("ERROR: You must provide an announcement channel and subscribe key to listen on, for example:");
        console.log("node provisioningListener.js provision pnAnnounce sub-abc-123");
        console.log();
        process.exit();
    } else {
        PNAnnounceChannel = process.argv[3];
        PNSubscribeKey = process.argv[4];

        listenForAnnounce();
    }
} else if (process.argv[2] == "monitor") {

// Handle Monitor Mode
    console.log();
    console.log("monitor mode detected.");
    console.log();


    if (!process.argv[3] && !process.argv[4]) {
        console.log("ERROR: You must provide announce channel, ingress, and egress connection strings when using monitor mode.");
        console.log("");
        console.log("Example:");
        console.log('node provisioningListener.js monitor "Endpoint=sb://foo-eventhub.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=FY8E/gU4o=;EntityPath=infromsubscriberhub"  "Endpoint=sb://bar-eventhub.servicebus.windows.net/;SharedAccessKeyName=outtopnpublisherhub;SharedAccessKey=FY8E/gU4o=;EntityPath=outtopnpublisher"');
        process.exit();
    } else {
        EHInConnectionString = process.argv[3];
        EHOutConnectionString = process.argv[4];

        fireEHListeners();
    }
} else {
    usage();
}


