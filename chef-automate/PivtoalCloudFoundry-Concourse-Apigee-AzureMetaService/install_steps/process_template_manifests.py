import yaml
import os
from uuid import uuid1
from jinja2 import Environment
from hashlib import sha256
global sshpubkey


def password(key, short=False):
    global sshpubkey
    password = sha256("{0}:{1}".format(sshpubkey, key)).hexdigest()
    if short:
        return password[:20]
    else:
        return password


def uuid(input):
    return str(uuid1())


def do_step(context):
    global sshpubkey

    env = Environment()
    env.filters['password'] = password
    env.filters['uuid'] = uuid

    settings = context.meta['settings']
    sshpubkey = settings['adminSSHKey']
    index_file = context.meta['index-file']

    f = open("manifests/{0}".format(index_file))
    manifests = yaml.safe_load(f)
    f.close()

    m_list = []
    for m in manifests['manifests']:
        m_list.append("manifests/{0}".format(m['file']))

    m_list.append('bosh.yml')

    # Normalize settings from ARM template
    norm_settings = {}
    norm_settings["DIRECTOR_UUID"] = "{{ DIRECTOR_UUID }}"
    norm_settings["CF_PUBLIC_IP_ADDRESS"] = settings["cf-ip"]

    for setting in context.meta['settings']:
        norm_settings[setting.replace("-", "_")] = settings[setting]

    # Render the yml template for bosh-init
    for template_path in m_list:

        if os.path.exists(template_path):
            with open(template_path, 'r') as f:
                contents = f.read()
                contents = env.from_string(contents).render(norm_settings)

        with open(os.path.join('bosh', template_path), 'w') as f:
            f.write(contents)

    return context
