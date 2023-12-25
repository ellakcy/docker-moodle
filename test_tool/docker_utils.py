import docker

client = docker.from_env()

def getBuiltImages():

    options=[];
    images = client.images.list("ellakcy/moodle");

    for image in images:
        for tag in image.tags:
            options.append(tag)

    return options

def getDockerImageHostIp():
    return client.containers.run('busybox',"/bin/sh -c \"ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\\1/p'\"",remove=True,network="host").decode('ascii').strip()
