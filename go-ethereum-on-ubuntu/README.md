# Geth Private Node

This Microsoft Azure template deploys a single Ethereum client with a private chain for development and testing.

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fgo-ethereum-on-ubuntu%2Fazuredeploy.json)
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fgo-ethereum-on-ubuntu%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

Once your deployment is complete you will have a sandbox environment with:

1. A Genesis file loading the provided private key with funds to test on the network

2. A private key** to import on into your ethereum node

3. A script to activate your private blockchain and begin interacting with the Ethereum protocol.

** Note this private key is exposed on a public GitHub repository. It should _never_ be used on a public network. If you use this key for anything besides sandbox testing purposes, your funds will be lost!


![Ethereum-Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/go-ethereum-on-ubuntu/images/eth.jpg)

# Template Parameters
When you launch the installation of the cluster, you need to specify the following parameters:
* `newStorageAccountNamePrefix`: make sure this is a unique identifier. Azure Storage's accounts are global so make sure you use a prefix that is unique to your account otherwise there is a good change it will clash with names already in use.
* `vmDnsPrefix`: this is the public DNS name for the VM that you will use interact with your geth console. You just need to specify an unique name.
* `adminUsername`: self-explanatory. This is the account you will use for connecting to the node
* `adminPassword`: self-explanatory. Be aware that Azure requires passwords to have One upper case, one lower case, a special character, and a number
* `vmSize`: The type of VM that you want to use for the node. The default size is D1 (1 core 3.5GB RAM) but you can change that if you expect to run workloads that require more RAM or CPU resources.
* `location`: The region where the VM should be deployed to

# Go Ethereum Private Node Walkthrough
1. Get your node's IP
 1. browse to https://portal.azure.com

 2. then click browse all, followed by "resource groups", and choose your resource group

 3. then expand your resources, and public ip address of your node.

2. Connect to your geth node
 1. SSH to the public ip of your node as the user you specified for `adminUsername`
 2. Enter your `adminPassword`

3. Import the private key
 1. By running the `ls` command you should see three files: `genesis.json`, `GuestBook.sol`, `priv_genesis.key` and `start-private-blockchain.sh`.
 2. Import the private key into geth by running the command `geth account import priv_genesis.key`
 3. Accept the legal disclaimer
 4. Enter a password to secure the key within geth (remember this! we'll use it later)

4. Initiate the private blockchain
 1. Run the command `sh start-private-blockchain.sh` to create your genesis block for your private Ethereum blockchain
 2. You are now in the go-ethereum command line console. You can verify that your private blockchain was successfully created by checking the balance via the console: `eth.getBalance('7fbe93bc104ac4bcae5d643fd3747e1866f1ece4')`
 3. You are now able to deploy a smart contract to the Ethereum network. Kill the current process (`ctrl+d`) - we'll get back to the console shortly

# Deploying your first contract

Welcome to the Ethereum ecosystem. You are now on your journey to becoming a decentralized application developer.

Earlier when you ran the `ls` command there was a file named `GuestBook.sol` - this is a very simple guest book contract written in the Solidity smart contract programming language.

[Learning Solidity](https://solidity.readthedocs.org) is beyond the scope of this walk through, but feel free to read the code and try to understand what the contract is trying to do.  

Getting familiar with Solidity contracts and deploying them to the network can be a bit of a learning curve - there are a number of different steps in the journey from source code to having a contract live on the public network; we'll try to address each of these steps.

## .sol - Solidity source
The file `GuestBook.sol` is an example of a smart contract's source code - written in the Solidity programming language. Solidity is one of the smart contract languages which compile down to the Ethereum Virtual Machine's byte code.

Decentralized application developers write contracts in Solidity (or its cousin languages Serpent & LLL) in order to realize the benefits of programming in higher level languages. However the .sol files are not what get loaded to the Ethereum network; instead we have to compile the code.

## Compiling from the console
Our next step is to take the `GuestBook.sol` and compile it in the geth console. To make our lives easier we can remove new lines from the file by running the command: `cat GuestBook.sol | tr '\n' ' '` and copying the output.

Next, lets start our node back up - `sh start-private-blockchain.sh`

The Geth console actually implmements a [JavaScript Runtime Environment](https://github.com/ethereum/go-ethereum/wiki/JavaScript-Console); so if you have familiarity with NodeJs this should be a comfortable environment. Let's set a variable containing our source code:

```
var guestBookSource = 'contract GuestBook {   mapping (address => string) entryLog;    function setEntry(string guestBookEntry) {     entryLog[msg.sender] = guestBookEntry;   }    function getMyEntry() constant returns (string) {     return entryLog[msg.sender];   } }'
```

And now we can proceed to compile this source code.

```
var guestBookCompiled = web3.eth.compile.solidity(guestBookSource);
```

The call to the solidity function returns us a JSON object which contains the EVM byte code (`guestBookCompiled.GuestBook.code`), as well as the ABI definition of the contract (`guestBookCompiled.GuestBook.info.abiDefinition
`).

Great - we have the source, and the compiled version of this source. Unfortunately for us, having these two things isn't exactly useful to us - we need to get the contract deployed to the network.

## Instantiating a contract
The next step is to use the web3 ethereum helpers to instantiate a contract object:

```
var contract = web3.eth.contract(guestBookCompiled['<stdin>:GuestBook'].info.abiDefinition);
```

This will give us an instantiated contract object containing the all important `new` function. `new` is what we'll use to actually deploy the contract to your Ethereum private network. Since we're in Javascript land, `new` takes a call back as its final parameter to notify us of successful or failed deployment; lets set up this call back first:

```
var callback = function(e, contract){
    if(!e) {
      if(!contract.address) {
        console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
      } else {
        console.log("Contract mined!");
        console.log(contract);
      }
    }
}
```

Next we'll need to define the contract initialization object which contains three key/value pairs:

   `from` - the address that is posting the contract

   `data` - the raw code from the contract

   `gas` - the initial gas that we're posting for the contract

Let's construct the initalizer:
```
var initializer =  {from:web3.eth.accounts[0], data: guestBookCompiled.GuestBook.code, gas: 300000}
```

## Deploying the Contract
We are now ready to deploy! Remember that `new` method? We can finally use it:

You will need to enter the password you entered when first importing the private key to unlock your account.

```
personal.unlockAccount(personal.listAccounts[0])
```

```
var guestBook = contract.new(initializer, callback);
```


Congratulations - you have a contract deployed to the Ethereum network!

...except for one little detail.

## Mining the contract
As it turns out, simply `send`ing the contract to the network isn't sufficient - there is a missing component: having the contract mined.

On the public network this would be solved for us simply by waiting approximately [15 seconds](https://stats.ethdev.com/) before the contract is added to the blockchain. However since this is our own private test network; there are no miners to speak of.

Interesting. How do we solve this problem? By turning on CPU mining locally:

```
web3.miner.start(1)
```

We'll have to wait a little bit while your node generates its Directed Acyclic Graph (DAG). This process is what helps the Ethereum network be resistant to ASIC mining; but that's a topic for another time.

Once the DAG is generated, our node will start mining. We'll see console messages like:

 :hammer:`Mined block`

And eventually our call back will fire:
`Contract mined!`

Congratulations - your contract is now alive on the Ethereum Network!

Go ahead and stop your miner for the moment:
```
web3.miner.stop()
```

## Reading from the contract
Our contract is now permanently stored on the blockchain - we can learn the contract's address by interrogating our  guestBook object: `guestBook.address`

The object returned will give us the address of the contract, as well as a hash of the contract and also all of the functions we defined in our original solidity source code.

We can read our guest book's entry via a call to `guestBook.getMyEntry()`

Giving it a try we get the response:
```
> guestBook.getMyEntry();
""
```

The empty string is expected - we haven't yet written an entry to the contract's storage. For this we will have to send a transaction to the contract and tell it to invoke the `setEntry` function.

## Writing to the contract
In our previous example we were able to call the `guestBook.getMyEntry()` function directly and receive a response synchronously from our local node. This is possible since read operations do not create a state change in the contract - no need to tell the network we are updating data.

However our next function all `guestBook.setEntry()` writes data to the contract's internal storage - here's the function declaration for a refresher:

```
...
mapping (address => string) entryLog;

function setEntry(string guestBookEntry) {
  entryLog[msg.sender] = guestBookEntry;
}
...
```

In order for us to write to the entryLog of the contract and have that update stored in the blockchain, we need to send a transaction to the contract address.

```
guestBook.setEntry.sendTransaction("Hello Azure!", {from: eth.accounts[0]});
```

Now if we read from the contract again we should see the following:
```
> guestBook.getMyEntry();
""
```

An empty string again - because we haven't yet mined this new transaction. We'll need to go back to mining blocks to get the transaction into the blockchain:

```
web3.miner.start()
```
:hammer:`Mined block`
```
web3.miner.stop()
```

Now if we read from the contract:
```
> guestBook.getMyEntry();
"Hello Azure"
```

Congratulations! Your first contract is alive and well on your private Ethereum blockchain.
