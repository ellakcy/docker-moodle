import socket
import random

def get_non_listening_tcp_ports(host, from_port=0, to_port=0,ports_to_exclude=()):
    '''
     Get a list for TCP Ports that have no active connections on them.

     :param host IP or domain to check for active connections
     :param from_port Port to start scanning. If 0 defaults to 1024
     :param to_post Port to stop Scanning. If 0 defaults to 49151
     :param ports_to_exclude A list of ports toi exclude from scanning

     :raise InvalidNetworkPort If from_port or to_port port is a non valid values (< 0 > 49151)
     :raise ValueError If from_port has value greater than to_port

     :return list(int)
    '''
    remoteServerIP = socket.gethostbyname(host)

    from_port = int(from_port)
    # Try not to list system defined port
    if from_port <= 0:
        from_port = 1024

    to_port=int(to_port)
    # Set to maximum
    if to_port <= 0:
        to_port = 49151

    if from_port > to_port:
        raise ValueError('Range is incorrectly given');

    # Store all closed ports
    available_ports = []

    for port in range(from_port, to_port + 1):

        if(port in ports_to_exclude):
            continue

        # Open a network connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((remoteServerIP, port))
        sock.close()

        if result != 0:
            available_ports.append(port)

    return available_ports

def validate_port(value):
    '''
     Validate a network port
     :param value The port as integer or numeric string
     :raises InvalidNetworkPort If network port is invalid
    '''
    value = int(value)
    if value >= 1 and value <= 49151:
        return value
    else:
        raise InvalidNetworkPort("This is not a valid port")

class InvalidNetworkPort(Exception):
    # Exception that is used when a port has an incorrect value
    pass
    