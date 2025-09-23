# docker-compose creation tool

It is a tool that generated a nessesary docker-compose.yml for testing the images and docker-compose.
Docker-compose files are created upon  `./docker-compose` folder as follows:

```
| - docker-compose
| -- ^moodle_version^-^php-version^-^flavour^

```

This would test the *multibase* setup of docker images.


# Setup

```
cd ./tools/mk_docker_compose
python3 -m venv ./.venv
source ./.venv/bin/activate
pip install -r ./requirements.txt
```

# Run:

```
cd ./tools/mk_docker_compose
python ./main.py ^dockerfile_path^ ^moodle_version^ ^php_version^
```