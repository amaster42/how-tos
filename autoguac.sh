#!/bin/bash

# Designed for debian systems, thoroughly tested on Ubuntu 18.04 LTS
# Credit goes to Chase Wright for the intial unsecured install of apache guacamole; please support his work
# https://github.com/MysticRyuujin
#

if ! [ $(id -u) = 0 ]; then
   echo "[+] Sorry dude, this script needs to be run as sudo or root... [+]"
   echo "[+] Exiting now.                                               [+]"
   exit 1
fi

cd /tmp

echo "[+] System update and adding dependencies                      [+]"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get -q -y install uuid-runtime

echo "[+] Installing guacamole...                                    [+]"
wget https://raw.githubusercontent.com/MysticRyuujin/guac-install/master/guac-install.sh
chmod +x guac-install.sh
#answer the prompts     #TODO automate the answers, or leave the auto-install params below
uuidgen >> /root/dbpass
dbuserdbpass=$(cat /root/dbpass)
./guac-install.sh --mysqlpwd $dbuserdbpass --guacpwd $dbuserdbpass --nomfa --installmysql
#cleanup
rm guac-install.sh
#sudo rm /root/dbpass

#temporarily disable 2FA 
#sudo mv /etc/guacamole/guacamole-auth-totp-* /etc/guacamole/guacamole-auth-totp.bk
#sudo service tomcat* restart

#TODO reverse proxy and https certs
apt-get -q -y install nginx
#SSL and https, self-signed first:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj "/C=US/ST=CA/L=LA/O=AcmeInc. /OU=ITDept/CN=acme.com" -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt
#edit nginx config here
cat << 'EOF' > /etc/nginx/sites-enabled/mysite.com
server {
        listen 80;
        return 301 https://$host$request_uri;
        #redirect all http 80 traffic to https 443
}
server {
        listen 443;
        server_name mysite.com;
        root /var/www/html/;

        ssl_certificate           /etc/nginx/cert.crt;
        ssl_certificate_key       /etc/nginx/cert.key;

        ssl on;
        ssl_session_cache  builtin:1000  shared:SSL:10m;
        ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
        ssl_prefer_server_ciphers on;

        location /guac {
        proxy_pass http://localhost:8080/guacamole;  # slashes herecan be bullshit, be careful
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_cookie_path /guacamole/ /guac;
        access_log off;
        tcp_nodelay on;
        tcp_nopush off;
        sendfile on;
        client_body_buffer_size 10K;
        client_max_body_size 8m;
        client_body_timeout 12;
        keepalive_timeout 15;
        #proxy_redirect http://localhost:8080/mysite https://mysite.com:8080/guac;
        }
}
EOF

cat << 'EOF2' > /var/www/html/index.html
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>Test Page!</title>
  <meta name="description" content="testy-test">
  <meta name="author" content="author">

  <link rel="stylesheet" href="css/styles.css?v=1.0">

</head>

<body>
  <h1>
  Test!
  </h1>
</body>
</html>
EOF2

nginx -t   ##test to see if config is successful; if not, hunt down errors
systemctl restart nginx
systemctl enable nginx  #persist through reboot
