FROM alpine:3
LABEL authors="Chris Fordham <chris@fordham.id.au>"
COPY container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
COPY 00-stdout.conf /etc/rsyslog.d/00-stdout.conf
COPY motd /etc/motd
# https://github.com/mitchellh/vagrant/tree/master/keys
# because why not.
ENV SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
ENV SSH_USER="root"
RUN apk --update --no-cache add \
	bash \
	openssh-server \
	openssh-server-pam \
	rsyslog && \
	mkdir /root/.ssh
ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]
CMD ["/usr/sbin/sshd.pam", "-D"]
