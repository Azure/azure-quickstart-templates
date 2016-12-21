#!/usr/bin/env python
import os
import urllib2
import apt
import tarfile
import sys
import json

from distutils import dir_util
from os import chdir
from os import symlink
from subprocess import call

def get_settings():
    import Utils.HandlerUtil as Util
    from Utils.WAAgentUtil import waagent
    waagent.LoggerInit('/var/log/waagent.log', '/dev/null')
    hutil = Util.HandlerUtility(
        waagent.Log,
        waagent.Error,
        "bosh-deploy-script")
    hutil.do_parse_context("enable")

    return hutil.get_public_settings()

def get_token_from_client_credentials(endpoint, client_id, client_secret):
    from urllib2 import Request
    from urllib2 import urlopen
    from urllib import urlencode
    payload = {
        'grant_type': 'client_credentials',
        'client_id': client_id,
        'client_secret': client_secret,
        'resource': 'https://management.core.windows.net/',
    }
    request = Request(endpoint)
    request.data = urlencode(payload)
    result = urlopen(request)
    return json.loads(result.read())['access_token']

def check_quota(subscription_id,tenant,client_id,secret,location,numofcores):

    from azure.mgmt.common import SubscriptionCloudCredentials
    endpoint = "https://login.microsoftonline.com/{0}/oauth2/token".format(tenant)
    token = get_token_from_client_credentials(endpoint,client_id,secret)
    creds = SubscriptionCloudCredentials(subscription_id, token)

    from azure.mgmt.compute import ComputeManagementClient

    compute_client = ComputeManagementClient(creds)

    usage_paged=compute_client.usage.list(location).usages
    core_usage=[usage for usage in usage_paged if usage.name.value == 'cores' ]
    available_cores=core_usage[0].limit-core_usage[0].current_value

    print "Current Cores %d Current Limit %d Available Cores %d Requested Cores %d" %(core_usage[0].current_value,core_usage[0].limit,available_cores,numofcores)

    print "###QUOTACHECK###"
    if numofcores > available_cores:
        print "CRITICAL Insufficient Quota, PCF will NOT deploy"
        sys.exit(0)
    else:
        print "Subscription Has Enough Quota"

# install packages
package_list = [
    "python-pip",
    "build-essential",
    "tmux",
    "ruby2.0",
    "ruby2.0-dev",
    "libxml2-dev",
    "libsqlite3-dev",
    "libxslt1-dev",
    "libpq-dev",
    "libmysqlclient-dev",
    "zlibc",
    "zlib1g-dev",
    "openssl",
    "libxslt1-dev",
    "libssl-dev",
    "libreadline6",
    "libreadline6-dev",
    "libyaml-dev",
    "sqlite3",
    "libffi-dev",
    "nodejs",
    "nodejs-legacy",
    "npm"]

print "Updating apt cache"

os.environ['DEBIAN_FRONTEND']='noninteractive'

cache = apt.cache.Cache()
cache.update(raise_on_error=False)
cache.open(None)

for package in package_list:
    pkg = cache[package]

    if not pkg.is_installed:
        pkg.mark_install(auto_inst=True)

try:
    cache.commit()
except Exception as arg:
    print >> sys.stderr, "Sorry, package installation failed [{err}]".format(
        err=str(arg))

import pip

pip_packages = ['jinja2', 'azure', 'azure-mgmt', 'click']
for package in pip_packages:
    pip.main(['install', package])

call("npm install -g sql-cli", shell=True)
call("curl https://s3.amazonaws.com/go-cli/releases/v6.21.1/cf-cli_6.21.1_linux_x86-64.tgz | tar xvz", shell=True)

release_url = 'https://s3-us-west-2.amazonaws.com/test-epsilon/gamma-release.tgz'
res = urllib2.urlopen(release_url)

code = res.getcode()
length = int(res.headers["Content-Length"])

# content-length
if code is 200:

    CHUNK = 16 * 1024
    filename = '/tmp/archive.tgz'

    with open(filename, 'wb') as temp:
        while True:
            chunk = res.read(CHUNK)

            if not chunk:
                break
            temp.write(chunk)

        print "Download complete."

    tfile = tarfile.open(filename, 'r:gz')
    tfile.extractall(".")

dir_util.copy_tree(".", "../..")
symlink('/usr/local/lib/python2.7/dist-packages/azure/mgmt', '../../azure/mgmt')

chdir("../..")

sys.path.append('')
print "Current working dir : %s" % os.getcwd()
print "Sys.Path: %s" % sys.path

# read values from settings and check quota
settings = get_settings()

subscription_id = settings['SUBSCRIPTION-ID']
tenant = settings['TENANT-ID']
client_id = settings['CLIENT-ID']
client_secret = settings['CLIENT-SECRET']
location = settings['location']
numofcores = 65

check_quota(subscription_id, tenant, client_id, client_secret, location, numofcores)

index_file = "index-{0}.yml".format(sys.argv[1].lower())
gamma_cmd = "./gamma.py --index {0}".format(index_file)

# start tmux, running deploy_bosh_and_releases
call("tmux new -d -s shared '{0}'".format(gamma_cmd), shell=True)
call("./gotty -c gamma:{0} -t --tls-crt '.gotty.crt' --tls-key '.gotty.key' -p '443' tmux attach -d -t shared &".format(sys.argv[2]), shell=True)
