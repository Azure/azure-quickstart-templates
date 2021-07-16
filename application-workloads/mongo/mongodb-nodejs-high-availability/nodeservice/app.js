var express = require('express');
var http = require('http');
var path = require('path');
var mongodb = require("mongodb");
var app = express();
var db;
app.set('port', process.env.PORT || 8080);

app.get('/', function (req, res) {

    var connString = "mongodb://youradminname:youradminpassword@10.0.0.10:27017,10.0.0.11:27017/tasks?replicaSet=rs0";
    var MongoClient = mongodb.MongoClient;

    MongoClient.connect(connString, function (err, database) {
        if (err) {
            return console.error('Unable to connect to the mongoDB server. Error:', err);
        } 
        db = database;

        console.log('Connection established to', connString);

        // Workload
        var collection = db.collection('tasks');

        //Clean
        collection.remove(function (err) {

            if(err)
            {
                return console.error('Unable to remove all data from collection. Error:', err);
            }
        
            //Create Tasks
            var task1 = { itemName: 'Item1', itemCategory: 'Cat2', itemCompleted: false, itemDate: Date.now };
            var task2 = { itemName: 'Item2', itemCategory: 'Cat2', itemCompleted: false, itemDate: Date.now };
            var task3 = { itemName: 'Item3', itemCategory: 'Cat1', itemCompleted: false, itemDate: Date.now };

            collection.insert([task1, task2, task3], function (err, result) {
                if (err) {
                    return console.error(err);
                }

                console.log('Inserted 3 documents into the "tasks" collection. The documents inserted with "_id" are:', result.length, result);
            });

            var all = collection.find().toArray(function (err, result) {
                if (err) {
                    return console.error(err);
                }

                else if (result.length) {
                    console.log('Found:', result);
                    res.status(200).json(result);
                }

                else {
                    console.log('No document(s) found with defined "find" criteria!');
                }
                
            });
        });
    });
});

http.createServer(app).listen(app.get('port'), function () {
    console.log('Express server listening on port ' + app.get('port'));
});
