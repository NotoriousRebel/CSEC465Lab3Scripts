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
    """Runs argparse

    Returns:
        argparse.Namespace: collection of args from cmd line
    """
    parser = ArgumentParser(description='Test a domain for AXFR zone transfers.')
    parser.add_argument('domain', help='name of the domain to be tested')
    args = parser.parse_args()
    return args

def axfrtest(domain):
    """Finds all nameservers registered to a domian and asks for an AXFR zone
        transfer from each.

    Prints if a nameserver allowed AXFR, passes otherwise.

    Args:
        domain (str): domain and TLD to be tested
    """
    try:
        nameservers = dns.resolver.query(domain, 'NS')
        for nameserver in nameservers.rrset:
            nameserver = str(nameserver)
            if nameserver and nameserver != "":
                axfr = dns.query.xfr(nameserver, domain, lifetime=5)
                try:
                    zone = dns.zone.from_xfr(axfr)
                    if zone:
                        print('{} allowed AXFR'.format(nameserver))
                except (dns.exception.FormError, dns.query.TransferError, EOFError):
                    continue
    except dns.resolver.NXDOMAIN:
        print('Error: NXDOMAIN -- the query name does not exist')

def main():
    """Main function

    Parses arguments and passes to axfrtest
    """
    args = parse_arguments()
    axfrtest(args.domain)

if __name__ == '__main__':
    main()
