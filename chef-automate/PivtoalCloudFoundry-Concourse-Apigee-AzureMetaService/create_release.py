#!/usr/bin/env python
import tarfile
import urllib2
import json
import requests

from sys import argv
from os import environ
from os import listdir
from os.path import isfile, isdir, join

files_to_archive = [
    'bosh.yml', 'setup_dns.py', 'create_cert.sh',
    'gotty', '.gotty.crt', '.gotty.key',
    '98-msft-love-cf', 'gamma.py']

for path in ["install_steps", "manifests", "certs", "meta-azure-service-broker"]:
    files_to_archive += [join(path, f) for f in listdir(path)
                         if isfile(join(path, f)) or isdir(join(path, f)) and not f.endswith('.pyc')]

tar = tarfile.open("gamma-release.tgz", "w:gz")
for name in files_to_archive:
    tar.add(name)
tar.close()


github_token = environ["GH_TOKEN"]
gh_url = 'https://api.github.com/repos/cf-platform-eng/bosh-azure-template/releases'

print gh_url

if len(argv) < 3:
    exit()

tag_name = argv[1]
commitish = argv[2]

# create the release
payload = """{{
  "tag_name": "{0}",
  "target_commitish": "{1}",
  "name": "{0}",
  "body": "Gamma installer payload",
  "draft": false,
  "prerelease": false
}}""".format(tag_name, commitish)

req = urllib2.Request(gh_url)
req.data = payload
headers = req.headers = {
    'Content-Type': 'application/json',
    'Authorization': "token {0}".format(github_token),
}

# upload the release asset
handler = urllib2.urlopen(req)
release = json.loads(handler.read())

headers = {
    'Content-Type': 'application/x-compressed',
    'Authorization': "token {0}".format(github_token),
}
upload_url = release['upload_url'].replace(
    '{?name,label}', '?name={0}-{1}.tgz').format("gamma-release", tag_name)
r = requests.post(
    upload_url,
    data=open(
        'gamma-release.tgz',
        'rb'),
    headers=headers)
