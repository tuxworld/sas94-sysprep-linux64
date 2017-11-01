echo "Update OpenStack SAS-IT instance with epel, upgrade, install missing packages that are common, remove restrictions on authorized keys, disable firewalld, "
      sudo yum install epel-release -y
      sudo yum upgrade -y
      yum install -y mlocate  nc lsof wget git bind-utils firefox telnet perl krb5-workstation.x86_64 bind-utils strace unzip
      yum install -y compat-libstdc++-33.x86_64 libXext.x86_64 libXext-devel.x86_64 libXp.x86_64 libXp-devel.x86_64 libXtst.x86_64 libXtst-devel.x86_64 glibc.x86_64 numactl.x86_64 perl.x86_64 compat-glibc libXrandr.x86_64

echo "Remove restrictions on loggin in with OpenStack PEM file which is restricted to centos user"
#https://saszone.unx.sas.com:8443/display/LAX/How+to+modify+OpenStack+Authorized+Keys+customizations
      cd $HOME/.ssh; cp authorized_keys authorized_keys.orig
      cat authorized_keys | cut -d" " -f14-15 > authorized_keys.new
      mv authorized_keys.new authorized_keys
      cat authorized_keys

 echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config


echo "disabling firewalld if running"
which firewalld
  if [[ $? -eq 0 ]]
    then
        echo "firewalld found, disabling"
        sudo systemctl stop firewalld.service
        sudo systemctl disable firewalld.service
    elif [[ $?=1 ]]; then
      #statements
	       echo "firewalld packages not found, nothing to disable"
fi


echo "fixing cloud.cfg to not remove hostname set, remove /etc/hosts entires or update hostname info"
      cp /etc/cloud/cloud.cfg /etc/cloud/cloud.cfg.orig
      cp ../conf/cloud-config-custom.cfg /etc/cloud/cloud.cfg


#echo "fixing ssh client/server to enable password plus other things"
#cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bkup
#cp /etc/ssh/ssh_config /etc/ssh/ssh_config
#wget ftp://destiny.unx.sas.com/tum_labs/custom_files/sm_custom_sshd_config
#cp -f sm_custom_sshd_config /etc/ssh/sshd_config
#systemctl restart sshd.service

#echo "create user passwords for root user + centos"
#usermod --password Orion123 root
#usermod --password Orion123 centos

echo "
*       hard    nofile  350000
*       soft    nofile  350000
*       hard    nproc   100000
*       soft    nproc   100000
*       hard    stack   10240
*       soft    stack   10240
" >> /etc/security/limits.conf

echo "root       soft    nproc     unlimited" > /etc/security/limits.d/20-nproc.conf


read -p "\nMount Common SAS TS NFS Mounts? (Y or N)" YesNo

YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
#update mounts
mkdir /TECHTMP /TECH /DEPOT /INSTALLDEPOT /BIGDATA /DESTINY  /DESTINYFTP
chmod 777 /TECHTMP /TECH /DEPOT /INSTALLDEPOT /BIGDATA /DESTINY  /DESTINYFTP
echo "ge.unx.sas.com:/vol/vol19/tux-tmp        /TECHTMP        nfs      exec,dev,suid,rw 1 1" >> /etc/fstab
echo "ge.unx.sas.com:/vol/vol19/tux-lnx        /TECH   nfs      exec,dev,suid,rw 1 1" >> /etc/fstap
echo "maytag.unx.sas.com:/vol/vol13/unix_depot        /DEPOT   nfs      exec,dev,suid,rw 1 1" >> /etc/fstab
echo "depotgen.unx.sas.com:/vol/sassd_root        /INSTALLDEPOT   nfs      exec,dev,suid,ro 1 1" >> /etc/fstab
echo "shake.unx.sas.com:/export/bi_tools /BIGDATA          nfs exec,dev,suid,ro 1 1" >> /etc/fstab
#MY (blake NFS shared - /DESTINY=depot mount usually + /DESTINYFTP are my other downloadable files.)
echo "destiny.unx.sas.com:/destiny /DESTINY nfs defaults 1 1" >> /etc/fstab
echo "destiny.unx.sas.com:/var/ftp /DESTINYFTP nfs defaults 1 1" >> /etc/fstab
mount -a
fi

echo "set selinux to be permissive"
sestatus
setenforce 0
sestatus



read -p "\nCreate install directorys /sas94/sashome config depot etc owned by sasinst? (Y or N)" YesNo
YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
    echo "Creating /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/ /etc/opt/vmware/vfabric "

fi
mkdir /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/
mkdir -p /etc/opt/vmware/vfabric

read -p "\nWould you like to create local user accounts for sasinst, sassrv, and sasdemo (select no if setting up LDAP/PAM)? (Y or N)" YesNo

YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
    echo "creating sasinst, sassrv, and sasdemo local user accounts. Default Password=Orion123. Default home =/home/username"
    #Create users
    useradd sasinst
    usermod --password Orion123 sasinst

    useradd sassrv
    usermod --password Orion123 sassrv
    usermod -aG sasinst sassrv

    useradd sasdemo
    usermod --password Orion123 sasdemo
    usermod -aG sasinst sasdemo
    id sasinst sassrv sasdemo
    chown sasinst:sasinst -R /etc/opt/vmware/
    chmod 755 /etc/opt/vmware/ -R
fi




