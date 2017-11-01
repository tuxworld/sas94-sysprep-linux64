echo "Update system epel, upgrade, install missing packages that are common, remove restrictions on authorized keys, disable firewalld, "
      sudo yum install epel-release -y
      sudo yum upgrade -y
      yum install -y mlocate  nc lsof wget git bind-utils firefox telnet perl krb5-workstation.x86_64 bind-utils strace unzip
      yum install -y compat-libstdc++-33.x86_64 libXext.x86_64 libXext-devel.x86_64 libXp.x86_64 libXp-devel.x86_64 libXtst.x86_64 libXtst-devel.x86_64 glibc.x86_64 numactl.x86_64 perl.x86_64 compat-glibc libXrandr.x86_64



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




echo "set selinux to be permissive"
sestatus
setenforce 0
sestatus

echo " "
echo " "

read -p "\nWould you like to create local user accounts for sasinst, sassrv, and sasdemo (select no if setting up LDAP/PAM)? (Y or N)" YesNo
YN=`echo $YesNo | tr [:lower:] [:upper:]`
echo " "
echo " "

#Test to see if user wants all files
clear

if [[ $YN = "Y" ]]
  then
    echo "creating sasinst, sassrv, and sasdemo local user accounts. Default Password=Orion123. Default home =/home/username"
    #Create users
    useradd sasinst sassrv sasdemo
    usermod -aG sasinst sassrv
    
    usermod --password Orion123 sasinst
    usermod --password Orion123 sassrv
    usermod --password Orion123 sasdemo
       
    id sasinst sassrv sasdemo
   
    
    USERS_CREATED_FLAG=1
fi

echo " "
echo " "

read -p "\nCreate install directorys /sas94/sashome config depot etc owned by sasinst? (Y or N)" YesNo

YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
    echo "Creating /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/ /etc/opt/vmware/vfabric "
    
mkdir /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/
mkdir -p /etc/opt/vmware/vfabric
echo " "
fi

if [[ $USERS_CREATED_FLAG = 1 ]]
 then
	echo "Detected users created by script - setting permissions"
		chown -R sasinst:sasinst /sas94 /etc/opt/vmware/
		chmod 755 -R /etc/opt/vmware/ /sas94
else
	echo " "
	echo "Users not created via script, please set install user to be owner of /sas94 + subfolders and /etc/opt/vmware including vfabric subfolder. Also set default permissions to 755 on all folders"
	echo " "
fi 
echo " "
echo "done"




