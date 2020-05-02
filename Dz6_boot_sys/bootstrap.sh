yum install -y epel-release
yum localinstall --nogpgcheck http://epel.mirror.net.in/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum localinstall --nogpgcheck http://archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm
yum update    
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
cp /vagrant/*.sh  /root/

#echo "SHELL=/bin/bash" >> /var/spool/cron/root
#echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin" >> /var/spool/cron/root
#echo "@reboot sleep 20 && bash /root/start_after_reboot.sh >/tmp/all 2>&1" >> /var/spool/cron/root
echo "Install Soft"
yum install -y mdadm smartmontools hdparm gdisk lvm2 nano mc screen xfsdump script kernel-devel zfs haveged
chkconfig haveged on
echo "Rename VG"
vgrename VolGroup00 OtusRoot
echo "Change VG in configs"
sed -i 's/VolGroup00/OtusRoot/g' /boot/grub2/grub.cfg
sed -i 's/VolGroup00/OtusRoot/g' /etc/fstab
#sed
sed -i 's/rghb/ /' /boot/grub2/grub.cfg
sed -i 's/quiet/ /' /boot/grub2/grub.cfg
echo "Install module init.d"
chmod +x /root/test.sh
chmod +x /root/module-setup.sh
mkdir /usr/lib/dracut/modules.d/01test
cp /root/module-setup.sh /usr/lib/dracut/modules.d/01test/
cp /root/test.sh /usr/lib/dracut/modules.d/01test/
echo "initrd image generate"
mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)



