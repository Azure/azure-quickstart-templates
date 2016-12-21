import bosh_client
import os
import yaml


def do_step(context):
    settings = context.meta['settings']

    username = settings["username"]
    home_dir = os.path.join("/home", username)
    index_file = context.meta['index-file']

    f = open("manifests/{0}".format(index_file))
    manifests = yaml.safe_load(f)
    f.close()

    client = bosh_client.BoshClient("https://10.0.0.4:25555", "admin", "admin")

    for m in manifests['manifests']:
        print "Running errands for {0}/manifests/{1}...".format(home_dir, m['file'])

        try:
            for errand in m['errands']:
                print "Running errand {0}".format(errand)

                task_id = client.run_errand(m['deployment-name'], errand)
                task = client.wait_for_task(task_id)

                retries = 0

                while task['state'] == 'error' and retries < 5:

                    retries += 1

                    print "Retrying errand {0}".format(errand)

                    task_id = client.run_errand(m['deployment-name'], errand)
                    task = client.wait_for_task(task_id)

                result = client.get_task_result(task_id)
                print "Errand finished with exit code {0}".format(result['exit_code'])

                print "=========== STDOUT ==========="
                print result['stdout'].encode('utf8')

                print "=========== STDERR ==========="
                print result['stderr'].encode('utf8')


        except KeyError:
            print "Ignoring KeyError exception"

    return context
