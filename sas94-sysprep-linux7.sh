
#Update Packages then install Linux server packages from OS repository that are requirements for SAS software deployment, usage, and troubleshooting.
echo "Updating packages + install required OS packages for SAS Deployment"
echo ""
echo "Update OpenStack SAS-IT instance with epel, upgrade, install missing packages that are common, remove restrictions on authorized keys, disable firewalld, "
      sudo yum install epel-release -y
      sudo yum upgrade -y
      yum install -y mlocate  nc lsof wget git bind-utils firefox telnet perl krb5-workstation.x86_64 bind-utils
      yum install -y compat-libstdc++-33.x86_64 libXext.x86_64 libXext-devel.x86_64 libXp.x86_64 libXp-devel.x86_64 libXtst.x86_64 libXtst-devel.x86_64 glibc.x86_64 numactl.x86_64 perl.x86_64 compat-glibc libXrandr.x86_64

echo ""
echo ""

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

#Update ulimit requirements on server for SAS install user + SAS Users

echo "Updating System Ulimits for nofile to be 150000 + nproc with 20480. This meets SAS planned deployment minimum requirements. Without updating these deployment could fail, especially when configuring the SAS Middle Tier"
echo ""
cp /etc/security/limits.conf /etc/security/limits.conf.bkup
echo "
*       hard    nofile  150000
*       soft    nofile  150000
*       hard    nproc   20480
*       soft    nproc   20480
*       hard    stack   10240
*       soft    stack   10240
" >> /etc/security/limits.conf
#updating the nproc ulimit file which can override /etc/security/limits.conf if not changes as well"
cp /etc/security/limits.d/20-nproc.conf /etc/security/limits.d/20-nproc.conf.bkup
echo "root       soft    nproc     unlimited" > /etc/security/limits.d/20-nproc.conf

echo "set selinux to be permissive - temporary - selinux will enable on reboot - if you need disable manually"
sestatus
setenforce 0
sestatus

read -p "\nWould you like to create local user accounts for sasinst, sassrv, and sasdemo (select no if setting up LDAP/PAM)? (Y or N)" YesNo

YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
    echo "creating sasinst, sassrv, and sasdemo local user accounts. Default Password=Orion123. Default home =/home/username"
    #Create users
    useradd sasinst
    usermod --password mypassword sasinst

    useradd sassrv
    usermod --password mypassword sassrv
    usermod -aG sasinst sassrv

    useradd sasdemo
    usermod --password mypassword sasdemo
    usermod -aG sasinst sasdemo
    id sasinst sassrv sasdemo

fi
echo ""
echo ""
echo ""
echo "Default SAS9.4 Folder Structure:"
echo "SAS Root Directory: /sas94"
echo "SASHOME: /sas94/sashome - SASHome folder required"
echo "SASCONFIG: /sas94/config - SAS Config folder required for planned deployment"
echo "SAS Depot: /sas94/depot - Folder to download/mount your SAS Software Depot to."
echo "SAS Third Party Foldar - optional folder to put things like jars/drivers"
echo "SAS Middle Tier VMWare VFabric Folder: /etc/opt/vmware/vafabric - required for SAS Middle Tier server deployment"
echo" "
read -p "\nCreate SAS94 folder structure to deploy with? wned by sasinst? (Y or N)" YesNo
echo ""
echo ""
YN=`echo $YesNo | tr [:lower:] [:upper:]`
#Test to see if user wants all files
clear
if [[ $YN = "Y" ]]
  then
    echo "Creating /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/ /etc/opt/vmware/vfabric "


mkdir /sas94/ /sas94/depot /sas94/sashome /sas94/config /sas94/thirdparty  /sas94/response_files /sas94/other; chown -R sasinst:sasinst  /sas94/
mkdir -p /etc/opt/vmware/vfabric
chown sasinst:sasinst -R /sas94
chmod 755 -R /sas94
chown sasinst:sasinst -R /etc/opt/vmware/
chmod 755 /etc/opt/vmware/ -R

fi
