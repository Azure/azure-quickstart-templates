// This file bridges a PN Subscribe to an Event Hub Input.  Upon receiving the message, the message is published back
// via PubNub to a "relay" channel.

'use strict';

var pubnub = require("pubnub")({
    ssl: true,  // <- enable TLS Tunneling over TCP
    publish_key: "demo-36",
    subscribe_key: "demo-36"
});

var EventHubClient = require('azure-event-hubs').Client;
var Promise = require('bluebird');

var PNPublish = function(relayMessage) {
    pubnub.publish({
        channel: "bot-relay",
        message: relayMessage.body
    });
}

var connectionString = 'Endpoint=sb://autonubeventhub.servicebus.windows.net/;SharedAccessKeyName=infromsubscriberhub;SharedAccessKey=533HJhCxZIynOV1xbQKBWgilDQ4euKRSUxWsbZBG1v4=;EntityPath=infrompnsubscriber';
var eventHubPath = '';

var printError = function (err) {
    console.error(err.message);
};

var printEvent = function (ehEvent) {
    PNPublish(ehEvent);

    console.log('Event Received: ');
    console.log(JSON.stringify(ehEvent.body));
    console.log('');
};

var client = EventHubClient.fromConnectionString(connectionString, eventHubPath);
var receiveAfterTime = Date.now() - 5000;

client.open()
    .then(client.getPartitionIds.bind(client))
    .then(function (partitionIds) {
        return Promise.map(partitionIds, function (partitionId) {
            return client.createReceiver('$Default', partitionId, { 'startAfterTime' : receiveAfterTime}).then(function (receiver) {
                receiver.on('errorReceived', printError);
                receiver.on('message', printEvent);
            });
        });
    })
    .catch(printError);

client.createSender().then(function(sender){
    pubnub.subscribe({
        channel: "bot_object",
        message: function (message) {
            sender.send(message);
        }
    })
});

