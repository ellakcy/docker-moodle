
#!/usr/bin/env bash

# NOTE: DEBIAN_FRONTEND=noninteractive prevents fron spawning user inpud during apt-get
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
apt-get -y clean

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

usermod -aG docker vagrant

export BUILDKIT_PROGRESS=plain

echo "alias docker-compose=\"docker compose\"" > /etc/profile.d/10-docker.sh
echo "export BUILDKIT_PROGRESS=plain" >> /etc/profile.d/10-docker.sh