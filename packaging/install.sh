#!/bin/bash -e

function usage() {
 echo ""
 echo "./install.sh -m | --install-management (Install the Management Server)";
 echo "./install.sh -a | --install-agent (Install the Agent)";
 echo "./install.sh -b | --install-baremetal (Install BareMetal Agent)";
 echo "./install.sh -s | --installus-user (Install the Usage Monitor)";
 echo "./install.sh -d | --installdb-database (Install the database server (from distribution's repo))";
 echo "./install.sh --install-management --install-agent --install-baremetal --install-user --install-database --install-mysql (Installing everything in one short using long option);"
 echo "./install.sh -m -a -b -s -d (Installing everything in one short using short option);"
 echo "./install.sh -u|--upgrade cloudstack|cdsk (Upgrade the CloudPlatform packages installed on this machine)";
 echo "./install.sh -r|--remove db (Remove the MySQL server (will not remove the MySQL databases))";
 echo "./install.sh -r cdsk|cloudstack (Removing all CloudPlatform packages on this machine)";
 echo "./install.sh -h | --help (To view the Man page)";
 echo ""
 exit 1;
 }

function cleanup() {
    rm -f /etc/yum.repos.d/cloud-temp.repo || true
}

function setuprepo() {
    pathtorepo=`pwd`
    echo "Setting up the temporary repository..." >&2
    echo \
"[cloud-temp]
baseurl=file://$pathtorepo
gpgcheck=0
enabled=1
name=CloudStack temporary repository
" > /etc/yum.repos.d/cloud-temp.repo

    echo "Cleaning Yum cache..." >&2
    rm -rf /var/cache/yum/x86_64/6Server/cloud-temp/
    yum clean expire-cache || true
}

function installed() {
    rpm -q "$@" > /dev/null 2>&1 || return $?
}

function doinstall() {
    yum install "$@" || return $?
}

function doinstallauto() {
    yum install "$@" -y || return $?
}

function doupdate() {

    if [[ "$(rpm -qa |grep cloudstack-awsapi)" ]]; then
    	rpm -qa |grep cloudstack-awsapi | xargs rpm -e --nodeps
    fi

    if [[ "$(rpm -qa |grep cloud-daemonize-3.0.7)" ]]; then
    	rpm -qa |grep cloud-daemonize-3.0.7 | xargs rpm -e --nodeps 2>/dev/null
    fi

    ##ignore if rpmsave file is not present
    if [[ "$(rpm -qa |grep cloudstack-agent)" ]]; then
        mv -f /etc/cloud.rpmsave /etc/cloud.old-rpmsave 2>/dev/null || true
    fi

    install_epel_pyargparse
    yum update --enablerepo='cloud-temp' 'cloudstack-*' || return $?

    if [[ "$(rpm -qa |grep cloud-agent-scripts-3.0.7)" ]]; then
    	rpm -qa |grep cloud-agent-scripts-3.0.7 | xargs rpm -e --nodeps 2>/dev/null
    fi

    CCP_Version=`rpm -qa |grep cloudstack-management|cut -f3 -d -`

    if [[ "$CCP_Version" > 4.5 ]]; then
        rm -rf /usr/share/cloudstack-management/webapps/client/WEB-INF/lib/cloud-*[0-9].[0-9].[0-9].[1-9].jar  2>/dev/null
        rm -rf /usr/share/cloudstack-management/webapps/client/WEB-INF/lib/cloudstack-*[0-9].[0-9].[0-9].[1-9].jar  2>/dev/null
    fi

    #rpm -Uvh --force cloud-scripts-*.rpm

}

function install_epel_pyargparse() {

    yum update --disablerepo=cloud-temp -y
    doinstallauto wget python-setuptools
    epel_download_path=/tmp/cloud-temp
    epel6_rpm_location=$epel_download_path/dl.fedoraproject.org/pub/epel/6/x86_64/
    epel7_rpm_location=$epel_download_path/dl.fedoraproject.org/pub/epel/7/x86_64/e
    echo "Installing EPEL "
    if [[ `rpm -qa | grep epel-release` == "" ]];then
        if [[ `cat /etc/redhat-release` =~ " 7." ]]; then
            wget -r --no-parent -A 'epel-release-*.noarch.rpm' http://dl.fedoraproject.org/pub/epel/7/x86_64/e/ -P $epel_download_path  2>/dev/null
           if [ -f $epel7_rpm_location/*.rpm ]; then
               rpm -ivh $epel7_rpm_location/*.rpm
           fi
        elif  [[ `cat /etc/redhat-release` =~ " 6." ]]; then
           wget -r --no-parent -A 'epel-release-*.noarch.rpm' http://dl.fedoraproject.org/pub/epel/6/x86_64/ -P $epel_download_path  2>/dev/null
           if [ -f $epel6_rpm_location/*.rpm ]; then
             rpm -ivh $epel6_rpm_location/*.rpm
           fi
        fi
    fi
    echo "Installing Python Argparse"
    if [[ `rpm -qa | grep python-argparse` == "" ]];then
        if [[ `cat /etc/redhat-release` =~ " 7." ]]; then
           rpm -ivh http://s3.download.accelerite.com/packages/python-argparse-1.2.1-6.1.noarch.rpm
        elif  [[ `cat /etc/redhat-release` =~ " 6." ]]; then
           rpm -ivh http://s3.download.accelerite.com/packages/python-argparse-1.2.1-2.el6.noarch.rpm
        fi
    fi
    rm -rf $epel_download_path

}

function doremove() {
    yum remove "$@" || return $?
}

set +e
[ `whoami` != 'root' ] && echo "This script must run as root" && exit 1
uname -a | grep 'x86_64' >/dev/null
[ "$?" -ne 0 ] && echo "CloudPlatform only supports x86_64 platform now" && exit 1
set -e

trap "cleanup" INT TERM EXIT

cd `dirname "$0"`

installms="    M) Install the Management Server
"
installag="    A) Install the Agent
"
installbm="    B) Install BareMetal Agent
"
installus="    S) Install the Usage Monitor
"
installdb="    D) Install the database server (from distribution's repo)
"
quitoptio="    Q) Quit
"
unset removedb
unset upgrade
unset remove

if installed cloudstack-management || installed cloudstack-agent || installed cloudstack-usage || installed cloudstack-baremetal-agent || installed cloud-client || installed cloud-agent || installed cloud-usage || installed cloud-baremetal-agent; then
    upgrade="    U) Upgrade the CloudPlatform packages installed on this computer
"
    remove="    R) Stop any running CloudPlatform services and remove the CloudPlatform packages from this computer
"
fi
if installed cloudstack-management ; then
    unset installms
fi
if installed cloudstack-agent ; then
    unset installag
fi
if installed cloudstack-usage ; then
    unset installus
fi
mysql_note=""

if installed mysql-server ; then
    unset installdb
    removedb="    E) Remove the MySQL server (will not remove the MySQL databases)
"
    mysql_note="3.We detect you already have MySql server installed, you can bypass mysql install chapter in CloudPlatform installation guide.
        Or you can use E) to remove current mysql then re-run install.sh selecting D) to reinstall if you think existing MySql server has some trouble.
        For MySql downloaded from community, the script may not be able to detect it."
fi


if [ $# -lt 1 ] ; then

setuprepo

	read -p "Welcome to the CloudPlatform Installer.  What would you like to do?

	NOTE:	For installing KVM agent, please setup EPEL<http://fedoraproject.org/wiki/EPEL> yum repo first;
		For installing CloudPlatform on RHEL6.x, please setup distribution yum repo either from ISO or from your registeration account.
		$mysql_note

$installms$installag$installbm$installus$installdb$upgrade$remove$removedb$quitoptio > " installtype

fi

if [ "$installtype" == "q" -o "$installtype" == "Q" ] ; then

    true

	elif [ "$installtype" == "m" -o "$installtype" == "M" ] ; then
		echo "Installing the Management Server..."
        install_epel_pyargparse
		doinstall cloudstack-management
		true

	elif [ "$installtype" == "a" -o "$installtype" == "A" ] ; then
		echo "Installing the Agent..." >&2
		install_epel_pyargparse
		if doinstall cloudstack-agent; then
                        modprobe kvm
                        modprobe kvm_intel > /dev/null 2>&1
                        modprobe kvm_amd > /dev/null 2>&1
                        yum localinstall 6.5/ccp-qemu-img* -y
			echo "Agent installation is completed, please add the host from management server" >&2
		else
			echo "Agent installation failed" >&2
                        exit 1
		fi

	elif [ "$installtype" == "b" -o "$installtype" == "B" ] ; then
		echo "Installing the BareMetal Agent..." >&2
		doinstall cloudstack-baremetal-agent
		true

	elif [ "$installtype" == "s" -o "$installtype" == "S" ] ; then
		echo "Installing the Usage Server..." >&2
		doinstall cloudstack-usage
		true

	elif [ "$installtype" == "d" -o "$installtype" == "D" ] ; then
		echo "Installing the MySQL server..." >&2
    	        if [[ `cat /etc/redhat-release` =~ "release 7." ]]; then
            	    mysql_type=mysql-community-server
        	    if [[ `curl -s --head -w %{http_code} http://dev.mysql.com/ -o /dev/null` == "200" ]]; then
                       echo "Mysql repo http://dev.mysql.com server exist"
                       rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm

        	    else
            	       echo "Unable to acccess http://dev.mysql.com/, mysql repo not configured, please configure mysql server repo"
                    fi
     	        else
        	    mysql_type=mysql-server
         fi
		if doinstall $mysql_type ; then
			#/sbin/chkconfig --add mysqld
			/sbin/chkconfig --level 345 mysqld on
        if /sbin/service mysqld status > /dev/null 2>&1 ; then
            echo "Restarting the MySQL server..." >&2
            /sbin/service mysqld restart # mysqld running already, we restart it
        else
            echo "Starting the MySQL server..." >&2
            /sbin/service mysqld start   # we start mysqld for the first time
        fi
		else
			true
		fi

	elif [ "$installtype" == "u" -o "$installtype" == "U" ] ; then
		echo "Updating the CloudPlatform and its dependencies..." >&2
		doupdate


	elif [ "$installtype" == "r" -o "$installtype" == "R" ] ; then
		echo "Removing all CloudPlatform packages on this computer..." >&2
		doremove 'cloudstack-*'

	elif [ "$installtype" == "e" -o "$installtype" == "E" ] ; then
		echo "Removing the MySQL server on this computer..." >&2
		doremove 'mysql-server'

#Start of auto detect options

elif [ $# -gt 0 ] ; then

function commonUpgrade () {
	#Common Upgrade section
		if installed cloud-client || installed cloud-agent || installed cloud-usage || installed cloud-baremetal-agent; then
			echo "***** Updating the CloudPlatform and its dependencies *****"
			doupdate
		fi
}

function commonRemoval () {
#Common Remove section
	if [ "$remove" == "cdsk" ] || [ "$remove" == "cloudstack" ]; then
		if installed cloud-client || installed cloud-agent || installed cloud-usage || installed cloud-baremetal-agent; then
		echo "***** Removing all CloudPlatform packages on this machine *****"
		doremove 'cloud-*'
		else
			echo "CloudPlatform is not installed on this machine"
		fi
	fi

	if [ "$remove" == "db" ]; then
		if installed mysql-server || installed MySQL-server-community-5.1.58 || installed MySQL-client-community-5.1.58; then
		echo "***** Removing the MySQL server on this computer *****"
		doremove 'mysql-server'
		else
			echo "mysql-server is not installed on this machine"
		fi
	fi

}

SHORTOPTS="hmabsdlu:r:"
LONGOPTS="help,install-management,install-agent,install-baremetal,install-usage,install-database,install-mysql,upgrade:,remove:"

ARGS=$(getopt -s bash -u -a --options $SHORTOPTS  --longoptions $LONGOPTS --name $0 -- "$@" )

eval set -- "$ARGS"

setuprepo

while [ $# -gt 0 ] ; do
 case "$1" in
  -h | --help)
     usage
     exit 0
     ;;
  -m | --install-management)
     echo "***** Installing the Management Server *****"
	 doinstallauto cloudstack-management
	 true
	 shift
     ;;
  -a | --install-agent)
     echo "***** Installing the Agent *****"
		if doinstallauto cloudstack-agent; then
                        modprobe kvm
                        modprobe kvm_intel > /dev/null 2>&1
                        modprobe kvm_amd > /dev/null 2>&1
                        yum localinstall 6.5/ccp-qemu-img* -y
			echo "Agent installation is completed, please add the host from management server" >&2
		else
			echo "Agent installation failed" >&2
			true
		fi
	shift
     ;;
  -b | --install-baremetal)
     echo "***** Installing the BareMetal Agent *****"
	 doinstallauto cloudstack-baremetal-agent
	 true
     shift
     ;;
  -s | --install-user)
     echo "***** Installing the Usage Server *****"
	 doinstallauto cloudstack-usage
	 true
     shift
     ;;
  -d | --install-database)
     echo "***** Installing the MySQL server *****"
    	 if [[ `cat /etc/redhat-release` =~ "release 7" ]]; then
               mysql_type=mysql-community-server
        	if [[ `curl -s --head -w %{http_code} http://dev.mysql.com/ -o /dev/null` == "200" ]]; then
                   echo "Mysql repo http://dev.mysql.com server exist"
                   rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
        	else
            	   echo "Unable to acccess http://dev.mysql.com/, mysql repo not configured, please configure mysql server repo"
                fi
     	 else
        	mysql_type=mysql-server
         fi

         if doinstallauto $mysql_type ; then
                        #/sbin/chkconfig --add mysqld
			/sbin/chkconfig --level 345 mysqld on
			if /sbin/service mysqld status > /dev/null; then
				echo "Restarting the MySQL server..."
				/sbin/service mysqld restart # mysqld running already, we restart it
			else
				echo "Starting the MySQL server..."
				/sbin/service mysqld start   # we start mysqld for the first time
			fi
		else
			true
		fi
     shift
     ;;
  -u | --upgrade)
     upgrade=$2
	 if [ "$upgrade" == "cdsk" -o "$upgrade" == "cloudstack" ] ; then
		commonUpgrade
	 else
		echo "Error: Incorrect value provided for the CloudPlatform upgrade, please provide proper value, see help ./install.sh --help|h ..."
	 exit 1
	 fi
     shift 2
     ;;
  -r | --remove)
     remove=$2
     if [ "$remove" == "cdsk" -o "$remove" == "cloudstack" -o "$remove" == "db" ] ; then
		commonRemoval
	 else
		echo "Error: Incorrect value provided for the removal , please provide proper value, see help ./install.sh --help|h ..."
	 exit 1
	 fi
     shift 2
     ;;
  --)
     shift
     break
     ;;
  -*)
    echo "Unrecognized option..."
	usage
	exit 1
	;;
   *)
     shift
     break
     ;;
  esac
done


#End of auto detect options

else
    echo "Incorrect choice.  Nothing to do." >&2
	echo "Please, execute just ./install.sh or ./install.sh --help for more help"
fi

echo "Done" >&2
cleanup
