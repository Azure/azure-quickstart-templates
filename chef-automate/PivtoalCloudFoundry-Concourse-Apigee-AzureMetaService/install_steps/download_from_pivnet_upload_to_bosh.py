import urllib2
import tempfile
import yaml
import bosh_client
import zipfile
import sys
import re
import os
from shutil import copy
from azure.storage import BlobService


def authorizedPost(url, token):
    req = urllib2.Request(url)
    req.add_header("Authorization", "Token {0}".format(token))
    req.add_header("Accept", "application/json")
    req.add_header("User-Agent", "azure-pcf-poc-install/1.0.0 (azure-marketplace@pivotal.io)")
    req.data = ''

    res = urllib2.urlopen(req)
    return res

def do_step(context):
    settings = context.meta['settings']
    index_file = context.meta['index-file']
    pivnetAPIToken = settings["pivnet-api-token"]

    f = open("manifests/{0}".format(index_file))
    manifests = yaml.safe_load(f)
    f.close()

    eula_urls = [
        "https://network.pivotal.io/api/v2/products/{0}/releases/{1}/eula_acceptance".format(
            m['release-name'],
            m['release-number']) for m in manifests['manifests']]

    release_urls = [
        "https://network.pivotal.io/api/v2/products/{0}/releases/{1}/product_files/{2}/download".format(
            m['release-name'],
            m['release-number'],
            m['file-number']) for m in manifests['manifests']]

    stemcell_urls = [m['stemcell'] for m in manifests['manifests']]

    # accept eula for each product
    for url in eula_urls:
        print url
        if not "concourse" in url:
            res = authorizedPost(url, pivnetAPIToken)
            code = res.getcode()

    # releases
    is_release_file = re.compile("^releases\/.+")
    if not os.path.exists("/tmp/releases"):
        os.makedirs("/tmp/releases")

    client = bosh_client.BoshClient("https://10.0.0.4:25555", "admin", "admin")
    storage_account_name = settings["STORAGE-ACCOUNT-NAME"]
    storage_access_key = settings["STORAGE-ACCESS-KEY"]

    blob_service = BlobService(storage_account_name, storage_access_key)
    blob_service.create_container(
        container_name='tempreleases',
        x_ms_blob_public_access='container')

    print "Processing releases."
    for url in release_urls:

        print "Downloading {0}.".format(url)

        if "concourse" in url:
            release_url = "https://s3-us-west-2.amazonaws.com/bosh-azure-releases/concourse.zip"
            res = urllib2.urlopen(release_url)
        else:
            res = authorizedPost(url, pivnetAPIToken)

        code = res.getcode()

        length = int(res.headers["Content-Length"])

        # content-length
        if code is 200:

            total = 0
            pcent = 0.0
            CHUNK = 16 * 1024

            with tempfile.TemporaryFile() as temp:
                while True:
                    chunk = res.read(CHUNK)
                    total += CHUNK
                    pcent = (float(total) / float(length)) * 100

                    sys.stdout.write(
                        "Download progress: %.2f%% (%.2fM)\r" %
                        (pcent, total / 1000000.0))
                    sys.stdout.flush()

                    if not chunk:
                        break

                    temp.write(chunk)

                print "Download complete."

                z = zipfile.ZipFile(temp)
                for name in z.namelist():
                    
                    # is this a release?
                    if is_release_file.match(name):

                        release_filename = "/tmp/{0}".format(name)

                        print "Unpacking {0}.".format(name)
                        z.extract(name, "/tmp")

                        print "Uploading {0} to Azure blob store".format(name)

                        blob_service.put_block_blob_from_path(
                            'tempreleases',
                            name,
                            "/tmp/{0}".format(name),
                            x_ms_blob_content_type='application/x-compressed'
                        )

                        os.unlink(release_filename)
                        blob_url = "http://{0}.blob.core.windows.net/{1}/{2}".format(
                            storage_account_name, 'tempreleases', name)

                        print "Uploading release {0} to BOSH director.".format(name)

                        task_id = client.upload_release(blob_url)
                        client.wait_for_task(task_id)

                z.close()
                temp.close()

    blob_service.delete_container("tempreleases")

    # stemcells
    print "Processing stemcells."

    for url in stemcell_urls:
        print "Processing stemcell {0}".format(url)
        task_id = client.upload_stemcell(url)
        client.wait_for_task(task_id)

    return context
