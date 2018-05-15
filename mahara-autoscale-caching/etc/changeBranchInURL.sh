#!/bin/bash

from=$1
to=$2

sed -i s/%2F${from}%2F/%2F${to}%2F/g README.md
sed -i s#/${from}/#/${to}/#g azuredeploy.json
