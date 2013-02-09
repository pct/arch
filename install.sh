#!/bin/bash
###############################################################################
#
# This programm should help you install arch linux on your pc (version 4444)
# Copyright (C) Vienna 2012 by Mario Aichinger
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
###############################################################################

function ask_select()
{
echo $1
select menu_item in $2; do
	[ -n "$menu_item" ] && break
done
}

function sh_contact()
{
echo "";
echo "Thank you for using!";
echo "If you have any feedback, wishes or errors please email me";
echo "at arch@mario-aichinger.at";
echo "Also feel free to leaf a comment on bbs.archlinux.org/viewtopic.php?id=146450";
echo "";
echo "Happy hacking";
echo "Mario";
echo "";
}

function ask_for_keyboard()
{
ask_select "Select keyboardlayout:" "de en es fr us other"
if [ "$menu_item" == "other" ]; then
	read -p "Other? :" menu_item;
fi
loadkeys $menu_item;
kbl=$menu_item;
unset menu_item;
}

function ask_use_fdisk()
{
while [ 1 ]; do
        read -p "Use automatic patition [y/n]: " usefdisk;
        if [[ "$usefdisk" =~ ^[Yy]$ ]] || [[ "$usefdisk" =~ ^[Nn]$ ]]; then
                break;
        fi
done
}

function config_fdisk()
{
if [[ "$usefdisk" =~ ^[Yy]$ ]]; then
	fdiskconfok="n";
	while [[ ! "$fdiskconfok" =~ ^[Yy]$ ]]; do
		read -p "Select device (default is [sda]): " device;
		read -p "Bootsize (default is 100M) [100[K/M/G]]: " bootsize;
		read -p "Swapsize (default is 1024M) [100[K/M/G]]: " swapsize;
		read -p "Use separat home partition (default is no)[y/n]: " usesephome;
		if [[ "$usesephome" =~ ^[Yy]$ ]]; then
			read -p "size for / (default is 3000M) [3000[K/M/G]]: " rootsize;
			if [ -z "$rootsize" ]; then
				rootsize="3000M";
			fi
		fi
		if [ -z "$bootsize" ]; then
			bootsize="100M";
		fi
		if [ -z "$swapsize" ]; then
			swapsize="1024M";
		fi
		if [ -z "$device" ]; then
			device="sda";
		fi
		show_partition_config;
		read -p "Config ok [y/n]? :" fdiskconfok;
	done
else

wait_for_usr "Continue?"
fi
}

function show_partition_config()
{
echo "Device is $device";
echo "Size of /boot is $bootsize";
echo "Size of swap is $swapsize";
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
	echo "Size of / is $rootsize";
	echo "Using separat /home: Yes";
	else
	echo "Using separat /home: No";
fi
}

function set_fs(){
#set_fs "home" "ext3"
read -p "Set filesystem for /$1 (default is $2): " fs;
if [ -z "$fs" ]; then
	fs=$2
fi
if [ -z "$1" ]; then
	eval "rootfs=$fs"
else
	eval "$1"'fs='"$fs"
fi
}

function wait_for_usr()
{
read -p "$1" a;
unset a;
}

function ask_bootloader()
{
ask_select "Select bootloader" "GRUB SYSLINUX NONE";
bootloader=$menu_item;
unset menu_item;
}

function ask_network_if(){
ifs=""
for i in `cat /proc/net/dev | grep ':' | cut -d ':' -f 1`; do
	ifs="$ifs $i";
done
ask_select "network" "$ifs"
network_if=$menu_item;
unset menu_item;
}

function ask_network_method()
{
ask_select "Set network method" "dhcpcd manual";
nw_method=$menu_item;
unset menu_item;
if [ "$nw_method" == "manual" ]; then
	ask_for_manual_network_data;
fi
}

function ask_for_manual_network_data()
{
while [ 1 ]; do
while [ 1 ]; do
	read -p "IP (like 192.168.0.100): " ipaddress;
	if [ "$ipaddress" ];  then
		break;
	fi
done
while [ 1 ]; do
	read -p "Subnetmask (eg: 255.255.255.0): " subnetmask;
	if [ "$subnetmask" ];  then
                 break;
         fi
done
while [ 1 ]; do
        read -p "Gateway (eg: 192.168.0.1): " gateway;
	if [ "$gateway" ];  then
        	break;
        fi
done
while [ 1 ]; do
	read -p "Broadcast (like 192.168.0.255)" broadcast;
	if [ "$broadcast" ]; then
		break;
	fi
done
while [ 1 ]; do
	read -p "DNS-Server (eg: 8.8.8.8 (google)): " dnsserver;
	if [ "$dnsserver" ];  then
        	break;
	fi
done
echo "";
echo "IP: $ipaddress";
echo "Subnetmask: $subnetmask";
echo "Gateway: $gateway";
echo "Broadcast: $broadcast";
echo "DNS: $dnsserver";
read -p "Configuration ok[Y/n]: " ipconfigok
	if [[ "$ipconfigok" =~ ^[Yy]$ ]]; then
		break;
	fi 
done
}

function ask_custom_mirror()
{
while [ 1 ]; do
        read -p "Use custom mirror? [y/n]: " usecmirror
        if [[ "$usecmirror" =~ ^[Yy]$ ]] || [[ "$usecmirror" =~ ^[Nn]$ ]]; then
	        if [[ "$usecmirror" =~ ^[Yy]$ ]]; then
        		read -p "Enter the mirrors URL: " custom_mirror;
		fi
		break
        fi
done
}

function ask_base_devel()
{
while [ 1 ]; do
        read -p "Install base-devel? [y/n]: " installbasedevel
        if [[ "$installbasedevel" =~ ^[Yy]$ ]] || [[ "$installbasedevel" =~ ^[Nn]$ ]]; then
                break
        fi
done
}

function ask_add_packages()
{
read -p "Enter additional packages (separated by [space]): " addPac;
}
function ask_for_localdomain()
{
read -p "Enter the localdomain [localdomain]: " localedomain;
if [ -z "$localdomain" ]; then
	localdomain="localdomain";
fi
}

function ask_for_hostname()
{
while [ 1 ]; do
        read -p "Enter the new hostname: " hostname;
        if [ $hostname ]; then
                break;
        fi
done
}

function ask_for_zone()
{
first_zones=$(ls -1 /usr/share/zoneinfo);
ask_select "Select Zone: " "$first_zones";
zone=$menu_item;
zone_path="/usr/share/zoneinfo/$zone";
if [ -d "/usr/share/zoneinfo/$zone" ]; then
	second_zones=$(ls -1 /usr/share/zoneinfo/$zone)
	ask_select "Select SubZone: " "$second_zones"
	subzone=$menu_item;
	zone_path="/usr/share/zoneinfo/$zone/$subzone"
fi
unset menu_item;
}

function ask_locale()
{
ask_select "Locale: " "de_DE.UTF-8 en_US.UTF-8 es_ES.UTF-8 other";
locale=$menu_item;
if [ "$locale" == "other" ]; then
	read -p "Locale: " locale;
fi
}


function ask_for_root_password()
{
while [ 1 ]; do
        stty -echo
        read -p "Password: " passwd1; echo
        read -p "Password: " passwd2; echo
        stty echo
        if [ "$passwd1" == "$passwd2" ]; then
                break;
        else
                echo "Passwords do not match. Please try again.";
        fi

done
}

function ask_for_manual_partition()
{
echo "plase use an other terminal to patition [alt]+[F2-F6]";
wait_for_usr

}

function start_partition()
{
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
fdisk /dev/$device << EOF
d
1
d
2
d
3
d
4
n
p
1

+$bootsize
n
p
2

+$swapsize
n
p
3

+$rootsize
n
p


a
1
t
2
82
p
w
EOF
else
fdisk /dev/$device << EOF
d
1
d
2
d
#3
d
4
n
p
1

+$bootsize
n
p
2

+$swapsize
n
p
3


a
1
t
2
82
p
w
EOF
fi
}

function do_partition(){
if [[ "$usefdisk" =~ ^[Yy]$ ]]; then
	start_partition
else
	ask_for_manual_partition	
fi
}

function do_formating()
{
mkfs -t "$bootfs" /dev/"$device"1;
mkswap /dev/"$device"2
mkfs -t "$rootfs" /dev/"$device"3;
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
        mkfs -t "$homefs" /dev/"$device"4;
fi
}
function do_mount()
{
mount /dev/"$device"3 /mnt;
mkdir /mnt/boot;
mount /dev/"$device"1 /mnt/boot;
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
        mkdir /mnt/home;
        mount /dev/"$device"4 /mnt/home;
fi
}

function do_network()
{
if [ "$nw_method" == "dhcpcd" ]; then
        dhcpcd "$network_if";
else
        ifconfig "$network_if" address "$ipaddress" netmask "$subnetmask"
	ip route add default via "$gateway";
        ip link set "$network_if" up
	cp /etc/resolv.conf /etc/resolv.conf_bak
	sed "s!# /etc/resolv.conf.tail can replace this line!nameserver $dnsserver\n#/etc/resolv.conf.tail can replace this line!g" /etc/resolv.conf_bak >/etc/resolv.conf
fi
# else
#         read -p "IP (like 192.168.0.100/24): " ipaddress;
#         read -p "Gateway (like 192.168.0.1): " gateway;
#         ip addr add $ipaddress dev "$network_if";
#         ip route add default via "$gateway";
#         ip "$network_if" up
# fi
}

function install_base_system()
{
if [[ "$usecmirror" =~ ^[Yy]$ ]]; then
        echo "Please configure now the file /etc/pacman.d/mirrorlist in an other terminal [alt]+[F2-F6]!"
        wait_for_usr "Continue?"
fi
}


function install_base_devel()
{
if [[ "$installbasedevel" =~ [Yy] ]]; then
        pacstrap /mnt base base-devel
else
        pacstrap /mnt base
fi
}

function install_bootloader()
{
if [ "$bootloader" == "GRUB" ]; then
        echo "Install grub-bios"
        pacstrap /mnt grub-bios
elif [ "$bootloader" == "SYSLINUX" ]; then
        echo "Install syslinux";
        pacstrap /mnt syslinux
fi
}

function install_add_packages()
{
if [ "$addPac" ]; then
	pacstrap /mnt "$addPac"
fi
}

function gen_fstab()
{
genfstab -p /mnt >> /mnt/etc/fstab
}

function mk_locale_conf()
{
touch locale.conf_new
echo 'LANG="'"$locale"'"' > locale.conf_new;
cp locale.conf_new /mnt/etc/locale.conf
rm locale.conf_new
}


function chroot_into_new_system()
{
arch-chroot /mnt << EOF
echo "setting network"


cp /etc/rc.conf /etc/rc.conf_bak
sed "s/# interface=/interface=$network_if/g" /etc/rc.conf_bak >/etc/rc.conf
if [ "$nw_method" == "manual" ]; then
cp /etc/rc.conf /etc/rc.conf_bak
sed "s/# address=/address=$ipaddress/g" /etc/rc.conf_bak >/etc/rc.conf
cp /etc/rc.conf /etc/rc.conf_bak
sed "s/# netmask=/netmask=$subnetmask/g" /etc/rc.conf_bak >/etc/rc.conf
cp /etc/rc.conf /etc/rc.conf_bak
sed "s/# gateway=/gateway=$gateway/g" /etc/rc.conf_bak >/etc/rc.conf
cp /etc/rc.conf /etc/rc.conf_bak
sed "s/# broadcast=/broadcast=$broadcast/g" /etc/rc.conf_bak >/etc/rc.conf

cp /etc/resolv.conf /etc/resolv.conf_bak
sed "s!# /etc/resolv.conf.tail can replace this line!nameserver $dnsserver\n# /etc/resolv.conf.tail can replace this line!g" /etc/resolv.conf_bak >/etc/resolv.conf
rm /etc/resolv.conf_bak
fi
rm /etc/rc.conf_bak
echo "Setting hostname...";
cp /etc/hosts /etc/hosts_bak
sed "s/# End of file/127.0.0.1 $hostname.$localdomain $hostname\n\n#End of file/g" /etc/hosts_bak >/etc/hosts
cp /etc/hosts /etc/hosts_bak
sed "s/# End of file/::1 $hostname.$localdomain $hostname\n\n#End of file/g" /etc/hosts_bak >/etc/hosts
rm /etc/hosts_bak
echo "$hostname" > /etc/hostname
echo "Setting zoneinfo...";
ln -s $zone_parh /etc/localtime
echo "setting up locale...";
locale -a
cp /etc/locale.gen /etc/locale.gen_bak
sed 's/#$locale/$locale/g' /etc/locale.gen_bak >/etc/locale.gen
rm /etc/locale.gen_bak
locale-gen
if [ $kbl ]; then
echo "Saving keyboardlayout...";
echo "KEYMAP=$kbl" >/etc/vconsole.conf
echo "FONT=lat9w-16" >>/etc/vconsole.conf
echo "FONT_MAP=8859-1_to_uni" >>/etc/vconsole.conf
fi
echo "mkinitcpio -p linux..."
mkinitcpio -p linux
echo "Starting dm-mod...";
if [ "$bootloader" == "GRUB" ]; then
modprobe dm-mod
echo "Install and configure GRUB..."
grub-install --recheck --debug /dev/"$device"
mkdir -p /boot/grub/locale
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg
elif [ "$bootloader" == "SYSLINUX" ]; then
echo "Install syslinux";
/usr/sbin/syslinux-install_update -iam
fi
passwd << EOPF
$passwd1
$passwd2
EOPF
clear
exit
EOF
}

function unmount()
{
umount /mnt/boot
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
        umount /mnt/home
fi
umount /mnt
}

ask_for_keyboard
ask_use_fdisk
config_fdisk
set_fs "boot" "ext2"
set_fs "" "ext3"
if [[ "$usesephome" =~ ^[Yy]$ ]]; then
	set_fs "home" "ext3"
fi

#############################################################################
#
#		starting install procedure
#
#sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss



ask_bootloader
ask_network_method
ask_network_if
ask_custom_mirror
ask_base_devel
ask_add_packages
ask_for_zone
ask_for_hostname
ask_for_localdomain
ask_locale
ask_for_root_password
do_partition
do_formating
do_mount
do_network
install_base_system
install_base_devel
install_bootloader
install_add_packages
gen_fstab
mk_locale_conf
chroot_into_new_system
unmount
sh_contact



