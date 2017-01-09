#!/usr/bin/env python

import sys
import yaml
import json
from pg import DB

bosh_manifest_path = sys.argv[1]
with open(bosh_manifest_path, 'r') as f:
    bosh_manifest = yaml.load(f.read())

settings_path = sys.argv[2]
with open(settings_path, 'r') as f:
    cf_ip = json.loads(f.read())['cf-ip']

postgres_properties = bosh_manifest['jobs'][0]['properties']['postgres']
dbname = postgres_properties.get('database')
host = postgres_properties.get('host')
port = postgres_properties.get('port', 5432)
user = postgres_properties.get('user')
passwd = postgres_properties.get('password')

db = DB(dbname=dbname, host=host, port=port, user=user, passwd=passwd)

domain_id = db.insert('domains', name='xip.io', type='NATIVE')['id']
db.insert('records', domain_id=domain_id, name='{0}.xip.io'.format(cf_ip), content='localhost foo@bar.com 1', type='SOA', ttl=86400, prio=None)
db.insert('records', domain_id=domain_id, name='{0}.xip.io'.format(cf_ip), content='dns-us1.powerdns.net', type='NS', ttl=86400, prio=None)
db.insert('records', domain_id=domain_id, name='*.{0}.xip.io'.format(cf_ip), content=cf_ip, type='A', ttl=120, prio=None)

db.close()
