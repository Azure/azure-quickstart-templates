#!/usr/bin/env python
import os
import re
import json
import traceback
from subprocess import call
from Utils.WAAgentUtil import waagent
import Utils.HandlerUtil as Util
from azure.storage import BlobService
from azure.storage import TableService

call("mkdir -p ./bosh", shell=True)
call("chmod +x deploy_bosh.sh", shell=True)
call("cp deploy_bosh.sh ./bosh/", shell=True)

# Get settings from CustomScriptForLinux extension configurations
waagent.LoggerInit('/var/log/waagent.log', '/dev/stdout')
hutil =  Util.HandlerUtility(waagent.Log, waagent.Error, "bosh-deploy-script")
hutil.do_parse_context("enable")
settings = hutil.get_public_settings()
with open (os.path.join('bosh','settings'), "w") as tmpfile:
    tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))
username = settings["username"]
home_dir = os.path.join("/home", username)
install_log = os.path.join(home_dir, "install.log")

# Prepare the containers
storage_account_name = settings["STORAGE-ACCOUNT-NAME"]
storage_access_key = settings["STORAGE-ACCESS-KEY"]
blob_service = BlobService(storage_account_name, storage_access_key)
blob_service.create_container('bosh')
blob_service.create_container('stemcell')

# Generate the private key and certificate
call("sh create_cert.sh", shell=True)
call("cp bosh.key ./bosh/bosh", shell=True)
with open ('bosh_cert.pem', 'r') as tmpfile:
    ssh_cert = tmpfile.read()
indentation = " " * 8
ssh_cert=("\n"+indentation).join([line for line in ssh_cert.split('\n')])

# Render the yml template for bosh-init
bosh_template = 'bosh.yml'
if os.path.exists(bosh_template):
    with open (bosh_template, 'r') as tmpfile:
        contents = tmpfile.read()
    for k in ["RESOURCE-GROUP-NAME", "STORAGE-ACCESS-KEY", "STORAGE-ACCOUNT-NAME", "SUBNET-NAME", "SUBSCRIPTION-ID", "VNET-NAME", "TENANT-ID", "CLIENT-ID", "CLIENT-SECRET"]:
        v = settings[k]
        contents = re.compile(re.escape(k)).sub(v, contents)
    contents = re.compile(re.escape("SSH-CERTIFICATE")).sub(ssh_cert, contents)
    with open (os.path.join('bosh', bosh_template), 'w') as tmpfile:
        tmpfile.write(contents)

# Install bosh_cli and bosh-init
#call("rm -r /tmp; mkdir /mnt/tmp; ln -s /mnt/tmp /tmp; chmod 777 /mnt/tmp; chmod 777 /tmp", shell=True)
call("mkdir /mnt/bosh_install; cp init.sh /mnt/bosh_install; cd /mnt/bosh_install; chmod +x init.sh; ./init.sh >{0} 2>&1;".format(install_log), shell=True)

# Render the yml template for concourse
concourse_template = 'concourse.yml'
if os.path.exists(concourse_template):
    with open (concourse_template, 'r') as tmpfile:
        contents = tmpfile.read()
    for k in ["SUBNET-NAME-FOR-CONCOURSE", "VNET-NAME", "CONCOURSE-IP"]:
        v = settings[k]
        contents = re.compile(re.escape(k)).sub(v, contents)
    with open (os.path.join('bosh', concourse_template), 'w') as tmpfile:
        tmpfile.write(contents)

# Copy all the files in ./bosh into the home directory
call("cp -r ./bosh/* {0}".format(home_dir), shell=True)
call("chown -R {0} {1}".format(username, home_dir), shell=True)
call("chmod 400 {0}/bosh".format(home_dir), shell=True)
