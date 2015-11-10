#!/bin/bash

geth --genesis genesis.json --networkid 101010101  --rpc --rpccorsdomain "*" console
