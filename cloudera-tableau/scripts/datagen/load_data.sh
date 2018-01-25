#!/bin/sh

set -x

SCALE=${1:-2}

echo "Converting data to Parquet"
impala-shell -i localhost -f ddl/bin_flat/parquettables.sql

