yum install -y epel-release
yum update       
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk lvm2 mc screen xfsdump script
pvcreate /dev/sdc && vgcreate vg_tmp_root /dev/sdc && lvcreate -n lv_tmp_root -l +100%FREE /dev/vg_tmp_root
mkfs.xfs /dev/vg_tmp_root/lv_tmp_root && mount /dev/vg_tmp_root/lv_tmp_root /mnt && xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
sed -i 's/VolGroup00/vg_tmp_root/' /boot/grub2/grub.cfg && sed -i 's/LogVol00/lv_tmp_root/' /boot/grub2/grub.cfg
grub2-set-default 1
exit
shutdown -r now