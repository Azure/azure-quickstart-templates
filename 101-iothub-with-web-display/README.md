# IoTHub + Web Display

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://azuredeploy.net/?repository=https://github.com/gcrev93/IoTHM/)

This repo includes an Azure Resource Manager(ARM) template that will deploy an Azure IoT Hub, Storage Account, Service Bus, Logic App and Web Application. (ARM template file is the azuredeploy.json)

![Architecture Diagram](https://github.com/gcrev93/IoTHM/blob/master/img/architecure_diagram.JPG?raw=true)

The Iot Hub will be used to manage the different IoT devices. It will also be built with a Service Bus included as one of the messaging routes. 

The Service Bus will be used to receive and handle messages from the IoT Device. 

The Storage Account will be used to save the messages in an Azure table. (Important Note: The ARM template does not create the actual stroage table for you, only the account. In the steps below you can find how to create a table that will work with the resources created by the ARM template)

The Logic App will be used to read the messages from the Service Bus and then push them to the appropriate Azure Table.

The Web Application will pull the messages from the Azure Table and display them in an HTML table. (The code for the web application is a part of this repo. So if you would like to edit the web application, feel free to fork and point your web app to the forked repo)


## How To Deploy

After you press the deploy button (and you are properly signed into your Azure account), you should see the following screen:

![Deploy to Azure](https://github.com/gcrev93/IoTHM/blob/master/img/deploy_to_az.JPG?raw=true)

It will automatically assume you want to create a new Resource Group and auto populate the Resource Group Name. Feel free to change the Resource Group to one you already have, or make a new one and change the Resource Group Name.

Next fill out the fields with names for your IoT Hub, Logic App, Service Bus, Storage Account, Service Bus Message Queue and Web Application. **Be sure to make the names as unique as possible, because the deployment will not check for unique names until later in the process**

Once the template is validated and everything is deployed, head over to your Resource group containing your new resources in the Azure Portal. We will need to make your storage table in your Storage Account, so select your **Storage Account** resource.

![Select Storage](https://github.com/gcrev93/IoTHM/blob/master/img/select_storage.JPG?raw=true)

When you are in the *Overview* section of your Storage Account, select the **Tables** 

![Select Table](https://github.com/gcrev93/IoTHM/blob/master/img/tables.JPG?raw=true)

At the top of the Table Service page, you will want to select **Add Table**

![Add Table](https://github.com/gcrev93/IoTHM/blob/master/img/add_table.JPG?raw=true)

### When it asks for your table name, you MUST name it the same as your Storage Account. If you do not remember what you named your storage account, you can find it at the top of the Table Service page.

![Table Storage Name](https://github.com/gcrev93/IoTHM/blob/master/img/table_name.JPG?raw=true)

Once this is done everything is ready to go, so that you may use your IoT Hub and view your messages. The rest of this README will show you how to use your IoT Hub. Creating a Device in your hub and some sample code (a Node.js app) can be seen below

## Using Your IoT Hub

Your first step will be to create a device or devices! You can do so first by selecting your IoTHub in your resource group

![Select IoT](https://github.com/gcrev93/IoTHM/blob/master/img/resource_group.JPG?raw=true)

When the IoT Hub blade and Overview come up, scroll down the blade and select **Device Explorer**

![Device Explorer](https://github.com/gcrev93/IoTHM/blob/master/img/device_explorer.JPG?raw=true)

At the top of the Device Explorer page, select **Add**

![Add Device](https://github.com/gcrev93/IoTHM/blob/master/img/add_device.JPG?raw=true)

A side blade will pop up! Fill in the Device Id with any name you would like. Be sure *Auto Generate Keys* is selected

![Device Id](https://github.com/gcrev93/IoTHM/blob/master/img/device_id.JPG?raw=true)

Once you create your device, you will see the Device Explorer page refresh and show your newly created device. Select the device and a blade should pop up with the Access Keys and Connection Strings of the device. Please copy and paste your **Connection String** to a secure location. 

![Device Connection](https://github.com/gcrev93/IoTHM/blob/master/img/device_connection.JPG?raw=true)

Now that you have a device set up in your cloud, you may now send messages (or any data you would like) from your device to your IoT Hub.

Below is a same Node app you can run to send some sample data. Feel free to expand on it and start sending real data to your hub. 

You will need to install the following node modules to use this sample code

`npm install -g azure-iot-device`

`npm install -g azure-iot-device-mqtt`

```
var Protocol = require('azure-iot-device-mqtt').Mqtt;
var Client = require('azure-iot-device').Client;
var Message = require('azure-iot-device').Message;

var connectionString = '<INSERT YOUR DEVICE CONNECTION STRING>';
var deviceId = '<DEVICE ID>'

// fromConnectionString must specify a transport constructor, coming from any transport package.
var client = Client.fromConnectionString(connectionString, Protocol);

var connectCallback = function (err) {
    if (err) {
        console.error('Could not connect: ' + err.message);
    } else {
        console.log('Client connected');

        client.on('error', function (err) {
            console.error(err.message);
        });

        client.on('disconnect', function () {
            clearInterval(sendInterval);
            client.removeAllListeners();
            client.open(connectCallback);
        });
    }
};

var time = new Date();
var data = JSON.stringify({ deviceId: deviceId, message: "this is a new message", time: time });
var message = new Message(data);

client.sendEvent(message, printResultFor('send'));

client.open(connectCallback);

function printResultFor(op) {
    return function printResult(err, res) {
        if (err) console.log(op + ' error: ' + err.toString());
        if (res) console.log(op + ' status: ' + res.constructor.name);
    };
}

```

These messages (or data) will be seen on your web app once they are pushed to the hub. Here is a view of an example table

![Example Table](https://github.com/gcrev93/IoTHM/blob/master/img/example_table.JPG?raw=true)

You may edit what messages stay in your table by using the [Azure Storage Explorer](https://azure.microsoft.com/en-us/features/storage-explorer/).



