import socket
import os
import yaml
import docker

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

def extractPortsFromDockerComposeYaml(pathfile):

    ports_to_ignore=[]

    with open(pathfile, "r") as docker_compose_file:
        docker_compose=yaml.safe_load(docker_compose_file)
        for service_name,service_conf in docker_compose['services'].items():
            if "ports" in service_conf:
                for port in service_conf['ports']:
                    ports_to_ignore.append(int(port.split(":")[0]))

    return ports_to_ignore

def scanForAllocatedPorts(dir):
    if(os.path.isdir(dir)==False):
        raise ValueError(dir+" is not a directory")

    dirs_to_scan=[dir]
    ports_to_ignore=[]

    for item in dirs_to_scan:
        for file_or_directory in os.scandir(item):
            if(os.path.isdir(file_or_directory)):
                dirs_to_scan.append(file_or_directory)
            elif( file_or_directory.name == "docker-compose.yml" or file_or_directory.name == "docker-compose.yaml" ): 
                ports_to_ignore+=extractPortsFromDockerComposeYaml(file_or_directory.path)
    
    return ports_to_ignore

def getDockerImageHostIp():
    client = docker.from_env()
    return client.containers.run('busybox',"/bin/sh -c \"ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\\1/p'\"",remove=True,network="host").decode('ascii').strip()