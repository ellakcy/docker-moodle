import os
from pathlib import Path
import time
import yaml

from config import MoodleConfig
from netconf import get_non_listening_tcp_port
import docker_compose_conf

def getPHPExecutionType(dockerfile:str)->str:
    return Path(dockerfile).parent.name

def createDockerComposeDir(php_version:str,execution_type:str,moodleVersion:str)->str:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    dirname="_".join([execution_type,"php",str(php_version),"moodle",str(moodleVersion),str(time.time())])
    dirname=os.path.join(script_dir,"..","..","docker-compose",dirname)
    os.mkdir(dirname)

    return dirname

def writeDockerCompose(basedir:str,docker_compose: dict):
    docker_compose_file=os.path.join(basedir,"docker_compose.yml")
    with open(docker_compose_file, "w") as file:
        yaml.dump(docker_compose,file, sort_keys=False)


def createApacheDockerCompose(basedir:str,dockerfile:str,php_version:str,moodle_version:str,config:MoodleConfig):
    
    project_name=Path(basedir).name.replace(".","_")

    docker_compose={
        "name": project_name,
        "services":{
        },
        "volumes":[
        ]
    }

    last_port = 8000

    for db_service_name in docker_compose_conf.db_services:

        db_service = docker_compose_conf.docker_compose_db_services[db_service_name]
        db_service['container_name']=project_name+'_'+db_service_name
        docker_compose['services'][db_service_name]=docker_compose_conf.docker_compose_db_services[db_service_name]
        docker_compose['volumes'].append(docker_compose_conf.db_volumes[db_service_name])

        data_volume = docker_compose_conf.moodle_data_volumes[db_service_name]
        www_volume = docker_compose_conf.moodle_www_volumes[db_service_name]

        docker_compose['volumes'].append(www_volume)
        docker_compose['volumes'].append(data_volume)

        moodle_service_name='php_'+db_service_name

        last_port=get_non_listening_tcp_port("localhost",last_port,9000)

        php_base_service = {
            "build": {
                "context": "../..",
                "dockerfile": dockerfile,
                "target": "multibase",
                "args":{
                    "PHP_VERSION":php_version,
                    "VERSION":moodle_version
                }
            },
            "container_name":project_name+"_"+moodle_service_name,
            'volumes': [
                data_volume+":/var/moodledata",
                www_volume+":/var/www"
            ],
            "ports":[
                "\""+str(last_port)+":80\""
            ],
            'depends_on':[db_service_name]
        }
            
        docker_compose['services'][moodle_service_name]=php_base_service

    return docker_compose


def createDockerCompose(basedir:str,dockerfile:str,php_version:str,moodle_version:str,config:MoodleConfig):

    if dockerfile == 'dockerfiles/apache/Dockerfile':
        docker_compose=createApacheDockerCompose(basedir,dockerfile,php_version,moodle_version,config)
    else:
        pass
    
    writeDockerCompose(basedir,docker_compose)
    