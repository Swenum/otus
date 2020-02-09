sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl  restart sshd
yum install -y epel-release
yum update       
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y mdadm smartmontools hdparm gdisk
#mdadm --zero-superblock --force /dev/sd{b,c,d,e}
# mdadm -S /dev/md1
mdadm --create --verbose /dev/md0 -l 5 -n 4 /dev/sd{b,c,d,e}	
yes | mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{f,g}     
mkfs.ext4 -b 4096 -E stride=16,stripe-width=32 /dev/md0
echo "DEVICE partitions" > /etc/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm.conf
parted -s /dev/md1 mklabel gpt
for i in {1..5} ; do sgdisk -n ${i}:0:+20M /dev/md1 ; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md1p$i; done
for i in $(seq 1 5); do mount /dev/md1p$i /raid/part$i; done
for i in $(seq 1 5); do echo "/dev/md1p$i /raid/part$i ext4 defaults 1 2 " >> /etc/fstab ; done
mkdir /raid5
echo '/dev/md0      /raid5     ext4    defaults    1 2' >> /etc/fstab
