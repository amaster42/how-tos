#!/bin/bash
echo ""
echo "[+] Auto-setup OpenSSH server on kali script           [+]"
echo ""
if ! [ $(id -u) = 0 ]; then
   echo "[+] Sorry dude, this script needs to be run as root... [+]"
   echo "[+] Exiting now.                                       [+]"
   exit 1
fi

echo "Warning: This script will perform a basic install with password authentication enabled. "
echo "Recommend you update your /etc/sshd_config file afterwards to suit your risk tolerance."
read -r -p "Would you like to continue? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] 
then
    echo ""
	echo "Installing openssh server if it isn't already:"
	sleep 1
	sudo apt -qq update
	sudo apt -qq install openssh-server
	sudo apt-mark auto openssh-server
	echo "Deleting default ssh keys"
	sudo rm -f /etc/ssh/ssh_host_*
	sudo dpkg-reconfigure openssh-server
	echo ""
	echo "These are your new keys:"
	sudo ls /etc/ssh/ssh_host_*
	echo ""
	sudo systemctl start ssh.service
	sleep 1
	sudo systemctl restart ssh
	sudo systemctl status ssh.service
	echo "If all went well, your server is available here:"
	sudo ss -antp | grep "sshd"
	echo "If you have a host-based firewall, go ahead and set an allow rule for the above port."
	echo "Done."
	echo ""
else
    echo ""
    echo "Nevermind then. Exiting."
    echo ""
fi