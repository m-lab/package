#!/usr/bin/python
"""Generates an rsyncd configuration."""

import optparse
import sys

ALLOW_HOSTS = ['108.170.192.0/18', '108.177.0.0/20', '142.250.0.0/15',
               '172.217.0.0/16', '172.253.0.0/16', '173.194.0.0/16',
               '192.178.0.0/15', '199.87.241.32/28', '207.223.160.0/20',
               '209.85.128.0/17', '216.239.32.0/19', '216.58.192.0/19',
               '64.233.160.0/19', '66.102.0.0/20', '66.249.64.0/19',
               '70.32.128.0/19', '70.90.219.48/29', '70.90.219.72/29',
               '72.14.192.0/18', '74.125.0.0/16', '23.228.128.64/26']

RSYNC_HEADER = """
pid file = /var/run/rsyncd.pid
port = {port}
hosts allow = {allow_hosts}
"""

MODULE_TEMPLATE = """
[{module}]
    comment = Data from {module}: See http://www.measurementlab.net
    path = {directory}
    list = yes
    read only = yes
    transfer logging = no
    ignore errors = no
    ignore nonreadable = yes
"""


def usage():
    return """
DESCRIPTION:
    rsyncd_config.py generates rsyncd configuration files for M-Lab experiments.

EXAMPLES:

    Standard slice configuration:

        rsyncd_config.py \\
            --module mlab_slicename \\
            --directory /var/spool/mlab_slicename

    Generates:
        pid file=/var/run/rsyncd.pid
        port = 7999
        hosts allow = 108.170.192.0/18, 108.177.0.0/20, ....
        # MODULE OPTIONS
        [mlab_slicename]
            comment = Data from mlab_slicename: See http://www.measurementlab.net
            path = /var/spool/mlab_slicename
            list = yes
            read only = yes
            transfer logging = no
            ignore errors = no
            ignore nonreadable = yes

    Custom slice configuration (multiple modules):

        rsyncd_config.py \\
            --module sidestream \\
            --directory /var/spool/iupui_npad/SideStream \\
            --module paris-traceroute \\
            --directory /var/spool/iupui_npad/paris-traceroute

    Custom slice configuration (differnt port and extra allowed hosts):

        rsyncd_config.py \\
            --port 51234 \\
            --module mlab_slicename \\
            --directory /var/spool/mlab_slicename \\
            --allow 72.14.192.0/18 --allow 74.125.0.0/16
"""


def parse_flags(args):

    parser = optparse.OptionParser(usage=usage())
    parser.add_option('',
                      '--port',
                      default='7999',
                      metavar='7999',
                      help='The rsync port. Can only be specified once.')
    parser.add_option(
        '',
        '--module',
        dest='modules',
        action='append',
        metavar='<slicename>',
        help='The name of an rsync module. May be specified multiple times.')
    parser.add_option(
        '',
        '--directory',
        dest='directories',
        action='append',
        metavar='/var/spool/<slicename>',
        help=('The full path to a directory containing the module data. Must '
              'be specified as many times as --module.'))
    parser.add_option(
        '',
        '--allow',
        dest='allow_hosts',
        action='append',
        default=ALLOW_HOSTS,
        metavar='11.22.33.0/24',
        help=('In addition to the default hosts allow set, allow these hosts. '
              'May be specified multiple times.'))

    (options, _) = parser.parse_args(args)

    if len(args) == 1:
        parser.print_help()
        sys.exit(1)

    if not options.modules:
        print >> sys.stderr, 'Error: please specify at least one "--module="'
        sys.exit(1)

    if len(options.modules) != len(options.directories):
        print >> sys.stderr, (
            'Error: "--module=" must be specified as many times as '
            '"--directory="')
        sys.exit(1)

    return options


def main(args):
    options = parse_flags(args)
    hosts = ', '.join(options.allow_hosts)
    output = RSYNC_HEADER.format(
        port=options.port, allow_hosts=hosts)
    for module, directory in zip(options.modules, options.directories):
        output += MODULE_TEMPLATE.format(module=module, directory=directory)
    print output


if __name__ == '__main__':
    main(sys.argv)
