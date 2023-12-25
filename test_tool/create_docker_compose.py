
import uuid
import netconf
import random
import docker-utils

'''
The credentials are fixed because we want test ones
These are NOT used upon production
we want these because we want to have a fixed test environment
'''
credentials = {
    "moodle_db_user":"moodleusr",
    "moodle_db":"moodle",
    "moodle_db_password":"moodledbpass",
    "moodle_web_usr":"moodleadmin"
    "moodle_web_passwd":"moodlepasswd"
    "moodle_web_email":"user@example.com"
}

def WWW_VOL(): return "www";
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
        "MYSQL_ONETIME_PASSWORD": "yes"
        "MYSQL_DATABASE": credentials['moodle_db'],
        "MYSQL_USER": credentials['moodle_db_user']
        "MYSQL_PASSWORD": credentials['moodle_db_password']
        }
    }

def getMariaDbService(credentials):
    return {
        "image": "mariadb:10.2"
        "volumes":[
           MYSQL_VOL()+':/var/lib/mysql'
        ],
        "environment":{
        "MYSQL_RANDOM_ROOT_PASSWORD": "yes",
        "MYSQL_ONETIME_PASSWORD": "yes"
        "MYSQL_DATABASE": credentials['moodle_db'],
        "MYSQL_USER": credentials['moodle_db_user']
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
            "POSTGRES_DB": credentials['moodle_db']
            "POSTGRES_USER": credentials['moodle_db_user']
            "POSTGRES_PASSWORD": credentials['moodle_db_password']
        }
    }


# @Todo handle multibase images
def sanitiseDbType(image,preferredbType):

    preferredbType=preferredbType.lower().strip()
    image=image.lower().strip()

    if preferredbType = "mysql":
        echo "Fixing db type into mysqli"
        return "mysqli"
    else if preferredbType in ("mariadb","maria"):
        echo "Fixing db type into mariadb"
        return "mariadb"
    else if preferredbType in ("postgresql","psql"):
        echo "Enforcing db type into postgres"
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
    else if "postgresql" in image:
        return "postgres"
    else if image == "latest" or image.startsWith("latest_php"):
        return "multibase"
    else:
        return "multibase"

def getPHPbaseService(
        image,
        base_url,
        db_service_name,
        smtp_service_name,
        credentials,
        use_ssl=False, 
        behindLb=False,
        preferredbType='mysql'
    ):
    
    preferredbType=sanitiseDbType(image,preferredbType)
    image=image.lower().strip()

    service =  {
        "image": image
        "volumes":{
            './data/moodle:/var/moodledata',
            WWW_VOL()+':/var/www/html'
        }
        "environment":{
            "MOODLE_URL": url,
            "MOODLE_ADMIN": credentials["moodle_admin"],
            "MOODLE_ADMIN_PASSWORD": credentials["moodle_web_passwd"]
            "MOODLE_ADMIN_EMAIL": credentials['moodle_web_email']
            "MOODLE_DB_TYPE": dbType
            "MOODLE_DB_HOST": db_service_name
            "MOODLE_DB_USER": credentials['moodle_db_user']
            "MOODLE_DB_PASSWORD": credentials['moodle_db_password']
            "MOODLE_DB_NAME": credentials['moodle_db']
            "MOODLE_REVERSE_LB": behindLb
            "MOODLE_SSL": use_ssl
            "MOODLE_EMAIL_TYPE_QMAIL": false
            "MOODLE_EMAIL_HOST": smtp_service_name
        }
    }

    # Should Also detect a Port for HTTPS as well? Idk
    if(isImageAnApacheOne(image)):
        available_ports=get_non_listening_tcp_ports("0.0.0.0","8000","8999")
        service.ports=(random.choice(port_to_map)+":80")

    return service


def bootstrapDockerComposedir():
    '''
      :return String with the folder where docker-compose will be located
    '''
    # @TODO implement logic

def generateDockerCompose(image_name, folder_location):
    
    final_compose={
        "version":"v3"
        "services":{
        },
        "volumes":[
            WWW_VOL(),
        ]
    }

    dbType = detectDbTypeFromImageName(image_name)
    hostIp = getDockerImageHostIp()
    # The smtp service must always run at 1025
    smtpIp = hostIp+":1025"

    isApache = isImageAnApacheOne(image_name)
    
    createMaria=(dbType=='multibase' or dbType='mysql')
    createMysql=(dbType=='multibase' or dbType='mysql')
    createPostgres=(dbType=='multibase' or dbType='postgres')

    if(createMaria):
        final_compose.volumes.append(MARIADB_VOL())
        final_compose.services["moodle_maria"] = getPHPbaseService(image,hostIp,smtpIp,credentials,false,false,'mariadb')
        final_compose.services['maria'] = getMariaDbService(credentials)
        if [ not isApache ]:
            # @TODO Create Nginx
            final_compose.services['moodle_maria_nginx']={}
    
    if(createMysql):
        final_compose.volumes.append(MYSQL_VOL())
        final_compose.services["moodle_mysql"] = getPHPbaseService(image,hostIp,smtpIp,credentials,false,false,'mysql')
        final_compose.services['mysql'] = getMysqlService(credentials)
        if [ not isApache ]:
            # @TODO Create Nginx
            final_compose.services['moodle_mysql_nginx']={}
    
    if(createPostgres):
        final_compose.volumes.append(POSTGRES_VOL())
        final_compose.services["moodle_postgres"] = getPHPbaseService(image,hostIp,smtpIp,credentials,false,false,'postgresql')
        final_compose.services['postgres'] = getPostgresqlService(credentials)
        if [ not isApache ]:
            # @TODO Create Nginx
            final_compose.services['moodle_postgres_nginx']={}



