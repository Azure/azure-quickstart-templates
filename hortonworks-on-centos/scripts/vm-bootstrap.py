#
# vm-bootstrap.py
#
# This script is used to prepare VMs launched via HDP Cluster Install Blade on Azure.
#
# Parameters passed from the bootstrap script invocation by the controller (shown in the parameter order).
# Required parameters:
#   action: "bootstrap" to set up VM and initiate cluster deployment.  "check" for checking on cluster deployment status.
#   cluster_id: user-specified name of the cluster
#   admin_password: password for the Ambari "admin" user
# Required parameters for "bootstrap" action:
#   scenario_id: "evaluation" or "standard"
#   num_masters: number of masters in the cluster
#   num_workers: number of workers in the cluster
#   master_prefix: hostname prefix for master hosts (master hosts are named <cluster_id>-<master_prefix>-<id>
#   worker_prefix: hostname prefix for worker hosts (worker hosts are named <cluster_id>-<worker_prefix>-<id>
#   domain_name: the domain name part of the hosts, starting with a period (e.g., .cloudapp.net)
#   id_padding: number of digits for the host <id> (e.g., 2 uses <id> like 01, 02, .., 10, 11)
#   masters_iplist: list of masters' local IPV4 addresses sorted from master_01 to master_XX delimited by a ','
#   workers_iplist: list of workers' local IPV4 addresses sorted from worker_01 to worker_XX delimited by a ','
# Required parameters for "check" action:
#   --check_timeout_seconds:
#     the number of seconds after which the script is required to exit
#   --report_timeout_fail:
#     if "true", exit code 1 is returned in case deployment has failed, or deployment has not finished after
#     check_timeout_seconds
#     if "false", exit code 0 is returned if deployment has finished successfully, or deployment has not finished after
#     check_timeout_seconds
# Optional:
#   protocol: if "https" (default), https:8443 is used for Ambari.  Otherwise, Ambari uses http:8080

from optparse import OptionParser
import base64
import json
import logging
import os
import pprint
import re
import socket
import sys
import time
import urllib2

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
handler = logging.FileHandler('/tmp/vm-bootstrap.log')
handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

logger.info('Starting VM Bootstrap...')

parser = OptionParser()
parser.add_option("--cluster_id", type="string", dest="cluster_id")
parser.add_option("--scenario_id", type="string", dest="scenario_id", default="evaluation")
parser.add_option("--num_masters", type="int", dest="num_masters")
parser.add_option("--num_workers", type="int", dest="num_workers")
parser.add_option("--master_prefix", type="string", dest="master_prefix")
parser.add_option("--worker_prefix", type="string", dest="worker_prefix")
parser.add_option("--domain_name", type="string", dest="domain_name")
parser.add_option("--id_padding", type="int", dest="id_padding", default=2)
parser.add_option("--admin_password", type="string", dest="admin_password", default="admin")
parser.add_option("--masters_iplist", type="string", dest="masters_iplist")
parser.add_option("--workers_iplist", type="string", dest="workers_iplist")
parser.add_option("--protocol", type="string", dest="protocol", default="https")
parser.add_option("--action", type="string", dest="action", default="bootstrap")
parser.add_option("--check_timeout_seconds", type="int", dest="check_timeout_seconds", default="250")
parser.add_option("--report_timeout_fail", type="string", dest="report_timeout_fail", default="false")

(options, args) = parser.parse_args()

cluster_id = options.cluster_id
scenario_id = options.scenario_id.lower()
num_masters = options.num_masters
num_workers = options.num_workers
master_prefix = options.master_prefix
worker_prefix = options.worker_prefix
domain_name = options.domain_name
id_padding = options.id_padding
admin_password = options.admin_password
masters_iplist = options.masters_iplist
workers_iplist = options.workers_iplist
protocol = options.protocol
action = options.action
check_timeout_seconds = options.check_timeout_seconds
report_timeout_fail = options.report_timeout_fail.lower() == "true"

logger.info('action=' + action)

admin_username = 'admin'
current_admin_password = 'admin'
request_timeout = 30

port = '8443' if (protocol == 'https') else '8080'

http_handler = urllib2.HTTPHandler(debuglevel=1)
opener = urllib2.build_opener(http_handler)
urllib2.install_opener(opener)

class TimeoutException(Exception):
  pass

def get_ambari_auth_string():
  return 'Basic ' + base64.encodestring('%s:%s' % (admin_username, current_admin_password)).replace('\n', '')

def run_system_command(command):
  os.system(command)

def get_hostname(id):
  if id <= num_masters:
    return master_prefix + str(id).zfill(id_padding)
  else:
    return worker_prefix + str(id - num_masters).zfill(id_padding)

def get_fqdn(id):
  return get_hostname(id) + domain_name

def get_host_ip(hostname):
  if (hostname.startswith(master_prefix)):
    return masters_iplist[int(hostname.split('-')[-1]) -1]
  else:
    return workers_iplist[int(hostname.split('-')[-1]) -1]

def get_host_ip_map(hostnames):
  host_ip_map = {}
  for hostname in hostnames:
    num_tries = 0
    ip = None
    while ip is None and num_tries < 5:
      try:
        ip = get_host_ip(hostname)
        # ip = socket.gethostbyname(hostname)
      except:
        time.sleep(1)
        num_tries = num_tries + 1
        continue
    if ip is None:
      logger.info('Failed to look up ip address for ' + hostname)
      raise
    else:
      logger.info(hostname + ' resolved to ' + ip)
      host_ip_map[hostname] = ip
  return host_ip_map

def update_etc_hosts(host_ip_map):
  logger.info('Adding entries to /etc/hosts file...')
  with open("/etc/hosts", "a") as file:
    for host in sorted(host_ip_map):
      file.write('%s\t%s\t%s\n' % (host_ip_map[host], host + domain_name, host))
  logger.info('Finished updating /etc/hosts')

def update_ambari_agent_ini(ambari_server_hostname):
  logger.info('Updating ambari-agent.ini file...')
  command = 'sed -i s/hostname=localhost/hostname=%s/ /etc/ambari-agent/conf/ambari-agent.ini' % ambari_server_hostname
  logger.info('Executing command: ' + command)
  run_system_command(command)
  logger.info('Finished updating ambari-agent.ini file')

 
def patch_ambari_agent():
  logger.info('Patching ambari-agent to prevent rpmdb corruption...')
  logger.info('Finished patching ambari-server')

def enable_https():
  command = """
printf 'api.ssl=true\nclient.api.ssl.cert_name=https.crt\nclient.api.ssl.key_name=https.key\nclient.api.ssl.port=8443' >> /etc/ambari-server/conf/ambari.properties

mkdir /root/ambari-cert
cd /root/ambari-cert

# create server.crt and server.key (self-signed)

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -batch
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

echo PulUuMWPp0o4Lq6flGA0NGDKNRZQGffW2mWmJI3klSyspS7mUl > pass.txt
cp pass.txt passin.txt

# encrypts server.key with des3 as server.key.secured with the specified password
openssl rsa -in server.key -des3 -out server.key.secured -passout file:pass.txt

# creates /tmp/https.keystore.p12
openssl pkcs12 -export -in 'server.crt' -inkey 'server.key.secured' -certfile 'server.crt' -out '/var/lib/ambari-server/keys/https.keystore.p12' -password file:pass.txt -passin file:passin.txt

mv pass.txt /var/lib/ambari-server/keys/https.pass.txt
cd ..
rm -rf /root/ambari-cert
  """
  run_system_command(command)


def set_admin_password(new_password, timeout):
  logger.info('Setting admin password...')


def poll_until_all_agents_registered(num_hosts, timeout):
  url = '%s://localhost:%s/api/v1/hosts' % (protocol, port)
  logger.info('poll until all agents')
  all_hosts_registered = False
  start_time = time.time()
  while time.time() - start_time < timeout:
    request = urllib2.Request(url)
    request.add_header("Authorization", get_ambari_auth_string())
    try:
      result = urllib2.urlopen(request, timeout=request_timeout).read()
      pprint.pprint(result)
      if (result is not None):
        jsonResult = json.loads(result)
        if len(jsonResult['items']) >= num_hosts:
          all_hosts_registered = True
          break
    except :
	    logger.exception('Could not poll agent status from the server.')
    time.sleep(5)
  if not all_hosts_registered:
    raise Exception('Timed out while waiting for all agents to register')

def is_ambari_server_host():
  hostname = socket.getfqdn()
  hostname = hostname.split('.')[0]
  logger.info(hostname)
  logger.info('Checking ambari host')
  logger.info(ambari_server_hostname)
  return hostname == ambari_server_hostname

def create_blueprint(scenario_id):
  blueprint_name = 'myblueprint'
  logger.info('Creating blueprint for scenario %s' % scenario_id)
  url = '%s://localhost:%s/api/v1/blueprints/%s' % (protocol, port, blueprint_name)

  evaluation_host_groups = [
   {
     "name" : "master_1",
     "components" : [	   
       {
         "name" : "AMBARI_SERVER"
       },
       {
         "name" : "DRPC_SERVER"
       },
       {
         "name" : "HIVE_SERVER"
       },
       {
         "name" : "MYSQL_SERVER"
       },
       {
         "name" : "NIMBUS"
       },	 
	   {
         "name" : "SECONDARY_NAMENODE"
       },	 
	   {
         "name" : "SPARK_JOBHISTORYSERVER"
       },	 
	   {
         "name" : "STORM_UI_SERVER"
       },
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
            ],
     "cardinality" : "1"
   },
   {
     "name" : "master_2",
     "components" : [
       {
         "name" : "APP_TIMELINE_SERVER"
       },
       {
         "name" : "FALCON_SERVER"
       },
       {
         "name" : "HBASE_MASTER"
       },
       {
         "name" : "HISTORYSERVER"
       },
       {
         "name" : "HIVE_METASTORE"
       },
       {
         "name" : "KAFKA_BROKER"
       },
       {
         "name" : "METRICS_COLLECTOR"
       },
       {
         "name" : "NAMENODE"
       },
       {
         "name" : "OOZIE_SERVER"
       },
       {
         "name" : "RESOURCEMANAGER"
       },
       {
         "name" : "WEBHCAT_SERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
     ],
     "cardinality" : "1"
   },
   {
     "name" : "workers",
     "components" : [
       {
         "name" : "DATANODE"
       },
	   {
         "name" : "HBASE_REGIONSERVER"
       },
       {
         "name" : "NODEMANAGER"
       },
       {
         "name" : "SUPERVISOR"
       },	   	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
     ],
     "cardinality" : "3"
   }
  ]

  small_host_groups = [
    {
      "name" : "master_1",
      "components" : [
        {
          "name" : "AMBARI_SERVER"
        }, 
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_2",
      "components" : [        
        {
          "name" : "METRICS_COLLECTOR"
        },
	   {
          "name" : "NAMENODE"
        },		
        {
          "name" : "NIMBUS"
        },
		{
          "name" : "ZOOKEEPER_SERVER"
        },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_3",
      "components" : [
       {
         "name" : "DRPC_SERVER"
       },
	   {
         "name" : "FALCON_SERVER"
       },
       {
         "name" : "HBASE_MASTER"
       },
       {
         "name" : "HISTORYSERVER"
       },
       {
         "name" : "HIVE_METASTORE"
       },
       {
         "name" : "KAFKA_BROKER"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_SERVER"
       },
       {
         "name" : "RESOURCEMANAGER"
       },
       {
         "name" : "SECONDARY_NAMENODE"
       },
       {
         "name" : "WEBHCAT_SERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_4",
      "components" : [
       {
         "name" : "APP_TIMELINE_SERVER"
       },
       {
         "name" : "HIVE_SERVER"
       },
       {
         "name" : "MYSQL_SERVER"
       },
       {
         "name" : "SPARK_JOBHISTORYSERVER"
       },
       {
         "name" : "STORM_UI_SERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
     "name" : "workers",
     "components" : [
       {
         "name" : "DATANODE"
       },
	   {
         "name" : "HBASE_REGIONSERVER"
       },
       {
         "name" : "NODEMANAGER"
       },
       {
         "name" : "SUPERVISOR"
       },	   	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       {
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "9"
    }
  ]
    
  medium_host_groups = [
    {
      "name" : "master_1",
      "components" : [
        {
          "name" : "AMBARI_SERVER"
        },   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
        { 
          "name" : "METRICS_MONITOR"
        },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_2",
      "components" : [        
        {
          "name" : "DRPC_SERVER"
        },		
        {
          "name" : "METRICS_COLLECTOR"
        },
		{
          "name" : "NAMENODE"
        },		
		{
          "name" : "ZOOKEEPER_SERVER"
        },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
        { 
          "name" : "METRICS_MONITOR"
        },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_3",
      "components" : [
       {
         "name" : "HIVE_SERVER"
       }, 
       {
         "name" : "SUPERVISOR"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
        { 
          "name" : "METRICS_MONITOR"
        },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_4",
      "components" : [
       {
         "name" : "APP_TIMELINE_SERVER"
       },
       {
         "name" : "HIVE_SERVER"
       },
       {
         "name" : "MYSQL_SERVER"
       },
       {
         "name" : "SPARK_JOBHISTORYSERVER"
       },
       {
         "name" : "STORM_UI_SERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
        { 
          "name" : "METRICS_MONITOR"
        },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
     "name" : "workers",
     "components" : [
       {
         "name" : "DATANODE"
       },
	   {
         "name" : "HBASE_REGIONSERVER"
       },
       {
         "name" : "NODEMANAGER"
       },
       {
         "name" : "SUPERVISOR"
       },	   	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
        { 
          "name" : "METRICS_MONITOR"
        },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "99"
    }
  ]

  large_host_groups = [
    {
      "name" : "master_1",
      "components" : [
        {
          "name" : "AMBARI_SERVER"
        },
        {
         "name" : "KAFKA_BROKER"
        },
        { 
          "name" : "METRICS_COLLECTOR"
        },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },	
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_2",
      "components" : [        
       {
         "name" : "METRICS_COLLECTOR"
       },
	   {
          "name" : "NAMENODE"
        },		
        {
          "name" : "NIMBUS"
        },
		{
          "name" : "ZOOKEEPER_SERVER"
        },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_3",
      "components" : [
       {
         "name" : "DRPC_SERVER"
       },
	   {
         "name" : "FALCON_SERVER"
       },
       {
         "name" : "HBASE_MASTER"
       },
       {
         "name" : "HISTORYSERVER"
       },
       {
         "name" : "HIVE_METASTORE"
       },
       {
         "name" : "KAFKA_BROKER"
       },
       {
         "name" : "OOZIE_SERVER"
       },
       {
         "name" : "RESOURCEMANAGER"
       },
       {
         "name" : "SECONDARY_NAMENODE"
       },
       {
         "name" : "WEBHCAT_SERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_4",
      "components" : [
       {
         "name" : "HIVE_METASTORE"
       },
       {
         "name" : "MYSQL_SERVER"
       },
       {
         "name" : "SECONDARY_NAMENODE"
       },
       {
         "name" : "SPARK_JOBHISTORYSERVER"
       },
       {
         "name" : "ZOOKEEPER_SERVER"
       },	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_5",
      "components" : [
        {
          "name" : "NODEMANAGER"
        },
        {
         "name" : "OOZIE_SERVER"
        },
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_6",
      "components" : [        
        {
          "name" : "RESOURCEMANAGER"
        },		
        {
          "name" : "WEBHCAT_SERVER"
        }, 
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_7",
      "components" : [
       {
         "name" : "HBASE_MASTER"
       },
	   {
         "name" : "HISTORYSERVER"
       },   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
      "name" : "master_8",
      "components" : [
       {
         "name" : "APP_TIMELINE_SERVER"
       },
       {
         "name" : "FALCON_SERVER"
       },
       {
         "name" : "NIMBUS"
       },   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "1"
    },
    {
     "name" : "workers",
     "components" : [
       {
         "name" : "DATANODE"
       },
	   {
         "name" : "HBASE_REGIONSERVER"
       },
       {
         "name" : "NODEMANAGER"
       },	   	   
       {
         "name" : "FALCON_CLIENT"
       },
       {
         "name" : "HBASE_CLIENT"
       },
       {
         "name" : "HCAT"
       },
       {
         "name" : "HDFS_CLIENT"
       },
       {
         "name" : "HIVE_CLIENT"
       },
       {
         "name" : "MAPREDUCE2_CLIENT"
       },
       { 
         "name" : "METRICS_MONITOR"
       },
       {
         "name" : "OOZIE_CLIENT"
       },
       {
         "name" : "PIG"
       },
       {
         "name" : "SLIDER"
       },
       {
         "name" : "SPARK_CLIENT"
       },
       {
         "name" : "SQOOP"
       },
       {
         "name" : "TEZ_CLIENT"
       },
       {
         "name" : "YARN_CLIENT"
       },	 
       {
         "name" : "ZOOKEEPER_CLIENT"
       }
      ],
      "cardinality" : "200"
    }
  ]

  if scenario_id == 'evaluation':
    host_groups = evaluation_host_groups
  elif scenario_id == 'small':
    host_groups = small_host_groups
  elif scenario_id == 'medium':
    host_groups = medium_host_groups
  elif scenario_id == 'large':
    host_groups = large_host_groups

  host_groups = evaluation_host_groups if scenario_id == 'evaluation' else small_host_groups

  evaluation_configurations = [
    {
           "ams-hbase-env" : {
                "properties" : {
                     "hbase_master_heapsize" : "512m",
                     "hbase_regionserver_heapsize" : "512m",
                     "hbase_regionserver_xmn_max" : "256m",
                     "hbase_regionserver_xmn_ratio" : "0.2"
                }
           }
        },
        {
            "capacity-scheduler" : {
                "yarn.scheduler.capacity.root.default.maximum-am-resource-percent" :  "0.5",
                "yarn.scheduler.capacity.maximum-am-resource-percent" : "0.5"
            }
        },
        {
            "cluster-env": {
                "cluster_name": "sandbox",
                "smokeuser": "ambari-qa",
                "user_group": "hadoop",
                "security_enabled": "false"
            }
        },
        {
            "core-site" : {
                "hadoop.proxyuser.hue.hosts" : "*",
                "hadoop.proxyuser.hue.groups" : "*",
                "hadoop.proxyuser.root.hosts" : "*",
                "hadoop.proxyuser.root.groups" : "*",
                "hadoop.proxyuser.oozie.hosts" : "*",
                "hadoop.proxyuser.oozie.groups" : "*",
                "hadoop.proxyuser.hcat.hosts" : "*",
                "hadoop.proxyuser.hcat.groups" : "*"
            }
        },
        {
            "hadoop-env": {
                "dtnode_heapsize" : "250",
                "hadoop_heapsize" : "250",
                "namenode_heapsize" : "250",
                "namenode_opt_newsize": "50",
                "namenode_opt_maxnewsize": "100"
            }
        },
        {
            "hbase-site" : {
                "hbase.security.authorization": "true",
                "hbase.rpc.engine": "org.apache.hadoop.hbase.ipc.SecureRpcEngine",
                "hbase_master_heapsize": "250",
                "hbase_regionserver_heapsize": "250",
                "hbase.rpc.protection": "PRIVACY"
            }
        },
        {
            "hdfs-site" : {
                "dfs.block.size" : "34217472",
                "dfs.replication" : "1",
                "dfs.namenode.accesstime.precision" : "3600000",
                "dfs.nfs3.dump.dir" : "/tmp/.hdfs-nfs",
                "dfs.nfs.exports.allowed.hosts" : "* rw",
                "dfs.datanode.max.xcievers" : "1024",
                "dfs.block.access.token.enable" : "false"
            }
        },
        {
		  "global": {
			"oozie_data_dir": "/disks/0/hadoop/oozie/data",
			"zk_data_dir": "/disks/0/hadoop/zookeeper",
			"falcon.embeddedmq.data": "/disks/0/hadoop/falcon/embeddedmq/data",
			"falcon_local_dir": "/disks/0/hadoop/falcon",
			"namenode_heapsize" : "16384m"
			}
        },
        {
            "hive-site" : {
                "javax.jdo.option.ConnectionPassword" : "hive",
                "hive.tez.container.size" : "250",
                "hive.tez.java.opts" : "-server -Xmx200m -Djava.net.preferIPv4Stack=true",
                "hive.heapsize" : "250",
                "hive.users.in.admin.role" : "hue,hive",
                "hive_metastore_user_passwd" : "hive",
                "hive.server2.enable.impersonation": "true",

                "hive.compactor.check.interval": "300s",
                "hive.compactor.initiator.on": "true",
                "hive.compactor.worker.timeout": "86400s",
                "hive.enforce.bucketing": "true",
                "hive.support.concurrency": "true",
                "hive.exec.dynamic.partition.mode": "nonstrict",
                "hive.server2.enable.doAs": "true",
                "hive.txn.manager": "org.apache.hadoop.hive.ql.lockmgr.DbTxnManager",
                "hive.txn.max.open.batch": "1000",
                "hive.txn.timeout": "300",
                "hive.security.authorization.enabled": "false",
                "hive.users.in.admin.role": "hue,hive"
            }
        },
        {
            "mapred-env": {
                "jobhistory_heapsize" : "250"
            }
        },
        {
            "mapred-site" : {
                "mapreduce.map.memory.mb" : "250",
                "mapreduce.reduce.memory.mb" : "250",
                "mapreduce.task.io.sort.mb" : "64",
                "yarn.app.mapreduce.am.resource.mb" : "250",
                "yarn.app.mapreduce.am.command-opts" : "-Xmx200m",
                "mapred.job.reduce.memory.mb" : "250",
                "mapred.child.java.opts" : "-Xmx200m",
                "mapred.job.map.memory.mb" : "250",
                "io.sort.mb" : "64",
                "mapreduce.map.java.opts" : "-Xmx200m",
                "mapreduce.reduce.java.opts" : "-Xmx200m"
            }
        },
        {
            "oozie-site" : {
                "oozie.service.ProxyUserService.proxyuser.hue.hosts" : "*",
                "oozie.service.ProxyUserService.proxyuser.hue.groups" : "*",
                "oozie.service.ProxyUserService.proxyuser.falcon.hosts": "*",
                "oozie.service.ProxyUserService.proxyuser.falcon.groups": "*",
                "oozie.service.JPAService.jdbc.password" : "oozie"
            }
        },
        {
            "storm-site" : {
                "logviewer.port" : 8005,
                "nimbus.childopts" : "-Xmx220m -javaagent:/usr/hdp/current/storm-client/contrib/storm-jmxetric/lib/jmxetric-1.0.4.jar=host=sandbox.hortonworks.com,port=8649,wireformat31x=true,mode=multicast,config=/usr/hdp/current/storm-client/contrib/storm-jmxetric/conf/jmxetric-conf.xml,process=Nimbus_JVM",
                "ui.childopts" : "-Xmx220m",
                "drpc.childopts" : "-Xmx220m"
            }
        },
        {
            "tez-site" : {
                "tez.am.java.opts" : "-server -Xmx200m -Djava.net.preferIPv4Stack=true -XX:+UseNUMA -XX:+UseParallelGC",
                "tez.am.resource.memory.mb" : "250",
                "tez.dag.am.resource.memory.mb" : "250",
                "yarn.app.mapreduce.am.command-opts" : "-Xmx200m"
            }
        },
        {
            "webhcat-site" : {
                "webhcat.proxyuser.hue.hosts" : "*",
                "webhcat.proxyuser.hue.groups" : "*",
                "webhcat.proxyuser.hcat.hosts" : "*",
                "webhcat.proxyuser.hcat.groups" : "*",
                "templeton.hive.properties" : "hive.metastore.local=false,hive.metastore.uris=thrift://sandbox.hortonworks.com:9083,hive.metastore.sasl.enabled=false,hive.metastore.execute.setugi=true,hive.metastore.warehouse.dir=/apps/hive/warehouse"
            }
        },
        {
            "yarn-env": {
                "apptimelineserver_heapsize" : "250",
                "resourcemanager_heapsize" : "250",
                "nodemanager_heapsize" : "250",
                "yarn_heapsize" : "250"
            }

        },
        {
            "yarn-site" : {
                "yarn.nodemanager.resource.memory-mb": "2250",
                "yarn.nodemanager.vmem-pmem-ratio" : "10",
                "yarn.scheduler.minimum-allocation-mb" : "250",
                "yarn.scheduler.maximum-allocation-mb" : "2250",
                "yarn.nodemanager.pmem-check-enabled" : "false",
                "yarn.acl.enable" : "false",
                "yarn.resourcemanager.webapp.proxyuser.hcat.groups" : "*",
                "yarn.resourcemanager.webapp.proxyuser.hcat.hosts" : "*",
                "yarn.resourcemanager.webapp.proxyuser.oozie.groups" : "*",
                "yarn.resourcemanager.webapp.proxyuser.oozie.hosts" : "*"
            }
        }
  ]

  standard_configurations = [
    {
      "yarn-site": {
        "yarn.nodemanager.local-dirs": "/disks/0/hadoop/yarn/local,/disks/1/hadoop/yarn/local,/disks/2/hadoop/yarn/local,/disks/3/hadoop/yarn/local,/disks/4/hadoop/yarn/local,/disks/5/hadoop/yarn/local,/disks/6/hadoop/yarn/local,/disks/7/hadoop/yarn/local",
        "yarn.nodemanager.log-dirs": "/disks/0/hadoop/yarn/log,/disks/1/hadoop/yarn/log,/disks/2/hadoop/yarn/log,/disks/3/hadoop/yarn/log,/disks/4/hadoop/yarn/log,/disks/5/hadoop/yarn/log,/disks/6/hadoop/yarn/log,/disks/7/hadoop/yarn/log,/disks/8/hadoop/yarn/log,/disks/9/hadoop/yarn/log,/disks/10/hadoop/yarn/log,/disks/11/hadoop/yarn/log,/disks/12/hadoop/yarn/log,/disks/13/hadoop/yarn/log,/disks/14/hadoop/yarn/log,/disks/15/hadoop/yarn/log",
        "yarn.timeline-service.leveldb-timeline-store.path": "/disks/0/hadoop/yarn/timeline",
        "yarn.nodemanager.resource.memory-mb" : "32768",
        "yarn.scheduler.maximum-allocation-mb" : "32768",
        "yarn.scheduler.minimum-allocation-mb" : "2048"
      }
    },
    {
      "tez-site": {
        "tez.am.resource.memory.mb" : "2048",
        "tez.am.java.opts" : "-server -Xmx1638m -Djava.net.preferIPv4Stack=true -XX:+UseNUMA -XX:+UseParallelGC"
      }
    },
    {
      "mapred-site": {
        "mapreduce.map.java.opts" : "-Xmx1638m",
        "mapreduce.map.memory.mb" : "2048",
        "mapreduce.reduce.java.opts" : "-Xmx1638m",
        "mapreduce.reduce.memory.mb" : "2048",
        "mapreduce.task.io.sort.mb" : "819",
        "yarn.app.mapreduce.am.command-opts" : "-Xmx1638m",
        "yarn.app.mapreduce.am.resource.mb" : "2048"
      }
    },
    {
      "hdfs-site": {
        "dfs.datanode.data.dir": "/disks/0/hadoop/hdfs/data,/disks/1/hadoop/hdfs/data,/disks/2/hadoop/hdfs/data,/disks/3/hadoop/hdfs/data,/disks/4/hadoop/hdfs/data,/disks/5/hadoop/hdfs/data,/disks/6/hadoop/hdfs/data,/disks/7/hadoop/hdfs/data,/disks/8/hadoop/hdfs/data,/disks/9/hadoop/hdfs/data,/disks/10/hadoop/hdfs/data,/disks/11/hadoop/hdfs/data,/disks/12/hadoop/hdfs/data,/disks/13/hadoop/hdfs/data,/disks/14/hadoop/hdfs/data,/disks/15/hadoop/hdfs/data",
        "dfs.namenode.checkpoint.dir": "/disks/0/hadoop/hdfs/namesecondary",
        "dfs.namenode.name.dir": "/disks/0/hadoop/hdfs/namenode,/disks/1/hadoop/hdfs/namenode,/disks/2/hadoop/hdfs/namenode,/disks/3/hadoop/hdfs/namenode,/disks/4/hadoop/hdfs/namenode,/disks/5/hadoop/hdfs/namenode,/disks/6/hadoop/hdfs/namenode,/disks/7/hadoop/hdfs/namenode",
        "dfs.datanode.failed.volumes.tolerated": "6"
      }
    },
    {
      "global": {
        "oozie_data_dir": "/disks/0/hadoop/oozie/data",
        "zk_data_dir": "/disks/0/hadoop/zookeeper",
        "falcon.embeddedmq.data": "/disks/0/hadoop/falcon/embeddedmq/data",
        "falcon_local_dir": "/disks/0/hadoop/falcon",
        "namenode_heapsize" : "16384m"
      }
    },
    {
      "hbase-site": {
        "hbase.tmp.dir": "/disks/0/hadoop/hbase"
      }
    },
    {
      "storm-site": {
        "storm.local.dir": "/disks/0/hadoop/storm"
      }
    },
    {
      "falcon-startup.properties": {
        "*.config.store.uri": "file:///disks/0/hadoop/falcon/store"
      }
    },
    {
      "hive-site": {
        "hive.auto.convert.join.noconditionaltask.size" : "716177408",
        "hive.tez.container.size" : "2048",
        "hive.tez.java.opts" : "-server -Xmx1638m -Djava.net.preferIPv4Stack=true -XX:NewRatio=8 -XX:+UseNUMA -XX:+UseParallelGC"
      }
    }
  ]

  configurations = evaluation_configurations if scenario_id == 'evaluation' else standard_configurations

  data = {
    "configurations" : configurations,
    "host_groups": host_groups,
    "Blueprints" : {
      "blueprint_name" : blueprint_name,
      "stack_name" : "HDP",
      "stack_version" : "2.2"
    }
  }
  data = json.dumps(data)
  request = urllib2.Request(url, data)
  request.add_header('Authorization', get_ambari_auth_string())
  request.add_header('X-Requested-By', 'ambari')
  request.add_header('Content-Type', 'text/plain')
  try:
    response = urllib2.urlopen(request, timeout=request_timeout)
    pprint.pprint(response.read())
  except urllib2.HTTPError as e:
    logger.error('Cluster deployment failed: ' + e.read())
    raise e
  return 'myblueprint'

def initiate_cluster_deploy(blueprint_name, cluster_id, num_masters, num_workers):
  logger.info('Deploying cluster...')
  url = '%s://localhost:%s/api/v1/clusters/%s' % (protocol, port, cluster_id)
  if num_masters + num_workers < 4:
    raise Exception('Cluster size must be 4 or greater')

  data = {
    "blueprint": blueprint_name,
    "default_password": "admin",
    "host_groups": [
    ]
  }

  for i in range(1, num_masters + 1):
    data['host_groups'].append({
      "name": "master_%d" % i,
      "hosts": [{
        "fqdn": get_fqdn(i)
      }]
    })

  worker_hosts = []
  for i in range(num_masters + 1, num_masters + num_workers + 1):
    worker_hosts.append({
      "fqdn": get_fqdn(i)
    })

  data['host_groups'].append({
    "name": "workers",
    "hosts": worker_hosts
  })

  data = json.dumps(data)
  pprint.pprint('data=' + data)
  request = urllib2.Request(url, data)
  request.add_header('Authorization', get_ambari_auth_string())
  request.add_header('X-Requested-By', 'ambari')
  request.add_header('Content-Type', 'text/plain')
  try:
    response = urllib2.urlopen(request, timeout=120)
    pprint.pprint(response.read())
  except urllib2.HTTPError as e:
    logger.error('Cluster deployment failed: ' + e.read())
    raise e

def poll_until_cluster_deployed(cluster_id, timeout):
  url = '%s://localhost:%s/api/v1/clusters/%s/requests/1?fields=Requests/progress_percent,Requests/request_status' % (protocol, port, cluster_id)
  deploy_success = False
  deploy_finished = False
  start_time = time.time()
  logger.info('poll until function')
  while time.time() - start_time < timeout:
    request = urllib2.Request(url)
    request.add_header("Authorization", get_ambari_auth_string())
    try:
      result = urllib2.urlopen(request, timeout=request_timeout).read()
      pprint.pprint(result)
      if (result is not None):
        jsonResult = json.loads(result)
        if jsonResult['Requests']['request_status'] == 'COMPLETED':
          deploy_success = True
        if int(jsonResult['Requests']['progress_percent']) == 100 or jsonResult['Requests']['request_status'] == 'FAILED':
          deploy_finished = True
          break
    except:
      logger.info('Could not poll deploy status from the server.')
    time.sleep(5)
  if not deploy_finished:
    raise TimeoutException('Timed out while waiting for cluster deployment to finish')
  elif not deploy_success:
    raise Exception('Cluster deploy failed')

if action == 'bootstrap':
  masters_iplist = masters_iplist.split(',')
  workers_iplist = workers_iplist.split(',')
  ambari_server_hostname = get_hostname(1)
  all_hostnames = map((lambda i: get_hostname(i)), range(1, num_masters + num_workers + 1))
  logger.info(all_hostnames)
  host_ip_map = get_host_ip_map(all_hostnames)
  update_etc_hosts(host_ip_map)

  update_ambari_agent_ini(ambari_server_hostname)

  patch_ambari_agent()

  run_system_command('chkconfig ambari-agent on')
  logger.info('Starting ambari-agent...')
  run_system_command('ambari-agent start')
  logger.info('ambari-agent started')

  if is_ambari_server_host():
    run_system_command('chkconfig ambari-server on')
    logger.info('Running ambari-server setup...')
    run_system_command('ambari-server setup -s -j /usr/jdk64/jdk1.7.0_45')
    logger.info('ambari-server setup finished')
    if protocol == 'https':
      logger.info('Enabling HTTPS...')
      enable_https()
      logger.info('HTTPS enabled')
    logger.info('Starting ambari-server...')
    run_system_command('ambari-server start')
    logger.info('ambari-server started')
    try:
      set_admin_password(admin_password, 60 * 2)
      # set current_admin_password so that HTTP requests to Ambari start using the new user-specified password
      current_admin_password = admin_password
      poll_until_all_agents_registered(num_masters + num_workers, 60 * 4)
      blueprint_name = create_blueprint(scenario_id)
      initiate_cluster_deploy(blueprint_name, cluster_id, num_masters, num_workers)
    except:
      logger.error('Failed VM Bootstrap')
      sys.exit(1)
else:
  try:
    current_admin_password = admin_password
    poll_until_cluster_deployed(cluster_id, check_timeout_seconds)
  except TimeoutException as e:
    logger.info(e)
    if report_timeout_fail:
      logger.error('Failed cluster deployment')
      sys.exit(1)
    else:
      logger.info('Cluster deployment has not completed')
      sys.exit(0)
  except:
    logger.error('Failed cluster deployment')
    sys.exit(1)

logger.info('Finished VM Bootstrap successfully')
sys.exit(0)
