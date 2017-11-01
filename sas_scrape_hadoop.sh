#!/bin/bash

#SAS Hadoop Scraper by: Blake Russo
##Execute script as sasinstall user.

#Host Info Basics
	echo -e " "
	echo -e "\e[31mHostname:\e[0m " `hostname`; echo
	echo -e "\e[31mOperating System:\e[0m " `cat /etc/*release`; echo
	echo -e "\e[31mMemory: \e[0m" `free -g`; echo 
	echo -e "\e[31mProcessors: \e[0m" `grep -c ^processor /proc/cpuinfo`; echo 
	echo -e " "
	
#check for script running as root user.
if [ "$(whoami)" = 'root' ]; then
        echo "Please execute this script as the SAS install user. This should now be your root user."
        exit 1;
fi

##Find SASHome Directory
if [ -f $HOME/.SASAppData/SASDeploymentWizard/sdwpreferences.txt ]
	then
		echo "sdwpreferences.txt exists"
		echo "Getting SASHome Path"
			SDW_SASHOME=`cat $HOME/.SASAppData/SASDeploymentWizard/sdwpreferences.txt | grep "SASHome="| cut -d"=" -f2 | uniq`
			export SDW_SASHOME
			
			echo " "
			echo "Your SASHOME path is: $SDW_SASHOME"
			echo " "
			
			#Checking to see if your SAS Home actually exists.
			if [ -d "$SDW_SASHOME" ]
				then 
					echo "SASHome Found at $SDW_SASHOME"
				else
					echo "SASHome was not found in $SDW_SASHOME"				
			fi	
	else
		echo "Unable to find $HOME/.SASAppData/SASDeploymentWizard/sdwpreferences.txt to determine SASHome..."
		echo "Please make sure you are logged in as the SAS install user account"
fi


#Find/Check for Configuration Directory
	
	for SAS_CONFIG_PATH in `cat $HOME/.SASAppData/SASDeploymentWizard/SDW*.log | grep "Configuration Directory:" | grep -v "Install Only" | awk '{print $3}' | uniq`; do
		if [ -d "$SAS_CONFIG_PATH" ]
			then 
				echo "SAS Configuration Path Found at: " $SAS_CONFIG_PATH
			else
				echo "SAS Configuration Path Not Found"
		fi 	
	done
	
#Check for SAS Hadoop Environment Variables being set in sasenv_local.
echo " "
echo "You have your SAS_HADOOP_CONFIG_PATH currently set to: "
	cat $SDW_SASHOME/SASFoundation/9.4/bin/sasenv_local | grep -i SAS_HADOOP_CONFIG_PATH
		if [ $? = 0 ]
			then
				echo "Setting SAS_HADOOP_CONFIG_PATH Environment variable for testing."
				`cat $SDW_SASHOME/SASFoundation/9.4/bin/sasenv_local | grep -i SAS_HADOOP_CONFIG_PATH` 
				echo "Your SAS_HADOOP_CONFIG_PATH is successfully set to: $SAS_HADOOP_CONFIG_PATH"
				#Check Config Files
				ls -la $SAS_HADOOP_CONFIG_PATH
				
			else
				echo "SAS_HADOOP_CONFIG_PATH Environment Variable not found"
		fi
		
		
#Check for Hadoop Jar Files
cat $SDW_SASHOME/SASFoundation/9.4/bin/sasenv_local | grep -i SAS_HADOOP_JAR_PATH
		if [ $? = 0 ]
			then
				echo "Setting SAS_HADOOP_JAR_PATH Environment variable for testing."
				`cat $SDW_SASHOME/SASFoundation/9.4/bin/sasenv_local | grep -i SAS_HADOOP_CONFIG_PATH` 
				echo "Your SAS_HADOOP_JAR_PATH is successfully set to: $SAS_HADOOP_JAR_PATH"
				#Check Jars
				echo "Found " `ls -la $SAS_HADOOP_JAR_PATH` "Jar files in $SAS_HADOOP_JAR_PATH."
				#ls -la $SAS_HADOOP_JAR_PATH 
			else
				echo "SAS_HADOOP_CONFIG_PATH Environment Variable not found"
		fi		

#Gather Hadoop Environment Details
##Is the cluser secured with Kerberos?
cat $SAS_HADOOP_CONFIG_PATH/core-site.xml | grep -e hadoop.security.authentication
cat $SAS_HADOOP_CONFIG_PATH/core-site.xml | grep -e hadoop.security.authentication -a1 | grep value


