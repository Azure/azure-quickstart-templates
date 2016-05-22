#!/bin/bash

PARITY_DEB_URL=https://vanity-service.ethcore.io/github-data/latest-parity-deb
PASSWORD=$1
AZUREUSER=$2
export HOME="/root"

echo "home: $HOME"
echo "user: $(whoami)"

echo "Installing parity"

sudo apt-get update -qq
sudo apt-get install -y -qq curl expect expect-dev

##################
# install parity #
##################
file=/tmp/parity.deb
curl -Lk $PARITY_DEB_URL > $file
sudo dpkg -i $file
rm $file


#####################
# create an account #
#####################
echo $PASSWORD > $HOME/.parity-pass

expect_out= expect -c "
spawn sudo parity account new
puts $HOME
expect \"Type password: \"
send ${PASSWORD}\n
expect \"Repeat password: \"
send ${PASSWORD}\n
interact
"

echo $expect_out

address=0x$(parity account list | awk 'END{print}' | tr -cd '[[:alnum:]]._-')

echo "address: $address"

cat > $HOME/chain.json <<EOL
{
  "name": "Private",
  "engine": {
    "BasicAuthority": {
      "params": {
        "gasLimitBoundDivisor": "0x0400",
        "durationLimit": "0x0d",
        "authorities" : ["${address}"]
      }
    }
  },
  "params": {
    "accountStartNonce": "0x00",
    "maximumExtraDataSize": "0x20",
    "minGasLimit": "0x1388",
    "networkID" : "0xad"
  },
  "genesis": {
    "seal": {
      "generic": {
        "fields": 1,
        "rlp": "0x11bbe8db4e347b4e8c937c1c8370e4b5ed33adb3db69cbdb7a38e1e50b1b82fa"
      }
    },
    "difficulty": "0x20000",
    "author": "0x0000000000000000000000000000000000000000",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "0x",
    "gasLimit": "0x2fefd8"
  },
  "nodes": [
  ],
  "accounts": {
    "0000000000000000000000000000000000000001": { "balance": "1", "nonce": "1048576", "builtin": { "name": "ecrecover", "pricing": { "linear": { "base": 3000, "word": 0 } } } },
    "0000000000000000000000000000000000000002": { "balance": "1", "nonce": "1048576", "builtin": { "name": "sha256", "pricing": { "linear": { "base": 60, "word": 12 } } } },
    "0000000000000000000000000000000000000003": { "balance": "1", "nonce": "1048576", "builtin": { "name": "ripemd160", "pricing": { "linear": { "base": 600, "word": 120 } } } },
    "0000000000000000000000000000000000000004": { "balance": "1", "nonce": "1048576", "builtin": { "name": "identity", "pricing": { "linear": { "base": 15, "word": 3 } } } },
    "${address}": {
      "balance": "1606938044258990275541962092341162602522202993782792835301376"
    }
  }
}
EOL

command="parity --chain $HOME/chain.json --author ${address} --unlock ${address} --password $HOME/.parity-pass --rpccorsdomain * --jsonrpc-interface all"

printf "%s\n%s" "#!/bin/sh" "$command" | sudo tee /etc/init.d/parity

sudo chmod +x /etc/init.d/parity
sudo update-rc.d parity defaults

nohup $command & exit 0

