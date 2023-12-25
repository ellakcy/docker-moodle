#!/usr/bin/env bash

bash < <(curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh)

SYSTEMD_CONFIG=$(cat << 'EOM'
[Unit]
Description=Mailpit
Documentation=https://github.com/axllent/mailpit
After=syslog.target network.target
AssertFileIsExecutable=/usr/local/bin/mailpit

[Service]
User=nobody
ExecStart=/usr/local/bin/mailpit
ExecReload=/bin/kill -USR2 $MAINPID

[Install]
WantedBy=multi-user.target

EOM
)

echo "$SYSTEMD_CONFIG" > /usr/lib/systemd/system/mailpit.service

systemctl enable mailpit
systemctl start mailpit