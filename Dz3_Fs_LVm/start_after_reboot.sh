#!/bin/bash
rm -f /var/spool/cron/root
yes | lvremove /dev/VolGroup00/LogVol00
yes | lvcreate -n root -L 8G VolGroup00
mkfs.xfs /dev/VolGroup00/root
sleep 10
mount /dev/VolGroup00/root /mnt
sleep 10
xfsdump -J - /dev/vg_tmp_root/lv_tmp_root | xfsrestore -J - /mnt
#sleep 60
echo "Prepare to chroot"
echo "SHELL=/bin/bash" >> /var/spool/cron/root
echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin" >> /mnt/var/spool/cron/root
echo "@reboot sleep 20 && bash /root/stage2.sh >/tmp/all 2>&1" >> /mnt/var/spool/cron/root
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
echo "Update  boot Images"
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
echo "Change boot LV"
sed -i 's/LogVol00/root/' /boot/grub2/grub.cfg
echo "Add next stage"
echo "Please reboot ME!"
exit
shutdown -r 
sleep 10