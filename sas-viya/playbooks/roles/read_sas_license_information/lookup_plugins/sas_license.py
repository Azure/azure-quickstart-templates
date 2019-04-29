# python 3 headers, required if submitting to Ansible
from __future__ import (absolute_import, division, print_function)

import os

__metaclass__ = type

DOCUMENTATION = """
      lookup: sas_license
        author: Chris Lyunch <Chris.Lynch@sas.com>
        version_added: "2.4.2"
        short_description: read a Viya license file and determine version information
        description:
            - This lookup returns a dictionary of attributes about a sas license file
        options:
          _terms:
            description: path(s) of license file zip to interogate
            required: True
        notes:
          - if read in variable context, the file can be interpreted as YAML if the content is valid to the parser.
          - this lookup does not understand 'globing' - use the fileglob lookup instead.
"""
from ansible.errors import AnsibleError, AnsibleParserError
from ansible.plugins.lookup import LookupBase
import sys
from tempfile import mkdtemp
import zipfile
import re
import datetime
import shutil

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display

    display = Display()


class SasLicenseCPU:
    def __init__(self, identifier, model, modnum, serial):
        # the license internal identifier for cpus in the setinit
        self.identifier = identifier
        # the model of cpu that this identifier is restricted to (blank means it can be anything)
        self.model = model
        # the model number of the cpu that this identifier is restricted to (blank mean it can be anything)
        self.modnum = modnum
        # the number of these cpus that are licensed to be used by sas. as I understand it, this actually translates into the maximum number of threads that can be spawned for a process.
        self.serial = serial

    def get_ansible_dict(self):
        ansible_dict = {'identifier': self.identifier,
                        'model': self.model,
                        'modnum': self.modnum,
                        'serial': self.serial}
        if self.serial.startswith('+'):
            ansible_dict['licensed_cores'] = int(self.serial.lstrip('+'))
        else:
            ansible_dict['licensed_cores'] = -1

        return ansible_dict

    @staticmethod
    def get_from_cpu_line(line):
        ret = None
        match = re.search(
            'CPU[ ]*MODEL[ ]*=[ ]*\'([^\']*)\'[ ]*MODNUM[ ]*=[ ]*\'([^\']*)\'[ ]*SERIAL[ ]*=[ ]*\'([^\']*)\'[ ]*NAME[ ]*=[ ]*(CPU[0-9]{3,})',
            line)
        if match is not None:
            identifier = match.group(4).strip(' ')
            model = match.group(1).strip(' ')
            modnum = match.group(2).strip(' ')
            serial = match.group(3).strip(' ')
            ret = SasLicenseCPU(identifier, model, modnum, serial)
        return ret


class SasLicenseProduct:
    def __init__(self, product_identifier, name):
        self.identifier = product_identifier
        self.name = name
        self.cpu_blocks = []
        self.expiration_date = None

    def __str__(self):
        cpu_string = None
        first = True
        cpu_string = ''
        for cpu in self.cpu_blocks:
            if cpu.serial.strip(' ') != '':
                if first:
                    first = False
                else:
                    cpu_string += ', '
                cpu_string += cpu.serial.lstrip("+")

        ret = "Sas Product '{}' licensed till {} ".format(self.name, self.expiration_date)
        if cpu_string != '':
            ret += "for {} cores".format(cpu_string)
        return ret

    def get_ansible_dict(self):
        ansible_dict = {'identifier': self.identifier,
                        'name': self.name,
                        'expiration_date': self.expiration_date.strftime('%Y-%m-%d')}
        for cpu in self.cpu_blocks:
            if 'cpus' not in ansible_dict:
                ansible_dict['cpus'] = []
            ansible_dict['cpus'].append(cpu.get_ansible_dict())

        return ansible_dict

    @staticmethod
    def get_from_license_line(line):
        ret = None
        match = re.search('\\*(PRODNUM[0-9]{3,}) = ([^;]+)', line)
        if match is not None:
            identifier = match.group(1)
            name = match.group(2)
            ret = SasLicenseProduct(identifier, name)
        return ret


class SasLicenseSite:
    def __init__(self, site_number, name):
        self.number = site_number
        self.name = name
        self.osname = None
        self.warn_days = None
        self.grace_days = None
        self.birthday = None
        self.expire = None
        self.password = None

    @staticmethod
    def get_from_license_line(line):
        ret = None
        match = re.search('\\*(PRODNUM[0-9]{3,}) = ([^;]+)', line)
        re.findall()
        if line:
            identifier = match.group(1)
            name = match.group(2)
            ret = SasLicenseProduct(identifier, name)
        return ret


class SasLicense:
    def __init__(self, license_file_path):
        self.license_file_path = license_file_path
        self.viya_version = None
        self.viya_major_version = None
        self.viya_minor_version = None
        self.release = None

        self.cpus = {}
        self.products = {}
        self.read_from_file()

    def read_from_file(self):
        self.viya_version = "3.3"
        self.viya_major_version = 3
        self.viya_minor_version = 3
        set_init_string = None
        temporary_dir = mkdtemp()
        target_license_information_file = ""
        with zipfile.ZipFile(self.license_file_path, mode='r') as zipf:
            for file in zipf.infolist():
                if file.filename.endswith('Linux_x86-64.txt'):
                    target_license_information_file = zipf.extract(file, temporary_dir)
                if file.filename.endswith('.jwt'):
                    self.viya_version = '3.4'
                    self.viya_minor_version = 4
        # Read the CPU info blocks
        with open(target_license_information_file, 'r') as file:
            setinit_string = file.read()
            self.parse_setinit(setinit_string)
        shutil.rmtree(temporary_dir)

    def parse_setinit(self, setinit_string):
        # first we split the file into pieces
        state = 1
        pre_setinit_tag = []
        in_setinit_tags = []
        post_setinit_tags = []
        for line in setinit_string.split('\n'):
            trim_line = line.strip('\r')
            # if we are prior to the setinit block
            if state == 1:
                if trim_line.strip(' ').upper().startswith('PROC SETINIT'):
                    state += 1
                else:
                    pre_setinit_tag.append(trim_line)
            # if we are in the setinit block
            if state == 2:
                if trim_line.strip(' ').upper().startswith('SAVE; RUN;'):
                    state += 1
                else:
                    in_setinit_tags.append(trim_line)
            elif state == 3:
                post_setinit_tags.append(trim_line)
        # Now get all the product identifiers to names tags (we will use them to join into the expire tags)
        for line in post_setinit_tags:
            product = SasLicenseProduct.get_from_license_line(line)
            if product is not None:
                self.products[product.identifier] = product
        # chunk the sas proc setinit into the seperate imparatives for further processing
        tag_blocks = []
        tag_block = ""
        for line in in_setinit_tags:  # type: str
            splits = line.split(';')
            while True:
                if len(splits) > 1:
                    tag_block += splits[0]
                    tag_blocks.append(tag_block)
                    splits.remove(splits[0])
                    tag_block = ""
                else:
                    break
            tag_block += splits[0]
        # process the imparatives, first finding the CPU blocks
        for tag_block in tag_blocks:  # type: str
            if tag_block.lstrip(' ').upper().startswith('CPU '):
                cpu = SasLicenseCPU.get_from_cpu_line(tag_block)
                if cpu is not None:
                    self.cpus[cpu.identifier] = cpu


        for tag_block in tag_blocks:  # type: str
            if tag_block.lstrip(' ').upper().startswith('PROC SETINIT'):
                value_matches = re.finditer('([0-9A-Za-z]+)=("([^"]*)"|\'([^\']*)\'|[^;]+|[^\\s]+)D?', tag_block)
                for value_match in value_matches:
                    value_split = value_match.group(0).split("=")
                    if value_split[0].strip(" ").upper() == 'RELEASE':
                        self.release = value_split[0].strip(" ").strip("'")

            if tag_block.lstrip(' ').upper().startswith('EXPIRE '):
                product_sets = []
                cpu_sets = []
                expire_date = None
                tag_split = tag_block.split(" ")
                # reading an expire string seems to split into a list of products, then a date, then a cpu= set, so we
                # will split these into stage 1 for products, 2 for date, and 3 for cpus. If there are other stages that
                # can be present in an expire block, I have not seen them.
                state = 1
                for tag in tag_split:
                    if tag == '':
                        pass
                    elif tag == 'EXPIRE':
                        state = 1
                    elif state == 1 and not tag.upper().endswith('D'):
                        product_sets.append(self.products[tag.strip("'")])
                    elif state == 1 and tag.upper().endswith('D'):
                        expire_date = SasLicense.parse_date(tag)
                        state = 2
                    elif state == 2 and tag.upper().startswith('CPU'):
                        split_tag = tag.split('=')
                        cpu_sets.append(self.cpus[split_tag[1]])
                        state = 3
                    elif state == 3:
                        cpu_sets.append(self.cpus[tag])

                # now we assosiate all the products with their new expire date and their cpu sets
                for product in product_sets:  # type: SasLicenseProduct
                    product.cpu_blocks.extend(cpu_sets)
                    product.expiration_date = expire_date

    def __str__(self):
        ret = 'SAS License for viya {}, marked as release {}'.format(self.viya_version, self.release)
        for product_key in self.products:
            ret += '\n\t{}'.format(self.products[product_key])

        return ret

    def get_ansible_dict(self):
        license_return = {'release': self.release,
                          'viya_version': self.viya_version,
                          'viya_version_major': self.viya_major_version,
                          'viya_version_minor': self.viya_minor_version}

        for product in self.products:
            if 'products' not in license_return:
                license_return['products'] = []
            license_return['products'].append(self.products[product].get_ansible_dict())

        return license_return

    @staticmethod
    def parse_date(date_string):
        ret = None  # type: datetime.datetime
        #Confirm that this is a date format string, by checking for the D at the end.
        if date_string.upper().endswith('D'):
            date_string_reformated = date_string.rstrip('D')
            date_string_reformated = date_string_reformated.strip("'")
            ret = datetime.datetime.strptime(date_string_reformated, '%d%b%Y')
        return ret

class LookupModule(LookupBase):

    def run(self, terms, variables=None, **kwargs):
        # lookups in general are expected to both take a list as input and output a list
        # this is done so they work with the looping construct `with_`.
        # Only the gods know why you would want to look through several viya licenses files, but conventions are conventions for a reason... so here we are.
        ret = []
        for term in terms:
            display.debug("License lookup term: %s" % term)

            # Find the file in the expected search path, using a class method
            # that implements the 'expected' search path for Ansible plugins.
            lookupfile = self.find_file_in_search_path(variables, 'files', term)

            # Don't use print or your own logging, the display class
            # takes care of it in a unified way.
            display.vvvv(u"Sas License lookup using %s as file" % lookupfile)
            try:
                if lookupfile:
                    sas_license = SasLicense(lookupfile)
                    # contents, show_data = self._loader._get_file_contents(lookupfile)
                    ret.append(sas_license.get_ansible_dict())
                else:
                    # Always use ansible error classes to throw 'final' exceptions,
                    # so the Ansible engine will know how to deal with them.
                    # The Parser error indicates invalid options passed
                    raise AnsibleParserError()
            except AnsibleParserError:
                raise AnsibleError("could not locate file in lookup: %s" % term)

        return ret