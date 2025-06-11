#!/bin/sh -e

# enable tcp forwarding for ssh tunnels
sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# ensure PAM is enabled to prevent 'User X not allowed because account is locked'
sed -i 's/#UsePAM no/UsePAM yes/g' /etc/ssh/sshd_config

ssh-keygen -A

sed -i '/module(load="imklog/d' /etc/rsyslog.conf
rsyslogd -n &

if [ "$SSH_USER" != 'root' ]; then
    echo "adding system user, ${SSH_USER}"
    adduser -D "${SSH_USER}"
    mkdir -p "/home/${SSH_USER}/.ssh"
    echo "$SSH_PUBLIC_KEY" > "/home/${SSH_USER}/.ssh/authorized_keys"
else
    echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
fi

echo "> $@"
exec "$@"
