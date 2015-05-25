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

for f in ['micro_bosh.yml','deploy_micro_bosh.sh','micro_cf.yml']:
    if not os.path.exists(f):
        continue 
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

call("sh create_cert.sh >> ./bosh/micro_bosh.yml",shell=True)
call("chmod 700 myPrivateKey.key",shell=True)
call("chmod 744 ./bosh/deploy_micro_bosh.sh",shell=True)
call("cp myPrivateKey.key ./bosh/.ssh/bosh.key",shell=True)
call("cp -r ./bosh/* /home/"+settings['username'],shell=True)
call("chown -R "+settings['username']+" "+"/home/"+settings['username'],shell=True)


call("rm -r /tmp; mkdir /mnt/tmp; ln -s /mnt/tmp /tmp; chmod 777 /mnt/tmp ;chmod 777 /tmp", shell=True)
call("mkdir /mnt/bosh_install; cp install_bosh_client.sh /mnt/bosh_install; cd /mnt/bosh_install ; sh install_bosh_client.sh >install.log 2>&1;",shell=True)
exit(0)
