#!/bin/bash

mkdir ~/feathur-install/
cd ~/feathur-install/
touch ~/feathur-install/install.log
exec 3>&1 > ~/feathur-install/install.log 2>&1

############################################################
# Functions
############################################################

function status {
	echo $1;
	echo $1 >&3
}

function selectValid {
	j=1
	for i in $@
	do
		status "$j: $i"
		j=$j+1
	done
	status "Please make your selection: "
	NOT_SATISFIED=1
	VALUE=0
	while $NOT_SATISFIED
	do
		read VALUE
		if [[ $VALUE -ge 1 ]]
		then
			if [[ $VALUE -le $# ]]
				NOT_SATISFIED=0
			else
				status "Invalid Selection."
				for i in $@
				do
					status "$j: $i"
					j=$j+1
				done
				status "Please make your selection: "
			fi
		else
			status "Invalid Selection."
			for i in $@
			do
				status "$j: $i"
				j=$j+1
			done
			status "Please make your selection: "
		fi
	done
	echo $VALUE
}

############################################################
# Begin Installation
############################################################

status "====================================="
status "     Welcome to Feathur Installation"
status "====================================="
status " "
FEATHUR_OS_NAME="Unsupported"
FEATHUR_OS_RELEASE=0

KVM_CAP=0

if [[ $UID -ne 0 && $EUID -ne 0 ]]
then
	status "Feathur installer must be executed as root."
	exit 1
fi

if [[ $(egrep -c "(vmx|svm)" /proc/cpuinfo | wc -l) -ne "0" ]]
then
	KVM_CAP=1
fi

if [ -f /etc/centos-release ]
then
	case $(cat /etc/centos-release) in
		CentOS\ release\ 6.*)
			FEATHUR_OS_NAME="CentOS"
			FEATHUR_OS_RELEASE=6
			;;
		CentOS\ Linux\ release\ 7.*)
			FEATHUR_OS_NAME="CentOS"
			FEATHUR_OS_RELEASE=7
			;;
	esac
elif [ -f /etc/debian_version ]
then
	case $(cat /etc/debian_version) in
		jessie*)
			FEATHUR_OS_NAME="Debian"
			FEATHUR_OS_RELEASE=8
			;;
		7.*)
			FEATHUR_OS_NAME="Debian"
			FEATHUR_OS_RELEASE=7
			;;
	esac
elif [ -f /etc/lsb-release ]
then
	case $(cat /etc/lsb-release | grep 'DISTRIB_DESCRIPTION' | awk -F= '{print $2}') in
		Ubuntu\ 14.04*)
			FEATHUR_OS_NAME="Ubuntu"
			FEATHUR_OS_RELEASE=14
			;;
		Ubuntu\ 14.10*)
			FEATHUR_OS_NAME="Ubuntu"
			FEATHUR_OS_RELEASE=14
			;;
	esac
fi

FEATHUR_MODE=0
FEATHUR_VIRT=0

FEATHUR_VIRT_SUPPORTED=("none")

if [[ $KVM_CAP -eq 1 ]]
then
	FEATHUR_VIRT_SUPPORTED+=("kvm")
fi

if [[ $FEATHUR_OS_NAME == "CentOS" ]]
then
	if [[ $FEATHUR_OS_RELEASE -eq 6 ]]
	then
		FEATHUR_VIRT_SUPPORTED+=("openvz")
	fi
fi

FEATHUR_MODE=$(selectValid "Master" "Slave")
FEATHUR_VIRT=$(selectValid $FEATHUR_VIRT_SUPPORTED)

if [[ $KVM_CAP -eq 0 ]]
	if [[ $FEATHUR_VIRT -eq 1 ]] # Person chose OpenVZ
		FEATHUR_VIRT=2

FEATHUR_INTERFACE=none

if [[ $FEATHUR_VIRT -eq 1 ]]
then
	INTERFACES=$(for i in $(ip link show | sed 'N;s/\n/ /' | grep ether | grep -v 'NO-CARRIER' | awk -F: '{print $2}' | awk '{print $1}'); do echo -n $i; done)
	status "What is your trunk interface?"
	status "If your interface is not on the list, check your ethernet cable."
	FEATHUR_INTERFACE=$INTERFACES[$(selectValid($INTERFACES))]
fi

PACKAGES=()
REPOS=()
PACKAGES2=()

case $FEATHUR_MODE in
	0)
		if [[ $FEATHUR_OS_NAME == "CentOS" ]]
		then
			if [[ $FEATHUR_OS_RELEASE -eq 6 ]]
			then
				REPOS+=("https://raw.githubusercontent.com/BlueVM/Feathur/Testing/data/nginx-rhel6.repo")
			else
				REPOS+=("https://raw.githubusercontent.com/BlueVM/Feathur/Testing/data/nginx-rhel7.repo")
			fi
			PACKAGES2+=("php" "php-fpm" "php-mysql" "mysql-server" "zip" "unzip" "pigz")
		else
			
		fi
		;;
	1)
		;;
esac

case $FEATHUR_VIRT in
	0)
		if [[ $FEATHUR_OS_NAME == "CentOS" ]]
		then
			PACKAGES2+=("rsync" "screen" "wget" "pigz")
		else
			PACKAGES+=("screen" "wget" "pigz")
		fi
		;;
	1)
		if [[ $FEATHUR_OS_NAME == "CentOS" ]]
		then
			PACKAGES+=("bridge-utils" "dhcp" "libvirt" "qemu-kvm" "lvm2" "rsync" "screen" "wget")
			if [[ $FEATHUR_OS_RELEASE -eq 6 ]]
			then
				PACKAGES+=( "http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm")
			elif [[ $FEATHUR_OS_RELEASE -eq 7 ]]
			then
				PACKAGES+=( "http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm")
			fi
			PACKAGES2+=("vnstat" "pigz")
		else
			PACKAGES+=("qemu-kvm" "libvirt-bin" "bridge-utils" "screen" "wget" "pigz")
		fi
		;;
	2)
		if [[ $FEATHUR_OS_NAME == "CentOS" && $FEATHUR_OS_RELEASE -eq 6 ]]
		then
			PACKAGES+=("rsync" "screen" "wget" "pigz")
			REPOS=("http://download.openvz.org/openvz.repo")
			PACKAGES2+=("vzkernel" "vzctl")
		fi
		;;
esac

case $FEATHUR_OS_NAME in
	CentOS)
		yum -y install $PACKAGES
		CURRENTDIR=$(pwd)
		cd /etc/yum.repos.d/
		for i in $REPOS
		do
			wget $i
		done
		cd $CURRENTDIR
		yum -y install $PACKAGES2
		;;
	Debian)
	Ubuntu)
		apt-get -y install $PACKAGES
		for i in $REPOS
		do
			echo $i >> /etc/apt/sources.list.d/feathur.list
		done
		apt-get -y install $PACKAGES2
		;;
esac

if [[ $FEATHUR_OS_NAME == "CentOS" ]]
then
	PACKAGES+=("bridge-utils" "dhcp" "libvirt" "qemu-kvm" "lvm2" "rsync" "screen" "wget")
	PACKAGES2+=("vnstat")
	if [[ $FEATHUR_OS_RELEASE -eq 6 ]]
	then
		PACKAGES+=( "http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm")
	elif [[ $FEATHUR_OS_RELEASE -eq 7 ]]
	then
		PACKAGES+=( "http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm")
	fi
else
	PACKAGES+=("qemu-kvm" "libvirt-bin" "bridge-utils" "screen" "wget")
fi

status "Feathur KVM slave CentOS installation."
status " "
status "Feathur will install KVM along with"
status "several other tools for VPS management."
status " "
status "It is recommended that you run this"
status "installer in a screen."
status " "
status "This script will begin installing"
status "Feathur in 10 seconds. If you wish to"
status "cancel the install press CTRL + C"
sleep 10
status "Feathur needs a bit of information before"
status "beginning the installation."
status " "
status "What is the name of your trunk interface?"
possibleOptions=$(for i in $(ifconfig -a | grep Link | grep -v inet6 | grep Ethernet | awk '{print $1}'); do echo -n $i; done)
status "Possible options: $possibleOptions";
read trunkinterface
status "What is the name of your volumegroup (Ex: volgroup00):"
read volumegroup
status "What is the name of your volume group backing volume: (Ex: /dev/sda3):"
read volumegroupbackingvolume
status " "
status "Beginning installation..."
## ACTION ##
yum -y install bridge-utils dhcp libvirt qemu-kvm vnstat lvm2 rsync screen wget nano 

cd /etc/yum.repos.d/;wget http://download.opensuse.org/repositories/home:/tsariounov:/cpuset/CentOS_CentOS-6/home:tsariounov:cpuset.repo;
cd ~/feathur-install/

vgcreate $volumegroup $volumegroupbackingvolume

mkdir -p /var/feathur/data

cp -R /etc/sysconfig/network-scripts /etc/sysconfig/network-scripts.backup
trunkconfig=$(egrep -v "(NM_CONTROLLED|IPADDR|GATEWAY|NETMASK|BROADCAST|BOOTPROTO)" /etc/sysconfig/network-scripts/ifcfg-$trunkinterface; echo 'BRIDGE="br0"')
bridgeconfig=$(egrep -v "(NM_CONTROLLED|DEVICE|TYPE)" /etc/sysconfig/network-scripts/ifcfg-$trunkinterface; echo 'INTERFACE="br0"'; echo 'TYPE="Bridge"')
echo "$trunkconfig" > /etc/sysconfig/network-scripts/ifcfg-$trunkinterface
echo "$bridgeconfig" > /etc/sysconfig/network-scripts/ifcfg-br0
service network restart
if [[ $(ping -c 3 8.8.8.8 | wc -l) == 5 ]]
then
	/bin/rm -Rf /etc/sysconfig/network-scripts/
	mv /etc/sysconfig/network-scripts.backup /etc/sysconfig/network-scripts
	service network restart
	echo "Error configuring network for bridge. Reverting."
fi

cd /
cd ~
mkdir ~/.ssh/
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
cd ~/.ssh/
cat id_rsa.pub >> ~/.ssh/authorized_keys
key=$(cat id_rsa)
status "Feathur SSH Key:"
status " "
status "$key"
iptables -F && service iptables save
status "Finishing installation"
