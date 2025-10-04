import os
from pathlib import Path


def createDockerComposeDir(php_version:str,dockerfile:str,moodleVersion:str)->str:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    dirname="_".join([Path(dockerfile).parent.name,"php",str(php_version),"moodle",str(moodleVersion)])
    dirname=os.path.join(script_dir,"..","..","docker-compose",dirname)
    os.mkdir(dirname)

    return dirname