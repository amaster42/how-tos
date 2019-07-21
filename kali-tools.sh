#!/bin/sh

#
# Copyright (c) 2017-2018, amaste
#
# kali-tools.sh comes with ABSOLUTELY NO WARRANTY.
# This is free software, and you are welcome to redistribute it
# under the terms of the GNU General Public License.
#
echo " "
if ! [ $(id -u) = 0 ]; then
   echo "[+] Sorry dude, this script needs to be run as root... [+]"
   echo "[+] Exiting now.                                       [+]"
   exit 1
fi

#bash colors
txtred="\e[91;1m"
txtgrn="\e[1;32m"
txtblu="\e[0;36m"
txtrst="\e[0m"
bldwht='\e[1;37m'
bldblu='\e[1;34m'

sudo echo -e "${bldwht}pentestbox script${txtrst} ${txtgrn}v1.0.1${txtrst}"

echo "[+] Starting...                                           [+]"
echo " "
echo "[+] Preparing for install...                              [+]"
echo " "
echo "[+] Current Disc Usage:                                   [+]"
sudo df -h
echo " "
sudo apt -y update
sudo apt -y -f install gpg gnupg dirmngr --install-recommends --allow-unauthenticated
gpg --keyserver hkp://keys.gnupg.net --recv-key 7D8D0BF6
gpg --fingerprint 7D8D0BF6
gpg -a --export ED444FF07D8D0BF6 | sudo apt-key add - 

#backup that shit
echo "[+] Backing up sources.list to /tmp                       [+]"
echo " "
sudo cp /etc/apt/sources.list /tmp/sources.bak
#add kali repository
echo "[+] Adding kali repo                                      [+]"
echo " "
sudo echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' >> /etc/apt/sources.list

sudo apt clean
sudo apt -yq update

export DEBIAN_FRONTEND=noninteractive

echo "[+] Finished prepping...                                  [+]"
echo " "
#install dependencies
echo "[+] Installing dependancies...                            [+]"
echo " "
sleep 1
sudo apt -y -f -qq install net-tools build-essential postgresql curl libreadline-dev libssl-dev libpq5 libpq-dev libreadline5 libsqlite3-dev libpcap-dev git-core autoconf pgadmin3 zlib1g-dev libxml2-dev libxslt1-dev libyaml-dev zlib1g-dev

#Install pen-testing tools
echo "[+] Installing pen-testing tools...                       [+]"
echo " "
sleep 1
languages="python ruby perl php asp "
remotetools="freerdp2-x11 rdesktop proxychains "
scanning="nmap enum4linux masscan openvas-cli openvas-manager openvas-scanner smtp-user-enum "
bruteforce="hydra ncrack "
networktools="tcpdump wireshark "
webstuff="nikto dirbuster dirb zaproxy burpsuite recon-ng wpscan cewl cadaver sqlmap sqlninja gobuster dnsrecon dnsmap websploit wfuzz xsser " #beef-xss
exploits="metasploit-framework exploitdb responder dos2unix powersploit "
shellsandwordlists="webshells wordlists "
privesc="unix-privesc-check linux-exploit-suggester "
passcrack="john truecrack ophcrack "
funny="toilet "
#wifi="aircrack-ng fern-wifi-cracker "

sudo apt -y -q -f install $languages $remotetools $scanning $bruteforce $networktools $networktools $webstuff $exploits $shellsandwordlists $privesc $passcrack $funny

#cleanup
echo "[+] Cleaning up...                                        [+]"
echo " "
#sudo cp -f /etc/apt/sources.list /tmp/sources.bak
#sudo rm -f /tmp/sources.bak

echo "[+] Current Disc Usage:                                   [+]"
sudo df -h
echo " "
echo "[+] Done, Enjoy!                                          [+]"
echo " "
sleep 4




#original one-liner, ignore

#sudo apt-get -f install acccheck ace-voip amap automater braa casefile cdpsnarf cisco-torch cookie-cadger copy-router-config dmitry dnmap dnsenum dnsmap dnsrecon dnstracer dnswalk dotdotpwn enum4linux enumiax exploitdb fierce firewalk fragroute fragrouter ghost-phisher golismero goofile lbd maltego-teeth masscan metagoofil miranda nmap p0f parsero recon-ng set smtp-user-enum snmpcheck sslcaudit sslsplit sslstrip sslyze thc-ipv6 theharvester tlssled twofi urlcrazy wireshark wol-e xplico ismtp intrace hping3 bbqsql bed cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch copy-router-config doona dotdotpwn greenbone-security-assistant hexorbase jsql lynis nmap ohrwurm openvas-cli openvas-manager openvas-scanner oscanner powerfuzzer sfuzz sidguesser siparmyknife sqlmap sqlninja sqlsus thc-ipv6 tnscmd10g unix-privesc-check yersinia aircrack-ng asleap bluelog blueranger bluesnarfer bully cowpatty crackle eapmd5pass fern-wifi-cracker ghost-phisher giskismet gqrx kalibrate-rtl killerbee kismet mdk3 mfcuk mfoc mfterm multimon-ng pixiewps reaver redfang spooftooph wifi-honey wifitap wifite apache-users arachni bbqsql blindelephant burpsuite cutycapt davtest deblaze dirb dirbuster fimap funkload grabber jboss-autopwn joomscan jsql maltego-teeth padbuster paros parsero plecost powerfuzzer proxystrike recon-ng skipfish sqlmap sqlninja sqlsus ua-tester uniscan vega w3af webscarab websploit wfuzz wpscan xsser zaproxy burpsuite dnschef fiked hamster-sidejack hexinject iaxflood inviteflood ismtp mitmproxy ohrwurm protos-sip rebind responder rtpbreak rtpinsertsound rtpmixsound sctpscan siparmyknife sipp sipvicious sniffjoke sslsplit sslstrip thc-ipv6 voiphopper webscarab wifi-honey wireshark xspy yersinia zaproxy cryptcat cymothoa dbd dns2tcp http-tunnel httptunnel intersect nishang polenum powersploit pwnat ridenum sbd u3-pwn webshells weevely casefile cutycapt dos2unix dradis keepnote magictree metagoofil nipper-ng pipal armitage backdoor-factory cisco-auditing-tool cisco-global-exploiter cisco-ocs cisco-torch crackle jboss-autopwn linux-exploit-suggester maltego-teeth set shellnoob sqlmap thc-ipv6 yersinia beef-xss binwalk bulk-extractor chntpw cuckoo dc3dd ddrescue dumpzilla extundelete foremost galleta guymager iphone-backup-analyzer p0f pdf-parser pdfid pdgmail peepdf volatility xplico dhcpig funkload iaxflood inviteflood ipv6-toolkit mdk3 reaver rtpflood slowhttptest t50 termineter thc-ipv6 thc-ssl-dos acccheck burpsuite cewl chntpw cisco-auditing-tool cmospwd creddump crunch findmyhash gpp-decrypt hash-identifier hexorbase john johnny keimpx maltego-teeth maskprocessor multiforcer ncrack oclgausscrack pack patator polenum rainbowcrack rcracki-mt rsmangler statsprocessor thc-pptp-bruter truecrack webscarab wordlists zaproxy apktool dex2jar python-distorm3 edb-debugger jad javasnoop jd ollydbg smali valgrind yara android-sdk apktool arduino dex2jar sakis3g smali
