#!/usr/bin/env python

from collections import OrderedDict
import os
import re
import json

customData = []

with open('custom-data.sh') as f:
    for line in f:
        m = re.match(r'(.*?)(parameters\([^\)]*\))(.*$)', line)
        if m:
            customData += ['\'' + m.group(1) + '\'',
                           m.group(2),
                           '\'' + m.group(3) + '\'',
                           '\'\n\'']
        else:
            customData += ['\'' + line + '\'']

with open('azuredeploy.json') as f:
    templ = json.load(f, object_pairs_hook=OrderedDict)
    templ['variables']['customData'] = '[concat(' + ', '.join(
        customData) + ')]'

os.rename('azuredeploy.json', 'azuredeploy.json.old')

with open('azuredeploy.json', 'w') as f:
    f.write(json.dumps(templ, indent=2).replace(' \n', '\n') + '\n')
