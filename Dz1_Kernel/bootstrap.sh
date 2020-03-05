sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl  restart sshd
yum install -y epel-release
yum update       
yum install -y patch xz-utils kernel-devel kernel-headers gcc make dkms perl bzip2 ncurses-devel  bc bison flex elfutils-libelf-devel openssl-devel grub2 wget curl iotop mc htop screen  
cd /usr/src/ && wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.5.tar.xz && unxz -v linux-5.5.tar.xz
cd /usr/src/  && wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/patch-5.5.xz && unxz patch-5.5.xz
yum install -y http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo elrepo-kernel install kernel-ml -y
	     

