import os
import bosh_client
import requests
from urllib2 import URLError
from subprocess import call


def do_step(context):

    settings = context.meta['settings']

    username = settings["username"]
    home_dir = os.path.join("/home", username)

    os.environ["HOME"] = home_dir

    # deploy director
    os.environ["BOSH_INIT_LOG_LEVEL"] = 'INFO'
    os.environ["BOSH_INIT_LOG_PATH"] = './bosh-init-debug.log'

    client = bosh_client.BoshClient("https://10.0.0.4:25555", "admin", "admin")
    try:
        client.get_info()
    except requests.exceptions.ConnectionError:
        res = None

        while res != 0:
            res = call("bosh-init deploy {0}/bosh.yml".format(home_dir), shell=True)

    return context
