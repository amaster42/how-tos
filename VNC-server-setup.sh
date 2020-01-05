#!/bin/bash
#
#This script will setup one VNC session for the user the script is run as. You will need sudo to install the server, but not for any of the rest.
#Many distros include sym-links for "vncserver"; however I used the tigervncserver binaries directly to reduce ambiguity. You can modify as you see fit.
#This script assumes you want to use xfce as your desktop environment and already have it installed; to use GNOME/KDE/MATE etc, you will need different commands in your xstarup file in the user's home directory.
#
#
#
#TODO remove all known vnc servers and clients to prevent issues, if they exist on the system
echo "[+] This part will ask for sudo creds to install the server 	[+]"
sudo apt -y update
sudo apt -y install tigervnc-standalone-server tigervnc-common tigervnc-xorg-extension
echo "[+] Enter your VNC password here: 							[+]"
tigervncpasswd #answer the prompts
echo "[+] Creating ~/.vnc/xsession file... 							[+]"
sleep 1s
echo -e '#!/bin/sh \n\n#xrdb $HOME/.Xresources \nunset SESSION_MANAGER \nunset DBUS_SESSION_BUS_ADDRESS \nstartxfce4 & ' | tee ~/.vnc/xstartup > /dev/null
echo "[+] Setting up VNC Server on session 1 (as current user)	 	[+]"
tigervncserver :1 -localhost no -depth 16
echo "[+] Finished!											 		[+]"