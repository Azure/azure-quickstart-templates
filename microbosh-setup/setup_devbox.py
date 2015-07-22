import os
import re
import json
from subprocess import call
from Utils.WAAgentUtil import waagent
import Utils.HandlerUtil as Util


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
home_dir = "/home/{0}".format(username)

# Generate the private key and certificate
call("sh create_cert.sh", shell=True)
call("cp bosh.key ./bosh/bosh", shell=True)
with open ('bosh_cert.pem', 'r') as tmpfile:
    ssh_cert = tmpfile.read()
ssh_cert = "|\n" + ssh_cert
ssh_cert="\n        ".join([line for line in ssh_cert.split('\n')])

# Render the yml template for bosh-init
bosh_template = 'bosh.yml'
if os.path.exists(bosh_template):
    with open (bosh_template, 'r') as tmpfile:
        contents = tmpfile.read()
    for k in ["RESOURCE-GROUP-NAME", "STORAGE-ACCESS-KEY", "STORAGE-ACCOUNT-NAME", "SUBNET-NAME", "SUBNET-NAME-FOR-CF", "SUBSCRIPTION-ID", "VNET-NAME"]:
        v = settings[k]
        contents = re.compile(re.escape(k)).sub(v, contents)
    contents = re.compile(re.escape("SSH-CERTIFICATE")).sub(ssh_cert, contents)
    with open (os.path.join('bosh', bosh_template), 'w') as tmpfile:
        tmpfile.write(contents)

# Copy all the files in ./bosh into the home directory
call("cp -r ./bosh/* {0}".format(home_dir), shell=True)
call("chown -R {0} {1}".format(username, home_dir), shell=True)
call("chmod 400 {0}/bosh".format(home_dir), shell=True)

# Install bosh_cli and bosh-init
#call("rm -r /tmp; mkdir /mnt/tmp; ln -s /mnt/tmp /tmp; chmod 777 /mnt/tmp; chmod 777 /tmp", shell=True)
call("mkdir /mnt/bosh_install; cp init.sh /mnt/bosh_install; cd /mnt/bosh_install; sh init.sh >{0}/install.log 2>&1;".format(home_dir), shell=True)

# Setup the devbox as a DNS
enable_dns = settings["enable-dns"]
if enable_dns:
    import urllib2
    cf_ip = settings["cf-ip"]
    dns_ip = re.search('\d+\.\d+\.\d+\.\d+', urllib2.urlopen("http://www.whereismyip.com").read()).group(0)
    call("python setup_dns.py -d cf.azurelovecf.com -i 10.0.16.4 -e {0} -n {1} >/dev/null 2>&1".format(cf_ip, dns_ip), shell=True)
    # Update motd
    call("cp -f 98-msft-love-cf /etc/update-motd.d/", shell=True)
    call("chmod 755 /etc/update-motd.d/98-msft-love-cf", shell=True)
    call("shutdown -r 1 &", shell=True)
