

# Common section of config
mysql_db_service_name="mysql"
mariadb_db_service_name="mariasdb"
postgres_db_service_name="postgres"

db_services=[
    mysql_db_service_name,
    mariadb_db_service_name,
    postgres_db_service_name
]

db_name="moodledb"
db_pass="moodlepass"
db_user="moodledbusr"
root_db_pass="rootpass"

moodle_admin="admin"
moodle_admin_password="StrongPassword123"
moodle_admin_email="admin@example.com"

# Service env variables
compose_name_var_name="COMPOSE_PROJECT_NAME"

db_service_env_vars={
    mysql_db_service_name,
    mariadb_db_service_name,
    postgres_db_service_name
}

moodle_service_env_vars={
    # This needs to be calculated
    "special":['MOODLE_URL'],
    # Common valuesa in all moodleinstances
    "common":{
        "MOODLE_ADMIN":moodle_admin,
        "MOODLE_ADMIN_PASSWORD":moodle_admin_password,
        "MOODLE_ADMIN_EMAIL":moodle_admin_email,
        "MOODLE_DB_USER":db_user,
        "MOODLE_DB_PASSWORD":db_pass,
        "MOODLE_DB_NAME":db_name,
    },
    "db":{
        mysql_db_service_name:{
            "MOODLE_DB_TYPE":"mysqli",
            "MOODLE_DB_HOST": mysql_db_service_name,
            "MOODLE_DB_PORT":"3306"
        },
        mariadb_db_service_name:{
            "MOODLE_DB_TYPE":"mariadb",
            "MOODLE_DB_HOST": mariadb_db_service_name,
            "MOODLE_DB_PORT":"3306"
        },
        postgres_db_service_name:{
            "MOODLE_DB_TYPE":"pgsql",
            "MOODLE_DB_HOST": postgres_db_service_name,
            "MOODLE_DB_PORT":"5432"
        }
    }
}

# Volume config
db_volumes={
    mariadb_db_service_name:mariadb_db_service_name+"_db_data",
    mysql_db_service_name:mysql_db_service_name+"_db_data",
    postgres_db_service_name:postgres_db_service_name+"_db_data"
}

moodle_data_volumes={
    mariadb_db_service_name:"moodle_"+mariadb_db_service_name+"_data",
    mysql_db_service_name:"moodle_"+mysql_db_service_name+"_data",
    postgres_db_service_name:"moodle_"+postgres_db_service_name+"_data"
}

moodle_www_volumes={
    mariadb_db_service_name:"moodle_"+mariadb_db_service_name+"_www",
    mysql_db_service_name:"moodle_"+mysql_db_service_name+"_www",
    postgres_db_service_name:"moodle_"+postgres_db_service_name+"_www"
}


# Service Config
docker_compose_db_services = {
    mysql_db_service_name:{
        "image": "mysql",
        "command": [
            "mysqld",
            "--character-set-server=utf8mb4",
            "--collation-server=utf8mb4_unicode_ci"
        ],
        "environment": {
            "MYSQL_ROOT_PASSWORD":root_db_pass,
            "MYSQL_DATABASE":db_name,
            "MYSQL_USER":db_user,
            "MYSQL_PASSWORD":db_pass
        },
        "volumes": [
            db_volumes[mysql_db_service_name]+":/var/lib/mysql"
        ]
    },
    
    mariadb_db_service_name:{
        "image": "mariadb",
        "command": [
            "mysqld",
            "--character-set-server=utf8mb4",
            "--collation-server=utf8mb4_unicode_ci"
        ],
        "environment":{
            "MARIADB_ROOT_PASSWORD":root_db_pass,
            "MARIADB_DATABASE":db_name,
            "MARIADB_USER":db_user,
            "MARIADB_PASSWORD":db_pass
        },
        "volumes": [
            db_volumes[mariadb_db_service_name]+":/var/lib/mysql"
        ]
    },
    postgres_db_service_name:{
        "image": "postgres",
        "environment":{
            "POSTGRES_USER":db_user,
            "POSTGRES_PASSWORD":db_pass,
            "POSTGRES_DB":db_name
        },
        "volumes": [
            db_volumes[postgres_db_service_name]+":/var/lib/postgresql/data"
        ]
    }
}