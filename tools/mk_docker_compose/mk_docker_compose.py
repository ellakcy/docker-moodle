import os
from pathlib import Path


mariadb_service={
    "image": "mariadb:${MARIADB_VERSION}",
    "container_name": "${COMPOSE_PROJECT_NAME}_mariadb",
    "command": [
        "mysqld",
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci"
    ],
    "environment": [
        "MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD}",
        "MARIADB_DATABASE=${MARIADB_DATABASE}",
        "MARIADB_USER=${MARIADB_USER}",
        "MARIADB_PASSWORD=${MARIADB_PASSWORD}"
    ],
    "volumes": [
        "mariadb_data:/var/lib/mysql"
    ]
}

mysql_service={
    "image": "mysql:${MYSQL_VERSION}",
    "container_name": "${COMPOSE_PROJECT_NAME}_mysql",
    "command": [
        "mysqld",
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_unicode_ci"
    ],
    "environment": [
        "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}",
        "MYSQL_DATABASE=${MYSQL_DATABASE}",
        "MYSQL_USER=${MYSQL_USER}",
        "MYSQL_PASSWORD=${MYSQL_PASSWORD}"
    ],
    "volumes": [
        "mysql_data:/var/lib/mysql"
    ]
}

postgres_service={
    "image": "postgres:${POSTGRES_VERSION}",
    "container_name": "${COMPOSE_PROJECT_NAME}_postgres",
    "environment": [
        "POSTGRES_USER=${POSTGRES_USER}",
        "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}",
        "POSTGRES_DB=${POSTGRES_DB}"
    ],
    "volumes": [
        "postgres_data:/var/lib/postgresql/data"
    ]
}

def getPHPExecutionType(dockerfile:str)->str:
    return Path(dockerfile).parent.name

def createDockerComposeDir(php_version:str,execution_type:str,moodleVersion:str)->str:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    dirname="_".join([execution_type,"php",str(php_version),"moodle",str(moodleVersion)])
    dirname=os.path.join(script_dir,"..","..","docker-compose",dirname)
    os.mkdir(dirname)

    return dirname

def createDockerCompose(basedir:str,flavour:str):

    docker_compose={
    "services":{
        'mariadb': mariadb_service,
        'mysql':mysql_service,
        'postgres':postgres_service
    },
    "volumes":[
        'mysql_data',
        'postgres_data',
        'mariadb_data'
    ]
}