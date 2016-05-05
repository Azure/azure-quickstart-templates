#!/usr/bin/env python

import subprocess
import socket
import sys

clustername = sys.argv[1]
number_nodes = sys.argv[2]
accountname = sys.argv[3] 
accountkey =  sys.argv[4]

print"inputs:\n"
print "clustername = " + clustername 
print "accontname = " + accountname 
print "accountkey = " + accountkey 

hostname = socket.gethostname()
print "hostname: " + hostname

hostbase = "10.0.2.1"
print "hostbase: " + hostbase


def RunCommand(cmd):
	ret = subprocess.check_output(cmd, shell=True)
	print ret
	return


cmds = ["yum -y install nano",
	"yum -y install java-1.8.0-openjdk.x86_64",
	"curl 'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.7.3.noarch.rpm' -o 'elasticsearch-1.7.3.noarch.rpm'",
	"rpm -ivh elasticsearch-1.7.3.noarch.rpm",
	"systemctl enable elasticsearch.service",
	"/usr/share/elasticsearch/bin/plugin -install royrusso/elasticsearch-HQ",
	"/usr/share/elasticsearch/bin/plugin -install elasticsearch/elasticsearch-cloud-azure/2.8.2"]

print "start running installs"
for cmd in cmds:
	RunCommand(cmd)

print "prep data disk for use"
cmds=["sfdisk /dev/sdc < sdc.layout",
	"mkfs -t ext4 /dev/sdc1",
	"mkdir /data",
	"mount /dev/sdc1 /data"]

for cmd in cmds:
	RunCommand(cmd)

temp = subprocess.check_output("blkid /dev/sdc1", shell=True)
uuid = temp[17:53]

with open("/etc/fstab", "a") as fstab:
    fstab.write("UUID="+uuid+"\t/data\text4\tdefaults\t1\t2\n")

print RunCommand("chmod go+w /data")

datapath = "/data/elastic"

cmds=["mkdir " + datapath,
	"chown -R elasticsearch:elasticsearch " + datapath,
	"chmod 755 " + datapath]
for cmd in cmds:
	RunCommand(cmd)


#re-write conf for heap
sysconf = '/etc/sysconfig/elasticsearch'
RunCommand("mv " + sysconf + " " + sysconf + ".bak")
heapsize="2g"
sysconfig = open(sysconf, 'w')
sysconfig.truncate()
sysconfig.write("ES_HEAP_SIZE=" + heapsize + "\n")
sysconfig.close()

print "start writing elastic config"

# write config
hosts=""
for n in range(0, int(number_nodes)):
	hosts=hosts+hostbase+str(n)+","
hosts=hosts[:-1]


filename = '/etc/elasticsearch/elasticsearch.yml'
RunCommand("mv " + filename + " " + filename + ".bak")
config = open(filename, 'w')
config.truncate()
config.write("cluster.name: " + clustername + "\n")
config.write("node.name: " + hostname + "\n")
config.write("path.data: " + datapath + "\n")
config.write("discovery.zen.ping.multicast.enabled: false\n")
config.write("discovery.zen.ping.unicast.hosts: " + hosts + "\n")
config.write("node.master: true\n")
config.write("node.data: true\n")
config.write("cloud:\n") 
config.write("  azure:\n")
config.write("    storage:\n")
config.write("       account: " + accountname + "\n")
config.write("       key: " + accountkey + "\n")
config.close()

print "finished writing config file" 


RunCommand("systemctl start elasticsearch")
print "elastic install script finished"

