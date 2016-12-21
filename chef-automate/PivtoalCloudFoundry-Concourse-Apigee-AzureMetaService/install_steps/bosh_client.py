import requests
import json
import base64
import time
import re

class BoshClient:

    def __init__(self, url, username, password):
        self.bosh_url = url
        self.username = username
        self.password = password

    def get(self, url):
        s = requests.Session()

        base64string = base64.encodestring(
            '%s:%s' %
            (self.username, self.password)).replace(
            '\n', '')

        s.headers.update({'Authorization': "Basic %s" % base64string})

        result = s.get(url, verify=False)
        return result.text

    def post(self, url, data, content_type):
        s = requests.Session()
        s.headers.update({'content-type': content_type})

        base64string = base64.encodestring(
            '%s:%s' %
            (self.username, self.password)).replace(
            '\n', '')

        s.headers.update({'Authorization': "Basic %s" % base64string})
        result = s.post(url, data=data, verify=False, allow_redirects=False)

        if result.status_code == 302:
    		m = re.search('\/tasks\/(\d+)', result.headers['location'])
    		task_id = m.group(1)

    		return task_id
        else:
            return result.text

    def wait_for_task(self, task_id):
        events = []

        result = self.get_task(task_id)

        while result['state'] == 'queued' or result['state'] == 'processing':

            task_events = self.get_task_events(task_id)

            for event in task_events:
                if 'error' in event:
                    print "{0} > \033[31m{1}\033[0m".format("Error".rjust(30, " "), event['error']['message'])
                    break

                existing = filter(lambda x: x['stage'] == event['stage'] and
                                  x['task'] == event['task'] and
                                  x['state'] == event['state'], events)

                if len(existing) == 0:
                    events.append(event)
                    print "{0} > \033[92m{1}\033[0m {2}" \
                        .format(event['stage'].rjust(30, " "),
                                event['task'], event['state'])

            time.sleep(3)

            result = self.get_task(task_id)

        return result

    def get_uuid(self):
        return self.get_info()["uuid"]

    def get_info(self):
        info_url = "{0}/info".format(self.bosh_url)
        self.info = json.loads(self.get(info_url))
        return self.info

    def get_task_events(self, task_id):
        task_url = "{0}/tasks/{1}/output?type=event".format(
            self.bosh_url, task_id)
        result = self.get(task_url)
        items = []

        for line in result.split("\n"):
            if not "Ignoring cloud config" in line:
                try:
                    items.append(json.loads(line))
                except ValueError:
                    pass

        return items

    def get_deployments(self):
        deployments_url = "{0}/deployments".format(self.bosh_url)
        self.deployments = json.loads(self.get(deployments_url))
        return self.deployments

    def create_deployment(self, manifest):
        deployments_url = "{0}/deployments".format(self.bosh_url)
        result = self.post(deployments_url, manifest, 'text/yaml')
        return result

    def run_errand(self, deployment_name, errand_name):
        errand_url = "{0}/deployments/{1}/errands/{2}/runs".format(
            self.bosh_url,
            deployment_name,
            errand_name
        )
        result = self.post(errand_url, "{}", 'application/json')
        return result

    def get_task(self, task_id):
        task_url = "{0}/tasks/{1}".format(
            self.bosh_url, task_id)
        return json.loads(self.get(task_url))

    def get_task_result(self, task_id):
        task_url = "{0}/tasks/{1}/output?type=result".format(
            self.bosh_url, task_id)
        return json.loads(self.get(task_url))

    def get_releases(self):
        releases_url = "{0}/releases".format(self.bosh_url)
        self.releases = json.loads(self.get(releases_url))
        return self.releases

    def get_vms(self, deployment_name):
        vms_url = "{0}/deployments/{1}/vms".format(
            self.bosh_url, deployment_name)
        vms = json.loads(self.get(vms_url))
        return vms

    def upload_stemcell(self, stemcell_url):
        stemcells_url = "{0}/stemcells".format(self.bosh_url)
        payload = '{"location":"%s"}' % stemcell_url
        result = self.post(stemcells_url, payload, 'application/json')
        return result

    def upload_release(self, release_url):
        releases_url = "{0}/releases".format(self.bosh_url)
        payload = '{"location":"%s"}' % release_url
        result = self.post(releases_url, payload, 'application/json')
    	return result

    def ip_table(self, deployment_name):
        url = "{0}/deployments/{1}/vms?format=full".format(
            self.bosh_url, deployment_name)
        res = self.get(url)
        task_id = json.loads(res)['id']
        self.wait_for_task(task_id)

        task_url = "{0}/tasks/{1}/output?type=result".format(
            self.bosh_url, task_id)
        response = self.get(task_url)
        ips = {}

        for vm in response.split("\n"):
            if vm:
                vm_dict = json.loads(vm)
                ips[vm_dict['job_name']] = vm_dict['ips']

        self.address_table = ips
        return self.address_table
