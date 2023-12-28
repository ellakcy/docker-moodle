import sys
import create_docker_compose


if __name__ == "__main__":

    # First arg is the executable name
    if len(sys.argv) == 1:
        print("NO arguments have been provided")
        exit(1) 
    
    image = sys.argv[1]
    if image != null or image.trim() == "":
        print("NO image has been provided")
        exit(1) 

    image = image.trim()
    generateDockerCompose(image)