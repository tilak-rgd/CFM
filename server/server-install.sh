#!/bin/bash
#comment out below line to print each command out
#set -x
installPath=/opt
tomcatLocation=$installPath/installation/server-tomcat
cd /opt/
source /etc/profile


muleServer_pid(){
	echo `ps aux | grep server-tomcat | grep -v grep | awk '{print $2}'`
}

sudo service cron stop
echo "################################################################################"
ps -ef | grep cron
if [ -d $installPath/installation/server-tomcat ]
then
		echo "Stopping MuleServer."
        kill -9 $(muleServer_pid)
        echo "MuleServer stoped."
      
        echo "################################################################################"
        echo "$(ps -ef | grep java)"
		
        if [ -d $tomcatLocation/webapps/CFMule ]
        then
                rm -rf $installPath/CFMule-bkp
				cp -a $s/webapps/CFMule $installPath/CFMule-bkp
                sleep 2
#                rm -rf $tomcatLocation/webapps/CFMule
                rm -rf $tomcatLocation/webapps/CFMule.war
        else
                echo "There is no existing war to take backup"
        fi
else
		echo "Installing server-tomcat."
#        cd $installPath/installation
#        wget https://arinstallers.s3-us-west-2.amazonaws.com/server-tomcat.zip
#        unzip server-tomcat.zip
        echo "Tomcat installed."
fi

cp -a $installPath/CFMule.war $tomcatLocation/webapps/
sleep  5s
cd $tomcatLocation/bin/
#./startup.sh
sleep  20s
sudo service apache2 restart
sleep  10s
echo "################################################################################"
echo "$(ps -ef | grep java)"
echo "MuleServer started"
echo "cron start"
echo "################################################################################"
sudo service cron start
echo "$(ps -ef | grep cron)"
echo "$(ls -lrt $tomcatLocation/webapps/)"
echo "$(exit)"