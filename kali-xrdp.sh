#!/bin/bash

#	Script notes:
#
#	Installs as current user; recommend you create a sudo 
#	user to install under. Also ensure any host-based 
#	firewall allows port 3389 (or whatever port xrdp is
#	configured to listen on). Check out the commented 
#	portions and uncomment them if you want to customize
#	your configuration more. 
#

echo "[+] Installing xfce4 and xrdp, this may take a bit"
sudo apt update
sudo apt --yes --force-yes install kali-desktop-xfce xorg xrdp
echo "[+] Configuring... "
echo " "
echo "[+] Starting xrdp service and enabling on boot"
#echo "[+] Configuring xrdp to listen on port 3390 rather than default"
#sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
sudo echo 'xfce4-session' > ~/.xsession
echo 'startxfce4' | sudo tee -a /etc/xrdp/startwm.sh
#sudo sed -i 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config
sudo systemctl enable xrdp-sesman #persist through reboots
sudo service xrdp restart
echo "[+] Reboot your machine and RDP in! "