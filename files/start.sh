#!/bin/bash
VOLUME=/volume
BASE=$VOLUME/shopware
MYSQL=$VOLUME/mysql

if [ ! -d $VOLUME ]
then
   echo MISSING VOLUME. Please start container with mounted $VOLUME directory!
   exit 1;
fi

sed --in-place "s!datadir.*=.*/var/lib/mysql!datadir         = $MYSQL!" /etc/mysql/my.cnf
sed --in-place "s#^key_buffer[^_]#key_buffer_size #" /etc/mysql/my.cnf

if [ ! -d $BASE ]
then
   mkdir -p $BASE/
   unzip -q /tmp/shopware_4.3.0.zip -d $BASE/
fi

if [ ! -f $VOLUME/phpmyadmin-htpasswd.txt ]
then
   pwgen -B -A 16 1 > $VOLUME/phpmyadmin-htpasswd.txt
fi
if [ -f /etc/apache2/phpmyadmin.htpasswd ]
then
  HTPASSWD_OPTS=-Bbi
else
  HTPASSWD_OPTS=-cBbi
fi
htpasswd $HTPASSWD_OPTS /etc/apache2/phpmyadmin.htpasswd phpmyadmin < $VOLUME/phpmyadmin-htpasswd.txt



chown -R www-data:www-data $BASE
chmod -R 755 $BASE

if [[ ! -d $MYSQL ]]; then
  mkdir -p $MYSQL
  echo "An empty or uninitialized MySQL volume was detected in $VOLUME/mysql"
  echo "Installing MySQL defaults..."
  if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
    cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
  fi
  mysql_install_db
  echo "Done."
  /usr/bin/mysqld_safe > /dev/null 2>&1 &
  /usr/bin/mysql_secure_installation
  killall mysqld
  sleep 5
else
  echo "Existing volume for MySQL found."
fi

supervisord -n -c /etc/supervisord.conf -e debug

