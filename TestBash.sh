#!/bin/bash

function main {

echo "Disabling potential network holes."

#Blocking ports

    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 2049 -j DROP       #NFS
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 2049 -j DROP       #NFS
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 23 -j DROP         #Telnet
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 6000:6009 -j DROP  #x windows
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 111 -j DROP        #rpc/NFS
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 111 -j DROP        #rpc/NFS
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 7100 -j DROP       #x indows font server
    iptables -A INPUT -p tcp -s 0/0 -d 0/0 --dport 515 -j DROP        #printer port
    iptables -A INPUT -p udp -s 0/0 -d 0/0 --dport 515 -j DROP        #printer port

echo "Holes blocked."

echo "Enabling Firewall and blocking ports."
    ufw enable
    ufw deny 23
    ufw deny 2049
    ufw deny 515
    ufw deny 111
echo "Firewall is enabled and some ports have been blocked."


echo "Deleting media files"
#Delete media files
    find / -name '*.mp3' -type f -delete >> DeletedFiles.txt
    find / -name '*.mp4' -type f -delete >> DeletedFiles.txt
    find / -name '*.m4a' -type f -delete >> DeletedFiles.txt
    find / -name '*.flv' -type f -delete >> DeletedFiles.txt
    find / -name '*.ogg' -type f -delete >> DeletedFiles.txt
    find / -name '*.avi' -type f -delete >> DeletedFiles.txt
    find / -name '*.mpg' -type f -delete >> DeletedFiles.txt
    find / -name '*.mpeg' -type f -delete >> DeletedFiles.txt
    find / -name '*.flac' -type f -delete >> DeletedFiles.txt
    find / -name '*.mov' -type f -delete >> DeletedFiles.txt
    find /home -name '*.jpg' -type f -delete >> DeletedFiles.txt
    find /home -name '*.jpeg' -type f -delete >> DeletedFiles.txt
    find /home -name '*.gif' -type f -delete >> DeletedFiles.txt
    find /home -name '*.png' -type f -delete >> DeletedFiles.txt
echo "Deleted media files"

echo "Running updates and reinstalling coreutils"
    apt-get -V -y install --reinstall coreutils
    apt-get update
    apt-get upgrade
    apt-get dist-upgrade
echo "Updates and Utils should be installed."


echo "Disabling root account"
    usermod -p '!' root
	passwd -l root
echo "Root account disabled"

}

#Checks for root/sudo access
if ! [ $(id -u) = 0 ]; then
   echo "The script is not being run as root."
   exit
else
	main
fi