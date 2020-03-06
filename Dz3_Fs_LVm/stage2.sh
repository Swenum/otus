#!/bin/bash
rm -f /var/spool/cron/root
yes | lvremove /dev/vg_tmp_root/lv_tmp_root && vgremove vg_tmp_root && pvremove /dev/sdc
mkdir /new_var && mkdir /new_home
lvcreate -n new_home  -L 1G VolGroup00 && mkfs.xfs /dev/VolGroup00/new_home
echo "Create LVM mirror"
vgcreate vg_raid1 /dev/sdc /dev/sdd
yes | lvcreate   --mirrors 1   --type raid1 -l 100%FREE   -n new_var vg_raid1
mkfs.xfs /dev/vg_raid1/new_var
echo "Add to fstab mount point"
echo '/dev/vg_raid1/new_var /new_var xfs    defaults    0 0' >> /etc/fstab
echo '/dev/VolGroup00/new_home  /new_home xfs    defaults    0 0' >> /etc/fstab
mount -a
touch /new_home/1.txt /new_home/sr.txt /new_home/egg.txt 
ls -la /new_home > /root/result.txt
lvcreate --size 1G --snapshot --name fist_snap /dev/VolGroup00/new_home
rm -f /new_home/sr.txt 
ls -la /new_home >> /root/result.txt
umount -f /new_home
lvconvert --merge /dev/VolGroup00/fist_snap
mount /dev/VolGroup00/new_home /new_home
ls -la /new_home >> /root/result.txt
mkfs.btrfs -m raid0 /dev/sdf /dev/sdg
mount /dev/sdf /opt
touch /opt/1_btrfs.txt /opt/sr_btrfs.txt /opt/egg_btrs.txt 
btrfs subvolume create /opt/subvolume
rm -f /opt/1_btrfs.txt
ls -la /opt >> /root/result.txt
btrfs subvolume delete /opt/subvolume

