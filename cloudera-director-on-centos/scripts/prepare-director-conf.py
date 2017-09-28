#! /usr/bin/env python

# Copyright (c) 2016 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This script prepares a base Cloudera Director config file based on user input and then imports
# the config (environment, instance templates and external DB server) into the Cloudera Director
# server.
#

from pyhocon import ConfigFactory
from pyhocon import tool
import commands
import logging
import sys
import os
from optparse import OptionParser

# logging starts
format = "%(asctime)s: %(message)s"
datefmt ='%a %b %d %H:%M:%S %Z %Y'
logFileName = '/var/log/cloudera-azure-initialize.log'
logging.basicConfig(format=format, datefmt=datefmt, filename=logFileName, level=logging.INFO)

DEFAULT_BASE_DIR = "/home"
DEFAULT_BASE_CONF_NAME = "azure.simple.conf"
DEFAULT_CONF_NAME = "azure.simple.expanded.conf"


def execAndLog(command):
    status, output = commands.getstatusoutput(command)
    # Convert command status
    status = os.WEXITSTATUS(status)
    # log command output
    logging.info("Command '%s' \nOutput: %s" % (command, output))
    if status != 0:
        logging.info(command + " has none zero return status: " + str(status))
        logging.info('Prepare and import Azure environment on Cloudera Director server ... Failed')
        sys.exit(status)


def parse_options():
    parser = OptionParser()

    parser.add_option('--envName', dest='env', type="string", help='Environment name')
    parser.add_option('--region', dest='region', type="string", help='Set Azure Region')
    parser.add_option('--subId', dest='subId', type="string", help='Set Azure Subscription ID')
    parser.add_option('--tenantId', dest='tenantId', type="string", help='Set Azure tenant ID')
    parser.add_option('--clientId', dest='clientId', type="string", help='Set Azure client ID')
    parser.add_option('--clientSecret', dest='clientSecret', type="string",
                      help='Set Azure client secret')
    parser.add_option('--username', dest='username', type="string", help='Set key file name')
    parser.add_option('--keyFileName', dest='keyFileName', type="string", help='Set company')
    parser.add_option('--networkSecurityGroupResourceGroup',
                      dest='networkSecurityGroupResourceGroup', type="string",
                      help='Set NetworkSecurityGroup ResourceGroup')
    parser.add_option('--networkSecurityGroup', dest='networkSecurityGroup', type="string",
                      help='Set NetworkSecurityGroup')
    parser.add_option('--virtualNetworkResourceGroup', dest='virtualNetworkResourceGroup',
                      type="string",
                      help='Set virtualNetworkResourceGroup')
    parser.add_option('--virtualNetwork', dest='virtualNetwork', type="string",
                      help='Set virtualNetwork')
    parser.add_option('--subnetName', dest='subnetName', type="string", help='Set subnetName')
    parser.add_option('--computeResourceGroup', dest='computeResourceGroup', type="string",
                      help='Set computeResourceGroup')
    parser.add_option('--hostFqdnSuffix', dest='hostFqdnSuffix', type="string",
                      help='Set hostFqdnSuffix')
    parser.add_option('--dbHostOrIP', dest='dbHostOrIP', type="string", help='Set dbHostOrIP')
    parser.add_option('--dbUsername', dest='dbUsername', type="string", help='Set dbUsername')
    parser.add_option('--dbPassword', dest='dbPassword', type="string", help='Set dbPassword')
    parser.add_option('--masterType', dest='masterType', type="string", help='Set masterType')
    parser.add_option('--workerType', dest='workerType', type="string", help='Set workerType')
    parser.add_option('--edgeType', dest='edgeType', type="string", help='Set edgeType')
    parser.add_option('--dirUsername', dest='dirUsername', type="string", help='Set dirUsername')
    parser.add_option('--dirPassword', dest='dirPassword', type="string", help='Set dirPassword')

    (options, args) = parser.parse_args()

    return options


def setInstanceParameters(conf, section, machineType, networkSecurityGroupResourceGroup,
                          networkSecurityGroup, virtualNetworkResourceGroup,
                          virtualNetwork, subnetName, computeResourceGroup, hostFqdnSuffix):
    conf.put(section + '.type', machineType)
    conf.put(section + '.networkSecurityGroupResourceGroup', networkSecurityGroupResourceGroup)
    conf.put(section + '.networkSecurityGroup', networkSecurityGroup)
    conf.put(section + '.virtualNetworkResourceGroup', virtualNetworkResourceGroup)
    conf.put(section + '.virtualNetwork', virtualNetwork)
    conf.put(section + '.subnetName', subnetName)
    conf.put(section + '.computeResourceGroup', computeResourceGroup)
    conf.put(section + '.hostFqdnSuffix', hostFqdnSuffix)


def generateKeyToFile(keyFileName, username):
    command = 'ssh-keygen -f %s -t rsa -q -N ""' % (keyFileName)
    execAndLog(command)
    execAndLog("chown " + username + " " + keyFileName)
    execAndLog('chmod 644 %s' % (keyFileName))


def prepareAndImportConf(options):
    logging.info('Parsing base config ...')

    conf = ConfigFactory.parse_file(DEFAULT_BASE_CONF_NAME)

    logging.info('Parsing base config ... Successful')

    logging.info('Assigning parameters ...')

    name = options.env
    region = options.region
    subscriptionId = options.subId
    tenantId = options.tenantId
    clientId = options.clientId
    clientSecret = options.clientSecret

    username = options.username
    keyFileName = DEFAULT_BASE_DIR + "/" + username + "/" + options.keyFileName
    generateKeyToFile(keyFileName, username)

    networkSecurityGroupResourceGroup = options.networkSecurityGroupResourceGroup
    networkSecurityGroup = options.networkSecurityGroup
    virtualNetworkResourceGroup = options.virtualNetworkResourceGroup
    virtualNetwork = options.virtualNetwork
    subnetName = options.subnetName
    computeResourceGroup = options.computeResourceGroup
    hostFqdnSuffix = options.hostFqdnSuffix

    dbHostOrIP = options.dbHostOrIP
    dbUsername = options.dbUsername
    dbPassword = options.dbPassword

    masterType = options.masterType.upper()
    workerType = options.workerType.upper()
    edgeType = options.edgeType.upper()

    dirUsername = options.dirUsername
    dirPassword = options.dirPassword

    logging.info('Assigning parameters ... Successful')

    logging.info('Modifying config ...')

    conf.put('name', name)
    conf.put('provider.region', region)
    conf.put('provider.subscriptionId', subscriptionId)
    conf.put('provider.tenantId', tenantId)
    conf.put('provider.clientId', clientId)
    conf.put('provider.clientSecret', clientSecret)

    conf.put('ssh.username', username)
    conf.put('ssh.privateKey', keyFileName)

    setInstanceParameters(conf, 'instances.master', masterType, networkSecurityGroupResourceGroup,
                          networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)
    setInstanceParameters(conf, 'instances.worker', workerType, networkSecurityGroupResourceGroup,
                          networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)
    setInstanceParameters(conf, 'instances.edge', edgeType, networkSecurityGroupResourceGroup,
                          networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)
    setInstanceParameters(conf, 'cloudera-manager.instance', edgeType,
                          networkSecurityGroupResourceGroup, networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)
    setInstanceParameters(conf, 'cluster.masters.instance', masterType,
                          networkSecurityGroupResourceGroup, networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)
    setInstanceParameters(conf, 'cluster.workers.instance', masterType,
                          networkSecurityGroupResourceGroup, networkSecurityGroup,
                          virtualNetworkResourceGroup, virtualNetwork, subnetName,
                          computeResourceGroup, hostFqdnSuffix)

    conf.put('databaseServers.mysqlprod1.host', dbHostOrIP)
    conf.put('databaseServers.mysqlprod1.user', dbUsername)
    conf.put('databaseServers.mysqlprod1.password', dbPassword)

    logging.info('Modifying config ... Successful')

    confLocation = DEFAULT_BASE_DIR + "/" + username + "/" + DEFAULT_CONF_NAME

    logging.info('Writing modified config to %s ...' % confLocation)

    with open(confLocation, "w") as text_file:
        text_file.write(tool.HOCONConverter.to_hocon(conf))

    logging.info('Writing modified config to %s ... Successful' % confLocation)

    logging.info('Importing config to Cloudera Director server ...')

    command = "python setup-default.py --admin-username '%s' --admin-password '%s' '%s'" % (
        dirUsername, dirPassword, confLocation)
    execAndLog(command)

    logging.info('Importing config to Cloudera Director server ... Successful')


def main():
    # Parse user options
    logging.info('Prepare and import Azure environment on Cloudera Director server ...')
    options = parse_options()
    prepareAndImportConf(options)
    logging.info('Prepare and import Azure environment on Cloudera Director server ... Successful')
    # This line marks the end of all VM extension script run.
    logging.info('---------- VM extension scripts completed ----------')
    return 0


if __name__ == "__main__":
    sys.exit(main())
