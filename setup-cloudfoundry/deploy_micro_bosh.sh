#!/bin/sh
azure config mode asm 
azure storage blob copy  show -a "#storageaccount#" -k "#storagekey#" --blob stemcell.vhd --container stemcell
echo "IF status is pending , please wait"
rm run.log >/dev/null 2>&1
rm -fr *.log>/dev/null 2>&1
rm ~/.bosh_config>/dev/null 2>&1
rm ~/.bosh_deployer_config>/dev/null 2>&1
rm bosh-deployments.yml>/dev/null 2>&1
bosh micro deployment micro_bosh.yml
bosh micro deploy stemcell