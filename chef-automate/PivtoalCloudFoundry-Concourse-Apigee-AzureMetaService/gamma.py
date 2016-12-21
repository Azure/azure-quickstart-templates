#!/usr/bin/env python
import click
import install_steps
import json
import os
import sys
import re
import Utils.HandlerUtil as Util
from Utils.WAAgentUtil import waagent
from subprocess import call, Popen, PIPE

from install_steps import prep_containers_and_tables, \
    create_certs, process_template_manifests, copy_files_home, \
    install_bosh_init, setup_dns, deploy_bosh, set_director_id, \
    download_from_pivnet_upload_to_bosh, deploy, configure_security_groups, \
    run_errands, deploy_metabroker, display_creds


def get_settings():
    hutil = Util.HandlerUtility(
        waagent.Log,
        waagent.Error,
        "bosh-deploy-script")
    hutil.do_parse_context("enable")
    settings_path = os.path.join('bosh', 'settings')

    call("mkdir -p ./bosh", shell=True)

    if not os.path.isfile(settings_path):
        settings = hutil.get_public_settings()
        with open(settings_path, "w") as tmpfile:
            tmpfile.write(json.dumps(settings, indent=4, sort_keys=True))
    else:
        with open(settings_path) as settings_file:
            settings = json.load(settings_file)

    return settings


def write_settings(settings_dict):
    settings_path = os.path.join('bosh', 'settings')

    with open(settings_path, "w") as tmpfile:
        tmpfile.write(json.dumps(settings_dict, indent=4, sort_keys=True))


@click.group(chain=True, invoke_without_command=True)
@click.option('--index', default='index.yml', help='Manifest index file')
@click.pass_context
def cli(ctx, index):
    # Get settings from CustomScriptForLinux extension configurations
    waagent.LoggerInit('/var/log/waagent.log', '/dev/null')
    ctx.meta["settings"] = settings = get_settings()
    ctx.meta["index-file"] = index

    group = ctx.command
    commands = sorted([c for c in group.commands])

    # start logging to stdout and install.log
    sys.stdout = os.fdopen(sys.stdout.fileno(), 'w', 0)

    username = settings["username"]
    log_file = os.path.join("/home", username, "pcf_install.log")

    tee = Popen(["tee", log_file], stdin=PIPE)
    os.dup2(tee.stdin.fileno(), sys.stdout.fileno())
    os.dup2(tee.stdin.fileno(), sys.stderr.fileno())

    if ctx.invoked_subcommand is None:
        for command in commands:
            command = re.sub('\d{2}_', '', command)
            print "Running {0}...".format(command)
            ctx.invoke(eval(command))
    else:
        pass


@cli.resultcallback()
def step_callback(ctx_array, index):
    last = ctx_array[len(ctx_array) - 1]

    if last.meta['settings']:
        write_settings(last.meta['settings'])


@cli.command('01_prep_containers')
@click.pass_context
def prep_containers(ctx):
    return install_steps.prep_containers_and_tables.do_step(ctx)


@cli.command('02_create_certs')
@click.pass_context
def create_certs(ctx):
    return install_steps.create_certs.do_step(ctx)


@cli.command('03_process_template_manifests')
@click.pass_context
def process_template_manifests(ctx):
    return install_steps.process_template_manifests.do_step(ctx)


@cli.command('04_copy_files_home')
@click.pass_context
def copy_files_home(ctx):
    return install_steps.copy_files_home.do_step(ctx)


@cli.command('05_install_bosh_init')
@click.pass_context
def install_bosh_init(ctx):
    return install_steps.install_bosh_init.do_step(ctx)


@cli.command('06_setup_dns')
@click.pass_context
def setup_dns(ctx):
    return install_steps.setup_dns.do_step(ctx)


@cli.command('07_deploy_bosh')
@click.pass_context
def deploy_bosh(ctx):
    return install_steps.deploy_bosh.do_step(ctx)


@cli.command('08_set_director_id')
@click.pass_context
def set_director_id(ctx):
    return install_steps.set_director_id.do_step(ctx)


@cli.command('09_download_from_pivnet_upload_to_bosh')
@click.pass_context
def download_from_pivnet_upload_to_bosh(ctx):
    return install_steps.download_from_pivnet_upload_to_bosh.do_step(ctx)


@cli.command('10_configure_security_groups')
@click.pass_context
def configure_security_groups(ctx):
    return install_steps.configure_security_groups.do_step(ctx)


@cli.command('11_deploy')
@click.pass_context
def deploy(ctx):
    return install_steps.deploy.do_step(ctx)


@cli.command('12_run_errands')
@click.pass_context
def run_errands(ctx):
    return install_steps.run_errands.do_step(ctx)

@cli.command('13_deploy_metabroker')
@click.pass_context
def deploy_metabroker(ctx):
    return install_steps.deploy_metabroker.do_step(ctx)

@cli.command('14_display_creds')
@click.pass_context
def display_creds(ctx):
    return install_steps.display_creds.do_step(ctx)

if __name__ == '__main__':
    cli()
