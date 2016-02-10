#!/usr/bin/env python
import json
import optparse
import os
import sys
from optparse import OptionParser
from subprocess import call


DNS_DIR = '/etc/bind/'
DNS_CONF_FILE = 'named.conf'
DNS_CONF = """\
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian.gz for information on the
// structure of BIND configuration files in Debian, *BEFORE* you customize
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
view "internal" {{
  match-clients {{ 10.0.0.0/8; }};
  allow-query {{ 10.0.0.0/8; }};
  recursion yes;
  zone "{0}" IN {{
    type master;
    file "{1}{2}";
  }};
  include "{1}named.conf.default-zones";
}};
view "external" {{
  match-clients {{ any; }};
  allow-query {{ any; }};
  recursion no;
  zone "{0}" IN {{
    type master;
    file "{1}{3}";
  }};
  include "{1}named.conf.default-zones";
}};
"""
DNS_CONF_OPT_FILE = 'named.conf.options'
DNS_CONF_OPT = """\
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        // forwarders {
        //      0.0.0.0;
        // };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on { any; };
        forwarders {
             8.8.8.8;
             8.8.4.4;
        };
};
"""
LAN_ZONE_FILE = 'cf.com.lan'
WAN_ZONE_FILE = 'cf.com.wan'
ZONE_CONF = """\
;
; BIND data file for local loopback interface
;
$TTL    604800
$ORIGIN {2}.
@       IN      SOA     ns      root (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns.{2}.
{2}.        IN      A       {0}
ns      IN      A       {0}
{3}      IN      A       {1}
*.{3}    IN      A       {1}
"""
ETH0_CFG = '/etc/network/interfaces.d/eth0.cfg'
ETH0_STATIC = """\
iface eth0 inet static
   address {0}
   netmask 255.255.255.0
   network 10.0.0.0
   gateway 10.0.0.1
"""
RESOLV_CONF = '/etc/resolvconf/resolv.conf.d/head'


def set_config(file, contents):
    with open(file, 'w') as f:
        f.write(contents)


def parse_dns_info(parser):
    (options, args) = parser.parse_args()

    domain_name = options.domain_name
    if not domain_name:
        print "The domain name is not provided."
        parser.print_help()
        sys.exit()

    cf_internal_ip = options.cf_internal_ip
    if not cf_internal_ip:
        print "The internal IP of CloudFoundry is not provided."
        parser.print_help()
        sys.exit()

    call("ifconfig eth0 | sed -n '/inet addr/p' | awk -F'[: ]+' '{print $4}' > /tmp/dns-internal-ip", shell=True)
    with open('/tmp/dns-internal-ip', 'r') as f:
        dns_internal_ip = f.read().strip()
    if not dns_internal_ip:
        print "Can not get the internal IP of DNS (IP of eth0). Exit!"
        sys.exit()


    dns_external_ip = None
    cf_external_ip = None
    settings_filename = options.settings_filename
    if settings_filename and os.path.isfile(settings_filename):
        dns_external_ip, cf_external_ip = parse_settings(settings_filename)

    # If external IPs of CF and DNS are specified as arguments, adopt them.
    if options.dns_external_ip:
        dns_external_ip = options.dns_external_ip
    if options.cf_external_ip:
        cf_external_ip = options.cf_external_ip

    if not (dns_external_ip and cf_external_ip):
        print "Can't get the external IP for CloudFoundry or DNS."
        print "Exit!"
        sys.exit()

    if options.verbose:
        print domain_name, cf_external_ip, dns_external_ip, cf_internal_ip, dns_internal_ip

    return domain_name, cf_external_ip, dns_external_ip, cf_internal_ip, dns_internal_ip


def parse_settings(file):
    # Get the reserved IP for CloudFoundry and DNS server
    with open(file, 'r') as f:
        contents = f.read()
    settings = json.loads(contents)
    dns_reserved_ip = settings.get('dns-ip')
    cf_reserved_ip = settings.get('cf-ip')
    return [dns_reserved_ip, cf_reserved_ip]


def change_eth0_to_static(dev_box_ip):
    with open(ETH0_CFG, 'r') as f:
        contents = f.read()
    contents = contents.replace('iface eth0 inet dhcp', ETH0_STATIC.format(dev_box_ip))
    set_config(ETH0_CFG, contents)

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("-d", "--domain", dest="domain_name",
                      help="The domain name")
    parser.add_option("-i", "--cf-internal", dest="cf_internal_ip",
                      help="The internal IP of CloudFoundry")
    parser.add_option("-e", "--cf-external", dest="cf_external_ip",
                      help="The external IP of CloudFoundry")
    parser.add_option("-n", "--dns-external", dest="dns_external_ip",
                      help="The external IP of DNS")
    parser.add_option("-s", "--settings", dest="settings_filename",
                      help="The file name of json settings")
    parser.add_option("-v", "--verbose",
                      action="store_true", dest="verbose",
                      help="Print verbose information")

    domain_name, cf_external_ip, dns_external_ip, cf_internal_ip, dns_internal_ip = parse_dns_info(parser)
    domain_name_prefix = domain_name.split('.')[0]
    zone_name = '.'.join(domain_name.split('.')[1:])
    print "Will setup DNS for the domain {0}".format(domain_name)

    # Install bind9
    call('apt-get -qq update', shell=True)
    call('apt-get install -yqq bind9 bind9utils', shell=True)

    dns_conf = DNS_CONF.format(zone_name, DNS_DIR, LAN_ZONE_FILE, WAN_ZONE_FILE)
    dns_conf_file = os.path.join(DNS_DIR, DNS_CONF_FILE)
    set_config(dns_conf_file, dns_conf)

    dns_conf_opt_file = os.path.join(DNS_DIR, DNS_CONF_OPT_FILE)
    set_config(dns_conf_opt_file, DNS_CONF_OPT)

    lan_zone_conf = ZONE_CONF.format(dns_internal_ip, cf_internal_ip, zone_name, domain_name_prefix)
    lan_zone_file = os.path.join(DNS_DIR, LAN_ZONE_FILE)
    set_config(lan_zone_file, lan_zone_conf)

    wan_zone_conf = ZONE_CONF.format(dns_external_ip, cf_external_ip, zone_name, domain_name_prefix)
    wan_zone_file = os.path.join(DNS_DIR, WAN_ZONE_FILE)
    set_config(wan_zone_file, wan_zone_conf)

    change_eth0_to_static(dns_internal_ip)
    call('echo "nameserver {0}" > {1}'.format(dns_internal_ip, RESOLV_CONF), shell=True)
    call('resolvconf -u', shell=True)
    # Restart bind9
    call('/etc/init.d/bind9 restart', shell=True)
