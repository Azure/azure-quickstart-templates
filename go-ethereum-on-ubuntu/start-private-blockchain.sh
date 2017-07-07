#!/bin/bash

geth --maxpeers 0 --genesis genesis.json --networkid 101010101  --rpc --rpccorsdomain "*" console
