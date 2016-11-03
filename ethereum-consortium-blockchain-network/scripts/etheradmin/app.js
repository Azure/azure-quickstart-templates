var express = require('express');
var exphbs = require('express-handlebars');
var session = require('express-session');
var bodyParser = require('body-parser');
var fs = require('fs');
var dns = require('dns');
var Web3 = require('web3');
var moment = require('moment');
var Promise = require('promise');

/*
 * Parameters
 */
var listenPort = process.argv[2]
var gethIPCPath = process.argv[3];
var coinbase = process.argv[4];
var coinbasePw = process.argv[5];
var mnNodePrefix = process.argv[6];
var numMNNodes = process.argv[7];
var txNodePrefix = process.argv[8];
var numTXNodes = process.argv[9];
var numConsortiumMembers = process.argv[10];

/*
 * Constants
 */
var gethRPCPort = "8545";
var refreshInterval = 10000;

var app = express();
var web3IPC = new Web3(new Web3.providers.IpcProvider(gethIPCPath, require('net')));

app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');
app.use(express.static('public'));
app.use(bodyParser.urlencoded({extended: true}));
app.use(session({
  secret: coinbasePw,
  resave: false,
  saveUninitialized: true
}))

var nodeInfoArray = [];
var timeStamp;

function getNodeInfo(hostName) {
  return new Promise(function (resolve, reject){
    var consortiumId;

    if(hostName.indexOf("-tx") !== -1) {
      consortiumId = 'N/A';
    }
    else {
      consortiumId = hostName.split('-mn')[1] % numConsortiumMembers;
    }

    try {
      var web3RPC = new Web3(new Web3.providers.HttpProvider("http://" + hostName + ":" + gethRPCPort));
    }
    catch(err) {
      console.log(err);
    }
    var web3PromiseArray = [];
    web3PromiseArray.push(new Promise(function(resolve, reject) {
      web3RPC.net.getPeerCount(function(error, result) {
        if(!error)
        {
          resolve(result);
        }
        else {
          resolve("Not running");
        }
      });
    }));
    web3PromiseArray.push(new Promise(function(resolve, reject) {
      web3RPC.eth.getBlockNumber(function(error, result) {
        if(!error)
        {
          resolve(result);
        }
        else {
          resolve("Not running");
        }
      });
    }));

    Promise.all(web3PromiseArray).then(function(values){
      var peerCount = values[0];
      var blockNumber = values[1];
      var nodeInfo = {hostname: hostName, peercount: peerCount, blocknumber: blockNumber, consortiumid: consortiumId};
      resolve(nodeInfo);
    });
  });
}

function getNodesInfo() {
  console.time("getNodesInfo");
  var promiseArray = [];

  for(var i = 0; i < numTXNodes; i++) {
    promiseArray.push(getNodeInfo(txNodePrefix.concat(i)));
  }
  for(var i = 0; i < numMNNodes; i++) {
    promiseArray.push(getNodeInfo(mnNodePrefix.concat(i)));
  }

  Promise.all(promiseArray).then(function(values) {
    nodeInfoArray = [];
    var arrLen = values.length;
    for(var i = 0; i< arrLen; ++i) {
      nodeInfoArray.push(values[i]);
    }
    // Sort the final result by consortium ID
    nodeInfoArray = nodeInfoArray.sort(function(a,b) {
      var aIsTx = a.consortiumid === 'N/A';
      var bIsTx = b.consortiumid === 'N/A';

      if (aIsTx && bIsTx)
        return 0;
      if (aIsTx)
        return -1;
      if (bIsTx)
        return 1;
      return (a.consortiumid - b.consortiumid);
    });

    timeStamp = moment().format('h:mm:ss A UTC,  MMM Do YYYY');
    console.timeEnd("getNodesInfo");
    // Schedule next refresh
    setTimeout(getNodesInfo, refreshInterval);
  });
}

// Kick-off refresh cycle
getNodesInfo();

// Check if we've mined a block yet
function minedABlock () {
  var result = nodeInfoArray.filter(function(item) {
    return item.blocknumber > 0;
  });

  return result.length > 0;
}

app.get('/', function (req, res) {
  // Check if the IPC endpoint is up and running
  if(fs.existsSync(gethIPCPath)) {
    var hasNodeRows = nodeInfoArray.length > 0;
    var data = { isSent: req.session.isSent, error: req.session.error, hasNodeRows: hasNodeRows, nodeRows: nodeInfoArray, minedABlock: minedABlock(), timestamp: timeStamp, refreshinterval: (refreshInterval/1000) };
    req.session.isSent = false;
    req.session.error = false;

    res.render('etheradmin', data);
  }
  else {
    res.render('etherstartup');
  }
});

app.post('/', function(req, res) {
  var address = req.body.etherAddress;

  if(web3IPC.isAddress(address)) {
    web3IPC.personal.unlockAccount(coinbase, coinbasePw, function(err, res) {
      console.log(res);
      web3IPC.eth.sendTransaction({from: coinbase, to: address, value: web3IPC.toWei(1000, 'ether')}, function(err, res){ console.log(address)});
    });

    req.session.isSent = true;
  } else {
    req.session.error = "Not a valid Ethereum address";
  }

  res.redirect('/');
});

app.listen(listenPort, function () {
  console.log('Admin webserver listening on port ' + listenPort);
});
