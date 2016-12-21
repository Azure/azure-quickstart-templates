import urllib2
from subprocess import call


def download(url, path):
    res = urllib2.urlopen(url)

    code = res.getcode()

    # content-length
    if code is 200:
        CHUNK = 16 * 1024

        with open(path, 'wb') as temp:
            while True:
                chunk = res.read(CHUNK)

                if not chunk:
                    break

                temp.write(chunk)


def do_step(context):

    download("https://s3.amazonaws.com/bosh-init-artifacts/bosh-init-0.0.81-linux-amd64", "/usr/local/bin/bosh-init")
    call("chmod +x /usr/local/bin/bosh-init", shell=True)

    return context
