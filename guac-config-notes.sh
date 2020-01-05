#guac installation notes, updated 20190412

https://github.com/MysticRyuujin/guac-install/blob/master/README.md
wget https://raw.githubusercontent.com/MysticRyuujin/guac-install/master/guac-install.sh
sudo chmod +x guac-install.sh
sudo ./guac-install.sh


#once done, browse to page on  http://[IP]:8080/guacamole/  and reset default creds; guacadmin:guacadmin

#temporarily disable two-factor authentication
sudo mv /etc/guacamole/guacamole-auth-totp-1.0.0.jar /etc/guacamole/guacamole-auth-totp-1.0.0.jar.bk
sudo service tomcat8 restart

#Customization of pages:
sudo vim /var/lib/tomcat8/webapps/guacamole/translations/en.json
#change variables you want, like version number and headings

#Final user-mapping file:   (Use the web-GUI to configure if possible)
#/etc/guacamole/user-mapping.xml
<user-mapping>

    <authorize 
            username="pabloesc"
            password="4f4c4d23c136d24efc2fd904966c35ac"
            encoding="md5">
	<connection name="Linux">
        <protocol>rdp</protocol>
        <param name="hostname">localhost</param>
        <param name="port">3389</param>
        </connection>
	<connection name="Windows 10">
        <protocol>rdp</protocol>
        <param name="hostname">10.0.0.52</param>
        <param name="port">3389</param>
        <param name="security">tls</param>
        <param name="ignore-cert">true</param>
	<param name="enable-wallpaper">true</param>
        </connection>
    </authorize>

</user-mapping>


#Next, proxy it:
sudo apt install  -y nginx

#SSL and https, self-signed first:

cd /etc/nginx
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt

sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/mysite.com
sudo vim /etc/nginx/sites-enabled/mysite.com

#use this example:
server {
        listen 80;
        return 301 https://$host$request_uri;
        #redirect all http 80 traffic to https 443
}
server {
        listen 443;
        server_name eternalpit.com;
        root /var/www/html/;

        ssl_certificate           /etc/nginx/cert.crt;
        ssl_certificate_key       /etc/nginx/cert.key;

        ssl on;
        ssl_session_cache  builtin:1000  shared:SSL:10m;
        ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
        ssl_prefer_server_ciphers on;

        location /rem {
        proxy_pass http://localhost:8080/guacamole;  # slashes herecan be bullshit, be careful
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_cookie_path /guacamole/ /rem;
        access_log off;
        tcp_nodelay on;
        tcp_nopush off;
        sendfile on;
        client_body_buffer_size 10K;
        client_max_body_size 8m;
        client_body_timeout 12;
        keepalive_timeout 15;
        #proxy_redirect http://localhost:8080/rem https://vpn.alexmaster.org:8080/rem;
        }

}

sudo nginx -t   ##test to see if config is successful; if not, hunt down errors
sudo service nginx restart
sudo systemctl enable nginx  #persist through reboot


#copy your own index.html into /var/www/html

#browse to https://[IP]/rem/       to test


#Customize Guac login page:
sudo vim /var/lib/tomcat8/webapps/guacamole/translations/en.json


#secure the guac host with a host-based firewall! use whatever you want, ufw shown
sudo ufw reset
sudo ufw allow in 22/tcp (ipv4+6)
sudo ufw allow proto tcp to 0.0.0.0/0 port 443 (only ipv4)
sudo ufw allow proto tcp to 0.0.0.0/0 port 80 (only ipv4)
#sudo ufw default allow outgoing
#sudo ufw default deny incoming
#sudo ufw status numbered
#sudo ufw delete 2     #deletes second rule
sudo ufw enable
sudo ufw status
#sudo ufw disable



#Now do LetsEncrypt for SSL certs, they're free
https://letsencrypt.org/getting-started/




#Add connections in GUI of Guacamole

##use these for reference
#Final user-mapping file:
#/etc/guacamole/user-mapping.xml
<user-mapping>

    <authorize 
            username="pabloesc"
            password="4f4c4d23c136d24efc2fd904966c35ac"
            encoding="md5">
	<connection name="Linux">
        <protocol>rdp</protocol>
        <param name="hostname">localhost</param>
        <param name="port">3389</param>
        </connection>
	<connection name="Windows 10">
        <protocol>rdp</protocol>
        <param name="hostname">10.0.0.52</param>
        <param name="port">3389</param>
        <param name="security">tls</param>
        <param name="ignore-cert">true</param>
	<param name="enable-wallpaper">true</param>
        </connection>
    </authorize>

</user-mapping>








#boxes

#If virtual, VMware tools
sudo apt install open-vm-tools
sudo apt install open-vm-tools-desktop

#Use xRDP
sudo apt install xrdp 
#if RDP windows10+, disable NLA and modify user-mapping




#need minimalist desktop? try a window manager like i3
#https://fedoramagazine.org/getting-started-i3-window-manager/
#https://www.reddit.com/r/i3wm/comments/77huzd/i3_remote_desktop_with_rdp/

sudo apt install -y i3 i3status dmenu i3lock xbacklight feh conky

#at bottom of /etc/xrdp/startwm.sh
xrdb -merge ~/.Xresources
/usr/bin/i3

sudo systemctl restart xrdp
cd /



#for lubuntu GUI:
sudo apt install lubuntu-desktop
sudo vim /etc/xrdp/startwm.sh
##last like should look like....#   /etc/X11/Xsession

cd ~ #(browse to home directory of user you'l log into)
sudo vim .xsession    #create if none exists       ##this step may not be necessary depending on distro
#add this line# lxsession -e LXDE -s Lubuntu
sudo service xrdp restart
sudo systemctl enable xrdp   #persist through reboots


		#for xfce4:
		#sudo echo xfce4-session >~/.xsession

		#sudo vim /etc/xrdp/startwm.sh
		## add thes lines to bottom:  
		#echo xfce4-session >~/.xsession
		#startxfce4
		##IMPORTANT
		#/etc/X11/Xwrapper.config 
		#set allowed_users=anybody

#if kali:

#https://forums.kali.org/showthread.php?34751-How-to-set-up-xrdp-on-the-AWS-Kali-image
#https://gist.github.com/Erreinion/f2eda80adfa06cf330d9874dc667e998

# New sudo user for rdp connections
sudo useradd -m user
sudo passwd user
sudo usermod -a -G sudo user
sudo chsh -s /bin/bash user

sudo systemctl enable xrdp-sesman
update-alternatives --config x-session-manager   #choose /usr/bin/startlxde, or whichever you want

sudo vim /etc/X11/Xwrapper.config 
# allowed_users=anybody

sudo vim /etc/xrdp/xrdp.ini
# max_bpp=16

sudo service xrdp restart

##test it!
xfreerdp -u user -size 800x600 -v XX.XX.XX.XX

##side note, good RDP client if you want:     sudo apt install freerdp2-x11    or 

#sudo apt-add-repository ppa:remmina-ppa-team/remmina-next
#sudo apt update
#sudo apt install remmina remmina-plugin-rdp remmina-plugin-secret


##kali ssh with password
apt list openssh-server
apt install openssh-server
systemctl enable ssh.service
#backup keys
mkdir /etc/ssh/default_keys
mv /etc/ssh/ssh_host_* /etc/ssh/default_keys/
#regen keys
dpkg-reconfigure openssh-server
vim /etc/ssh/sshd_config
# PasswordAuthentication yes
# PermitRootLogin yes
systemctl enable ssh.service #persist through reboots
systemctl status ssh.service


