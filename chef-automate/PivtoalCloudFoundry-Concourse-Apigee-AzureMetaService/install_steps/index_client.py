import yaml

class IndexClient:

    def __init__(self, index_file):
        self.index_file = "manifests/{0}".format(index_file)

        with open(self.index_file, 'r') as stream:
            content = stream.read()
            try:
                self.doc = yaml.load(content)
            except yaml.YAMLError as exc:
                print(exc)

    def find_by_release(self, release_name):
        for manifest in self.doc['manifests']:
            if manifest['release-name'] == release_name:
                return manifest

        return None
