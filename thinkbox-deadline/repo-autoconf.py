import subprocess
import os
import re
import socket

DB_CONNECT = 'C:\DeadlineRepository7\settings\dbConnect.xml'

def change_line(src, pattern, sub, dest=None, verbose=False): 
    dest = dest if dest else src
    lines = []

    if verbose:
        print 'Editing:', src
        print 'Searching for:', pattern
        print 'Replacing with:', sub

    with open(src, 'r') as f:
        lines = f.readlines()

    with open(dest, 'w') as f:
        for line in lines:
            if verbose and re.search(pattern, line):
                print '\tBefore:', line
                print '\tAfter:', re.sub(pattern, sub, line)
            f.write(re.sub(pattern, sub, line))


def set_database(database):
	change_line(DB_CONNECT, '(<Hostname>).*', '\g<1>' + database + '</Hostname>', verbose=True)


hostname = socket.gethostname()
ipAddress = socket.gethostbyname(hostname)

set_database(ipAddress)