import yaml
import os


def do_step(context):

    settings = context.meta['settings']
    username = settings["username"]
    home_dir = os.path.join("/home", username)
    index_file = context.meta['index-file']

    f = open("{0}/manifests/elastic-runtime.yml".format(home_dir))
    manifest = yaml.safe_load(f)
    f.close()

    apps_manager_address = "https://apps.{0}".format(manifest['system_domain'])
    admin_password = manifest['properties']['admin_password']

    os.system('clear')
    print "============================================================"
    print "Apps Manager URL : {0}".format(apps_manager_address)
    print "Admin password   : {0}".format(admin_password)
    print "Documentation    : http://docs.pivotal.io/pivotalcf/installing/pcf-docs.html"
    print "============================================================"

    raw_input("")
