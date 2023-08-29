#!/bin/sh -e

echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys

# enable tcp forward for ssh tunnels
sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

ssh-keygen -A

echo "> $@"
exec "$@"
