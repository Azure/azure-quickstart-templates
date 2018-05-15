import json
import os
import time

from azure.mgmt.resource.resources.v2017_05_10.models import DeploymentMode


class Configuration:
    def __init__(self):
        self.deployment_name = 'azuredeploy'
        self.client_id = os.getenv('SPNAME')
        self.secret = os.getenv('SPPASSWORD')
        self.tenant_id = os.getenv('SPTENANT')
        self.location = os.getenv('LOCATION', 'southcentralus')
        self.source_branch = self.identify_source_branch()
        self.fullci_branches = os.getenv('FULLCI_BRANCHES', 'master').split(':')
        self.commit_message = os.getenv('TRAVIS_COMMIT_MESSAGE', None)
        self.ssh_key = self.identify_ssh_key()
        self.resource_group = self.identify_resource_group()
        self.deployment_properties = self.generate_deployment_properties()

    def identify_resource_group(self):
        resource_group = os.getenv('RESOURCEGROUP')
        if resource_group is None:
            resource_group = 'azmdl-travis-' + os.getenv('TRAVIS_BUILD_NUMBER', 'manual-{}'.format(time.time()))
        return resource_group

    def identify_ssh_key(self):
        ssh_key = os.getenv('SPSSHKEY')
        if ssh_key is None:
            with open('azure_moodle_id_rsa.pub', 'r') as sshkey_fd:
                ssh_key = sshkey_fd.read()
        return ssh_key

    def generate_deployment_properties(self):
        with open('azuredeploy.json', 'r') as template_fd:
            template = json.load(template_fd)

        with open('azuredeploy.parameters.json', 'r') as parameters_fd:
            parameters = json.load(parameters_fd)
        parameters = parameters['parameters']
        parameters['sshPublicKey']['value'] = self.ssh_key
        parameters['_artifactsLocation'] = {'value': self.identify_artifacts_location()}

        return {
            'mode': DeploymentMode.incremental,
            'template': template,
            'parameters': parameters,
        }

    def identify_artifacts_location(self):
        slug = os.getenv('TRAVIS_PULL_REQUEST_SLUG')
        if not slug:
            slug = os.getenv('TRAVIS_REPO_SLUG')
        return "https://raw.githubusercontent.com/{}/{}/".format(slug, self.source_branch)

    def identify_source_branch(self):
        branch = os.getenv('TRAVIS_PULL_REQUEST_BRANCH')
        if not branch:
            branch = os.getenv('TRAVIS_BRANCH')
        return branch

    def is_valid(self):
        valid = True

        for key, value in vars(self).items():
            if value is None:
                valid = False
                print('(missing configuration for {})'.format(key))

        if self.deployment_properties['parameters']['_artifactsLocation']['value'] is None:
            valid = False
            print('(could not identify _artifactsLocation)')

        return valid

    def should_run_full_ci(self):
        if self.source_branch in self.fullci_branches:
            return True

        message = self.commit_message.upper()
        if '[FULL CI]' in message or '[FULLCI]' in message:
            return True

        return False
