
#!/usr/bin/env bash

# NOTE: DEBIAN_FRONTEND=noninteractive prevents fron spawning user inpud during apt-get

echo "Setting up and configuring Docker and installing the required docker images"
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common git python3-pip
DEBIAN_FRONTEND=noninteractive curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#@todo verify the key
#sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y

DEBIAN_FRONTEND=noninteractive  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "I am $(whoami) user and I am enabling the docker capabilities without sudo"

sudo usermod -aG docker vagrant

echo "Installing Docker Compose"

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo service docker start

sudo apt-get -y autoremove
sudo apt-get -y clean

export BUILDKIT_PROGRESS=plain