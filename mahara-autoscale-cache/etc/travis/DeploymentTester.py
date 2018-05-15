import os
import pycurl
import sys
import tempfile
import time
import urllib
from io import BytesIO
from pycurl import Curl

from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.subscription import SubscriptionClient
from msrestazure.azure_active_directory import ServicePrincipalCredentials

from travis.Configuration import Configuration


class DeploymentTester:
    @staticmethod
    def elapsed(since):
        elapsed = int(time.time() - since)
        elapsed = '{:02d}:{:02d}:{:02d}'.format(elapsed // 3600, (elapsed % 3600 // 60), elapsed % 60)
        return elapsed

    def __init__(self):
        self.config = Configuration()
        self.deployment = None

        self.credentials = None
        """:type : ServicePrincipalCredentials"""

        self.resource_client = None
        """:type : ResourceManagementClient"""

    def run(self):
        self.check_configuration()
        self.login()
        self.create_resource_group()
        self.validate()
        if not self.config.should_run_full_ci():
            print('\n\nBasic CI tests successful.')
            return
        self.deploy()
        self.moodle_smoke_test()
        self.moodle_admin_login()
        print('\n\nFull CI tests successful!')

    def check_configuration(self):
        print('\nChecking configuration...')
        if not self.config.is_valid():
            print('No Azure deployment info given, skipping test deployment and exiting.')
            print('Further information: https://github.com/Azure/Moodle#automated-testing-travis-ci')
            sys.exit()
        artifacts_location = self.config.deployment_properties['parameters']['_artifactsLocation']
        print('- Detected "_artifactsLocation": ' + artifacts_location['value'])
        print("(all check)")

    def login(self):
        print('\nLogging in...')
        self.credentials = ServicePrincipalCredentials(
            client_id=self.config.client_id,
            secret=self.config.secret,
            tenant=self.config.tenant_id,
        )
        print('(got credentials)')
        subscription_client = SubscriptionClient(self.credentials)
        subscription = next(subscription_client.subscriptions.list())
        print('(found subscription)')
        self.resource_client = ResourceManagementClient(self.credentials, subscription.subscription_id)
        print("(logged in)")

    def create_resource_group(self):
        print('\nCreating group "{}" on "{}"...'.format(self.config.resource_group, self.config.location))
        self.resource_client.resource_groups.create_or_update(self.config.resource_group,
                                                              {'location': self.config.location})
        print('(created)')

    def validate(self):
        print('\nValidating template...')

        validation = self.resource_client.deployments.validate(self.config.resource_group,
                                                               self.config.deployment_name,
                                                               self.config.deployment_properties)
        if validation.error is not None:
            print("*** VALIDATION FAILED ({}) ***".format(validation.error))
            print(validation.error.message)
            for detail in validation.error.details:
                print("- {}:\n{}".format(detail.code, detail.message))
            sys.exit(1)

        print("(valid)")

    def deploy(self):
        print('\nDeploying template, feel free to take a nap...')
        deployment = self.resource_client.deployments.create_or_update(self.config.resource_group,
                                                                       self.config.deployment_name,
                                                                       self.config.deployment_properties)
        """:type : msrestazure.azure_operation.AzureOperationPoller"""
        started = time.time()
        while not deployment.done():
            print('... after {} still "{}" ...'.format(self.elapsed(started), deployment.status()))
            deployment.wait(60)
        print("WAKE UP! After {} we finally got status {}.".format(self.elapsed(started), deployment.status()))

        print("Checking deployment response...")
        properties = deployment.result(0).properties
        if properties.provisioning_state != 'Succeeded':
            print("*** DEPLOY FAILED ***")
            print('Provisioning state: ' + properties.provisioning_state)
            sys.exit(1)
        self.load_deployment_outputs(properties.outputs)
        print("(success)")

    def load_deployment_outputs(self, outputs):
        self.deployment = {}
        for key, value in outputs.items():
            self.deployment[key] = value['value']
            print("- Found: " + key)

    def moodle_smoke_test(self):
        print("\nMoodle Smoke Test...")
        url = 'https://' + self.deployment['siteURL']
        curl = Curl()
        curl.setopt(pycurl.URL, url)
        curl.setopt(pycurl.SSL_VERIFYPEER, False)
        curl.setopt(pycurl.WRITEFUNCTION, lambda x: None)
        curl.perform()
        status = curl.getinfo(pycurl.HTTP_CODE)
        if status != 200:
            print("*** DEPLOY FAILED ***")
            print('HTTP Status Code: ' + status)
            sys.exit(1)
        print('(ok: {})'.format(status))

    def moodle_admin_login(self):
        print("\nLogging in into Moodle as 'admin'...")
        response = self.moodle_admin_login_curl()
        if 'Admin User' not in response:
            print("*** FAILED: 'Admin User' keyword not found ***")
            sys.exit(1)
        print('(it worked)')

    def moodle_admin_login_curl(self):
        fd, path = tempfile.mkstemp()
        try:
            response = BytesIO()
            url = 'https://' + self.deployment['siteURL'] + '/login/index.php'
            curl = Curl()
            curl.setopt(pycurl.URL, url)
            curl.setopt(pycurl.SSL_VERIFYPEER, False)
            curl.setopt(pycurl.WRITEFUNCTION, response.write)
            curl.setopt(pycurl.POST, True)
            curl.setopt(pycurl.COOKIEJAR, path)
            curl.setopt(pycurl.COOKIEFILE, path)
            post = urllib.parse.urlencode({'username': 'admin', 'password': self.deployment['moodleAdminPassword']})
            curl.setopt(pycurl.POSTFIELDS, post)
            curl.setopt(pycurl.FOLLOWLOCATION, True)
            curl.perform()
            status = curl.getinfo(pycurl.HTTP_CODE)
            if status != 200:
                print("*** FAILED: {} ***".format(status))
                sys.exit(1)
            response = response.getvalue().decode('utf-8')
        finally:
            os.remove(path)
        return response
