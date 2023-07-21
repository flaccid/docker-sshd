#!/bin/sh -e

echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys

ssh-keygen -A

echo "> $@"
exec "$@"
