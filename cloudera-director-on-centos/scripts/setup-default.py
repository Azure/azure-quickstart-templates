#! /usr/bin/env python

# Copyright (c) 2015 Cloudera, Inc.
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

# Simple script that shows how to use the Cloudera Director API to initialize
# the environment and instance templates

import argparse
import ConfigParser
import sys
import time
import uuid
import urllib2

from os.path import dirname, isfile, join, realpath
from pyhocon import ConfigFactory
from urllib2 import HTTPError

from cloudera.director.latest.models import (CloudProviderMetadata,
    Environment, InstanceProviderConfig, InstanceTemplate, Login, SshCredentials,
    ExternalDatabaseServerTemplate)

from cloudera.director.common.client import ApiClient
from cloudera.director.latest import (AuthenticationApi, EnvironmentsApi,
    InstanceTemplatesApi, ProviderMetadataApi, DatabaseServersApi)

def get_authenticated_client(args):
    """
    Create a new API client and authenticate against a server as admin

    @param args: dict of parsed command line arguments that
                 include server host and admin credentials

    @rtype:      ApiClient
    @return:     authenticated API client
    """

    # Start by creating a client pointing to the right server
    client = ApiClient(args.server)

    # Authenticate. This will start a session and store the cookie
    auth = AuthenticationApi(client)
    auth.login(Login(username=args.admin_username, password=args.admin_password))

    return client


def create_environment(client, config, provider_type, cloud_provider_metadata):
    """
    Create a new environment with data from the HOCON configuration file

    @param client:                  authenticated API client
    @param config:                  parsed configuration
    @param provider_type:           configured provider type
    @param cloud_provider_metadata: cloud provider metadata for the specified provider type

    @rtype:                         str
    @return:                        name of the created environment
    """

    # Define SSH credentials for this environment

    ssh_config = config.get_config('ssh')
    credentials = configure_ssh_credentials(ssh_config)

    # Define provider

    provider_config = config.get_config('provider')
    merged_provider_config = merge_configs([ssh_config, provider_config])
    provider = configure_provider(merged_provider_config, provider_type, cloud_provider_metadata)

    # Create a new environment object using the credentials and provider

    env = Environment()
    env.name = config.get_string('environmentName', "%s Environment" % config.get_string('name'))
    env.credentials = credentials
    env.provider = provider

    # Post this information to Cloudera Director (to be validated and stored)

    api = EnvironmentsApi(client)
    try:
        api.create(env)

    except HTTPError as e:
        if e.code == 302:
            print "Warning: an environment with the same name already exists"
        else:
            raise e

    print "Environments: %s" % api.list()
    return env.name


def configure_ssh_credentials(ssh_config):
    """
    Create SSH credentials based on the specified configuration

    @param config:                  parsed SSH configuration

    @rtype:                         SshCredentials
    @return:                        ssh credentials
    """

    credentials = SshCredentials()
    # read and set required ssh username from config
    credentials.username = ssh_config.get_string('username')
    # read and set optional password from config
    config_value = ssh_config.get_string('password', '')
    if config_value:
        credentials.password = config_value
    # read and set optional ssh private key from config
    config_value = ssh_config.get_string('privateKey', '')
    if config_value:
        if isfile(config_value):
            with open(config_value) as f:
                credentials.privateKey = f.read()
        else:
            credentials.privateKey = config_value
    # read and set optional ssh private key passphrase from config
    config_value = ssh_config.get_string('passphrase', '')
    if config_value:
        credentials.passphrase = config_value
    # set ssh port from config
    credentials.port = 22
    config_value = ssh_config.get_string('port', '')
    if config_value:
        credentials.port = int(config_value)

    return credentials


def configure_provider(merged_provider_config, provider_type, cloud_provider_metadata):
    """
    Create instance provider configuration based on the specified configuration

    @param merged_provider_config:  merged provider configuration
    @param provider_type:           configured provider type
    @param cloud_provider_metadata: cloud provider metadata for the specified provider type

    @rtype:                         InstanceProviderConfig
    @return:                        instance provider configuration
    """

    provider = InstanceProviderConfig()
    provider.type = provider_type
    if debug:
        print "merged_provider_config: %s" % merged_provider_config
    provider.config = {}

    provider.config.update(get_configuration_property_values(merged_provider_config, cloud_provider_metadata.credentialsProperties))
    provider.config.update(get_configuration_property_values(merged_provider_config, cloud_provider_metadata.configurationProperties))
    for resource_provider_metadata in cloud_provider_metadata.resourceProviders:
        provider.config.update(get_configuration_property_values(merged_provider_config, resource_provider_metadata.configurationProperties))

    if debug:
        print "provider.config: %s" % provider.config
        print "Unknown keys: %s" % (merged_provider_config.viewkeys() - provider.config.viewkeys())

    return provider


def create_instance_templates(client, config, environment_name, provider_type, cloud_provider_metadata):
    """
    Create an instance template with data from the configuration

    @param client:                  authenticated API client
    @param config:                  parsed configuration
    @param environment_name:        name of the environment
    @param provider_type:           configured provider type
    @param cloud_provider_metadata: cloud provider metadata for the specified provider type

    @rtype:                         list
    @return:                        names of the created instance templates
    """

    template_names = []

    ssh_config = config.get_config('ssh')
    provider_config = config.get_config('provider')
    merged_provider_config = merge_configs([ssh_config, provider_config])

    for resource_provider_metadata in cloud_provider_metadata.resourceProviders:
        if resource_provider_metadata.type == 'COMPUTE':
            instance_provider_metadata = resource_provider_metadata
            break
    if instance_provider_metadata is None:
        print "Warning: there is no compute instance provider for provider type: %s" % provider_type
    else:
        template_configs_by_template_name = config.get_config('instances')
        for template_name in template_configs_by_template_name.viewkeys():
            template_config = template_configs_by_template_name.get_config(template_name)
            merged_template_config = merge_configs([merged_provider_config, template_config])
            if debug:
                print "template %s: %s" % (template_name, merged_template_config)
            template = configure_instance_template(merged_template_config, template_name, instance_provider_metadata)
            print "Creating a new instance template: %s ..." % template_name
            create_instance_template(client, environment_name, template)
            template_names.append(template_name)

    return template_names


def configure_instance_template(merged_template_config, template_name, instance_provider_metadata):
    """
    Create an instance template with data from the configuration

    @param merged_template_config:  merged template configuration
    @param template_name:           name of the template
    @param provider_type:           configured provider type
    @param cloud_provider_metadata: cloud provider metadata for the specified provider type

    @rtype:                         InstanceTemplate
    @return:                        instance template configuration
    """

    template = InstanceTemplate()

    template.name = template_name
    # read and set template type from config
    config_value = merged_template_config.get('type', '')
    if config_value:
        template.type = config_value
    # read and set template image from config
    template.image = ''
    config_value = merged_template_config.get('image', '')
    if config_value:
        template.image = config_value
    # read and set optional template ssh username from config
    template.sshUsername = ''
    config_value = merged_template_config.get('sshUsername', '')
    if config_value:
        template.sshUsername = config_value
    # read and set optional template normalize instance flag from config
    template.normalizeInstance = ''
    config_value = merged_template_config.get('normalizeInstance', '')
    if config_value:
        template.normalizeInstance = bool(config_value)
    # read and set optional template bootstrap script from config
    template.bootstrapScript = ''
    config_value = merged_template_config.get('bootstrapScript', '')
    if config_value:
        template.bootstrapScript = config_value
    else:
        # read and set optional template bootstrap script path from config
        config_value = merged_template_config.get('bootstrapScriptPath', '')
        if config_value:
            with open(config_value) as f:
                template.bootstrapScript = f.read()
    # read and set optional template tags from config
    template.tags = {}
    if 'tags' in merged_template_config:
        template.tags.update(merged_template_config.get('tags'))
    # read and set additional template configuration properties from config
    template.config = {}
    template.config.update(get_configuration_property_values(merged_template_config, instance_provider_metadata.templateProperties))

    if debug:
        print "name: %s, type: %s, image: %s, sshUsername: %s, normalizeInstance: %s, bootstrapScript: %s, tags: %s" % \
            (template.name, template.type, template.image, template.sshUsername, template.normalizeInstance, template.bootstrapScript, template.tags)
        print "template.config: %s" % template.config
        print "Unknown keys: %s" % (merged_template_config.viewkeys() - template.config.viewkeys())

    return template


def create_instance_template(client, environment_name, template):
    """
    Create an instance template with data from the configuration

    @param client:           authenticated API client
    @param environment_name: name of the environment
    @param template:         template

    @rtype:                  str
    @return:                 names of the created instance template
    """

    api = InstanceTemplatesApi(client)
    try:
        api.create(environment_name, template)

    except HTTPError as e:
        if e.code == 302:
            print "Warning: an instance template with the same name already exists"
        else:
            raise e

    return template.name


def add_existing_external_db_servers(client, config, environment_name):
    """
    Add existing external DB servers with data from the configuration

    @param client:           authenticated API client
    @param config:           parsed configuration
    @param environment_name: name of the environment
    :return:                 the external DB server config template names
    """

    db_server_names = []

    ssh_config = config.get_config('ssh')
    provider_config = config.get_config('provider')
    merged_provider_config = merge_configs([ssh_config, provider_config])

    db_configs_by_db_name = config.get_config('databaseServers')
    for db_name in db_configs_by_db_name.viewkeys():
        db_config = db_configs_by_db_name.get_config(db_name)
        if is_existing_db_server(db_config):
            merged_db_config = merge_configs([merged_provider_config, db_config])
            if debug:
                print "external db %s: %s" % (db_name, merged_db_config)
            db_server_template = configure_external_db_server(merged_db_config, db_name)
            print "Adding an existing external DB server: %s ..." % db_name
            create_external_db_server(client, environment_name, db_server_template)
            db_server_names.append(db_name)
        else:
            print "External DB server config template %s is not referring to an existing server" \
                  % db_name

    return db_server_names


def is_existing_db_server(db_server_config):
    """
    Check if an external DB server config template is referring to an existing external DB server.
    If a DB server config template has host and port defined, it is referring to an existing server.
    :param db_server_config: External DB server config template
    :return: True if the External DB server config template is referring to an existing DB server
    """
    return db_server_config.get('host') and db_server_config.get('port')


def configure_external_db_server(db_server_config, db_name):
    """
    Create a External DB server config

    :param db_server_config: external DB configuration data
    :param db_name           external DB name
    :return:                 external DB configuration
    """
    db_server_template = ExternalDatabaseServerTemplate()

    db_server_template.name = db_name
    # read and set db hostname from config
    config_value = db_server_config.get('host', '')
    if config_value:
        db_server_template.hostname = config_value
    # read and set db port from config
    config_value = db_server_config.get('port', '')
    if config_value:
        db_server_template.port = config_value
    # read and set db username from config
    config_value = db_server_config.get('user', '')
    if config_value:
        db_server_template.username = config_value
    # read and set db password from config
    config_value = db_server_config.get('password', '')
    if config_value:
        db_server_template.password = config_value
    # read and set db type from config
    config_value = db_server_config.get('type', '')
    if config_value:
        # XXX DB type is case sensitive and must be ALL CAPS
        db_server_template.type = config_value.upper()

    if debug:
        print "name: %s, hostname: %s, port: %s, username: %s, type: %s" % \
            (db_name, db_server_template.hostname, db_server_template.port,
             db_server_template.username, db_server_template.type)

    return db_server_template


def create_external_db_server(client, environment_name, db_server):
    """
    API call to create an external DB server with DB server config template

    :param client:           authenticated API client
    :param environment_name: name of the environment
    :param db_server:        DB server config
    :return:                 name of the created external DB server
    """
    api = DatabaseServersApi(client)
    try:
        api.create(environment_name, db_server)

    except HTTPError as e:
        if e.code == 302:
            print "Warning: an database server with the same name already exists"
        else:
            raise e

    return db_server.name


def get_cloud_provider_metadata(client, provider_type):
    """
    Retrieve pluggable provider metadata

    @param client:        authenticated API client
    @param provider_type: configured provider type

    @rtype:               CloudProviderMetadata
    @return:              provider metadata for the specified provider type
    """

    api = ProviderMetadataApi(client)
    try:
        cloud_provider_metadata = api.get(provider_type)

    except HTTPError as e:
        if e.code == 404:
            print "Error: no such provider type: %s" % provider_type
        raise e

    return cloud_provider_metadata


def merge_configs(configs):
    """
    Creates a single configuration merging the specified configurations.

    @param configs: configurations, from least-specific to most-specific

    @rtype:         dict
    @return:        merged configurations
    """

    merged_config = {}
    for config in configs:
        merged_config.update(config)

    return merged_config


def get_configuration_property_values(config, configuration_properties):
    """
    Retrieve pluggable provider metadata

    @param config:                   configuration
    @param configuration_properties: configuration properties to retrieve

    @rtype:                          dict
    @return:                         configuration property values for the specified properties
    """

    values_by_config_key = {}
    for configuration_property in configuration_properties:
        config_key = configuration_property.configKey
        if configuration_property.required:
            if config_key not in config:
                raise KeyError("Required property: '%s' is absent" % config_key)
            config_value = str(config.get(config_key))
        else:
            default_value = configuration_property.defaultValue
            if default_value is None:
                default_value = ''
            config_value = str(config.get(config_key, default_value))
        set_configuration_property_value(values_by_config_key, config_key, config_value, configuration_property.type)

    return values_by_config_key


def set_configuration_property_value(values_by_config_key, config_key, config_value, config_type):
    """
    Set a configuration value in a dict

    @param values_by_config_key: configuration value dict
    @param config_key:           configuration key
    @param config_value:         configuration value
    @param config_type:          configuration parameter type
    """

    if config_value:
        if debug:
            print "setting %s: %s" % (config_key, config_value)
        if config_type == 'BOOLEAN':
            config_value = config_value.lower()
        values_by_config_key[config_key] = config_value

    return


def load_config(config_file, fallback_config_files):
    """
    Load configuration from a HOCON configuration file, with an optional fallback chain

    @param config_file:           the primary configuration file
    @param fallback_config_files: an optional list of fallback configuration files

    @rtype:                       ConfigTree
    @return:                      configuration
    """

    config = ConfigFactory.parse_file(config_file)

    if fallback_config_files:
        for fallback_config_file in fallback_config_files:
            if isfile(fallback_config_file):
                config = config.with_fallback(fallback_config_file)
            else:
                print 'Warn: "%s" not found or not a file' % fallback_config_file

    return config

def main():

    parser = argparse.ArgumentParser(prog='setup-default.py')

    parser.add_argument('--admin-username', default='admin',
                        help='Name of a user with administrative access to Cloudera Director (defaults to %(default)s)')
    parser.add_argument('--admin-password', default='admin',
                        help='Password for the administrative user (defaults to %(default)s)')
    parser.add_argument('--server', default='http://localhost:7189',
                        help="Cloudera Director server URL (defaults to %(default)s)")
    parser.add_argument('--debug', default=False, action='store_true',
                        help="Whether to provide additional debugging output (defaults to %(default)s)")

    parser.add_argument('config_file', help="HOCON configuration file (.conf)")

    args = parser.parse_args()

    global debug
    debug = args.debug
    if debug:
        # Enable HTTP request logging to help with debugging
        h = urllib2.HTTPHandler(debuglevel=1)
        opener = urllib2.build_opener(h)
        urllib2.install_opener(opener)

    if not isfile(args.config_file):
        print 'Error: "%s" not found or not a file' % args.config_file
        return -1

    script_path = dirname(realpath(__file__))
    config = load_config(args.config_file, [
                             join(script_path, 'aws.conf'),
                             join(script_path, 'reference.conf')
                         ])

    client = get_authenticated_client(args)

    providerType = config.get_string('provider.type')
    cloudProviderMetadata = get_cloud_provider_metadata(client, providerType)

    print "Creating a new environment ..."
    environment_name = create_environment(client, config, providerType, cloudProviderMetadata)

    print "Creating new instance templates ..."
    create_instance_templates(client, config, environment_name, providerType, cloudProviderMetadata)

    print "Adding existing external database servers ..."
    add_existing_external_db_servers(client, config, environment_name)

    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())

    except HTTPError as e:
        print e.read()
        raise e
