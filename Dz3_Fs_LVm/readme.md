# Работа с lvm  и файловыми системами

## Для того чтобы уменьшить раздел с системой, нужно его пересоздать.
## Первый этап происходит так - создаёться временный lvm и туда переноситься система, в неё делается chroot и пернастраивается загрузчик.


### bootstrap.sh
```bash

yum install -y epel-release
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
yum install -y mdadm smartmontools hdparm gdisk lvm2 nano mc screen xfsdump script
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

```

## После первой стадии необходимо зайти в машину и перезапустить её

```bash
vagrant ssg
sudo reboot

```

## После этого удаляется старый lvm и создаёться новый в 8 Gb

### start_after_reboot.sh
```bash
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

```

## После первой стадии необходимо зайти в машину и снова перезапустить её

```bash
vagrant ssg
sudo reboot

```

## Удаляем временный lvm и создаём mirror lvm и snapshot lvm и добавляем точки монтирования в fstab. Удаляем\Добавляем файлы и восстанавливаемся из snapshot.

### stage2.sh
```bash
#!/bin/bash
rm -f /var/spool/cron/root
yes | lvremove /dev/vg_tmp_root/lv_tmp_root && vgremove vg_tmp_root && pvremove /dev/sdc
mkdir /new_var && mkdir /new_home
lvcreate -n new_home  -L 1G VolGroup00 && mkfs.xfs /dev/VolGroup00/new_home
echo "Create LVM mirror"
vgcreate vg_raid1 /dev/sdc /dev/sdd
yes | lvcreate   --mirrors 1   --type raid1 -l 100%FREE    -n new_var vg_raid1
mkfs.xfs /dev/vg_raid1/new_var
echo "Add to fstab mount point"
echo '/dev/vg_raid1/new_var /new_var xfs    defaults    0 0' >> /etc/fstab
echo '/dev/VolGroup00/new_home  /new_home xfs    defaults    0 0' >> /etc/fstab
mount -a
touch /new_home/1.txt /new_home/sr.txt /new_home/egg.txt 
ls -la /new_home > /root/result.txt
lvcreate --size 1G --snapshot --name fist_snap /dev/VolGroup00/new_home
rm -f /new_home/sr.txt 
ls -la >> /root/result.txt
umount -f /new_home
lvconvert --merge /dev/VolGroup00/fist_snap
mount /dev/VolGroup00/new_home /new_home
ls -la /new_home >> /root/result.txt
```
