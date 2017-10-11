# sas94-sysprep-linux64
Shell Script to prepare a Linux 7.X (RHEL/Centos) server to deploy SAS 9.4 server deployment.


sudo yum install -y git

git clone https://github.com/tuxworld/sas94-sysprep-linux64
cd sas94-sysprep-linux7
chmod +x sas94-sysprep-linux7

#You will need to execute with sudo or with root user account as the script performs system configuration steps requiring you to be root such as create users.

sudo ./sas94-sysprep-linux7.sh
or

sudo su
./sas94-sysprep-linux7.sh

