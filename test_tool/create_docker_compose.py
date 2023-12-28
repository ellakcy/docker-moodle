

import uuid
import netconf
import random
from pathlib import Path
import os

import docker_utils
import config

'''
The credentials are fixed because we want test ones
These are NOT used upon production
we want these because we want to have a fixed test environment
'''
credentials = {
    "moodle_db_user":"moodleusr",
    "moodle_db":"moodle",
    "moodle_db_password":"moodledbpass",
    "moodle_web_usr":"moodleadmin",
    "moodle_web_passwd":"moodlepasswd",
    "moodle_web_email":"user@example.com",
}

def MOODLE_DOMAIN(): return "192.168.56.4";


def MYSQL_VOL(): return "moodledb_mysql";
def POSTGRES_VOL(): return "moodledb_postgres";
def MARIADB_VOL(): return "moodledb_maria";

def createDBName(type):
    return "moodledb_"+type+"_"+str(uuid.uuid4().get_hex().upper()[0:16])


def getMysqlService(credentials): 
    return {
        "image": "mysql:5.7",
        "volumes":[
           MYSQL_VOL()+':/var/lib/mysql'
        ],
        "environment":{
        "MYSQL_RANDOM_ROOT_PASSWORD": "yes",
        "MYSQL_ONETIME_PASSWORD": "yes",
        "MYSQL_DATABASE": credentials['moodle_db'],
        "MYSQL_USER": credentials['moodle_db_user'],
        "MYSQL_PASSWORD": credentials['moodle_db_password']
        }
    }

def getMariaDbService(credentials):
    return {
        "image": "mariadb:10.2",
        "volumes":[
           MYSQL_VOL()+':/var/lib/mysql'
        ],
        "environment":{
        "MYSQL_RANDOM_ROOT_PASSWORD": "yes",
        "MYSQL_ONETIME_PASSWORD": "yes",
        "MYSQL_DATABASE": credentials['moodle_db'],
        "MYSQL_USER": credentials['moodle_db_user'],
        "MYSQL_PASSWORD": credentials['moodle_db_password']
        }
    }

def getPostgresqlService(credentials):
    return {
        "image": "postgres:11",
        "volumes":[
            POSTGRES_VOL()+':/var/lib/postgresql/data'
        ],
        "environment": {
            "POSTGRES_DB": credentials['moodle_db'],
            "POSTGRES_USER": credentials['moodle_db_user'],
            "POSTGRES_PASSWORD": credentials['moodle_db_password']
        }
    }


# @Todo handle multibase images
def sanitiseDbType(image,preferredbType):

    preferredbType=preferredbType.lower().strip()
    image=image.lower().strip()

    if preferredbType == "mysql":
        print("Fixing db type into mysqli")
        return "mysqli"
    elif preferredbType in ("mariadb","maria"):
        print("Fixing db type into mariadb")
        return "mariadb"
    elif preferredbType in ("postgresql","psql"):
        print("Enforcing db type into postgres")
        return "pgsql"
    
    return image


def isImageAnApacheOne(image):
    '''
    return :bool
    '''
    image=image.lower().strip()
    # Keeping tag only
    image = image.replace("ellakcy/moodle:","")

    return image=="latest" or "apache" in image or "latest_php" in image


def detectDbTypeFromImageName(image):
    '''
    :return string
    '''

    image=image.lower().strip()
    # Keeping tag only
    image = image.replace("ellakcy/moodle:","")

    if "mysql_maria" in image:
        return "mysql"
    elif "postgresql" in image:
        return "postgres"
    elif image == "latest" or image.startsWith("latest_php"):
        return "multibase"
    else:
        return "multibase"

def getPHPbaseService(
        image,
        base_url,
        db_service_name,
        smtp_service_name,
        credentials,
        www_volume,
        data_volume,
        port,
        use_ssl=False, 
        behindLb=False,
        preferredbType='mysql'
    ):
    
    preferredbType=sanitiseDbType(image,preferredbType)
    image=image.lower().strip()
    www_volume=www_volume.strip()
    
    service =  {
        "image": image,
        "volumes":{
            data_volume+':/var/moodledata',
            www_volume+':/var/www/html'
        },
        "environment":{
            "MOODLE_URL": "http://"+base_url,
            "MOODLE_ADMIN": credentials["moodle_admin"],
            "MOODLE_ADMIN_PASSWORD": credentials["moodle_web_passwd"],
            "MOODLE_ADMIN_EMAIL": credentials['moodle_web_email'],
            "MOODLE_DB_TYPE": dbType,
            "MOODLE_DB_HOST": db_service_name,
            "MOODLE_DB_USER": credentials['moodle_db_user'],
            "MOODLE_DB_PASSWORD": credentials['moodle_db_password'],
            "MOODLE_DB_NAME": credentials['moodle_db'],
            "MOODLE_REVERSE_LB": behindLb,
            "MOODLE_SSL": use_ssl,
            "MOODLE_EMAIL_TYPE_QMAIL": false,
            "MOODLE_EMAIL_HOST": smtp_service_name
        }
    }

    if isImageAnApacheOne(image):
        service['ports']=[port+":80"]

    return service


def bootstrapDockerComposeDir(image_name):
    '''
      :image_name The name of the image its tag will be used as folder path
      :return String with the folder where docker-compose will be located
    '''
    
    image=image.lower().strip()
    # Keeping tag only and use that as fodler name
    folder_name = image.replace("ellakcy/moodle:","")
    
    docker_compose_dir =  os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','docker-compose/')
    docker_compose_main_dir = os.path.join(docker_compose_dir,folder_name)

    dirs={
        "all_docker_compose_dir": docker_compose_dir,
        "docker_compose_main_dir":docker_compose_main_dir,
        "docker_compose_file":os.path.join(docker_compose_main_dir,"docker-compose.yml"),
        "nginx_conf_dir":os.path.join(docker_compose_main_dir,"nginx")
    }

    for index,dir in dirs:
        if index == 'docker_compose_file':
            continue
        os.mkdir(dir)

    return dirs
                    

def createNginxConf(path,port,fpm_service):
    conf="""
events {
  worker_connections  768;
}

http {
  include  /etc/nginx/mime.types;
  default_type  application/octet-stream;

  charset  utf-8;

  gzip  on;
  gzip_disable  "msie6";
  client_max_body_size 10000M;

  log_format compression '$remote_addr - $remote_user [$time_local] '
                         '"$request" $status $body_bytes_sent '
                         '"$http_referer" "$http_user_agent" "$gzip_ratio"';

  server {
    # We do not listen to port 80 in order to prevent redirect loops.
    listen  {port};

    server_name  _;
    proxy_redirect    off;

    root  /var/www/html;
    index  index.php;

    access_log /var/log/nginx/access.log compression;

    location / {
      try_files  $uri $uri/ =404;
    }

    location ~ [^/]\.php(/|$) {
      fastcgi_split_path_info  ^(.+\.php)(/.+)$;
      #fastcgi_index index.php;
      include   fastcgi_params;
      fastcgi_param   PATH_INFO       $fastcgi_path_info;
      fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
      fastcgi_pass  {service}:9000;
    }

    location /dataroot/ {
        internal;
        alias /var/moodledata/; # ensure the path ends with /
    }

  }
}
    """.format(port=port,service=service)

    conf_file=fpm_service+".nginx.conf"
    final_file = os.path.join(path,conf_file)

    with open(final_file, 'w') as pf: pf.write(conf)


    return conf_file

def createNginxService(path,port,fpm_service,www_volume,data_volume):
    file = createNginxConf(path,port,fpm_service)
    service_conf={
        "image":"nginx-fpm",
        "ports":[port+":"+port],
        "volumes":[
            "./"+file+":/etc/nginx/nginx.conf:ro",
            www_volume+":/var/www/data",
            data_volume+":/var/moodledata"
        ],
        
    }

def generateDockerCompose(image_name):
    
    final_compose={
        "version":"v3",
        "services":{},
        "volumes":{}
    }

    dirs = bootstrapDockerComposeDir(image_name)
    dbType = detectDbTypeFromImageName(image_name)
    hostIp = getDockerImageHostIp()

    # The smtp service must always run at 1025
    smtpIp = hostIp+":1025"

    isApache = isImageAnApacheOne(image_name)
    
    createMaria=(dbType=='multibase' or dbType=='mysql')
    createMysql=(dbType=='multibase' or dbType=='mysql')
    createPostgres=(dbType=='multibase' or dbType=='postgres')

    # Should Also detect a Port for HTTPS as well? Idk
    available_ports=get_non_listening_tcp_ports("0.0.0.0","8080","8999")

    if(createMaria):
        final_compose['volumes'][MARIADB_VOL()]=""
        final_compose['volumes']["moodle_maria"]=""
        final_compose['volumes']['moodle_maria_data']=""
        port = available_ports.pop(1)
        domain = MOODLE_DOMAIN()+":"+port
        final_compose.services["moodle_maria"] = getPHPbaseService(image,domain,smtpIp,credentials,"moodle_maria","moodle_maria_data",false,false,'mariadb')
        final_compose.services['maria'] = getMariaDbService(credentials)
        

        if [ not isApache ]:
            final_compose.services['moodle_maria_nginx']=createNginxService(dirs['nginx_conf_dir'],port,"moodle_maria","moodle_maria","moodle_maria_data")
    
    if(createMysql):
        final_compose.volumes[MYSQL_VOL()]=""
        final_compose.volumes["moodle_mysql"]=""
        final_compose.volumes["moodle_mysql_data"]=""

        port = available_ports.pop(1)
        domain = MOODLE_DOMAIN()+":"+port

        final_compose.services["moodle_mysql"] = getPHPbaseService(image,domain,smtpIp,credentials,"moodle_mysql","moodle_mysql_data",false,false,'mysql')
        final_compose.services['mysql'] = getMysqlService(credentials)
        if [ not isApache ]:
            # @TODO Create Nginx
            final_compose.services['moodle_mysql_nginx']=createNginxService(dirs['nginx_conf_dir'],port,"moodle_mysql","moodle_mysql","moodle_mysql_data")
    
    if(createPostgres):
        
        final_compose.volumes[POSTGRES_VOL()]=""
        final_compose.volumes["moodle_postgres"]=""
        final_compose.volumes["moodle_postgres_data"]=""

        port = available_ports.pop(1)
        domain = MOODLE_DOMAIN()+":"+port

        final_compose.services["moodle_postgres"] = getPHPbaseService(image,domain,smtpIp,credentials,"moodle_postgres","moodle_postgres_data",false,false,'postgresql')
        final_compose.services['postgres'] = getPostgresqlService(credentials)

        if [ not isApache ]:
            # @TODO Create Nginx
            final_compose.services['moodle_postgres_nginx']=createNginxService(dirs['nginx_conf_dir'],port,"moodle_postgres","moodle_postgres","moodle_postgres_data")

        print(final_compose)


