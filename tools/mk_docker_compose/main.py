from config import MoodleConfig
import sys
import semver

# Dict that wouldbe output as docker-compose
docker_compose={
    "services":[],
    "volumes":[]
}

# env variables
env={}



def pad_semver(ver) -> str:

    parts = ver.split(".")
    while len(parts) < 3:
        parts.append("0")
    return ".".join(parts)

if __name__:
    config = MoodleConfig()

    if len(sys.argv) < 2:
        print("Usage: python main.py <dockerfile_path> [moodle_version] [php_version]")
        sys.exit(1)

    dockerfile_path = sys.argv[1]
    moodle_version = sys.argv[2] if len(sys.argv) > 2 else config.LATEST
    php_version = sys.argv[3] if len(sys.argv) > 3 else str(config.MOODLE_MIN_PHP[int(moodle_version)])
    
    min_version = config.MOODLE_MIN_PHP[int(moodle_version)]
    min_version_full = pad_semver(str(min_version))

    print("Dockerfile:", dockerfile_path)
    print("Moodle version:", moodle_version)
    print("PHP version:", php_version)

    if semver.compare(pad_semver(php_version), min_version_full) < 0:
        print(f"PHP version {php_version} is not supported for {moodle_version}. Minimum supported {min_version}")
        sys.exit(1)
    
    



