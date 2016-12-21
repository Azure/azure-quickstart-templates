import bosh_client
import os
import yaml
from urllib2 import Request
from urllib2 import urlopen
from urllib import urlencode
import json
from jinja2 import Template
from hashlib import sha256


from subprocess import call
from azure.mgmt.common import SubscriptionCloudCredentials
from azure.mgmt.resource import ResourceManagementClient


MANIFEST_YAML = """
---
applications:
- name: meta-azure-service-broker
  buildpack: https://github.com/cloudfoundry/nodejs-buildpack
  instances: 1
  env:
    environment: {{environment}}
    subscription_id: {{subscription_id}}
    tenant_id: {{tenant_id}}
    client_id: {{client_id}}
    client_secret: {{client_secret}}
    docDb_hostEndPoint: {{docdb_hostendpoint}}
    docDb_masterKey: {{docdb_masterkey}}
"""

DEFAULT_JSON = """
{
  \"apiVersion\": \"2.8.0\",
  \"authUser\": \"{{service_broker_auth_user}}\",
  \"authPassword\": \"{{service_broker_auth_password}}\",
  \"name\": \"Meta Azure Service Broker\",
  \"port\": 5001,
  \"database\": {
    \"server\": \"{{service_broker_sql_server}}\",
    \"user\": \"{{service_broker_sql_user}}\",
    \"password\": \"{{service_broker_sql_password}}\",
    \"database\": \"{{service_broker_sql_database_name}}\"
  }
}
"""
def password(key, sshpubkey, short=False):
    password = sha256("{0}:{1}".format(sshpubkey, key)).hexdigest()
    if short:
        return password[:20]
    else:
        return password


def get_token_from_client_credentials(endpoint, client_id, client_secret):
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


def do_step(context):
    settings = context.meta['settings']
    username = settings["username"]
    home_dir = os.path.join("/home", username)

    f = open("{0}/manifests/elastic-runtime.yml".format(home_dir))
    manifest = yaml.safe_load(f)
    f.close()

    api_endpoint = "https://api.{0}".format(manifest['system_domain'])
    metabroker_name = "meta-azure-service-broker"
    metabroker_url = "https://{0}.{1}".format(metabroker_name, manifest['apps_domain'])
    cf_admin_password = manifest['properties']['admin_password']
    cf_user = "admin"

    sshpubkey = settings['adminSSHKey']
    sqlservernameFQDN = settings["sqlServerFQDN"]
    sqlservername = settings["sqlServerName"]
    sqlusername = settings["sqlServerAdminLogin"]
    sqlpassword = settings["sqlServerAdminPassword"]
    docdb_hostendpoint = settings["documentdb-endpoint"]
    docdb_masterkey = settings["documentdb-masterkey"]
    metabroker_user = "metabrokeradmin"
    metabroker_environment = settings["metabrokerenvironment"]

    call("/usr/local/bin/mssql --server {0} --database azuremetabroker --user {1}@{2} --pass {3} --encrypt -q '.read ./meta-azure-service-broker/scripts/schema.sql'".format(sqlservernameFQDN, sqlusername, sqlservername, sqlpassword), shell=True)

    subscription_id = settings['SUBSCRIPTION-ID']
    tenant = settings['TENANT-ID']
    endpoint = "https://login.microsoftonline.com/{0}/oauth2/token".format(tenant)
    client_token = settings['CLIENT-ID']
    client_secret = settings['CLIENT-SECRET']

    token = get_token_from_client_credentials(endpoint, client_token, client_secret)
    creds = SubscriptionCloudCredentials(subscription_id, token)

    metabroker_password = password(sqlpassword, sshpubkey, True)

    resource_client = ResourceManagementClient(creds)
    resource_client.providers.register('Microsoft.DocumentDB')
    resource_client.providers.register('Microsoft.ServiceBus')
    resource_client.providers.register('Microsoft.Sql')
    resource_client.providers.register('Microsoft.Storage')
    resource_client.providers.register('Microsoft.Cache')

    template_context = {
        'service_broker_auth_user': metabroker_user,
        'service_broker_auth_password': metabroker_password,
        'service_broker_sql_server': sqlservernameFQDN,
        'service_broker_sql_user': sqlusername,
        'service_broker_sql_password': sqlpassword,
        'service_broker_sql_database_name': 'azuremetabroker',
        'environment': metabroker_environment,
        'subscription_id': subscription_id,
        'tenant_id': tenant,
        'client_id': client_token,
        'client_secret': client_secret,
        'docdb_hostendpoint': docdb_hostendpoint,
        'docdb_masterkey': docdb_masterkey
    }

    default_config = Template(DEFAULT_JSON).render(template_context)
    manifest = Template(MANIFEST_YAML).render(template_context)

    with open('meta-azure-service-broker/config/default.json', 'w') as f:
        f.write(default_config)

    with open('meta-azure-service-broker/manifest.yml', 'w') as f:
        f.write(manifest)

    call ("./cf login --skip-ssl-validation -a {0} -u {1}  -p {2}".format(api_endpoint, cf_user, cf_admin_password), shell=True)
    call ("./cf create-space development", shell=True)
    call ("./cf target -o system -s development" , shell=True)
    call ("./cf push -p ./meta-azure-service-broker -f ./meta-azure-service-broker/manifest.yml", shell=True)
    call ("./cf create-service-broker demo-service-broker {0} {1} {2}".format(metabroker_user, metabroker_password, metabroker_url), shell=True)
    call ("./cf enable-service-access azure-storageblob", shell=True)
    call ("./cf enable-service-access azure-rediscache", shell=True)
    call ("./cf enable-service-access azure-documentdb", shell=True)
    call ("./cf enable-service-access azure-servicebus", shell=True)
    call ("./cf enable-service-access azure-sqldb", shell=True)
    return context
