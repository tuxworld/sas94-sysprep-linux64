#!/bin/bash
#SAS Install Check Script


echo -e "\e[1;4mSAS Install Check Script\e[0m"

#Host Info
	echo -e "\e[31mHostname:\e[0m " `hostname`; echo
	echo -e "\e[31mOperating System:\e[0m " `cat /etc/*release`; echo
	echo -e "\e[31mMemory: \e[0m" `free -g`; echo 
	echo -e "\e[31mProcessors: \e[0m" `grep -c ^processor /proc/cpuinfo`; echo 
	echo -e " "

#Checking Security Requirements
echo -e "\e[1;4mChecking Security Requirements\e[0m"
	CURRELEASE=`cat /etc/*-release | grep "release" | uniq | awk '{print $7}'| cut -d"." -f1`
	#Check Firewall/IPTABLS
	if [ $CURRELEASE -eq 6 ]
			then
				echo "RHEL 6"
				service iptables status
		elif [ $CURRELEASE -eq 7 ]
			then
				echo "RHEL 7"
				/bin/systemctl status firewalld
		else
			echo "Another non-RedHat distribution of LINUX (possibly) found"
	fi
	#Check SELINUX Status 
	sestatus 
	
#Check SAS External User Accounts
	echo -e "\e[31mCheck Install User\e[0m"; echo ""
		whoami; id; echo $HOME; echo $SHELL
	echo -e "\e[31mCheck for Other SAS External User Accounts (ie. sassrv, sasdemo, ect)\e[0m"
		id | awk '{print $2}' | cut -d"=" -f2 | cut -d"(" -f1
	#Find Users of the logged in users primary group
		getent group | grep `id | awk '{print $2}' | cut -d"=" -f2 | cut -d"(" -f1`

	#Check for SUDO/root
	#sudo -l
	
	ulimit -a | grep -i -e "open files" -e "max user processes" -e "stack size"
	
	
	echo -e "UMASK: " `umask`
	mount | grep noexec	
	
	
#Checking Network Settings and DNS
	echo -e "\e[31mChecking Network and DNS\e[0m"; echo

	#Check to see if they have any /etc/hosts entries
	cat /etc/hosts | grep -v "#"  | grep -v localhost
	#Check DNS for an entry to for hostname
	
	echo -e "\e[31DNS Lookup Results for $HOSTNAME \e[0m"
	nslookup $HOSTNAME
	#Get Server IP Address
	echo -e "IP Address: " `ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
	#Reverse DNS Lookup on IP
	echo -e "ReverseDNS Lookup Results: "
	nslookup `ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`





#Check for Previous SAS Install Attempt, then check more if found.
if [ -d "$HOME/.SASAppData/SASDeploymentWizard" ]; then
  echo "Previous Installation Attempts Found - $HOME/.SASAppData Found - Gathering Previous Install Details"
  echo "Number of Previous SDW logs Found: " `ls -t $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | wc -l`
	#echo "Latests SDW*.log " `ls -t $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | head -1`
		cat `ls -t $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | head -1` | grep "User ID:"
	#echo "Latest Deployment Summary: "
			#cat `ls -t $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | head -1` | grep -a5 "INFO: Deployment Summary"
			
			
	#Check Machine Name and to see if install is planned.
	cat $HOME/.SASAppData/SASDeploymentWizard/sdwpreferences.txt | grep  -e "MachineName=" -e "PlannedInstall=" -e "Order"
	
	#Find/Check  for the existence of SASHOME
		for sashomedir in `cat $HOME/.SASAppData/SASDeploymentWizard/sdwpreferences.txt | grep -i sashome | cut -d"=" -f2 | uniq `; do 
			if [ -d "$sashomedir" ]; then 
				echo "SASHome Found at $sashomedir"
			fi		
		done
	
	#Find/Check for Configuration Directory
	
		for sasconfigdir in `cat $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | grep "Configuration Directory:" | grep -v "Install Only" | awk '{print $3}' | uniq`; do
			if [ -d "$sasconfigdir" ]; then 
				# Check status of sas.servers, if it exists.
				if [ -f "$sasconfigdir/sas.servers" ]; then $sasconfigdir/sas.servers status; fi 	
			fi
		done
	

#Check Port Status
	echo -e "Checking for Configured Listening Ports"; echo " " 
	for sasports in `cat $HOME/.SASAppData/SASDeploymentWizard/ResponseRecord*log | grep -i "port=" | grep -v "#" | cut -d"=" -f2 | sort | uniq`; do 
		lsof -i tcp:$sasports | grep LISTEN
	done
		
	$sasconfigdir/sas.servers status 

fi #END Intial if -d for .SASAppData, do not delete.

#OS Package Check
#yum list numactl
#yum list LibXP
