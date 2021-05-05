"""	
Bootstrap an installation of TLJH.	
Sets up just enough TLJH environments to invoke tljh.installer.	
This script is run as:	
    curl <script-url> | sudo python3 -	
Constraints:	
  - Entire script should be compatible with Python 3.6 (We run on Ubuntu 18.04+)	
  - Script should parse in Python 3.4 (since we exit with useful error message on Ubuntu 14.04+)	
  - Use stdlib modules only	
"""	
import os	
import subprocess	
import sys	
import logging	
import shutil	

logger = logging.getLogger(__name__)	

def get_os_release_variable(key):	
    """	
    Return value for key from /etc/os-release	
    /etc/os-release is a bash file, so should use bash to parse it.	
    Returns empty string if key is not found.	
    """	
    return subprocess.check_output([	
        '/bin/bash', '-c',	
        "source /etc/os-release && echo ${{{key}}}".format(key=key)	
    ]).decode().strip()	

# Copied into tljh/utils.py. Make sure the copies are exactly the same!	
def run_subprocess(cmd, *args, **kwargs):	
    """	
    Run given cmd with smart output behavior.	
    If command succeeds, print output to debug logging.	
    If it fails, print output to info logging.	
    In TLJH, this sends successful output to the installer log,	
    and failed output directly to the user's screen	
    """	
    logger = logging.getLogger('tljh')	
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, *args, **kwargs)	
    printable_command = ' '.join(cmd)	
    if proc.returncode != 0:	
        # Our process failed! Show output to the user	
        logger.error('Ran {command} with exit code {code}'.format(	
            command=printable_command, code=proc.returncode	
        ))	
        logger.error(proc.stdout.decode())	
        raise subprocess.CalledProcessError(cmd=cmd, returncode=proc.returncode)	
    else:	
        # This goes into installer.log	
        logger.debug('Ran {command} with exit code {code}'.format(	
            command=printable_command, code=proc.returncode	
        ))	
        # This produces multi line log output, unfortunately. Not sure how to fix.	
        # For now, prioritizing human readability over machine readability.	
        logger.debug(proc.stdout.decode())	

def validate_host():	
    """	
    Make sure TLJH is installable in current host	
    """	
    # Support only Ubuntu 18.04+	
    distro = get_os_release_variable('ID')	
    version = float(get_os_release_variable('VERSION_ID'))	
    if distro != 'ubuntu':	
        print('The Littlest JupyterHub currently supports Ubuntu Linux only')	
        sys.exit(1)	
    elif float(version) < 18.04:	
        print('The Littlest JupyterHub requires Ubuntu 18.04 or higher')	
        sys.exit(1)	

    if sys.version_info < (3, 5):	
        print("bootstrap.py must be run with at least Python 3.5")	
        sys.exit(1)	

    if not (shutil.which('systemd') and shutil.which('systemctl')):	
        print("Systemd is required to run TLJH")	
        # Only fail running inside docker if systemd isn't present	
        if os.path.exists('/.dockerenv'):	
            print("Running inside a docker container without systemd isn't supported")	
            print("We recommend against running a production TLJH instance inside a docker container")	
            print("For local development, see http://tljh.jupyter.org/en/latest/contributing/dev-setup.html")	
        sys.exit(1)	

def main():	
    validate_host()	
    install_prefix = os.environ.get('TLJH_INSTALL_PREFIX', '/opt/tljh')	
    hub_prefix = os.path.join(install_prefix, 'hub')	

    # Set up logging to print to a file and to stderr	
    os.makedirs(install_prefix, exist_ok=True)	
    file_logger_path = os.path.join(install_prefix, 'installer.log')	
    file_logger = logging.FileHandler(file_logger_path)	
    # installer.log should be readable only by root	
    os.chmod(file_logger_path, 0o500)	

    file_logger.setFormatter(logging.Formatter('%(asctime)s %(message)s'))	
    file_logger.setLevel(logging.DEBUG)	
    logger.addHandler(file_logger)	

    stderr_logger = logging.StreamHandler()	
    stderr_logger.setFormatter(logging.Formatter('%(message)s'))	
    stderr_logger.setLevel(logging.INFO)	
    logger.addHandler(stderr_logger)	
    logger.setLevel(logging.DEBUG)	

    logger.info('Checking if TLJH is already installed...')	
    if os.path.exists(os.path.join(hub_prefix, 'bin', 'python3')):	
        logger.info('TLJH already installed, upgrading...')	
        initial_setup = False	
    else:	
        logger.info('Setting up hub environment')	
        initial_setup = True	
        # Install software-properties-common, so we can get add-apt-repository	
        # That helps us make sure the universe repository is enabled, since	
        # that's where the python3-pip package lives. In some very minimal base	
        # VM images, it looks like the universe repository is disabled by default,	
        # causing bootstrapping to fail.	
        run_subprocess(['apt-get', 'update', '--yes'])	
        run_subprocess(['apt-get', 'install', '--yes', 'software-properties-common'])	
        run_subprocess(['add-apt-repository', 'universe'])	

        run_subprocess(['apt-get', 'update', '--yes'])	
        run_subprocess(['apt-get', 'install', '--yes', 	
            'python3',	
            'python3-venv',	
            'python3-pip',	
            'git'	
        ])	
        logger.info('Installed python & virtual environment')	
        os.makedirs(hub_prefix, exist_ok=True)	
        run_subprocess(['python3', '-m', 'venv', hub_prefix])	
        logger.info('Set up hub virtual environment')	

    if initial_setup:	
        logger.info('Setting up TLJH installer...')	
    else:	
        logger.info('Upgrading TLJH installer...')	

    pip_flags = ['--upgrade']	
    if os.environ.get('TLJH_BOOTSTRAP_DEV', 'no') == 'yes':	
        pip_flags.append('--editable')	
    tljh_repo_path = os.environ.get(	
        'TLJH_BOOTSTRAP_PIP_SPEC',	
        'git+https://github.com/jupyterhub/the-littlest-jupyterhub.git'	
    )	

    run_subprocess([	
        os.path.join(hub_prefix, 'bin', 'pip'),	
        'install'	
    ] + pip_flags + [tljh_repo_path])	
    logger.info('Setup tljh package')	

    logger.info('Starting TLJH installer...')	
    os.execv(	
        os.path.join(hub_prefix, 'bin', 'python3'),	
        [	
            os.path.join(hub_prefix, 'bin', 'python3'),	
            '-m',	
            'tljh.installer',	
        ] + sys.argv[1:]	
    )	


if __name__ == '__main__':	
    main() 	

