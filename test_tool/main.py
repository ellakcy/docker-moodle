import sys
from create_docker_compose import generateDockerCompose


if __name__ == "__main__":

    # First arg is the executable name
    if len(sys.argv) == 1:
        print("NO arguments have been provided")
        exit(1) 
    
    image = sys.argv[1]
    if image is None or image.strip() == "":
        print("NO image has been provided")
        exit(1) 

    image = image.strip()
    generateDockerCompose(image)