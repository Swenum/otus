yum install -y epel-release
yum localinstall --nogpgcheck http://epel.mirror.net.in/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
yum localinstall --nogpgcheck http://archive.zfsonlinux.org/epel/zfs-release.el7.noarch.rpm
yum update    
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
cp /vagrant/*.sh  /root/
chmod +x /root/start_after_reboot.sh
chmod +x /root/stage2.sh
echo "SHELL=/bin/bash" >> /var/spool/cron/root
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin" >> /var/spool/cron/root
echo "@reboot sleep 20 && bash /root/start_after_reboot.sh >/tmp/all 2>&1" >> /var/spool/cron/root
echo "Install Soft"
yum install -y mdadm smartmontools hdparm gdisk lvm2 nano mc screen xfsdump script kernel-devel zfs
echo "Create Tempory LV"
pvcreate /dev/sdc && vgcreate vg_tmp_root /dev/sdc && lvcreate -n lv_tmp_root -l +100%FREE /dev/vg_tmp_root
mkfs.xfs /dev/vg_tmp_root/lv_tmp_root && mount /dev/vg_tmp_root/lv_tmp_root /mnt && xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
echo "Prepare to chroot"
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
echo "Update  boot Images"
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
echo "Change boot LV"
sed -i 's/VolGroup00/vg_tmp_root/' /boot/grub2/grub.cfg && sed -i 's/LogVol00/lv_tmp_root/' /boot/grub2/grub.cfg
echo "Please reboot ME!"
grub2-set-default 1
exit
echo "Reboot"
/usr/sbin/shutdown -r


