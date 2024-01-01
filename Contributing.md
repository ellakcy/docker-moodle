# Notes for Contributors
First of all thank you for providing a helping hand into out efforts.

## Docker files
As you noticed there are 2 `docker-compose.yml` files:

* The normal `docker-compose.yml` that is used for buidling the images
* Τhe `docker-compose-ssl-reverse-nginx.yml` used for testing the moodle's behavior againist a nginx reverse proxy.

## Something wrong happens during container launch:
Then run the following commands:

```
docker-compose -f docker-compose-ssl-reverse-nginx.yml down -v --remove-orphans
docker-compose down -v --remove-orphans
```
## Ressetting the installation
Run the same commands as above.

## HTTP timeout
Also in case of an arror that mentions:

```
UnixHTTPConnectionPool(host='localhost', port=None): Read timed out. (read timeout=60)
```

Export the following enviromental variables:

```
export DOCKER_CLIENT_TIMEOUT=120
export COMPOSE_HTTP_TIMEOUT=120
```

## Testing built images

At `./test_tool` folder exists a utility tool that generates docker-compose image in `./docker-compose` folders. In order to run you must launch Vagrant vm then ssh into it:

```
vagrant up
vagrant ssh
```

Then you must visit the `./code/test_tool` and run:

```
python3 main.py ^image_name^
```

That will create a distince docker-compose in its own folder. In prder to launch it run:

```
cd ~/code/docker-compose/^image_name^
docker-compose up -d

```

The `^image_name^` is the built tag.