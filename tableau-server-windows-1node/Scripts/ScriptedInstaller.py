from __future__ import print_function
import sys
import os
import re
import argparse
import subprocess
import tempfile
import json
import shutil
import yaml

# If one of the entries in KNOWN_GOOD_PYTHON_VERSIONS matches a prefix if the current version, we're good.
# That is to say, 2.7 matches 2.7.x where x is anything. 2.8.1 only would match 2.8.1, and so on.
# A very strange set of good versions, for example, could be : [ (2,7,5), (2,8), (11,) ]
KNOWN_GOOD_PYTHON_VERSIONS = [(2,7) ]
# Default installation dir.
TABLEAU_DEFAULT_INSTALL_DIR = r'C:\Program Files\Tableau\Tableau Server'
TABLEAU_DEFAULT_DATA_DIR = r'C:\ProgramData\Tableau\Tableau Server'
RELATIVE_WORKGROUP_YML_PATH = r'data\tabsvc\config\workgroup.yml'
# Minimum version that can be upgraded with this.
MINIMUM_UPGRADEABLE_VERSION = 9.0
# Minimum version that can be upgraded with this if this is a cluster
MINIMUM_CLUSTER_UPGRADEABLE_VERSION = 9.3

# Older versions of tabadmin don't have the 'get' command. Try to use it, but if we can't, fallback
# to a terrible hacky version.
TABADMIN_HAS_GET_COMMAND = True

INNO_SETUP_EXIT_CODES = {
    1: 'Inno Setup: Setup failed to initialize.',
    2: 'Inno Setup: The user clicked Cancel in the wizard before the actual installation started, or chose "No" on the opening "This will install..." message box.',
    3: 'Inno Setup: A fatal error occurred while preparing to move to the next installation phase (for example, from displaying the pre-installation wizard pages to the actual installation process). This should never happen except under the most unusual of circumstances, such as running out of memory or Windows resources.',
    4: 'Inno Setup: A fatal error occurred during the actual installation process.',
    5: 'Inno Setup: The user clicked Cancel during the actual installation process, or chose Abort at an Abort-Retry-Ignore box.',
    6: 'Inno Setup: The Setup process was forcefully terminated by the debugger',
    7: 'Inno Setup: The Preparing to Install stage determined that Setup cannot proceed with installation.',
    8: 'Inno Setup: The Preparing to Install stage determined that Setup cannot proceed with installation, and that the system needs to be restarted in order to correct the problem.'
}


# An executable is missing
class MissingExecutableError(Exception):
    pass

# Input errors related to invalid or missing configuration options
# passed on the command line or in a configuration file
class OptionsError(Exception):
    pass

# There is an existing installation of Tableau Server
class ExistingInstallationError(Exception):
    pass

# Some user input wasn't valid
class ValidationError(Exception):
    pass

# An external command exited with a non-success exit code
class ExitCodeError(Exception):
    def __init__(self, binary, exit_code):
        super(ExitCodeError, self).__init__('%s execution exited with code: %d' % (str(binary), exit_code))
        self.exit_code = exit_code

# Parses the command line arguments and configuration files specified by the user
def get_options():
    cmd_parser = make_cmd_line_parser()
    cmd_line_args = cmd_parser.parse_args()
    return cmd_line_args

def make_cmd_line_parser():
    parser = argparse.ArgumentParser(
        description='Tableau Server Cluster silent installation script',
        add_help=True,
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    # Required arguments
    subparsers = parser.add_subparsers(help='Install or Upgrade Tableau Server')

    ### INSTALL ARGS
    install_parser = subparsers.add_parser('install')
    install_parser.set_defaults(installer_action='install')
    # Optional flags (have reasonable defaults)
    optional_flags = install_parser.add_argument_group('Optional arguments')
    optional_flags.add_argument('--installDir', dest='installDir', help='installation directory', default=TABLEAU_DEFAULT_INSTALL_DIR)
    optional_flags.add_argument('--configFile', dest='configFile', help='Configuration and topology yml file', default=None)
    optional_flags.add_argument('--installerLog', dest='installerLog', help='Installer logfile; a default will be created if unspecified', default=None)
    optional_flags.add_argument('--enablePublicFwRule', dest='enablePublicFwRule', action='store_true', help='If configured to add firewall rules to connect to gateway, also enable firewall rule to connect "public" Windows profile')

    # Required flags (no reasonable defaults)
    required_flags = install_parser.add_argument_group('required flags')
    required_flags.add_argument('installer', help='installer path, e.g: Tableau-Server-64bit-9-3-1.exe')
    required_flags.add_argument('--secretsFile', dest='secretsFile', required=True, help='User credentials json file')
    required_flags.add_argument('--registrationFile', dest='registrationFile', required=True, help='User registration file, in json format')

    mutex_flags = install_parser.add_mutually_exclusive_group(required=True)
    mutex_flags.add_argument('--licenseKey', dest='licenseKey', help='Activation key')
    mutex_flags.add_argument('--trialLicense', dest='trial', action='store_true', default=False, help='Use an expiring trial license')

    ### UPGRADE ARGS
    upgrade_parser = subparsers.add_parser('upgrade')
    upgrade_parser.set_defaults(installer_action='upgrade')
    # Optional flags (have reasonable defaults)
    optional_flags = upgrade_parser.add_argument_group('Optional arguments')
    optional_flags.add_argument('--installDir', dest='installDir', help='installation directory', default=TABLEAU_DEFAULT_INSTALL_DIR)
    optional_flags.add_argument('--secretsFile', dest='secretsFile', help='User credentials json file; required if you use non-default runas username', default=None)
    optional_flags.add_argument('--installerLog', dest='installerLog', help='Installer logfile; a default will be created if unspecified', default=None)
    optional_flags.add_argument('--fastuninstall', dest='fastuninstall', action='store_true', help='Use the optional \'fastuninstall\' functionality of the installer to skip making a backup before upgrading')
    required_flags = upgrade_parser.add_argument_group('required flags')
    required_flags.add_argument('installer', help='installer path, e.g: Tableau-Server-64bit-9-3-1.exe')

    return parser

##### Validate things
#####

# Validate user inputs for installing a new server
# Since we have to read files in to validate them, return any data that we already read in
# so we don't have to read them twice later in this script.
#
# Currently, we only use the data from secrets, so that's all we return
def validate_install_inputs(options):
    # Try reading the options file (if present) in; validate that it's at least valid yaml before we do a bunch more work.
    validate_config_file(options)
    # Is the registration file valid?
    validate_registration_file(options)
    # Is the secrets file valid?
    secrets = validate_secrets_file(options)
    # Is the installer executable valid?
    validate_installer_executable(options)
    return secrets

# Be sure our inputs for upgrade are set. The secrets file may or may not be set.
# return the secrets contained therein, or an empty dict if no file/not present.
def validate_upgrade_inputs(options):
    # Is the installer executable valid?
    validate_installer_executable(options)
    # Is the secrets file valid? If not present, 
    secrets = {}
    if options.secretsFile:
        secrets = validate_secrets_file(options, require_initialuser=False)
    return secrets

def validate_python_version():
    current_version_tuple = (sys.version_info.major, sys.version_info.minor, sys.version_info.micro)
    for good_version_tuple in KNOWN_GOOD_PYTHON_VERSIONS:
        if good_version_tuple == current_version_tuple[:len(good_version_tuple)]:
            return True
    raise ValidationError('You are using an unsupported version of Python; known good version: ' + good_python_versions_string(len(current_version_tuple)))

def good_python_versions_string(min_version_parts):
    versions_as_string = []
    for version_tuple in KNOWN_GOOD_PYTHON_VERSIONS:
        string_tuple = list(map(str,version_tuple))
        if len(string_tuple) < min_version_parts:
            string_tuple.extend('x' * (min_version_parts - len(string_tuple)))
        versions_as_string.append('.'.join(string_tuple))
    return ', '.join(versions_as_string)

# Be sure the config file is well-formed (or at least well-formed enough for the parser)
# and has the config.version line in there.
# It's okay if there's no config file; all defaults will be used.
def validate_config_file(options):
    if options.configFile:
        try:
            with open(options.configFile) as yaml_file:
                yaml_doc = yaml.safe_load(yaml_file)
                if not 'config.version' in yaml_doc:
                    raise ValidationError('Config YAML file "%s" must have, at minimum, config.version' % options.configFile)
        except IOError as ex:
            raise ValidationError('Could not open or read config yaml YAML "%s"' % options.configFile)
        except yaml.YAMLError as ex:
            raise ValidationError('Error parsing config YAML file "%s"' % options.configFile)
    return True

# Be sure the registration file is present and parseable
def validate_registration_file(options):
    try:
        return read_json_file(options.registrationFile)
    except IOError as ex:
        raise ValidationError('Could not open registration json file "%s"' % options.registrationFile)
    except ValueError as ex:
        raise ValidationError('The registration json file "%s" contains malformed json' % options.registrationFile)

# Be sure the secrets file is present, parseable and, optionally, contains admin user info
def validate_secrets_file(options, require_initialuser=True):
    try:
        secrets = read_json_file(options.secretsFile)
        # be sure they have at least initial user and password
        if require_initialuser and not 'content_admin_user' in secrets.keys():
            raise ValidationError('Missing content_admin_user in secrets file "%s"' % options.secretsFile)
        if require_initialuser and not 'content_admin_pass' in secrets.keys():
            raise ValidationError('Missing content_admin_pass in secrets file "%s"' % options.secretsFile)
        return secrets
    except IOError as ex:
        raise ValidationError('Could not open secrets file "%s"' % options.secretsFile)
    except ValueError as ex:
        raise ValidationError('The secrets file "%s" contains malformed json' % options.secretsFile)

# Be sure the installer executable actually exist and is an executable.
def validate_installer_executable(options):
    if not os.path.isfile(options.installer):
        raise ValidationError('The executable file %s does not exist' % options.installer)
    # Let's see if the file is an executable. On Windows, os.access(blah, os.X_OK) doesn't work
    # so we'll check that the file extension is one of our allowed ones.
    (base, extension) = os.path.splitext(options.installer)
    if not extension:
        raise ValidationError('The installer executable file %s is not executable (no extension)' % options.installer)
    if not extension.lower() in [ pathext.lower() for pathext in os.environ['PathExt'].split(';')]:
        raise ValidationError('The installer executable file %s exists but is not executable' % options.installer)
    return True

# Be sure an existing installation is at least a minimum version level.
def validate_upgrade_version(tabadmin_path, options):
    string_version = get_config_parameter(options, tabadmin_path, 'version.current')
    # version may be a string, or a float. handle it.
    if not string_version:
        raise ExistingInstallationError("Could not determine version of current installation")
    try:
        version = float(string_version)
        if version < MINIMUM_UPGRADEABLE_VERSION:
            raise ExistingInstallationError("The current version of the server (%s) cannot be safely upgraded" % str(string_version))
        return version
    except ValueError as ex:
        raise ExistingInstallationError("Could not determine version of existing installation (told us %s)" % str(string_version))

# If we're a multi-node installation, some versions can't be handled by this script
# because they require special care and feeding.
def validate_multi_node_upgrade_versions(server_version, tabadmin_path, options):
    worker_hosts = get_config_parameter(options, tabadmin_path, 'worker.hosts')
    if not worker_hosts:
        raise ExistingInstallationError("Could not determine if we are a cluster or not (cannot find worker.hosts)")
    hosts_parts = str(worker_hosts).split(',')
    if len(hosts_parts) < 2:
        print("This is not a cluster; no cluster-specific versioning check required")
        return True
    if server_version < MINIMUM_CLUSTER_UPGRADEABLE_VERSION:
        raise ExistingInstallationError("The current version of the cluster (%s) cannot be safely upgraded" % str(server_version))

# Raises an error if there is an existing installation of Tableau Server
def validate_no_existing_installation():
    if is_server_installed():
        raise ExistingInstallationError('An existing installation of Tableau Server has been found. '
            'Please uninstall it before updating to the new version. '
            'Data currently in Tableau server will be preserved during this process.')

#### Helper methods
####

# Helper method to write to stderr.
def print_error(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# Read a json file from storage, convert to python object
def read_json_file(file_path):
    with open(file_path) as json_file:
        return json.loads(json_file.read())

# Checks if there is an existing installation of Tableau Server
def is_server_installed():
    out = subprocess.check_output(['sc', 'query', 'type=', 'service', 'state=', 'all'])
    return ('Tableau Server' in out)

#### General methods to place configs, run utilities, whatever.
####

# We allow the user to specify the runas parameters in the secrets file to keep it seperate from the general config file.
# However, we need to use 'set' to get the server to recognize this.
# Note that 'tabadmin install' is needed for this to have any effect.
def configure_runas_secrets(tabadmin_path, secrets):
    had_runas_secret = False
    if must_set_value_for_parameter(secrets, 'runas_user'):
        run_command(tabadmin_path, ['set', 'service.runas.username', secrets['runas_user']])
        had_runas_secret = True
    if must_set_value_for_parameter(secrets, 'runas_pass'):
        run_command(tabadmin_path, ['set', 'service.runas.password', secrets['runas_pass']], False)
        had_runas_secret = True
    return had_runas_secret

# parameter must be in keys, and must not be null, emtpy, or just whitespace
def must_set_value_for_parameter(param_map, parameter):
    return parameter in param_map.keys() and not(not param_map[parameter] or param_map[parameter].isspace())

# Install Tableau as a service
def install_service(tabadmin_path, options, secrets):
    tabadmin_args = ['install', '--auto']
    if must_set_value_for_parameter(secrets, 'runas_pass'):
        tabadmin_args.extend(['--password', secrets['runas_pass']])
        
    run_command(tabadmin_path, tabadmin_args)

# Runs the installer.exe, and checks for the exit code
def run_inno_installer(inno_installer_args, options):
    if not options.installerLog:
        inno_log_file = tempfile.NamedTemporaryFile(prefix='TableauServerInstaller_', suffix='.log', delete=False);
        options.installerLog = inno_log_file.name
        inno_log_file.close()
    print('Installer log file at ' + options.installerLog)
    inno_installer_args.append('/LOG=' + options.installerLog)

    try:
        run_command(options.installer, inno_installer_args)
    except ExitCodeError as ex:
        if(ex.exit_code >= 1 and ex.exit_code <= 8):
            print_error(INNO_SETUP_EXIT_CODES[ex.exit_code])
        else:
            print_error('Unknown exit code from the Inno Setup installer: %d' % ex.exit_code)

        # print the last 5 lines from the Inno Setup log
        print_error('For more details see log file %s' % options.installerLog)
        with open(options.installerLog) as inno_log_file:
            content = inno_log_file.readlines()
            for line in content[-5:]:
                print_error(line)
        raise

# Where are tabadmin.exe, tabcmd.exe, etc located? Somewhere under our install path. Go find it!
def get_tab_binaries_path(options):
    print('Getting binaries path')
    for root, dirs, files in os.walk(options.installDir):
        if "tabadmin.exe" in files:
            return root
    return None

# Where is Windows' netsh.exe located? Probably under C:\Windows , but we can't guarantee that.
# Go find it under wherever Windows is actually installed.
def get_netsh_path():
    system_root = os.environ['SystemRoot']
    netsh_exe = os.path.join(system_root, "system32", "netsh.exe")
    if not os.path.isfile(netsh_exe):
        raise MissingExecutableError('The executable file %s does not exist' % netsh_exe)
    return netsh_exe

def get_workgroup_yml(options):
    print("get_workgroup_yml with installDir set to: %s" % options.installDir)
    workgroup_yml_base_dir = options.installDir if (options.installDir != TABLEAU_DEFAULT_INSTALL_DIR) else TABLEAU_DEFAULT_DATA_DIR
    workgroup_yml_path = os.path.join(workgroup_yml_base_dir, RELATIVE_WORKGROUP_YML_PATH)
    with open(workgroup_yml_path) as yaml_file:
        return yaml.safe_load(yaml_file)

# Get a configuration parameter using tabadmin get. The output contains some preceding text, so we have
# to ignore that that to get the actual value. The return value from tabadmin get is 0 whether that config parameter
# is actually set or not.
# Some older versions of the server don't have "tabadmin get". In that case, hack our way to it; find the
# workgroup.yml file, load it, and read the file directly from it.
# If we detect that "tabadmin get" isn't available, set a global flag so we don't waste time on further calls
# trying to call it.
def get_config_parameter(options, tabadmin_path, config_parameter):
    global TABADMIN_HAS_GET_COMMAND
    if TABADMIN_HAS_GET_COMMAND:
        try:
            tabadmin_output = run_command(tabadmin_path, ['get', config_parameter])
            # Filter out extraneous stuff from output; all we want is the value.
            match = re.search('(?<=is:)[\s\w]+', tabadmin_output)
            if match:
                value = match.group(0)
                if value:
                    return value.strip()
        except ExitCodeError as ex:
            pass
        # If we get here, running the command failed for some reason. fallback to trying to read the value directly.
        print("\"tabadmin get %s\" failed; falling back to manual parsing." % config_parameter)
        TABADMIN_HAS_GET_COMMAND = False
        return get_config_parameter(options, tabadmin_path, config_parameter)
    else:
        workgroup_yml = get_workgroup_yml(options)
        if config_parameter in workgroup_yml:
            if config_parameter in workgroup_yml:
                return str(workgroup_yml[config_parameter])
        return None

# Open the firewall on a given port.
def open_firewall_for_gateway(tabadmin_path, gateway_port, options):
    try:
        firewall_profile = 'private,domain'
        if options.enablePublicFwRule:
            firewall_profile = firewall_profile + ',public'

        netsh_path = get_netsh_path()
        run_command(netsh_path, ['advfirewall', 'firewall','add', 'rule', 'name=Tableau Server', 'dir=in', 'action=allow',
                                 'protocol=TCP', 'profile=' + firewall_profile, 'localport=' + gateway_port])
    except MissingExecutableError as mee:
        print_error('Cound not find executable: ' + mee)
        raise mee
    except ExitCodeError as ex:
        print_error('attempt to modify firewall using advfirewall exited with code %d' % ex.exit_code)
        raise ex

# If we need any firewall rules added, add them. If we have any, we'll always have one for the non-SSL port; if
# we have SSL enabled, open a hole for that, too.
def handle_firewalls(tabadmin_path, gateway_port, options):
    open_firewall = get_config_parameter(options, tabadmin_path, 'install.firewall.gatewayhole') or 'false'
    if open_firewall.lower() == 'true':
        print('Opening firewall for connections to the gateway')
        open_firewall_for_gateway(tabadmin_path, gateway_port, options)
        open_ssl_port = get_config_parameter(options, tabadmin_path, 'ssl.enabled') or 'false'
        if open_ssl_port.lower() == 'true':
            print('Opening firewall for connections to the gateway')
            ssl_gateway_port = get_config_parameter(options, tabadmin_path, 'ssl.port') or '443'
            open_firewall_for_gateway(tabadmin_path, ssl_gateway_port, options)
    else:
        print('Not opening firewall for connections to the gateway')

# Run a command. If the exit code isn't zero, it'll throw an exception.
# If exit code is zero, return the output from running the command.
def run_command(binary_path, arguments, show_args=True):
    if not os.path.isfile(binary_path):
        raise MissingExecutableError('The executable file %s does not exist' % binary_path)
    print("Running: " + str(binary_path) + str(arguments if show_args else ''))
    try:
        output = subprocess.check_output([binary_path] + arguments, stderr=subprocess.STDOUT)
        return output
    except subprocess.CalledProcessError as ex:
        print_error("Failed with output %s" % ex.output)
        raise ExitCodeError(binary_path, ex.returncode)

# Install the server; run installer, install services, activate, register, open firewall ports, whatever.
def run_install(options, secrets):
    # Run the installer. This unpacks the binaries and does initial boostrapping. After this is done, we have
    # a runnable server.
    print('Running installer executable')

    inno_installer_args = [
        '/VERYSILENT',          # No progress GUI, message boxes still possible
        '/SUPPRESSMSGBOXES',    # No message boxes. Only has an effect when combined with '/SILENT' or '/VERYSILENT'.
        '/ACCEPTEULA',
        '/DIR=' + options.installDir
    ]
    if options.configFile:
        inno_installer_args.append('/CUSTOMCONFIG=' + options.configFile)

    run_inno_installer(inno_installer_args, options)

    # Get path to relevant binaries
    binaries_path = get_tab_binaries_path(options)
    tabadmin_path = os.path.join(binaries_path, 'tabadmin.exe')
    tabcmd_path = os.path.join(binaries_path, 'tabcmd.exe')

    # If our secrets file has runas config info in it, the values will be set for the server
    if configure_runas_secrets(tabadmin_path, secrets):
        print('Set runas credentials into configuration')
    else:
        print('Runas credentials not specified; using defaults')

    # Run configure to be sure any credential changes are properly distributed. This also works around AWS-related configuration quirks.
    run_command(tabadmin_path, ['configure'])

        # Install the Windows service
    install_service(tabadmin_path, options, secrets)

    # If they're using the 'trial' option, activate with that. Otherwise, use the license key given on the cmdline
    if options.trial:
        print('Activating product using trial option')
        run_command(tabadmin_path, ['activate', '--trial'])
    else:
        print('Activating product')
        run_command(tabadmin_path, ['activate', '--key', options.licenseKey])

    print('Registering product set')
    run_command(tabadmin_path, ['register', '--file', options.registrationFile])

    # Start it up!
    print('Server is starting')
    run_command(tabadmin_path, ['start'])

    # Register our initial user
    print('Server is installed and running')
    gateway_port = get_config_parameter(options, tabadmin_path, 'worker0.gateway.port') or '80'
    # Just in case we're using SSL, we'll be redirected, so using the non-ssl port will be fine.
    # However, skip checking the cert in case it's self-signed.
    run_command(tabcmd_path, ['initialuser', '--server', 'localhost:' + gateway_port,
                '--no-certcheck', '--no-prompt',
                '--username', secrets['content_admin_user'], '--password', secrets['content_admin_pass']]
                , False)
    print('Initial admin created')

    # Open any firewall holes, if desired.
    handle_firewalls(tabadmin_path, gateway_port, options)

    print('Installation complete')

def run_upgrade(options, secrets):
    print('Running installer executable to perform update')

    print("Checking that there's a previous installation at /DIR")
    binaries_path = get_tab_binaries_path(options)
    if not binaries_path:
        raise ExistingInstallationError("No existing installation detected at %s; cannot upgrade" % options.installDir)
    tabadmin_path = os.path.join(binaries_path, 'tabadmin.exe')

    print("Checking that we can safely upgrade the current version; some older versions can't be upgraded with this script.")
    server_version = validate_upgrade_version(tabadmin_path, options)
    print("Checking to see if this is a cluster, which would require a minimum version to upgrade from")
    validate_multi_node_upgrade_versions(server_version, tabadmin_path, options)

    inno_installer_args = [
        '/VERYSILENT',          # No progress GUI, message boxes still possible
        '/SUPPRESSMSGBOXES',    # No message boxes. Only has an effect when combined with '/SILENT' or '/VERYSILENT'.
        '/ACCEPTEULA',
        '/DIR=' + options.installDir
    ]
    if options.fastuninstall:
        print("Using FASTUNINSTALL option")
        inno_installer_args.append('/FASTUNINSTALL')
    else:
        print("Not using FASTUNINSTALL option")

    run_inno_installer(inno_installer_args, options)

    # So, our paths likely have changed after the upgrade. Find them again.
    binaries_path = get_tab_binaries_path(options)
    if not binaries_path:
        raise ExistingInstallationError("Could not find newly installed binaries")
    tabadmin_path = os.path.join(binaries_path, 'tabadmin.exe')

    # If a secrets file was specified (which is required if they're not using the default runas username 
    # and password), set the values.
    if configure_runas_secrets(tabadmin_path, secrets):
        print('Set runas credentials into configuration for performing upgrade')
        # Run configure to be sure any credential changes are properly distributed.
        run_command(tabadmin_path, ['configure'])
    else:
        print('Runas credentials not specified; username will be unchanged, password assumed to be blank')

    # Re-install the Windows service (just in case the runas user changed)
    install_service(tabadmin_path, options, secrets)
    
    # Get path to relevant binaries
    # Start it up!
    print('Server is starting')
    run_command(tabadmin_path, ['start'])
    print('Upgrade complete.')

# Main entry point
def main():
    # Make sure they're using a version of Python we're okay with
    try:
        validate_python_version()
        options = get_options()
        if options.installer_action == 'install':
            print("Trying to perform install")
            validate_no_existing_installation()
            secrets = validate_install_inputs(options)
            run_install(options, secrets)
        elif options.installer_action == 'upgrade':
            print("Trying to perform update")
            secrets = validate_upgrade_inputs(options)
            run_upgrade(options, secrets)
        else:
            raise OptionsError("Unknown action %s" % options.installer_action)
        return 0
    # Uncaught exceptions will result in an exit with 1
    except ExistingInstallationError as ex:
        print_error(ex)
        return 2
    except OptionsError as ex:
        print_error(ex)
        return 3
    except ExitCodeError as ex:
        return 4
    except ValidationError as ve:
        print_error(ve)
        return 5

if __name__ == '__main__':
    sys.exit(main())