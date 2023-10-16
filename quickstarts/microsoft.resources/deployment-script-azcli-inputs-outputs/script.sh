#!/bin/bash
set -e

usage="Usage: ./script.sh <myBool> <myInt> <myString> <myArray> <myObject>"
myBool=${1:?"Missing myBool. ${usage}"}
myInt=${2:?"Missing myInt. ${usage}"}
myString=${3:?"Missing myString. ${usage}"}
myArray=${4:?"Missing myArray. ${usage}"}
myObject=${5:?"Missing myObject. ${usage}"}

echo "myBool: $myBool"
echo "myInt: $myInt"
echo "myString: $myString"
echo "myArray: $myArray"
echo "myObject: $myObject"

output=$(jq -n \
  --argjson myBool $myBool \
  --argjson myInt $myInt \
  --arg myString "$myString" \
  --argjson myArray "$myArray" \
  --argjson myObject "$myObject" \
  '$ARGS.named')

echo $output > $AZ_SCRIPTS_OUTPUT_PATH