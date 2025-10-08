import os
from pathlib import Path
import time
import yaml

from config import MoodleConfig
from netconf import get_non_listening_tcp_port
import docker_compose_conf

def get_db_version(config:MoodleConfig,db_service_name:str,moodle_version:str)->str:

    if(db_service_name == docker_compose_conf.mysql_db_service_name):
        version=config.MIN_MYSQL_VERSION[moodle_version]
    elif(db_service_name == docker_compose_conf.mariadb_db_service_name):
        version=config.MIN_MARIADB_VERSION[moodle_version]
    else:
        version=config.MIN_POSTGRES_VERSION[moodle_version]
    
    return str(version)


class DockerComposeCreator:

    def __init__(self, moodle_version:str, php_version:str,dockerfile:str,config:MoodleConfig):

        self.__moodle_version = moodle_version
        self.__php_version = php_version
        self.__dockerfile = dockerfile
        self.__config = config

        self.__basedir = self.__createDockerComposeDir()
        
        self.__create_nginx = True

        if self.__dockerfile == 'dockerfiles/apache/Dockerfile':
            self.__create_nginx=False
        
   
    def __createDockerComposeDir(self)->str:

        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        execution_type=Path(self.__dockerfile).parent.name

        dirname="_".join([execution_type,"php",str(self.__php_version),"moodle",str(self.__moodle_version),str(time.time())])

        dirname_full=os.path.join(script_dir,"..","..","docker-compose",dirname)
        
        os.mkdir(dirname_full)

        return dirname_full

    def __writeDockerCompose(self,docker_compose: dict):

        docker_compose_file=os.path.join(self.__basedir,"docker-compose.yml")

        yaml.add_representer(type(None), lambda dumper, value: dumper.represent_scalar('tag:yaml.org,2002:null', ''))
        
        with open(docker_compose_file, "w") as file:
            yaml.dump(docker_compose,file, sort_keys=False)
    
    def __generateDockerComposeDict(self)->dict:
        project_name=Path(self.__basedir).name.replace(".","_")

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
            db_service['image']=db_service['image']+":"+get_db_version(self.__config,db_service_name,self.__moodle_version)

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
            last_port=str(last_port)

            php_env={"MOODLE_URL":"http://localhost:"+last_port}|docker_compose_conf.moodle_service_env_vars['common']|docker_compose_conf.moodle_service_env_vars['db'][db_service_name]
            
            php_base_service = {
                "build": {
                    "context": "../..",
                    "dockerfile": self.__dockerfile,
                    "target": "multibase",
                    "args":{
                        "PHP_VERSION":self.__php_version,
                        "VERSION":self.__moodle_version
                    }
                },
                "container_name":project_name+"_"+moodle_service_name,
                'volumes': [
                    data_volume+":/var/moodledata",
                    www_volume+":/var/www"
                ],
                "ports":[
                    last_port+":80"
                ],
                'depends_on':[db_service_name],
                "environment":php_env,
            }
                
            docker_compose['services'][moodle_service_name]=php_base_service

        return docker_compose

    
    def create(self):
        dockerComposeDict = self.__generateDockerComposeDict()
        self.__writeDockerCompose(dockerComposeDict)