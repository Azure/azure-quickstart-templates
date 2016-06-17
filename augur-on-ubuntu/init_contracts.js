#!/usr/bin/env node

"use strict";

//var augur = require("augur.js");

var args = process.argv.slice(2);

var http = args[0] || "http://127.0.0.1:8545";
var options = {};
options.http = http;
options.ws = null;
options.contracts = JSON.parse("{{ $BUILD_AZURE_CONTRACTS }}");

augur.connect(options, function (connected) {
    if (!connected) return console.error("connect failed:", connected);
    augur.initDefaultBranch(function (res) {
        console.log("initDefaultBranch sent:", res);
    }, function (res) {
        console.log("initDefaultBranch success:", res);
    }, function (err) {
        console.error("initDefaultBranch failed:", err);
    });
});
