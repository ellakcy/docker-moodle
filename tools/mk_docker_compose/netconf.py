import socket
import os
import yaml

def get_non_listening_tcp_port(host, from_port=0, to_port=0):
    '''
     Get a list for TCP Ports that have no active connections on them.

     :param host IP or domain to check for active connections
     :param from_port Port to start scanning. If 0 defaults to 1024
     :param to_post Port to stop Scanning. If 0 defaults to 49151

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

    for port in range(from_port, to_port + 1):
        # Open a network connection
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        result = sock.connect_ex((remoteServerIP, port))
        sock.close()

        if result != 0:
            return port

    raise ValueError("Open Port not found")