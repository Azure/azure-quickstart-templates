var express = require('express');
var exphbs = require('express-handlebars');
var session = require('express-session');
var bodyParser = require('body-parser');
var fs = require('fs');
var dns = require('dns');
var Web3 = require('web3');

var gethIPCPath = process.argv[2];
var coinbase = process.argv[3];
var coinbasePw = process.argv[4];
var mnNodePrefix = process.argv[5];
var numMNNodes = process.argv[6];
var txNodePrefix = process.argv[7];
var numTXNodes = process.argv[8];

var app = express();
var web3 = new Web3(new Web3.providers.IpcProvider(gethIPCPath, require('net')));


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

function getNodeInfo(hostName) {
  // We perform a lookup to get the consortium ID by subnet IP
  dns.lookup(hostName, function(err, address, family) {
    var peerCount;
    var blockNumber;
    var consortiumId = address.split('.')[2];

    // Transaction nodes - in subnet 10 - do not belong to any consortiumId
    if (consortiumId === '10')
      consortiumId = 'N/A';

    try {
      var web3nodeInfo = new Web3(new Web3.providers.HttpProvider("http://" + hostName + ":8545"));
      peerCount = web3nodeInfo.net.peerCount;
      blockNumber = web3nodeInfo.eth.blockNumber;

    }
    catch(err) {
      console.log(err);
      peerCount = "Not running";
      blockNumber = "Not running";
    }

    var nodeInfo = {hostname: hostName, peercount: peerCount, blocknumber: blockNumber, consortiumid: consortiumId};
    nodeInfoArray.push(nodeInfo);
  });
}


function getNodesInfo() {
  nodeInfoArray = [];

  for(var i = 0; i < numTXNodes; i++) {
    getNodeInfo(txNodePrefix.concat(i));
  }

  for(var i = 0; i < numMNNodes; i++) {
    getNodeInfo(mnNodePrefix.concat(i));
  }

  // Sort the final result by consortium ID
  nodeInfoArray;
}

setInterval(getNodesInfo, 30000);

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
    var sortedNodeArray = nodeInfoArray.sort(function(a,b) {
      var aIsTx = a.consortiumid === 'N/A';
      var bIsTx = b.consortiumid === 'N/A';

      if (aIsTx && bIsTx)
        return 0;
      if (aIsTx)
        return -1;
      if (bIsTx)
        return 1;
      return a.consortiumid - b.consortiumid
    });
    var data = { isSent: req.session.isSent, error: req.session.error, hasNodeRows: hasNodeRows, nodeRows: sortedNodeArray, minedABlock: minedABlock() };
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

  if(web3.isAddress(address)) {
    web3.personal.unlockAccount(coinbase, coinbasePw, function(err, res) {
      console.log(res);
      web3.eth.sendTransaction({from: coinbase, to: address, value: web3.toWei(1000, 'ether')}, function(err, res){ console.log(address)});
    });

    req.session.isSent = true;
  } else {
    req.session.error = "Not a valid Ethereum address";
  }

  res.redirect('/');
});

app.listen(3000, function () {
  console.log('Admin webserver listening on port 3000!');
});
