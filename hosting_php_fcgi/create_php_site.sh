#!/bin/bash
# @author: Seb Dangerfield
# http://www.sebdangerfield.me.uk/?p=513 
# Created:   11/08/2011
# Modified:   07/01/2012
# Modified:   27/11/2012

# Modify the following to match your system
NGINX_CONFIG='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
PHP_INI_DIR='/etc/php/7.0/fpm/pool.d'
WEB_SERVER_GROUP='www-data'
NGINX_INIT='/etc/init.d/nginx'
PHP_FPM_INIT='/etc/init.d/php7.0-fpm'
# --------------END 
SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
	echo "No domain name given"
	exit 1
fi
DOMAIN=$1

# check the domain is valid!
PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating hosting for:" $DOMAIN
else
	echo "invalid domain name"
	exit 1 
fi

# Create a new user!
echo "Please specify the username for this site?"
read USERNAME
HOME_DIR=$USERNAME
sudo adduser $USERNAME
# -------
# CentOS:
# If you're using CentOS you will need to uncomment the next 3 lines!
# -------
#echo "Please enter a password for the user: $USERNAME"
#read -s PASS
#echo $PASS | passwd --stdin $USERNAME

echo "Would you like to change to web root directory (y/n)?"
read CHANGEROOT
if [ $CHANGEROOT == "y" ]; then
	echo "Enter the new web root dir (after the public_html/)"
	read DIR
	PUBLIC_HTML_DIR='/public_html/'$DIR
else
	PUBLIC_HTML_DIR='/public_html'
fi

# Now we need to copy the virtual host template
CONFIG=$NGINX_CONFIG/$DOMAIN.conf
MYLOGPATH="/var/log/nginx/${DOMAIN}_"
sudo cp $CURRENT_DIR/nginx.vhost.conf.template $CONFIG
sudo $SED -i "s/@@HOSTNAME@@/$DOMAIN/g" $CONFIG
sudo $SED -i "s#@@PATH@@#\/home\/"$USERNAME$PUBLIC_HTML_DIR"#g" $CONFIG
sudo $SED -i "s#@@LOG_PATH@@#${MYLOGPATH}#g" $CONFIG
sudo $SED -i "s#@@SOCKET@@#/var/run/"$USERNAME"_fpm.sock#g" $CONFIG

echo "How many FPM servers would you like by default: (Use 3)"
read FPM_SERVERS
echo "Min number of FPM servers would you like: (Use 2)"
read MIN_SERVERS
echo "Max number of FPM servers would you like: (Use 10)"
read MAX_SERVERS
# Now we need to create a new php fpm pool config
FPMCONF="$PHP_INI_DIR/$DOMAIN.pool.conf"

sudo cp $CURRENT_DIR/pool.conf.template $FPMCONF

sudo $SED -i "s/@@USER@@/$USERNAME/g" $FPMCONF
sudo $SED -i "s/@@HOME_DIR@@/\/home\/$USERNAME/g" $FPMCONF
sudo $SED -i "s/@@START_SERVERS@@/$FPM_SERVERS/g" $FPMCONF
sudo $SED -i "s/@@MIN_SERVERS@@/$MIN_SERVERS/g" $FPMCONF
sudo $SED -i "s/@@MAX_SERVERS@@/$MAX_SERVERS/g" $FPMCONF
MAX_CHILDS=$((MAX_SERVERS+START_SERVERS))
sudo $SED -i "s/@@MAX_CHILDS@@/$MAX_CHILDS/g" $FPMCONF

sudo usermod -aG $USERNAME $WEB_SERVER_GROUP
sudo chmod g+rx /home/$HOME_DIR
sudo chmod 600 $CONFIG

sudo ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf

# set file perms and create required dirs!
sudo mkdir -p /home/$HOME_DIR$PUBLIC_HTML_DIR
sudo mkdir /home/$HOME_DIR/_sessions
sudo chmod 750 /home/$HOME_DIR -R
sudo chmod 700 /home/$HOME_DIR/_sessions
sudo chmod 750 /home/$HOME_DIR$PUBLIC_HTML_DIR
sudo chown $USERNAME:$WEB_SERVER_GROUP /home/$HOME_DIR/ -R

sudo $NGINX_INIT reload
sudo $PHP_FPM_INIT restart

echo -e "\nSite Created for $DOMAIN with PHP support"

