import docker

client = docker.from_env()


def 

images = client.images.list("ellakcy/moodle");

for image in images:
    for tag in image.tags:
        print(tag)