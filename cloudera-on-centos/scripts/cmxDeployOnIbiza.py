#!/usr/bin/env python
# 
__version__ = '0.11.2803'

import socket
import re
import urllib
import urllib2
from optparse import OptionParser
import hashlib
import os
import sys
import random
import paramiko
from paramiko import SSHClient

from time import sleep

from cm_api.api_client import ApiResource, ApiException
from cm_api.endpoints.hosts import *
from cm_api.endpoints.services import ApiServiceSetupInfo, ApiService

LOG_DIR='/log/cloudera'

def getParameterValue(vmsize, parameter):
    log("vmsize: "+vmsize+", parameter:"+parameter)
    switcher = {
        "Standard_DS14:yarn_nodemanager_resource_cpu_vcores": "10",
        "Standard_DS14:yarn_nodemanager_resource_memory_mb": "45056",
        "Standard_DS14:impalad_memory_limit": "42949672960",
        "Standard_DS13:yarn_nodemanager_resource_cpu_vcores": "5",
        "Standard_DS13:yarn_nodemanager_resource_memory_mb": "20028",
        "Standard_DS13:impalad_memory_limit": "21500000000"

    }
    return switcher.get(vmsize+":"+parameter, "0")

def getDataDiskCount():
    bashCommand="lsblk | grep /data | grep -v /data/ | wc -l"
    client=SSHClient()
    client.set_missing_host_key_policy(paramiko.client.AutoAddPolicy())
    log(socket.getfqdn(cmx.cm_server))
    toconnect=socket.getfqdn(cmx.cm_server).replace("-mn0", "-dn0")
    log(toconnect)
    client.connect(toconnect, username=cmx.ssh_root_user, password=cmx.ssh_root_password)
    stdin, stdout, stderr = client.exec_command(bashCommand)
    count=stdout.readline().rstrip('\n')

    return count

def setZookeeperOwnerDir(HA):
    os.system("sudo chown zookeeper:zookeeper "+LOG_DIR+"/zookeeper")
    # setup other masters in HA environment
    if HA:
        client=SSHClient()
        client.set_missing_host_key_policy(paramiko.client.AutoAddPolicy())
        toconnect=socket.getfqdn(cmx.cm_server).replace("-mn0", "-mn1")
        client.connect(toconnect, username=cmx.ssh_root_user, password=cmx.ssh_root_password)
        client.exec_command("sudo chown zookeeper:zookeeper "+LOG_DIR+"/zookeeper")
        toconnect=socket.getfqdn(cmx.cm_server).replace("-mn0", "-mn2")
        client.connect(toconnect, username=cmx.ssh_root_user, password=cmx.ssh_root_password)
        client.exec_command("sudo chown zookeeper:zookeeper "+LOG_DIR+"/zookeeper")




def init_cluster():
    """
    Initialise Cluster
    :return:
    """
    #using default username/password to login first, create new admin user base on provided value, then delete admin
    api = ApiResource(server_host=cmx.cm_server, username="admin", password="admin")
    api.create_user(cmx.username, cmx.password, ['ROLE_ADMIN'])
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    api.delete_user("admin")

    # Update Cloudera Manager configuration
    cm = api.get_cloudera_manager()
    cm.update_config({"REMOTE_PARCEL_REPO_URLS": "http://archive.cloudera.com/cdh5/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/impala/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/cdh4/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/search/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/spark/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/sqoop-connectors/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/accumulo/parcels/{latest_supported}/,"
                                                 "http://archive.cloudera.com/accumulo-c5/parcels/{latest_supported},"
                                                 "http://archive.cloudera.com/gplextras5/parcels/{latest_supported}",
                      "PHONE_HOME": False, "PARCEL_DISTRIBUTE_RATE_LIMIT_KBS_PER_SECOND": "1024000"})

    print "> Initialise Cluster"
    if cmx.cluster_name in [x.name for x in api.get_all_clusters()]:
        print "Cluster name: '%s' already exists" % cmx.cluster_name
    else:
        print "Creating cluster name '%s'" % cmx.cluster_name
        api.create_cluster(name=cmx.cluster_name, version=cmx.cluster_version)


def add_hosts_to_cluster():
    """
    Add hosts to cluster
    :return:
    """
    print "> Add hosts to Cluster: %s" % cmx.cluster_name
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    cm = api.get_cloudera_manager()

    # deploy agents into host_list
    host_list = list(set([socket.getfqdn(x) for x in cmx.host_names] + [socket.getfqdn(cmx.cm_server)]) -
                     set([x.hostname for x in api.get_all_hosts()]))
    if host_list:
        cmd = cm.host_install(user_name=cmx.ssh_root_user, host_names=host_list,
                              password=cmx.ssh_root_password, private_key=cmx.ssh_private_key)
        print "Installing host(s) to cluster '%s' - [ http://%s:7180/cmf/command/%s/details ]" % \
              (socket.getfqdn(cmx.cm_server), cmx.cm_server, cmd.id)
        #check.status_for_command("Hosts: %s " % host_list, cmd)
        print "Installing hosts. This might take a while."
        while cmd.success == None:
            sleep(20)
            cmd = cmd.fetch()
            print "Installing hosts... Checking"

        if cmd.success != True:
            print "cm_host_install failed: " + cmd.resultMessage
            exit(0)

    print "Host install finish, agents installed"
    hosts = []
    for host in api.get_all_hosts():
        if host.hostId not in [x.hostId for x in cluster.list_hosts()]:
            print "Adding {'ip': '%s', 'hostname': '%s', 'hostId': '%s'}" % (host.ipAddress, host.hostname, host.hostId)
            hosts.append(host.hostId)

    print "adding new hosts to cluster"
    if hosts:
        print "Adding hostId(s) to '%s'" % cmx.cluster_name
        print "%s" % hosts
        cluster.add_hosts(hosts)


def host_rack():
    """
    Add host to rack
    :return:
    """
    # TODO: Add host to rack
    print "> Add host to rack"
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    hosts = []
    for h in api.get_all_hosts():
        # host = api.create_host(h.hostId, h.hostname,
        # socket.gethostbyname(h.hostname),
        # "/default_rack")
        h.set_rack_id("/default_rack")
        hosts.append(h)

    cluster.add_hosts(hosts)


def deploy_parcel(parcel_product, parcel_version):
    """
    Deploy parcels
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    parcel = cluster.get_parcel(parcel_product, parcel_version)
    if parcel.stage != 'ACTIVATED':
        print "> Deploying parcel: [ %s-%s ]" % (parcel_product, parcel_version)
        parcel.start_download()
        # unlike other commands, check progress by looking at parcel stage and status
        while True:
            parcel = cluster.get_parcel(parcel_product, parcel_version)
            if parcel.stage == 'DISTRIBUTED' or parcel.stage == 'DOWNLOADED' or parcel.stage == 'ACTIVATED':
                break
           # if parcel.state.errors:
            #    raise Exception(str(parcel.state.errors))
            msg = " [%s: %s / %s]" % (parcel.stage, parcel.state.progress, parcel.state.totalProgress)
            sys.stdout.write(msg + " " * (78 - len(msg)) + "\r")
            sys.stdout.flush()

        print ""
        print "1. Parcel Stage: %s" % parcel.stage
        parcel.start_distribution()

        while True:
            parcel = cluster.get_parcel(parcel_product, parcel_version)
            if parcel.stage == 'DISTRIBUTED' or parcel.stage == 'ACTIVATED':
                break
           # if parcel.state.errors:
               # raise Exception(str(parcel.state.errors))
            msg = " [%s: %s / %s]" % (parcel.stage, parcel.state.progress, parcel.state.totalProgress)
            sys.stdout.write(msg + " " * (78 - len(msg)) + "\r")
            sys.stdout.flush()

        print "2. Parcel Stage: %s" % parcel.stage
        if parcel.stage == 'DISTRIBUTED':
            parcel.activate()

        while True:
            parcel = cluster.get_parcel(parcel_product, parcel_version)
            if parcel.stage != 'ACTIVATED':
                msg = " [%s: %s / %s]" % (parcel.stage, parcel.state.progress, parcel.state.totalProgress)
                sys.stdout.write(msg + " " * (78 - len(msg)) + "\r")
                sys.stdout.flush()
           # elif parcel.state.errors:
             #   raise Exception(str(parcel.state.errors))
            else:
                print "3. Parcel Stage: %s" % parcel.stage
                break


def setup_zookeeper(HA):
    """
    Zookeeper
    > Waiting for ZooKeeper Service to initialize
    Starting ZooKeeper Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "ZOOKEEPER"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "zookeeper"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        
        hosts = management.get_hosts()
        cmhost= management.get_cmhost()
        
        service.update_config({"zookeeper_datadir_autocreate": True})

        # Ensure zookeeper has access to folder
        setZookeeperOwnerDir(HA)

        # Role Config Group equivalent to Service Default Group
        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "SERVER":
                rcg.update_config({"maxClientCnxns": "1024",
                                   "dataLogDir": LOG_DIR+"/zookeeper",
                                   "dataDir": LOG_DIR+"/zookeeper",
                                   "zk_server_log_dir": LOG_DIR+"/zookeeper"})
                # Pick 3 hosts and deploy Zookeeper Server role for Zookeeper HA
                # mingrui change install on primary, secondary, and CM
                if HA:
                    print cmhost
                    print [x for x in hosts if x.id == 0 ][0]
                    print [x for x in hosts if x.id == 1 ][0]
                    cdh.create_service_role(service, rcg.roleType, cmhost)
                    cdh.create_service_role(service, rcg.roleType, [x for x in hosts if x.id == 0 ][0])
                    cdh.create_service_role(service, rcg.roleType, [x for x in hosts if x.id == 1 ][0])
                #No HA, using POC setup, all service in one master node aka the cm host
                else:
                    cdh.create_service_role(service, rcg.roleType, cmhost)



        # init_zookeeper not required as the API performs this when adding Zookeeper
        # check.status_for_command("Waiting for ZooKeeper Service to initialize", service.init_zookeeper())
        check.status_for_command("Starting ZooKeeper Service", service.start())


def setup_hdfs(HA):
    """
    HDFS
    > Checking if the name directories of the NameNode are empty. Formatting HDFS only if empty.
    Starting HDFS Service
    > Creating HDFS /tmp directory
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "HDFS"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "hdfs"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service_config = cdh.dependencies_for(service)
        service_config.update({"dfs_replication": "3",
                               "dfs_block_local_path_access_user": "impala,hbase,mapred,spark"})
        service.update_config(service_config)

        # Get Disk Information - assume that all disk configuration is heterogeneous throughout the cluster

        default_name_dir_list = ""
        default_snn_dir_list = ""
        default_data_dir_list = ""


        dfs_name_dir_list = default_name_dir_list
        dfs_snn_dir_list = default_snn_dir_list
        dfs_data_dir_list = default_data_dir_list

        for x in range(int(diskcount)):
          dfs_data_dir_list+=",/data%d/dfs/dn" % (x)

        dfs_name_dir_list+=",/data/dfs/nn"
        dfs_snn_dir_list+=",/data/dfs/snn"

        #No HA, using POC setup, all service in one master node aka the cm host
        if not HA:
            nn_host_id=management.get_cmhost()
            snn_host_id=management.get_cmhost()
        else:
            nn_host_id = [host for host in hosts if host.id == 0][0]
            snn_host_id = [host for host in hosts if host.id == 1][0]

        
        
        # Role Config Group equivalent to Service Default Group
        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "NAMENODE":
                # hdfs-NAMENODE - Default Group
                rcg.update_config({"dfs_name_dir_list": dfs_name_dir_list,
                                   "namenode_java_heapsize": "1677058304",
                                   "dfs_namenode_handler_count": "70",
                                   "dfs_namenode_service_handler_count": "70",
                                   "dfs_namenode_servicerpc_address": "8022",
                                   "namenode_log_dir": LOG_DIR+"/hadoop-hdfs"})
                cdh.create_service_role(service, rcg.roleType, nn_host_id)
            if rcg.roleType == "SECONDARYNAMENODE":
                # hdfs-SECONDARYNAMENODE - Default Group
                rcg.update_config({"fs_checkpoint_dir_list": dfs_snn_dir_list,
                                   "secondary_namenode_java_heapsize": "1677058304",
                                   "secondarynamenode_log_dir": LOG_DIR+"/hadoop-hdfs"})
                # chose a server that it's not NN, easier to enable HDFS-HA later

                cdh.create_service_role(service, rcg.roleType, snn_host_id)

            if rcg.roleType == "DATANODE":
                # hdfs-DATANODE - Default Group
                rcg.update_config({"datanode_java_heapsize": "351272960",
                                   "dfs_data_dir_list": dfs_data_dir_list,
                                   "dfs_datanode_data_dir_perm": "755",
                                   "dfs_datanode_du_reserved": "3508717158",
                                   "dfs_datanode_failed_volumes_tolerated": "0",
                                   "dfs_datanode_max_locked_memory": "1257242624",
                                   "datanode_log_dir": LOG_DIR+"/hadoop-hdfs"})
            if rcg.roleType == "FAILOVERCONTROLLER":
                rcg.update_config({"failover_controller_log_dir": LOG_DIR+"/hadoop-hdfs"})
            if rcg.roleType == "HTTPFS":
                rcg.update_config({"httpfs_log_dir": LOG_DIR+"/hadoop-httpfs"})
                
            if rcg.roleType == "GATEWAY":
                # hdfs-GATEWAY - Default Group
                rcg.update_config({"dfs_client_use_trash": True})



    # print nn_host_id.hostId
    # print snn_host_id.hostId
    for role_type in ['DATANODE']:
        for host in management.get_hosts(include_cm_host = False):
            if host.hostId != nn_host_id.hostId:
                if host.hostId != snn_host_id.hostId:
                            cdh.create_service_role(service, role_type, host)

        for role_type in ['GATEWAY']:
            for host in management.get_hosts(include_cm_host=(role_type == 'GATEWAY')):
                cdh.create_service_role(service, role_type, host)
                
        nn_role_type = service.get_roles_by_type("NAMENODE")[0]
        commands = service.format_hdfs(nn_role_type.name)
        for cmd in commands:
            check.status_for_command("Format NameNode", cmd)

        check.status_for_command("Starting HDFS.", service.start())
        check.status_for_command("Creating HDFS /tmp directory", service.create_hdfs_tmp())

    # Additional HA setting for yarn
    if HA:
        setup_hdfs_ha()



def setup_hbase():
    """
    HBase
    > Creating HBase root directory
    Starting HBase Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "HBASE"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "hbase"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        master_host_id = [host for host in hosts if host.id == 0][0]
        backup_master_host_id = [host for host in hosts if host.id == 1][0]    
        cmhost = management.get_cmhost()

        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "MASTER":
                cdh.create_service_role(service, rcg.roleType, master_host_id)
                cdh.create_service_role(service, rcg.roleType, backup_master_host_id)
                cdh.create_service_role(service, rcg.roleType, cmhost)

            if rcg.roleType == "REGIONSERVER":
                for host in management.get_hosts(include_cm_host = False):
                    if host.hostId != master_host_id.hostId:
                        if host.hostId != backup_master_host_id.hostId:
                            cdh.create_service_role(service, rcg.roleType, host)

        #for role_type in ['HBASETHRIFTSERVER', 'HBASERESTSERVER']:
        #    cdh.create_service_role(service, role_type, random.choice(hosts))

        for role_type in ['GATEWAY']:
            for host in management.get_hosts(include_cm_host=(role_type == 'GATEWAY')):
                cdh.create_service_role(service, role_type, host)

        check.status_for_command("Creating HBase root directory", service.create_hbase_root())
        check.status_for_command("Starting HBase Service", service.start())


def setup_solr():
    """
    Solr
    > Initializing Solr in ZooKeeper
    > Creating HDFS home directory for Solr
    Starting Solr Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "SOLR"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "solr"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        # Role Config Group equivalent to Service Default Group
        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "SOLR_SERVER":
                cdh.create_service_role(service, rcg.roleType, [x for x in hosts if x.id == 0][0])
            if rcg.roleType == "GATEWAY":
                for host in management.get_hosts(include_cm_host=True):
                    cdh.create_service_role(service, rcg.roleType, host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)

        # check.status_for_command("Initializing Solr in ZooKeeper", service._cmd('initSolr'))
        # check.status_for_command("Creating HDFS home directory for Solr", service._cmd('createSolrHdfsHomeDir'))
        check.status_for_command("Initializing Solr in ZooKeeper", service.init_solr())
        check.status_for_command("Creating HDFS home directory for Solr",
                                 service.create_solr_hdfs_home_dir())
        # This service is started later on
        # check.status_for_command("Starting Solr Service", service.start())


def setup_ks_indexer():
    """
    KS_INDEXER
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "KS_INDEXER"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "ks_indexer"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        # Pick 1 host to deploy Lily HBase Indexer Default Group
        cdh.create_service_role(service, "HBASE_INDEXER", random.choice(hosts))

        # HBase Service-Wide configuration
        hbase = cdh.get_service_type('HBASE')
        hbase.stop()
        hbase.update_config({"hbase_enable_indexing": True, "hbase_enable_replication": True})
        hbase.start()

        # This service is started later on
        # check.status_for_command("Starting Lily HBase Indexer Service", service.start())



def setup_spark_on_yarn():
    """
    Sqoop Client
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "SPARK_ON_YARN"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "spark_on_yarn"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        cmhost= management.get_cmhost()

        soy=service.get_role_config_group("{0}-SPARK_YARN_HISTORY_SERVER-BASE".format(service_name))
        soy.update_config({"log_dir": LOG_DIR+"/spark"})
        cdh.create_service_role(service, "SPARK_YARN_HISTORY_SERVER",cmhost)

        for host in management.get_hosts(include_cm_host=True):
            cdh.create_service_role(service, "GATEWAY", host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)

        check.status_for_command("Execute command CreateSparkUserDirCommand on service Spark",
                                 service._cmd('CreateSparkUserDirCommand'))
        check.status_for_command("Execute command CreateSparkHistoryDirCommand on service Spark",
                                 service._cmd('CreateSparkHistoryDirCommand'))
        check.status_for_command("Execute command SparkUploadJarServiceCommand on service Spark",
                                 service._cmd('SparkUploadJarServiceCommand'))

        # This service is started later on
        # check.status_for_command("Starting Spark Service", service.start())


def setup_yarn(HA):
    """
    Yarn
    > Creating MR2 job history directory
    > Creating NodeManager remote application log directory
    Starting YARN (MR2 Included) Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "YARN"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "yarn"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()
        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        # empty list so it won't use ephemeral drive
        default_yarn_dir_list = ""

        yarn_dir_list = default_yarn_dir_list

        for x in range(int(diskcount)):
          yarn_dir_list+=",/data%d/yarn/nm" % (x)

        cmhost= management.get_cmhost()
        rm_host_id = [host for host in hosts if host.id == 0][0]
        srm_host_id = [host for host in hosts if host.id == 1][0]

        if not HA:
            rm_host_id=cmhost
            srm_host_id=cmhost

        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "RESOURCEMANAGER":
                # yarn-RESOURCEMANAGER - Default Group
                rcg.update_config({"resource_manager_java_heapsize": "2000000000",
                                   "yarn_scheduler_maximum_allocation_mb": "2568",
                                   "yarn_scheduler_maximum_allocation_vcores": "2",
                                   "resource_manager_log_dir": LOG_DIR+"/hadoop-yarn"})
                cdh.create_service_role(service, rcg.roleType, rm_host_id)
            if rcg.roleType == "JOBHISTORY":
                # yarn-JOBHISTORY - Default Group
                rcg.update_config({"mr2_jobhistory_java_heapsize": "1000000000",
                                   "mr2_jobhistory_log_dir": LOG_DIR+"/hadoop-mapreduce"})

                cdh.create_service_role(service, rcg.roleType, cmhost)
                
            if rcg.roleType == "NODEMANAGER":
                # yarn-NODEMANAGER - Default Group
                rcg.update_config({"yarn_nodemanager_heartbeat_interval_ms": "100",
                                   "node_manager_java_heapsize": "2000000000",
                                   "yarn_nodemanager_local_dirs": yarn_dir_list,
                                   "yarn_nodemanager_resource_cpu_vcores": getParameterValue(cmx.vmsize, "yarn_nodemanager_resource_cpu_vcores"),
                                   "yarn_nodemanager_resource_memory_mb": getParameterValue(cmx.vmsize,"yarn_nodemanager_resource_memory_mb"),
                                   "node_manager_log_dir": LOG_DIR+"/hadoop-yarn",
                                   "yarn_nodemanager_log_dirs": LOG_DIR+"/hadoop-yarn/container"})
#                for host in hosts:
#                    cdh.create_service_role(service, rcg.roleType, host)
            if rcg.roleType == "GATEWAY":
                # yarn-GATEWAY - Default Group
                rcg.update_config({"mapred_submit_replication": "3"})
                for host in management.get_hosts(include_cm_host=True):
                    cdh.create_service_role(service, rcg.roleType, host)


        #print rm_host_id.hostId
        #print srm_host_id.hostId
        for role_type in ['NODEMANAGER']:
                for host in management.get_hosts(include_cm_host = False):
                        #print host.hostId
                        if host.hostId != rm_host_id.hostId:
                            if host.hostId != srm_host_id.hostId:
                                cdh.create_service_role(service, role_type, host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)

        check.status_for_command("Creating MR2 job history directory", service.create_yarn_job_history_dir())
        check.status_for_command("Creating NodeManager remote application log directory",
                                 service.create_yarn_node_manager_remote_app_log_dir())
        # This service is started later on
        # check.status_for_command("Starting YARN (MR2 Included) Service", service.start())

        # Additional HA setting for yarn
    if HA:
        setup_yarn_ha()


def setup_mapreduce(HA):
    """
    MapReduce
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "MAPREDUCE"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "mapreduce"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        jk=management.get_cmhost()
        if HA:
            jk=[x for x in hosts if x.id == 0][0]

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "JOBTRACKER":
                # mapreduce-JOBTRACKER - Default Group
                rcg.update_config({"jobtracker_mapred_local_dir_list": "/mapred/jt"})
                cdh.create_service_role(service, rcg.roleType, jk)
            if rcg.roleType == "TASKTRACKER":
                # mapreduce-TASKTRACKER - Default Group
                rcg.update_config({"tasktracker_mapred_local_dir_list": "/mapred/local",
                                   "mapred_tasktracker_map_tasks_maximum": "1",
                                   "mapred_tasktracker_reduce_tasks_maximum": "1", })
            if rcg.roleType == "GATEWAY":
                # mapreduce-GATEWAY - Default Group
                rcg.update_config({"mapred_reduce_tasks": "1", "mapred_submit_replication": "1"})

        for role_type in ['GATEWAY', 'TASKTRACKER']:
            for host in management.get_hosts(include_cm_host=(role_type == 'GATEWAY')):
                cdh.create_service_role(service, role_type, host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)

        # This service is started later on
        # check.status_for_command("Starting MapReduce Service", service.start())


def setup_hive():
    """
    Hive
    > Creating Hive Metastore Database
    > Creating Hive Metastore Database Tables
    > Creating Hive user directory
    > Creating Hive warehouse directory
    Starting Hive Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "HIVE"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "hive"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        # hive_metastore_database_host: Assuming embedded DB is running from where embedded-db is located.
        service_config = {"hive_metastore_database_host": socket.getfqdn(cmx.cm_server),
                          "hive_metastore_database_user": "hive",
                          "hive_metastore_database_name": "metastore",
                          "hive_metastore_database_password": cmx.hive_password,
                          "hive_metastore_database_port": "5432",
                          "hive_metastore_database_type": "postgresql"}
        service_config.update(cdh.dependencies_for(service))
        service.update_config(service_config)

        hcat = service.get_role_config_group("{0}-WEBHCAT-BASE".format(service_name))
        hcat.update_config({"hcatalog_log_dir": LOG_DIR+"/hcatalog"})
        hs2 = service.get_role_config_group("{0}-HIVESERVER2-BASE".format(service_name))
        hs2.update_config({"hive_log_dir": LOG_DIR+"/hive"})
        hms = service.get_role_config_group("{0}-HIVEMETASTORE-BASE".format(service_name))
        hms.update_config({"hive_log_dir": LOG_DIR+"/hive"})
        
        
        #install to CM node, mingrui
        cmhost= management.get_cmhost()
        for role_type in ['HIVEMETASTORE', 'HIVESERVER2']:
            cdh.create_service_role(service, role_type, cmhost)

        for host in management.get_hosts(include_cm_host=True):
            cdh.create_service_role(service, "GATEWAY", host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)

        check.status_for_command("Creating Hive Metastore Database Tables", service.create_hive_metastore_tables())
        check.status_for_command("Creating Hive user directory", service.create_hive_userdir())
        check.status_for_command("Creating Hive warehouse directory", service.create_hive_warehouse())
        # This service is started later on
        # check.status_for_command("Starting Hive Service", service.start())


def setup_sqoop():
    """
    Sqoop 2
    > Creating Sqoop 2 user directory
    Starting Sqoop 2 Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "SQOOP"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "sqoop"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        #install to CM node, mingrui
        cmhost= management.get_cmhost()
        cdh.create_service_role(service, "SQOOP_SERVER", cmhost)

        # check.status_for_command("Creating Sqoop 2 user directory", service._cmd('createSqoopUserDir'))
        check.status_for_command("Creating Sqoop 2 user directory", service.create_sqoop_user_dir())
        # This service is started later on
        # check.status_for_command("Starting Sqoop 2 Service", service.start())


def setup_sqoop_client():
    """
    Sqoop Client
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "SQOOP_CLIENT"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "sqoop_client"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        # hosts = get_cluster_hosts()

        # Service-Wide
        service.update_config({})

        for host in management.get_hosts(include_cm_host=True):
            cdh.create_service_role(service, "GATEWAY", host)

        # Example of deploy_client_config. Recommended to Deploy Cluster wide client config.
        # cdh.deploy_client_config_for(service)


def setup_impala(HA):
    """
    Impala
    > Creating Impala user directory
    Starting Impala Service
    :return:
    """

    default_impala_dir_list = ""

    impala_dir_list = default_impala_dir_list

    for x in range(int(diskcount)):
        impala_dir_list+="/data%d/impala/scratch" % (x)
        max_count=int(diskcount)-1
        if x < max_count:
          impala_dir_list+=","
          print "x is %d. Adding comma" % (x)

    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "IMPALA"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "impala"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        service_config = {"impala_cmd_args_safety_valve": "-scratch_dirs=%s" % (impala_dir_list) }
        service.update_config(service_config)        
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        impalad=service.get_role_config_group("{0}-IMPALAD-BASE".format(service_name))
        impalad.update_config({"log_dir": LOG_DIR+"/impalad",
                               "impalad_memory_limit": getParameterValue(cmx.vmsize, "impalad_memory_limit")})
        #llama=service.get_role_config_group("{0}-LLAMMA-BASE".format(service_name))
        #llama.update_config({"log_dir": LOG_DIR+"impala-llama"})
        ss = service.get_role_config_group("{0}-STATESTORE-BASE".format(service_name))
        ss.update_config({"log_dir": LOG_DIR+"/statestore"})
        cs = service.get_role_config_group("{0}-CATALOGSERVER-BASE".format(service_name))
        cs.update_config({"log_dir": LOG_DIR+"/catalogd"})

        cmhost= management.get_cmhost()
        for role_type in ['CATALOGSERVER', 'STATESTORE']:
            cdh.create_service_role(service, role_type, cmhost)

        if HA:
            # Install ImpalaD
            head_node_1_host_id = [host for host in hosts if host.id == 0][0]
            head_node_2_host_id = [host for host in hosts if host.id == 1][0]

            for host in hosts:
                # impalad should not be on hn-1 and hn-2
                if (host.id!=head_node_1_host_id.id and host.id!=head_node_2_host_id.id):
                    cdh.create_service_role(service, "IMPALAD", host)
        else:
            # All master services on CM host, install impalad on datanode host
            for host in hosts:
                if (host.id!=cmhost.id):
                    cdh.create_service_role(service, "IMPALAD", host)


        check.status_for_command("Creating Impala user directory", service.create_impala_user_dir())
        check.status_for_command("Starting Impala Service", service.start())


def setup_oozie():
    """
    Oozie
    > Creating Oozie database
    > Installing Oozie ShareLib in HDFS
    Starting Oozie Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "OOZIE"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "oozie"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        # Role Config Group equivalent to Service Default Group
        # install to CM server, mingrui
        cmhost= management.get_cmhost()
        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "OOZIE_SERVER":
                rcg.update_config({"oozie_log_dir": LOG_DIR+"/oozie",
                                   "oozie_data_dir": LOG_DIR+"/lib/oozie/data"})
                cdh.create_service_role(service, rcg.roleType, cmhost)

        check.status_for_command("Creating Oozie database", service.create_oozie_db())
        check.status_for_command("Installing Oozie ShareLib in HDFS", service.install_oozie_sharelib())
        # This service is started later on
        # check.status_for_command("Starting Oozie Service", service.start())


def setup_hue():
    """
    Hue
    Starting Hue Service
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "HUE"
    if cdh.get_service_type(service_type) is None:
        print "> %s" % service_type
        service_name = "hue"
        print "Create %s service" % service_name
        cluster.create_service(service_name, service_type)
        service = cluster.get_service(service_name)
        hosts = management.get_hosts()

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))

        # Role Config Group equivalent to Service Default Group
        # install to CM, mingrui
        cmhost= management.get_cmhost()
        for rcg in [x for x in service.get_all_role_config_groups()]:
            if rcg.roleType == "HUE_SERVER":
                rcg.update_config({"hue_server_log_dir": LOG_DIR+"/hue"})
                cdh.create_service_role(service, "HUE_SERVER", cmhost)
            if rcg.roleType == "KT_RENEWER":
                rcg.update_config({"kt_renewer_log_dir": LOG_DIR+"/hue"})
        # This service is started later on
        # check.status_for_command("Starting Hue Service", service.start())


def setup_flume():
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "FLUME"
    if cdh.get_service_type(service_type) is None:
        service_name = "flume"
        cluster.create_service(service_name.lower(), service_type)
        service = cluster.get_service(service_name)

        # Service-Wide
        service.update_config(cdh.dependencies_for(service))
        hosts = management.get_hosts()
        cdh.create_service_role(service, "AGENT", [x for x in hosts if x.id == 0][0])
        # This service is started later on
        # check.status_for_command("Starting Flume Agent", service.start())


def setup_hdfs_ha():
    """
    Setup hdfs-ha
    :return:
    """
    # api = ApiResource(cmx.cm_server, username=cmx.username, password=cmx.password, version=6)
    # cluster = api.get_cluster(cmx.cluster_name)
    try:
        print "> Setup HDFS-HA"
        hdfs = cdh.get_service_type('HDFS')
        zookeeper = cdh.get_service_type('ZOOKEEPER')

        # Requirement Hive/Hue
        hive = cdh.get_service_type('HIVE')
        hue = cdh.get_service_type('HUE')
        hosts = management.get_hosts()

        nn=[x for x in hosts if x.id == 0 ][0]
        snn=[x for x in hosts if x.id == 1 ][0]
        cm=management.get_cmhost()

        if len(hdfs.get_roles_by_type("NAMENODE")) != 2:
            # QJM require 3 nodes
            jn = random.sample([x.hostRef.hostId for x in hdfs.get_roles_by_type("DATANODE")], 3)
            # get NAMENODE and SECONDARYNAMENODE hostId
            nn_host_id = hdfs.get_roles_by_type("NAMENODE")[0].hostRef.hostId
            sndnn_host_id = hdfs.get_roles_by_type("SECONDARYNAMENODE")[0].hostRef.hostId

            # Occasionally SECONDARYNAMENODE is also installed on the NAMENODE
            if nn_host_id == sndnn_host_id:
                standby_host_id = random.choice([x.hostId for x in jn if x.hostId not in [nn_host_id, sndnn_host_id]])
            elif nn_host_id is not sndnn_host_id:
                standby_host_id = sndnn_host_id
            else:
                standby_host_id = random.choice([x.hostId for x in hosts if x.hostId is not nn_host_id])

            # hdfs-JOURNALNODE - Default Group
            role_group = hdfs.get_role_config_group("%s-JOURNALNODE-BASE" % hdfs.name)
            role_group.update_config({"dfs_journalnode_edits_dir": "/data/dfs/jn"})

            cmd = hdfs.enable_nn_ha(hdfs.get_roles_by_type("NAMENODE")[0].name, standby_host_id,
                                    "nameservice1", [dict(jnHostId=nn_host_id), dict(jnHostId=sndnn_host_id), dict(jnHostId=cm.hostId)],
                                    zk_service_name=zookeeper.name)
            check.status_for_command("Enable HDFS-HA - [ http://%s:7180/cmf/command/%s/details ]" %
                                     (socket.getfqdn(cmx.cm_server), cmd.id), cmd)

            # hdfs-HTTPFS
            cdh.create_service_role(hdfs, "HTTPFS", [x for x in hosts if x.id == 0][0])
            # Configure HUE service dependencies
            cdh(*['HDFS', 'HIVE', 'HUE', 'ZOOKEEPER']).stop()
            if hue is not None:
                hue.update_config(cdh.dependencies_for(hue))
            if hive is not None:
                check.status_for_command("Update Hive Metastore NameNodes", hive.update_metastore_namenodes())
            cdh(*['ZOOKEEPER', 'HDFS', 'HIVE', 'HUE']).start()

    except ApiException as err:
        print " ERROR: %s" % err.message


def setup_yarn_ha():
    """
    Setup yarn-ha
    :return:
    """
    # api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    # cluster = api.get_cluster(cmx.cluster_name)
    print "> Setup YARN-HA"
    yarn = cdh.get_service_type('YARN')
    zookeeper = cdh.get_service_type('ZOOKEEPER')
    hosts = management.get_hosts()
    # hosts = api.get_all_hosts()
    if len(yarn.get_roles_by_type("RESOURCEMANAGER")) != 2:
        # Choose secondary name node for standby RM
        rm = [x for x in hosts if x.id == 1 ][0]

        cmd = yarn.enable_rm_ha(rm.hostId, zookeeper.name)
        check.status_for_command("Enable YARN-HA - [ http://%s:7180/cmf/command/%s/details ]" %
                                 (socket.getfqdn(cmx.cm_server), cmd.id), cmd)


def setup_kerberos():
    """
    Setup Kerberos - work in progress
    :return:
    """
    # api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    # cluster = api.get_cluster(cmx.cluster_name)
    print "> Setup Kerberos"
    hdfs = cdh.get_service_type('HDFS')
    zookeeper = cdh.get_service_type('ZOOKEEPER')
    hue = cdh.get_service_type('HUE')
    hosts = management.get_hosts()

    # HDFS Service-Wide
    hdfs.update_config({"hadoop_security_authentication": "kerberos", "hadoop_security_authorization": True})

    # hdfs-DATANODE-BASE - Default Group
    role_group = hdfs.get_role_config_group("%s-DATANODE-BASE" % hdfs.name)
    role_group.update_config({"dfs_datanode_http_port": "1006", "dfs_datanode_port": "1004",
                              "dfs_datanode_data_dir_perm": "700"})

    # Zookeeper Service-Wide
    zookeeper.update_config({"enableSecurity": True})
    cdh.create_service_role(hue, "KT_RENEWER", [x for x in hosts if x.id == 0][0])


def setup_sentry():
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    service_type = "SENTRY"
    if cdh.get_service_type(service_type) is None:
        service_name = "sentry"
        cluster.create_service(service_name.lower(), service_type)
        service = cluster.get_service(service_name)

        # Service-Wide
        # sentry_server_database_host: Assuming embedded DB is running from where embedded-db is located.
        service_config = {"sentry_server_database_host": socket.getfqdn(cmx.cm_server),
                          "sentry_server_database_user": "sentry",
                          "sentry_server_database_name": "sentry",
                          "sentry_server_database_password": "cloudera",
                          "sentry_server_database_port": "5432",
                          "sentry_server_database_type": "postgresql"}

        service_config.update(cdh.dependencies_for(service))
        service.update_config(service_config)
        hosts = management.get_hosts()

        #Mingrui install sentry to cm host
        cmhost= management.get_cmhost()
        cdh.create_service_role(service, "SENTRY_SERVER", cmhost)
        check.status_for_command("Creating Sentry Database Tables", service.create_sentry_database_tables())

        # Update configuration for Hive service
        hive = cdh.get_service_type('HIVE')
        hive.update_config(cdh.dependencies_for(hive))

        # Disable HiveServer2 Impersonation - hive-HIVESERVER2-BASE - Default Group
        role_group = hive.get_role_config_group("%s-HIVESERVER2-BASE" % hive.name)
        role_group.update_config({"hiveserver2_enable_impersonation": False})

        # This service is started later on
        # check.status_for_command("Starting Sentry Server", service.start())


def setup_easy():
    """
    An example using auto_assign_roles() and auto_configure()
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    cluster = api.get_cluster(cmx.cluster_name)
    print "> Easy setup for cluster: %s" % cmx.cluster_name
    # Do not install these services
    do_not_install = ['KEYTRUSTEE', 'KMS', 'KS_INDEXER', 'ISILON', 'FLUME', 'MAPREDUCE', 'ACCUMULO',
                      'ACCUMULO16', 'SPARK_ON_YARN', 'SPARK', 'SOLR', 'SENTRY']
    service_types = list(set(cluster.get_service_types()) - set(do_not_install))

    for service in service_types:
        cluster.create_service(name=service.lower(), service_type=service.upper())

    cluster.auto_assign_roles()
    cluster.auto_configure()

    # Hive Metastore DB and dependencies ['YARN', 'ZOOKEEPER']
    service = cdh.get_service_type('HIVE')
    service_config = {"hive_metastore_database_host": socket.getfqdn(cmx.cm_server),
                      "hive_metastore_database_user": "hive",
                      "hive_metastore_database_name": "metastore",
                      "hive_metastore_database_password": cmx.hive_password,
                      "hive_metastore_database_port": "5432",
                      "hive_metastore_database_type": "postgresql"}
    service_config.update(cdh.dependencies_for(service))
    service.update_config(service_config)
    check.status_for_command("Executing first run command. This might take a while.", cluster.first_run())



def teardown(keep_cluster=True):
    """
    Teardown the Cluster
    :return:
    """
    api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    try:
        cluster = api.get_cluster(cmx.cluster_name)
        service_list = cluster.get_all_services()
        print "> Teardown Cluster: %s Services and keep_cluster: %s" % (cmx.cluster_name, keep_cluster)
        check.status_for_command("Stop %s" % cmx.cluster_name, cluster.stop())

        for service in service_list[:None:-1]:
            try:
                check.status_for_command("Stop Service %s" % service.name, service.stop())
            except ApiException as err:
                print " ERROR: %s" % err.message

            print "Processing service %s" % service.name
            for role in service.get_all_roles():
                print " Delete role %s" % role.name
                service.delete_role(role.name)

            cluster.delete_service(service.name)
    except ApiException as err:
        print err.message
        exit(1)

    # Delete Management Services
    try:
        mgmt = api.get_cloudera_manager()
        check.status_for_command("Stop Management services", mgmt.get_service().stop())
        mgmt.delete_mgmt_service()
    except ApiException as err:
        print " ERROR: %s" % err.message

    # cluster.remove_all_hosts()
    if not keep_cluster:
        # Remove CDH Parcel and GPL Extras Parcel
        for x in cmx.parcel:
            print "Removing parcel: [ %s-%s ]" % (x['product'], x['version'])
            parcel_product = x['product']
            parcel_version = x['version']

            while True:
                parcel = cluster.get_parcel(parcel_product, parcel_version)
                if parcel.stage == 'ACTIVATED':
                    print "Deactivating parcel"
                    parcel.deactivate()
                else:
                    break

            while True:
                parcel = cluster.get_parcel(parcel_product, parcel_version)
                if parcel.stage == 'DISTRIBUTED':
                    print "Executing parcel.start_removal_of_distribution()"
                    parcel.start_removal_of_distribution()
                    print "Executing parcel.remove_download()"
                    parcel.remove_download()
                elif parcel.stage == 'UNDISTRIBUTING':
                    msg = " [%s: %s / %s]" % (parcel.stage, parcel.state.progress, parcel.state.totalProgress)
                    sys.stdout.write(msg + " " * (78 - len(msg)) + "\r")
                    sys.stdout.flush()
                else:
                    break

        print "Deleting cluster: %s" % cmx.cluster_name
        api.delete_cluster(cmx.cluster_name)



class ManagementActions:
    """
    Example stopping 'ACTIVITYMONITOR', 'REPORTSMANAGER' Management Role
    :param role_list:
    :param action:
    :return:
    """
    def __init__(self, *role_list):
        self._role_list = role_list
        self._api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        self._cm = self._api.get_cloudera_manager()
        try:
            self._service = self._cm.get_service()
        except ApiException:
            self._service = self._cm.create_mgmt_service(ApiServiceSetupInfo())
        self._role_types = [x.type for x in self._service.get_all_roles()]

    def stop(self):
        self._action('stop_roles')

    def start(self):
        self._action('start_roles')

    def restart(self):
        self._action('restart_roles')

    def _action(self, action):
        state = {'start_roles': ['STOPPED'], 'stop_roles': ['STARTED'], 'restart_roles': ['STARTED', 'STOPPED']}
        for mgmt_role in [x for x in self._role_list if x in self._role_types]:
            for role in [x for x in self._service.get_roles_by_type(mgmt_role) if x.roleState in state[action]]:
                for cmd in getattr(self._service, action)(role.name):
                    check.status_for_command("%s role %s" % (action.split("_")[0].upper(), mgmt_role), cmd)

    def setup(self):
        """
        Setup Management Roles
        'ACTIVITYMONITOR', 'ALERTPUBLISHER', 'EVENTSERVER', 'HOSTMONITOR', 'SERVICEMONITOR'
        Requires License: 'NAVIGATOR', 'NAVIGATORMETASERVER', 'REPORTSMANAGER"
        :return:
        """
        # api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        print "> Setup Management Services"
        self._cm.update_config({"TSQUERY_STREAMS_LIMIT": 1000})
        hosts = management.get_hosts(include_cm_host=True)
        # pick hostId that match the ipAddress of cm_server
        # mgmt_host may be empty then use the 1st host from the -w
        try:
            mgmt_host = [x for x in hosts if x.ipAddress == socket.gethostbyname(cmx.cm_server)][0]
        except IndexError:
            mgmt_host = [x for x in hosts if x.id == 0][0]

        for role_type in [x for x in self._service.get_role_types() if x in self._role_list]:
            try:
                if not [x for x in self._service.get_all_roles() if x.type == role_type]:
                    print "Creating Management Role %s " % role_type
                    role_name = "mgmt-%s-%s" % (role_type, mgmt_host.md5host)
                    for cmd in self._service.create_role(role_name, role_type, mgmt_host.hostId).get_commands():
                        check.status_for_command("Creating %s" % role_name, cmd)
            except ApiException as err:
                print "ERROR: %s " % err.message

        # now configure each role
        for group in [x for x in self._service.get_all_role_config_groups() if x.roleType in self._role_list]:
            if group.roleType == "ACTIVITYMONITOR":
                group.update_config({"firehose_database_host": "%s:5432" % socket.getfqdn(cmx.cm_server),
                                     "firehose_database_user": "amon",
                                     "firehose_database_password": cmx.amon_password,
                                     "firehose_database_type": "postgresql",
                                     "firehose_database_name": "amon",
                                     "mgmt_log_dir": LOG_DIR+"/cloudera-scm-firehose",
                                     "firehose_heapsize": "215964392"})
            elif group.roleType == "ALERTPUBLISHER":
                group.update_config({"mgmt_log_dir": LOG_DIR+"/cloudera-scm-alertpublisher"})
            elif group.roleType == "EVENTSERVER":
                group.update_config({"event_server_heapsize": "215964392",
                                     "mgmt_log_dir": LOG_DIR+"/cloudera-scm-eventserver",
                                     "eventserver_index_dir": LOG_DIR+"/lib/cloudera-scm-eventserver"})
            elif group.roleType == "HOSTMONITOR":
                group.update_config({"mgmt_log_dir": LOG_DIR+"/cloudera-scm-firehose",
                                     "firehose_storage_dir": LOG_DIR+"/lib/cloudera-host-monitor"})
            elif group.roleType == "SERVICEMONITOR":
                group.update_config({"mgmt_log_dir": LOG_DIR+"/cloudera-scm-firehose",
                                     "firehose_storage_dir": LOG_DIR+"/lib/cloudera-service-monitor"})
            elif group.roleType == "NAVIGATOR" and management.licensed():
                group.update_config({})
            elif group.roleType == "NAVIGATORMETADATASERVER" and management.licensed():
                group.update_config({})
            elif group.roleType == "REPORTSMANAGER" and management.licensed():
                group.update_config({"headlamp_database_host": "%s:5432" % socket.getfqdn(cmx.cm_server),
                                     "headlamp_database_name": "rman",
                                     "headlamp_database_password": cmx.rman_password,
                                     "headlamp_database_type": "postgresql",
                                     "headlamp_database_user": "rman",
                                     "headlamp_scratch_dir": LOG_DIR+"/lib/cloudera-scm-headlamp",
                                     "mgmt_log_dir": LOG_DIR+"/cloudera-scm-headlamp"})
            elif group.roleType == "OOZIE":
                group.update_config({"oozie_database_host": "%s:5432" % socket.getfqdn(cmx.cm_server),
                                     "oozie_database_name": "oozie",
                                     "oozie_database_password": cmx.oozie_password,
                                     "oozie_database_type": "postgresql",
                                     "oozie_database_user": "oozie",
                                     "oozie_log_dir": LOG_DIR+"/oozie" })

    @classmethod
    def licensed(cls):
        """
        Check if Cluster is licensed
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        cm = api.get_cloudera_manager()
        try:
            return bool(cm.get_license().uuid)
        except ApiException as err:
            return "Express" not in err.message

    @classmethod
    def upload_license(cls):
        """
        Upload License file
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        cm = api.get_cloudera_manager()
        if cmx.license_file and not management.licensed():
            print "Upload license"
            with open(cmx.license_file, 'r') as f:
                license_contents = f.read()
                print "Upload CM License: \n %s " % license_contents
                cm.update_license(license_contents)
                # REPORTSMANAGER required after applying license
                management("REPORTSMANAGER").setup()
                management("REPORTSMANAGER").start()

    @classmethod
    def begin_trial(cls):
        """
        Begin Trial
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        print "def begin_trial"
        if not management.licensed():
            try:
                api.post("/cm/trial/begin")
                # REPORTSMANAGER required after applying license
                management("REPORTSMANAGER").setup()
                management("REPORTSMANAGER").start()
            except ApiException as err:
                print err.message

    @classmethod
    def get_mgmt_password(cls, role_type):
        """
        Get password for "ACTIVITYMONITOR', 'REPORTSMANAGER', 'NAVIGATOR", "OOZIE", "HIVEMETASTORESERVER"
        :param role_type:
        :return:
        """
        contents = []
        mgmt_password = False

        if os.path.exists('/etc/cloudera-scm-server'):
            file_path = os.path.join('/etc/cloudera-scm-server', 'db.mgmt.properties')
            try:
                with open(file_path) as f:
                    contents = f.readlines()
            except IOError:
                print "Unable to open file %s." % file_path

        # role_type expected to be in
        # ACTIVITYMONITOR, REPORTSMANAGER, NAVIGATOR, OOZIE, HIVEMETASTORESERVER
        if role_type in ['ACTIVITYMONITOR', 'REPORTSMANAGER', 'NAVIGATOR','OOZIE','HIVEMETASTORESERVER']:
            idx = "com.cloudera.cmf.%s.db.password=" % role_type
            match = [s.rstrip('\n') for s in contents if idx in s][0]
            mgmt_password = match[match.index(idx) + len(idx):]

        return mgmt_password
    
    @classmethod
    def get_cmhost(cls):
        """
        return cm host in the same format as other host
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)

        idx = len(set(enumerate(cmx.host_names)))

        
        _host = [x for x in api.get_all_hosts() if x.ipAddress == socket.gethostbyname(cmx.cm_server)][0]
        cmhost={
            'id': idx,
            'hostId': _host.hostId,
            'hostname': _host.hostname,
            'md5host': hashlib.md5(_host.hostname).hexdigest(),
            'ipAddress': _host.ipAddress,
        }

        return type('', (), cmhost)

    @classmethod
    def get_hosts(cls, include_cm_host=False):
        """
        because api.get_all_hosts() returns all the hosts as instanceof ApiHost: hostId hostname ipAddress
        and cluster.list_hosts() returns all the cluster hosts as instanceof ApiHostRef: hostId
        we only need Cluster hosts with instanceof ApiHost: hostId hostname ipAddress + md5host
        preserve host order in -w
        hashlib.md5(host.hostname).hexdigest()
        attributes = {'id': None, 'hostId': None, 'hostname': None, 'md5host': None, 'ipAddress': None, }
        return a list of hosts
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)

        w_hosts = set(enumerate(cmx.host_names))
        if include_cm_host and socket.gethostbyname(cmx.cm_server) \
                not in [socket.gethostbyname(x) for x in cmx.host_names]:
            w_hosts.add((len(w_hosts), cmx.cm_server))

        hosts = []
        for idx, host in w_hosts:
            _host = [x for x in api.get_all_hosts() if x.ipAddress == socket.gethostbyname(host)][0]
            hosts.append({
                'id': idx,
                'hostId': _host.hostId,
                'hostname': _host.hostname,
                'md5host': hashlib.md5(_host.hostname).hexdigest(),
                'ipAddress': _host.ipAddress,
            })

        return [type('', (), x) for x in hosts]

    @classmethod
    def restart_management(cls):
        """
        Restart Management Services
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        mgmt = api.get_cloudera_manager().get_service()

        check.status_for_command("Stop Management services", mgmt.stop())
        check.status_for_command("Start Management services", mgmt.start())


class ServiceActions:
    """
    Example stopping/starting services ['HBASE', 'IMPALA', 'SPARK', 'SOLR']
    :param service_list:
    :param action:
    :return:
    """
    def __init__(self, *service_list):
        self._service_list = service_list
        self._api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        self._cluster = self._api.get_cluster(cmx.cluster_name)

    def stop(self):
        self._action('stop')

    def start(self):
        self._action('start')

    def restart(self):
        self._action('restart')

    def _action(self, action):
        state = {'start': ['STOPPED'], 'stop': ['STARTED'], 'restart': ['STARTED', 'STOPPED']}
        for services in [x for x in self._cluster.get_all_services()
                         if x.type in self._service_list and x.serviceState in state[action]]:
            check.status_for_command("%s service %s" % (action.upper(), services.type),
                                     getattr(self._cluster.get_service(services.name), action)())

    @classmethod
    def get_service_type(cls, name):
        """
        Returns service based on service type name
        :param name:
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        cluster = api.get_cluster(cmx.cluster_name)
        try:
            service = [x for x in cluster.get_all_services() if x.type == name][0]
        except IndexError:
            service = None

        return service

    @classmethod
    def deploy_client_config_for(cls, obj):
        """
        Example deploying GATEWAY Client Config on each host
        Note: only recommended if you need to deploy on a specific hostId.
        Use the cluster.deploy_client_config() for normal use.
        example usage:
        # hostId
        for host in get_cluster_hosts(include_cm_host=True):
            deploy_client_config_for(host.hostId)

        # cdh service
        for service in cluster.get_all_services():
            deploy_client_config_for(service)

        :param host.hostId, or ApiService:
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        # cluster = api.get_cluster(cmx.cluster_name)
        if isinstance(obj, str) or isinstance(obj, unicode):
            for role_name in [x.roleName for x in api.get_host(obj).roleRefs if 'GATEWAY' in x.roleName]:
                service = cdh.get_service_type('GATEWAY')
                print "Deploying client config for service: %s - host: [%s]" % \
                      (service.type, api.get_host(obj).hostname)
                check.status_for_command("Deploy client config for role %s" %
                                         role_name, service.deploy_client_config(role_name))
        elif isinstance(obj, ApiService):
            for role in obj.get_roles_by_type("GATEWAY"):
                check.status_for_command("Deploy client config for role %s" %
                                         role.name, obj.deploy_client_config(role.name))

    @classmethod
    def create_service_role(cls, service, role_type, host):
        """
        Helper function to create a role
        :return:
        """
        service_name = service.name[:4] + hashlib.md5(service.name).hexdigest()[:8] \
            if len(role_type) > 24 else service.name

        role_name = "-".join([service_name, role_type, host.md5host])[:64]
        print "Creating role: %s on host: [%s]" % (role_name, host.hostname)
        for cmd in service.create_role(role_name, role_type, host.hostId).get_commands():
            check.status_for_command("Creating role: %s on host: [%s]" % (role_name, host.hostname), cmd)

    @classmethod
    def restart_cluster(cls):
        """
        Restart Cluster and Cluster wide deploy client config
        :return:
        """
        api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
        cluster = api.get_cluster(cmx.cluster_name)
        print "Restart cluster: %s" % cmx.cluster_name
        check.status_for_command("Stop %s" % cmx.cluster_name, cluster.stop())
        check.status_for_command("Start %s" % cmx.cluster_name, cluster.start())
        # Example deploying cluster wide Client Config
        check.status_for_command("Deploy client config for %s" % cmx.cluster_name, cluster.deploy_client_config())

    @classmethod
    def dependencies_for(cls, service):
        """
        Utility function returns dict of service dependencies
        :return:
        """
        service_config = {}
        config_types = {"hue_webhdfs": ['NAMENODE', 'HTTPFS'], "hdfs_service": "HDFS", "sentry_service": "SENTRY",
                        "zookeeper_service": "ZOOKEEPER", "hbase_service": "HBASE", "solr_service": "SOLR",
                        "hive_service": "HIVE", "sqoop_service": "SQOOP",
                        "impala_service": "IMPALA", "oozie_service": "OOZIE",
                        "mapreduce_yarn_service": ['MAPREDUCE', 'YARN'], "yarn_service": "YARN"}

        dependency_list = []
        # get required service config
        for k, v in service.get_config(view="full")[0].items():
            if v.required:
                dependency_list.append(k)

        # Extended dependence list, adding the optional ones as well
        if service.type == 'HUE':
            dependency_list.extend(['sqoop_service',
                                    'impala_service'])
        if service.type in ['HIVE', 'HDFS', 'HUE', 'HBASE', 'OOZIE', 'MAPREDUCE', 'YARN']:
            dependency_list.append('zookeeper_service')
#        if service.type in ['HIVE']:
#            dependency_list.append('sentry_service')
        if service.type == 'OOZIE':
            dependency_list.append('hive_service')
#        if service.type in ['FLUME', 'IMPALA']:
#            dependency_list.append('hbase_service')
        if service.type in ['FLUME', 'SPARK', 'SENTRY']:
            dependency_list.append('hdfs_service')
#        if service.type == 'FLUME':
#            dependency_list.append('solr_service')

        for key in dependency_list:
            if key == "hue_webhdfs":
                hdfs = cdh.get_service_type('HDFS')
                if hdfs is not None:
                    service_config[key] = [x.name for x in hdfs.get_roles_by_type('NAMENODE')][0]
                    # prefer HTTPS over NAMENODE
                    if [x.name for x in hdfs.get_roles_by_type('HTTPFS')]:
                        service_config[key] = [x.name for x in hdfs.get_roles_by_type('HTTPFS')][0]
            elif key == "mapreduce_yarn_service":
                for _type in config_types[key]:
                    if cdh.get_service_type(_type) is not None:
                        service_config[key] = cdh.get_service_type(_type).name
                    # prefer YARN over MAPREDUCE
                    if cdh.get_service_type(_type) is not None and _type == 'YARN':
                        service_config[key] = cdh.get_service_type(_type).name
            elif key == "hue_hbase_thrift":
                hbase = cdh.get_service_type('HBASE')
                if hbase is not None:
                    service_config[key] = [x.name for x in hbase.get_roles_by_type(config_types[key])][0]
            else:
                if cdh.get_service_type(config_types[key]) is not None:
                    service_config[key] = cdh.get_service_type(config_types[key]).name

        return service_config


class ActiveCommands:
    def __init__(self):
        self._api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)

    def status_for_command(self, message, command):
        """
        Helper to check active command status
        :param message:
        :param command:
        :return:
        """
        _state = 0
        _bar = ['[|]', '[/]', '[-]', '[\\]']
        while True:
            if self._api.get("/commands/%s" % command.id)['active']:
                sys.stdout.write(_bar[_state] + ' ' + message + ' ' + ('\b' * (len(message) + 5)))
                sys.stdout.flush()
                _state += 1
                if _state > 3:
                    _state = 0
                time.sleep(2)
            else:
                print "\n [%s] %s" % (command.id, self._api.get("/commands/%s" % command.id)['resultMessage'])
                self._child_cmd(self._api.get("/commands/%s" % command.id)['children']['items'])
                break

    def _child_cmd(self, cmd):
        """
        Helper cmd has child objects
        :param cmd:
        :return:
        """
        if len(cmd) != 0:
            print " Sub tasks result(s):"
            for resMsg in cmd:
                if resMsg.get('resultMessage'):
                    print "  [%s] %s" % (resMsg['id'], resMsg['resultMessage']) if not resMsg.get('roleRef') \
                        else "  [%s] %s - %s" % (resMsg['id'], resMsg['resultMessage'], resMsg['roleRef']['roleName'])
                self._child_cmd(self._api.get("/commands/%s" % resMsg['id'])['children']['items'])

def display_eula():

    fname=raw_input("Please enter your first name: ")
    lname=raw_input("Please enter your last name: ")
    company=raw_input("Please enter your company: ")
    email=raw_input("Please enter your email: ")
    phone=raw_input("Please enter your phone: ")
    jobrole=raw_input("Please enter your jobrole: ")
    jobfunction=raw_input("Please enter your jobfunction: ")
    accepted=raw_input("Please enter yes to accept EULA: ")
    if accepted =='yes' and fname and lname and company and email and phone and jobrole and jobfunction:
       postEulaInfo(fname, lname, email, company,
                    jobrole, jobfunction, phone)
       return True
    else:
        return False


def parse_options():
    global cmx
    global check, cdh, management

    cmx_config_options = {'ssh_root_password': None, 'ssh_root_user': 'root', 'ssh_private_key': None,
                          'cluster_name': 'Cluster 1', 'cluster_version': 'CDH5',
                          'username': 'cmadmin', 'password': 'cmpassword', 'cm_server': None,
                          'host_names': None, 'license_file': None, 'parcel': [], 'company': None,
                          'email': None, 'phone': None, 'fname': None, 'lname': None, 'jobrole': None,
                          'jobfunction': None, 'vmsize': None,'do_post':True}

    def cmx_args(option, opt_str, value, *args, **kwargs):
        if option.dest == 'host_names':
            print "switch %s value check: %s" % (opt_str, value)
            for host in value.split(','):
                if not hostname_resolves(host):
                    exit(1)
            else:
                cmx_config_options[option.dest] = [socket.gethostbyname(x) for x in value.split(',')]
        elif option.dest == 'cm_server':
            print "switch %s value check: %s" % (opt_str, value)

            cmx_config_options[option.dest] = socket.gethostbyname(value) if \
                hostname_resolves(value) else exit(1)
            retry_count = 5
            while retry_count > 0:
                s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                if not s.connect_ex((socket.gethostbyname(value), 7180)) == 0:
                    print "Cloudera Manager Server is not started on %s " % value
                    s.close()
                    sleep(60)
                else:
                    break
                retry_count -= 1
            if retry_count == 0:
                print "Couldn't connect to Cloudera Manager after 5 minutes, exiting"
                exit(1)
        elif option.dest == 'ssh_private_key':
            with open(value, 'r') as f:
                license_contents = f.read()
            cmx_config_options[option.dest] = license_contents
        else:
            cmx_config_options[option.dest] = value

    def hostname_resolves(hostname):
        """
        Check if hostname resolves
        :param hostname:
        :return:
        """
        try:
            if socket.gethostbyname(hostname) == '0.0.0.0':
                print "Error [{'host': '%s', 'fqdn': '%s'}]" % \
                      (socket.gethostbyname(hostname), socket.getfqdn(hostname))
                return False
            else:
                print "Success [{'host': '%s', 'fqdn': '%s'}]" % \
                      (socket.gethostbyname(hostname), socket.getfqdn(hostname))
                return True
        except socket.error:
            print "Error 'host': '%s'" % hostname
            return False

    def manifest_to_dict(manifest_json):
        if manifest_json:
            dir_list = json.load(
                urllib2.urlopen(manifest_json))['parcels'][0]['parcelName']
            parcel_part = re.match(r"^(.*?)-(.*)-(.*?)$", dir_list).groups()
            return {'product': str(parcel_part[0]).upper(), 'version': str(parcel_part[1]).lower()}
        else:
            raise Exception("Invalid manifest.json")

    parser = OptionParser()
    parser.add_option('-m', '--cm-server', dest='cm_server', type="string", action='callback', callback=cmx_args,
                      help='*Set Cloudera Manager Server Host. '
                           'Note: This is the host where the Cloudera Management Services get installed.')
    parser.add_option('-w', '--host-names', dest='host_names', type="string", action='callback',
                      callback=cmx_args,
                      help='*Set target node(s) list, separate with comma eg: -w host1,host2,...,host(n). '
                           'Note:'
                           ' - enclose in double quote, also avoid leaving spaces between commas.'
                           ' - CM_SERVER excluded in this list, if you want install CDH Services in CM_SERVER'
                           ' add the host to this list.')
    parser.add_option('-n', '--cluster-name', dest='cluster_name', type="string", action='callback',
                      callback=cmx_args, default='Cluster 1',
                      help='Set Cloudera Manager Cluster name enclosed in double quotes. Default "Cluster 1"')
    parser.add_option('-u', '--ssh-root-user', dest='ssh_root_user', type="string", action='callback',
                      callback=cmx_args, default='root', help='Set target node(s) ssh username. Default root')
    parser.add_option('-p', '--ssh-root-password', dest='ssh_root_password', type="string", action='callback',
                      callback=cmx_args, help='*Set target node(s) ssh password..')
    parser.add_option('-k', '--ssh-private-key', dest='ssh_private_key', type="string", action='callback',
                      callback=cmx_args, help='The private key to authenticate with the hosts. '
                                              'Specify either this or a password.')
    parser.add_option('-l', '--license-file', dest='license_file', type="string", action='callback',
                      callback=cmx_args, help='Cloudera Manager License file name')
    parser.add_option('-d', '--teardown', dest='teardown', action="store", type="string",
                      help='Teardown Cloudera Manager Cluster. Required arguments "keep_cluster" or "remove_cluster".')
    parser.add_option('-a', '--highavailable', dest='highAvailability', action="store_true", default=False,
                      help='Create a High Availability cluster')
    parser.add_option('-c', '--cm-user', dest='username', type="string", action='callback',
                      callback=cmx_args, help='Set Cloudera Manager Username')
    parser.add_option('-s', '--cm-password', dest='password', type="string", action='callback',
                      callback=cmx_args, help='Set Cloudera Manager Password')
    parser.add_option('-r', '--email-address', dest='email', type="string", action='callback',
                      callback=cmx_args, help='Set email address')
    parser.add_option('-b', '--business-phone', dest='phone', type="string", action='callback',
                      callback=cmx_args, help='Set phone')
    parser.add_option('-f', '--first-name', dest='fname', type="string", action='callback',
                      callback=cmx_args, help='Set first name')
    parser.add_option('-t', '--last-name', dest='lname', type="string", action='callback',
                      callback=cmx_args, help='Set last name')
    parser.add_option('-o', '--job-role', dest='jobrole', type="string", action='callback',
                      callback=cmx_args, help='Set job role')
    parser.add_option('-i', '--job-function', dest='jobfunction', type="string", action='callback',
                      callback=cmx_args, help='Set job function')
    parser.add_option('-y', '--company', dest='company', type="string", action='callback',
                      callback=cmx_args, help='Set company')
    parser.add_option('-e', '--accept-eula', dest='accepted', action="store_true", default=False,
                      help='Must accept eula before install')
    parser.add_option('-v', '--vmsize', dest='vmsize', type="string", action="callback",
                      callback=cmx_args, help='provide vmsize for setup')

    (options, args) = parser.parse_args()

    # Install CDH5 latest version
    cmx_config_options['parcel'].append(manifest_to_dict(
        'http://archive.cloudera.com/cdh5/parcels/5/manifest.json'))

    # Install GPLEXTRAS5 latest version
    cmx_config_options['parcel'].append(manifest_to_dict(
        'http://archive.cloudera.com/gplextras5/parcels/5/manifest.json'))

    msg_req_args = "Please specify the required arguments: "
    if cmx_config_options['cm_server'] is None:
        parser.error(msg_req_args + "-m/--cm-server")
    else:
        if not (cmx_config_options['ssh_private_key'] or cmx_config_options['ssh_root_password']):
            parser.error(msg_req_args + "-p/--ssh-root-password or -k/--ssh-private-key")
        elif cmx_config_options['host_names'] is None:
            parser.error(msg_req_args + "-w/--host-names")
        elif cmx_config_options['ssh_private_key'] and cmx_config_options['ssh_root_password']:
            parser.error(msg_req_args + "-p/--ssh-root-password _OR_ -k/--ssh-private-key")
    if (cmx_config_options['email'] is None or cmx_config_options['phone'] is None or
        cmx_config_options['fname'] is None or cmx_config_options['lname'] is None or
        cmx_config_options['jobrole'] is None or cmx_config_options['jobfunction'] is None or
        cmx_config_options['company'] is None or
        options.accepted is not True):

        eula_result=display_eula()
        if(eula_result):
            cmx_config_options['do_post']=False
        else:
            parser.error(msg_req_args + 'please provide email, phone, firstname, lastname, jobrole, jobfunction, company and accept eula'+
                         '-r/--email-address, -b/--business-phone, -f/--first-name, -t/--last-name, -o/--job-role, -i/--job-function,'+
                         '-y/--company, -e/--accept-eula')

    # Management services password. They are required when adding Management services
    management = ManagementActions
    if not (bool(management.get_mgmt_password("ACTIVITYMONITOR"))
            and bool(management.get_mgmt_password("REPORTSMANAGER"))):
        exit(1)
    else:
        cmx_config_options['amon_password'] = management.get_mgmt_password("ACTIVITYMONITOR")
        cmx_config_options['rman_password'] = management.get_mgmt_password("REPORTSMANAGER")
        cmx_config_options['oozie_password'] = management.get_mgmt_password("OOZIE")
        cmx_config_options['hive_password'] = management.get_mgmt_password("HIVEMETASTORESERVER")

    cmx = type('', (), cmx_config_options)
    check = ActiveCommands()
    cdh = ServiceActions
    if cmx_config_options['cm_server'] and options.teardown:
        if options.teardown.lower() in ['remove_cluster', 'keep_cluster']:
            teardown(keep_cluster=(options.teardown.lower() == 'keep_cluster'))
            print "Bye!"
            exit(0)
        else:
            print 'Teardown Cloudera Manager Cluster. Required arguments "keep_cluster" or "remove_cluster".'
            exit(1)

    # Uncomment here to see cmx configuration options
    # print cmx_config_options
    return options

def log(msg):
    print time.strftime("%X") + ": " + msg

def postEulaInfo(firstName, lastName, emailAddress, company,jobRole, jobFunction, businessPhone):
    elqFormName='Cloudera_Azure_EULA'
    elqSiteID='1465054361'
    cid='70134000001PsLS'
    url = 'https://s1465054361.t.eloqua.com/e/f2'
    data = urllib.urlencode({'elqFormName': elqFormName,
                             'elqSiteID': elqSiteID,
                             'cid': cid,
                             'firstName': firstName,
                             'lastName': lastName,
                             'company': company,
                             'emailAddress': emailAddress,
                             'jobRole': jobRole,
                             'jobFunction': jobFunction,
                             'businessPhone': businessPhone
                            })
    results = urllib2.urlopen(url, data)
    with open('results.html', 'w') as f:
        log(results.read())

def main():
    # Parse user options
    log("parse_options")
    options = parse_options()
    global diskcount
    diskcount= getDataDiskCount()
    log("data_disk_count"+`diskcount`)
    if(cmx.do_post):
        postEulaInfo(cmx.fname, cmx.lname, cmx.email, cmx.company,
                     cmx.jobrole, cmx.jobfunction, cmx.phone)
    # Prepare Cloudera Manager Server:
    # 1. Initialise Cluster and set Cluster name: 'Cluster 1'
    # 3. Add hosts into: 'Cluster 1'
    # 4. Deploy latest parcels into : 'Cluster 1'
    log("init_cluster")
    init_cluster()
    log("add_hosts_to_cluster")
    add_hosts_to_cluster()
    # Deploy CDH Parcel
    log("deploy_parcel")
    deploy_parcel(parcel_product=cmx.parcel[0]['product'],
                  parcel_version=cmx.parcel[0]['version'])

    log("setup_management")
    # Example CM API to setup Cloudera Manager Management services - not installing 'ACTIVITYMONITOR'
    mgmt_roles = ['SERVICEMONITOR', 'ALERTPUBLISHER', 'EVENTSERVER', 'HOSTMONITOR']
    if management.licensed():
        mgmt_roles.append('REPORTSMANAGER')
    management(*mgmt_roles).setup()
    # "START" Management roles
    management(*mgmt_roles).start()
    # "STOP" Management roles
    # management_roles(*mgmt_services).stop()

    # Upload license or Begin Trial
    if options.license_file:
        management.upload_license()
    else:
        management.begin_trial()

    # Step-Through - Setup services in order of service dependencies
    # Zookeeper, hdfs, HBase, Solr, Spark, Yarn,
    # Hive, Sqoop, Sqoop Client, Impala, Oozie, Hue
    log("setup_components")
    setup_zookeeper(options.highAvailability)
    setup_hdfs(options.highAvailability)
    setup_yarn(options.highAvailability)
    setup_spark_on_yarn()
    setup_hive()
    setup_impala(options.highAvailability)
    setup_oozie()
    setup_hue()

    #setup_mapreduce(options.highAvailability)

    # Note: setup_easy() is alternative to Step-Through above
    # This this provides an example of alternative method of
    # using CM API to setup CDH services.
    # setup_easy()

    # Example setting hdfs-HA and yarn-HA
    # You can uncomment below after you've setup the CDH services.
    # setup_hdfs_ha()
    # setup_yarn_ha()
        
    #if options.highAvailability:
    #    setup_hdfs_ha()
    #    setup_yarn_ha()

    # Deploy GPL Extra Parcel
    # deploy_parcel(parcel_product=cmx.parcel[1]['product'],parcel_version=cmx.parcel[1]['version'])

    # Restart Cluster and Deploy Cluster wide client config
    log("restart_cluster")
    cdh.restart_cluster()

    # Other examples of CM API
    # eg: "STOP" Services or "START"
    # cdh('HBASE', 'IMPALA', 'SPARK', 'SOLR', 'FLUME').stop()

    # Example restarting Management Service
    # management_role.restart_management()
    # or Restart individual Management Roles
    management(*mgmt_roles).restart()
    # Stop REPORTSMANAGER Management Role
    # management("REPORTSMANAGER").stop()

    # Example setup Kerberos, Sentry
    # setup_kerberos()
    # setup_sentry()

    print "Enjoy!"


if __name__ == "__main__":
    print "%s" % '- ' * 20
    print "Version: %s" % __version__
    print "%s" % '- ' * 20
    main()

    #   def setup_template():
    #     api = ApiResource(server_host=cmx.cm_server, username=cmx.username, password=cmx.password)
    #     cluster = api.get_cluster(cmx.cluster_name)
    #     service_type = ""
    #     if cdh.get_service_type(service_type) is None:
    #         service_name = ""
    #         cluster.create_service(service_name.lower(), service_type)
    #         service = cluster.get_service(service_name)
    #
    #         # Service-Wide
    #         service.update_config(cdh.dependencies_for(service))
    #
    #         hosts = sorted([x for x in api.get_all_hosts()], key=lambda x: x.ipAddress, reverse=False)
    #
    #         # - Default Group
    #         role_group = service.get_role_config_group("%s-x-BASE" % service.name)
    #         role_group.update_config({})
    #         cdh.create_service_role(service, "X", [x for x in hosts if x.id == 0][0])
    #
    #         check.status_for_command("Starting x Service", service.start())
