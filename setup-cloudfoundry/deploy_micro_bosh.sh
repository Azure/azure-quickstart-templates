#!/bin/sh
rm run.log >/dev/null 2>&1
rm -fr *.log>/dev/null 2>&1
rm ~/.bosh_config>/dev/null 2>&1
rm ~/.bosh_deployer_config>/dev/null 2>&1
rm bosh-deployments.yml>/dev/null 2>&1
bosh micro deployment micro_bosh.yml
bosh micro deploy $1 