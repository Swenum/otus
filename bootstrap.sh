sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl  restart sshd
yum install -y epel-release
yum update       
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
#mdadm --zero-superblock --force /dev/sd{b,c,d,e}
mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd{b,c,d,e}	     
mkfs.ext4 -b 4096 -E stride=16,stripe-width=32 /dev/md0
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf
mkdir /raid5
echo '/dev/md0      /raid5     ext4    defaults    1 2' >> /etc/fstab