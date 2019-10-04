"""
pingsweeper.py

@Description : Script that takes in an IP range and conducts a ping sweep 
to detect if which hosts in that range are up.

@Author: Jon Bauer (JonBauer123)
"""
import sys
import ipaddress
import os

def parseCider(range):
    """
    Gets a list of every IP address in the Cider notation defined network
    
    @range : Cider defined IP address network

    @return : list of individual IPs in the network
    """
    ipList = []
    for ip in ipaddress.ip_network(range):
        ipList.append(str(ip))

    return ipList

def parseDash(range):
    """
    Gets a list of every IP address in the Dash notation defined network
    
    @range : Dash defined IP address network

    @return : list of individual IPs in the network
    """
    ipList = []
    start, end = range.split("-")
    start = ipaddress.ip_address(start)
    end = ipaddress.ip_address(end)

    while start < end + 1:
        ipList.append(str(start))
        start += 1

    return ipList

def parseIP(range):
    """
    Checks the IP address range. decides if it is in Cider or Dash
    notation, calls the helper function and returns a list of the range.

    Cider : 10.10.0.0/16
    Dash : 10.10.1.1-10.10.2.50

    @range : a string of IP address ranges

    @return : list of individual IP ranges
    """
    if '/' in range:
        return parseCider(range)
    elif '-' in range:
        return parseDash(range)
    else:
        invalid("Invalid IP address range")

def sweep(range):
    """
    Conducts a ping sweep for the IPs that are passed

    @range : list of IPs to conduct pings on 
    """

    # Sets the ping timer for different OSs

    numPings = None
    linuxPipe = ""
    if os.name == "nt":
        numPings = "-n"
    else:
        numPings = "-c"
        linuxPipe = " > /dev/null"

    for ip in range:
        response = os.system(f"ping {numPings} 1 {ip}{linuxPipe}")

        if response == 0:
            print(f"\tHost: {ip} is up.")

def invalid(error):
    """
    Prints the error message, the usage, and exits the program
    """
    print(error)
    print("Usage: python3 pingsweeper.py <IP_RANGE>")
    exit()

def main():

    # Input Checking
    if len(sys.argv) != 2:
        invalid("Invalid number of arguments.")

    print("Scanning IP Range: " + sys.argv[1])

    range = parseIP(sys.argv[1])
    sweep(range)

if __name__ == "__main__":
    main()