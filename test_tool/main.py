import docker

client = docker.from_env()





def select_list(message,list):

    if (len(list) < 0):
        raise ValueError("List has no Items") 

    print (message)
    print()

    for index,item in list:
        print(index+")"+list)
    
    print()
    
    # Input reading and validation
    while True:
     option = input("Your option?")
     
     # value exiosts in list
     if option in list:
        return option
     
     # Index exists in list
     option = int(option)
     if list[option] then:
        return list[option]


if __name__ == "__main__":
    tags = getBuiltImages();

    selectedImage = select_list("Select for which image a docker-compose file will be built",tags)
    
