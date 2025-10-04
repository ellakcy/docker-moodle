from config import MoodleConfig
import sys
import semver
import inquirer
import mk_docker_compose

# Dict that wouldbe output as docker-compose


# env variables
env={}

def pad_semver(ver) -> str:
    parts = ver.split(".")
    while len(parts) < 3:
        parts.append("0")
    return ".".join(parts)


def selectPHP(mooddleVersion: str,config: MoodleConfig)->str:

    min_version = config.MOODLE_MIN_PHP[int(moodle_version)]
    min_version_full = pad_semver(str(min_version))

    available_versions=[]
    print("Select PHP VERSION")
    prompt_string=""
    
    for version in config.PHP_VERSIONS:
        if semver.compare(pad_semver(version), min_version_full) < 0:
            continue
        
        available_versions.append(version)

    questions = [
        inquirer.List(
            'php_version',
            message="Select PHP version",
            choices=available_versions
        ),
    ]

    return inquirer.prompt(questions)['php_version']


if __name__:
    config = MoodleConfig()

    questions = [
        inquirer.List(
            'dockerfile',
            message="Select Dockerfile",
            choices=config.DOCKERFILES
        ),
        inquirer.List(
            'moodle_version',
            message="Select Moodle version",
            choices=config.MOODLE_VERSIONS
        ),
    ]
    
    answers=inquirer.prompt(questions)
    
    dockerfile=answers['dockerfile']
    moodle_version=answers['moodle_version']

    print("Dockerfile:", dockerfile)
    print("Moodle version:", moodle_version)
    
    php_version=selectPHP(moodle_version,config)
    
    print("PHP Version: ",php_version)

    print("Creating docker-compose dir")

    execution_type=mk_docker_compose.getPHPExecutionType(dockerfile)
    docker_compose_dir=mk_docker_compose.createDockerComposeDir(php_version,execution_type,moodle_version)
    print("Docker compose dir",docker_compose_dir)


