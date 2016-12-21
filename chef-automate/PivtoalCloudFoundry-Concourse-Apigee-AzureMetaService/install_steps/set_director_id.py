import os
import yaml
import bosh_client
from jinja2 import Template


def do_step(context):

    settings = context.meta['settings']
    username = settings["username"]
    home_dir = os.path.join("/home", username)
    index_file = context.meta['index-file']

    client = bosh_client.BoshClient("https://10.0.0.4:25555", "admin", "admin")
    bosh_uuid = client.get_info()['uuid']

    print "Director uuid is {0}".format(bosh_uuid)

    f = open("manifests/{0}".format(index_file))
    manifests = yaml.safe_load(f)
    f.close()

    # set the director id on the manifests
    for m in manifests['manifests']:
        with open("{0}/manifests/{1}".format(home_dir, m['file']), 'r+') as f:

            contents = f.read()
            template = Template(contents)
            contents = template.render(DIRECTOR_UUID=bosh_uuid)

            f.seek(0)
            f.write(contents)
            f.truncate()
            f.close()

    return context
