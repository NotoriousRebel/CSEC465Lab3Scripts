#!/usr/bin/env python3
"""axfrtest.py

Tests the nameservers of a domain for AXFR zone transfers.

Python 3.7.3
"""

from argparse import ArgumentParser
import dns.resolver
import dns.query
import dns.zone


def parse_arguments():
    """
    Runs argparse

    Returns:
        argparse.Namespace: collection of args from cmd line
    """
    parser = ArgumentParser(
        description='Test a domain for AXFR zone transfers.')
    parser.add_argument(
        '-d',
        '--domain',
        help='name of the domain to be tested',
        type=str,
        required=True)
    args = parser.parse_args()
    return args


def axfrtest(domain: str):
    """
    Finds all nameservers registered to a domian and asks for an AXFR zone
        transfer from each.
    Prints if a nameserver allowed AXFR, passes otherwise.
    @:param
        domain (str): domain and TLD to be tested
    """
    try:
        nameservers = dns.resolver.query(domain, 'NS')
        # get list of nameservers for given domain
        for nameserver in nameservers.rrset:
            nameserver = str(nameserver)
            if nameserver and nameserver != "":
                axfr = dns.query.xfr(nameserver, domain, lifetime=5)
                try:
                    zone = dns.zone.from_xfr(axfr)
                    # attempt axfr record transfer
                    if zone:
                        print(f'AXFR Transfer Allowed for {zone}')
                        print('Printing contents of record')
                        for name, node in zone.nodes.items():
                            rdatasets = node.rdatasets
                            print('\n'.join(map(str, rdatasets)))
                except (dns.exception.FormError, dns.query.TransferError, EOFError):
                    print(f'No information found for: {nameserver}')
    except dns.resolver.NXDOMAIN:
        print('Error: NXDOMAIN -- the query name does not exist')


def main():
    """
    Main function
    Parses arguments and passes to axfrtest
    """
    args = parse_arguments()
    axfrtest(args.domain)


if __name__ == '__main__':
    main()
