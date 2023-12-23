#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

apt-get install ca-certificates software-properties-common curl
curl -fsSL https://server.chillibits.com/files/repo/gpg | sudo apt-key add -
add-apt-repository "deb https://repo.chillibits.com/$(lsb_release -is | awk '{print tolower($0)}')-$(lsb_release -cs) $(lsb_release -cs) main"

# Legacy key is added above we convert into new apty keyring type
for KEY in $(apt-key --keyring /etc/apt/trusted.gpg list | grep -E "(([ ]{1,2}(([0-9A-F]{4}))){10})" | tr -d " " | grep -E "([0-9A-F]){8}\b" ); do K=${KEY:(-8)}; apt-key export $K | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/imported-from-trusted-gpg-$K.gpg; done

apt-get update
apt-get install -y compose-generator