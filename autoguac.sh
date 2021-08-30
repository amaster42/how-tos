#!/bin/bash

# Designed for debian systems, thoroughly tested on Ubuntu 18.04 LTS
# Credit goes to Chase Wright for the intial unsecured install of apache guacamole; please support his work
# https://github.com/MysticRyuujin
#

if ! [ $(id -u) = 0 ]; then
  echo "[+] Sorry dude, this needs to be run as sudo or root...      [+]"
  echo "[+] Exiting now.                                             [+]"
  exit 1
fi

cd /tmp
echo "[+] AUTOGUAC! Apache Guacamole Installer script              [+]"
echo ""
echo ""

echo "[+] Repo updates...                                          [+]"
DEBIAN_FRONTEND=noninteractive apt-get -y -q update 1>/dev/null
echo ""

echo "[+] Upgrading packages and adding any needed dependencies... [+]"
DEBIAN_FRONTEND=noninteractive apt-get -y -q upgrade 1>/dev/null 
DEBIAN_FRONTEND=noninteractive apt-get -y -q install uuid-runtime 1>/dev/null

echo "[+] Installing guacamole...                                  [+]"
wget https://raw.githubusercontent.com/MysticRyuujin/guac-install/master/guac-install.sh
chmod +x guac-install.sh
#answer the prompts     #TODO automate the answers, or leave the auto-install params below
mkdir /root/.guac
uuidgen >> /root/.guac/dbpass
dbuserdbpass=$(cat /root/.guac/dbpass)
./guac-install.sh --mysqlpwd $dbuserdbpass --guacpwd $dbuserdbpass --totp --installmysql
#cleanup
rm guac-install.sh
#sudo rm /root/.guac/dbpass

#Customization of pages:
#sudo vim /var/lib/tomcat8/webapps/guacamole/translations/en.json
#change variables you want, like version number and headings

#implement reverse proxy and https certs
apt-get -y -q install nginx
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
#browse to https://[IP]/guac/       to test
echo ""
echo ""
echo "[+] Remember to login to the HTTPS web console and           [+]"
echo "[+] change the gaucadmin:gaucadmin creds!                    [+]"
echo ""
echo "https://[IP]/guac/"
echo ""
echo "[+] Have fun!                                                [+]"


#Other notes:

#secure the guac host with a host-based firewall! use whatever you want, ufw shown
#sudo ufw reset
#sudo ufw allow in 22/tcp (ipv4+6)
#sudo ufw allow proto tcp to 0.0.0.0/0 port 443 (only ipv4)
#sudo ufw allow proto tcp to 0.0.0.0/0 port 80 (only ipv4)
#sudo ufw default allow outgoing
#sudo ufw default deny incoming
#sudo ufw status numbered
#sudo ufw delete 2     #deletes second rule
#sudo ufw enable
#sudo ufw status
#sudo ufw disable



#Now do LetsEncrypt for SSL certs, they're free - certbox makes it easy, or do them manually. Make sure port 80 is temporarily open
#https://letsencrypt.org/getting-started/


#Add connections in GUI of Guacamole when possible.

##use these for reference if needed though-
#user-mapping file
#/etc/guacamole/user-mapping.xml
#<user-mapping>
#
#    <authorize 
#            username="pabloesc"
#            password="4f4c4d23c136d24efc2fd904966c35ac"
#           encoding="md5">
#  <connection name="Linux">
#        <protocol>rdp</protocol>
#        <param name="hostname">localhost</param>
#        <param name="port">3389</param>
#        </connection>
#  <connection name="Windows 10">
#        <protocol>rdp</protocol>
#        <param name="hostname">10.0.0.52</param>
#        <param name="port">3389</param>
#        <param name="security">tls</param>
#        <param name="ignore-cert">true</param>
#  <param name="enable-wallpaper">true</param>
#        </connection>
#    </authorize>
#
#</user-mapping>



#--------------------------------------------------------------------------------------------------
#depricated code

#distro=$(uname -a | awk '{print $2}')
#if [ $distro == 'kali' ]; then
#  echo "removing problematic package(s)... "
#  DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y -q king-phisher 1>/dev/null #problematic update package sometimes
#fi


#temporarily disable 2FA - often not needed with updated installer
#sudo mv /etc/guacamole/guacamole-auth-totp-* /etc/guacamole/guacamole-auth-totp.bk
#sudo service tomcat* restart