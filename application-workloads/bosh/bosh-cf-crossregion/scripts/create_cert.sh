#!/usr/bin/env bash

set -e

key=$1
cert=$2

openssl genrsa -out $key 2048 >/dev/null 2>&1
openssl req -new -x509 -days 365 -key $key -out $cert >/dev/null 2>&1 << EndOfMessage
AU
ZJU
ZHCN
Linux
Soft
SShKey
test@abc.com
EndOfMessage
