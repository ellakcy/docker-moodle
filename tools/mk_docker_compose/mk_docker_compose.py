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
    docker_compose_file=os.path.join(basedir,"docker-compose.yml")
    yaml.add_representer(type(None), lambda dumper, value: dumper.represent_scalar('tag:yaml.org,2002:null', ''))
    with open(docker_compose_file, "w") as file:
        yaml.dump(docker_compose,file, sort_keys=False)

def get_db_version(config:MoodleConfig,db_service_name:str,moodle_version:str)->str:

    if(db_service_name == docker_compose_conf.mysql_db_service_name):
        version=config.MIN_MYSQL_VERSION[moodle_version]
    elif(db_service_name == docker_compose_conf.mariadb_db_service_name):
        version=config.MIN_MARIADB_VERSION[moodle_version]
    else:
        version=config.MIN_POSTGRES_VERSION[moodle_version]
    
    return str(version)

def createApacheDockerCompose(basedir:str,dockerfile:str,php_version:str,moodle_version:str,config:MoodleConfig):
    
    project_name=Path(basedir).name.replace(".","_")

    docker_compose={
        "name": project_name,
        "services":{
        },
        "volumes":{}
    }

    last_port = 8000

    for db_service_name in docker_compose_conf.db_services:

        db_service = docker_compose_conf.docker_compose_db_services[db_service_name]
        db_service['container_name']=project_name+'_'+db_service_name
        db_service['image']=db_service['image']+":"+get_db_version(config,db_service_name,moodle_version)

        # Rearranging keys in order to ensure its showing position upon yaml,improving readability
        docker_compose['services'][db_service_name]={
            "image":db_service['image'],
            "container_name":db_service['container_name'],
            "environment":db_service['environment'],
            'volumes':db_service['volumes']
        }

        docker_compose['volumes'][docker_compose_conf.db_volumes[db_service_name]]=None

        data_volume = docker_compose_conf.moodle_data_volumes[db_service_name]
        www_volume = docker_compose_conf.moodle_www_volumes[db_service_name]

        docker_compose['volumes'][www_volume]=None
        docker_compose['volumes'][data_volume]=None

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
                str(last_port)+":80"
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
    