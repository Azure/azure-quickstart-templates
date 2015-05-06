from Utils.WAAgentUtil import waagent
import Utils.HandlerUtil as Util
import commands
import os
import re
import json
waagent.LoggerInit('/var/log/waagent.log','/dev/stdout')
hutil =  Util.HandlerUtility(waagent.Log, waagent.Error, "bosh-deploy-script")
hutil.do_parse_context("enable")
settings= hutil.get_public_settings()

from subprocess import call
call("mkdir -p ./bosh",shell=True)
call("mkdir -p ./bosh/.ssh",shell=True)

if "some_id" in settings:
    id = settings["some_id"]
    resourcegroup = id.split("/")[4]
    settings["resourcegroup"]=resourcegroup

for f in ['micro_bosh.yml','update_os.sh','deploy_micro_bosh.sh','install_bosh_client.sh']:
    with open (f,"r") as tmpfile:
        content = tmpfile.read()
    for i  in settings.keys():
        if i == 'fileUris':
           continue
        content=re.compile(re.escape("#"+i+"#"), re.IGNORECASE).sub(settings[i],content)
    with open (os.path.join('bosh',f),"w") as tmpfile:
        tmpfile.write(content)

with open (os.path.join('bosh','settings'),"w") as tmpfile:
    tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))

if not os.path.exists('/bosh_os.tar') and settings['stemcell'].find('bosh_os.tar')>0:
    call("sh update_os.sh",shell=True)
    exit(0)

call("sh create_cert.sh >> ./bosh/micro_bosh.yml",shell=True)
call("chmod 700 myPrivateKey.key",shell=True)
call("cp myPrivateKey.key ./bosh/.ssh/bosh.key",shell=True)
call("cp -r ./bosh /home/"+settings['username'],shell=True)
call("chown -R "+settings['username']+" "+"/home/"+settings['username'],shell=True)

call("sudo apt-get install -y nodejs-legacy npm",shell=True)
call("sudo npm install azure-cli optimist azure-mgmt-resource retry async azure-common -g",shell=True)  

call(["echo","-H","-u",settings['username'],"bash","-c","azure config mode asm"])
call( ["sudo","-H","-u",settings['username'],"bash","-c","azure storage container create --container stemcell -a "+settings['storageaccount']+" -k "+settings['storagekey']])
call( ["sudo","-H","-u",settings['username'],"bash","-c","azure storage blob copy start  --dest-account-name "+settings['storageaccount']+"  --dest-container stemcell --dest-blob stemcell.vhd --source-uri '"+settings['stemcell']+"' --dest-account-key '"+settings['storagekey']+"' --quiet"])

call("rm -r /tmp; mkdir /mnt/tmp; ln -s /mnt/tmp /tmp; chmod 777 /mnt/tmp ;chmod 777 /tmp", shell=True)
if not os.path.exists('/bosh_os.tar'):
    call("mkdir /mnt/bosh_install; cp install_bosh_client.sh /mnt/bosh_install; cd /mnt/bosh_install ; sh install_bosh_client.sh;",shell=True)
exit(0)
