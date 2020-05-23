sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl  restart sshd
yum install -y epel-release
yum update       
mkdir -p ~root/.ssh
cp ~vagrant/.ssh/auth* ~root/.ssh
yum install -y -q tree yum-utils mc wget gcc vim git  screen
yum install fish wget -y -q
useradd -m admin           
echo "login;*;*;Wk0000-2400 " >> /etc/security/time.conf
echo "account    [success=1 default=ignore] pam_succeed_if.so user ingroup admin" >> /etc/security/time.conf
echo "account    required     pam_time.so" >> /etc/security/time.conf

# Install docker-ce
           sudo yum install -y -q yum-utils links \
           device-mapper-persistent-data \
           lvm2
           sudo yum-config-manager \
           --add-repo \
           https://download.docker.com/linux/centos/docker-ce.repo
           yum install docker-ce docker-compose -y -q
           systemctl start docker
 
 
 
 
 
 