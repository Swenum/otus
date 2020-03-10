sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl  restart sshd
yum install -y epel-release
yum update       
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y -q tree yum-utils mc wget gcc vim git  screen
           yum install fish wget -y -q
# Install tools for building rpm
           yum install rpmdevtools rpm-build -y -q
           
# Install tools for building woth mock and make prepares    
           yum install mock -y -q
           usermod -a -G mock root
# Install tools for creating your own REPO
           yum install nginx -y -q
           yum install createrepo -y -q
# Install docker-ce
           sudo yum install -y -q yum-utils links \
           device-mapper-persistent-data \
           lvm2
           sudo yum-config-manager \
           --add-repo \
           https://download.docker.com/linux/centos/docker-ce.repo
           yum install docker-ce docker-compose -y -q
           systemctl start docker
 #Add repository nginx
 cp ~vagrant/nginx.repo   /etc/yum.repos.d/nginx.repo
 yum update
  
 cd ~
 rpmdev-setuptree
 yumdownloader --source nginx
 rpm -Uvh nginx*.src.rpm
 #rpm2cpio nginx*.src.rpm | cpio -idmv 
 yum-builddep -y nginx
 cd /usr/src
 wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
 tar xzvf  openssl-*.tar.gz
 git clone https://github.com/eustas/ngx_brotli.git
 cd ngx_brotli
 git submodule update --init 
 echo "--add-module=/usr/src/ngx_brotli --with-openssl=/usr/src/openssl-1.1.1d --with-openssl-opt=enable-tls1_3" >> ~/rpmbuild/SPECS/nginx.spec
 cd ~/rpmbuild/SPECS/
 rpmbuild -ba nginx.spec