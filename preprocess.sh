apt-get update
apt-get dist-upgrade -y
mkdir /var/run/fail2ban
apt-get install sudo ufw fail2ban nano -y
adduser ether1node systemd-journal

# Configuring firewall
yes | ufw reset
ufw allow 22/tcp
ufw allow 4001/tcp
ufw allow 5001/tcp
ufw allow 30305/tcp
ufw allow 30305/udp
yes | ufw enable

chmod -x /var/run/
cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl restart fail2ban

sleep 2
fail2ban-client status
