#!/bin/sh

if [ ! -z "$no_install" ]; then
	echo "Executing PrestaShop without installation ...";
else
	if [ "$db_password" == "" ]; then
		mysqladmin -h $DB_SERVER -u $DB_USER drop $DB_NAME --force >2 /dev/null;
		mysqladmin -h $DB_SERVER -u $DB_USER create $DB_NAME --force >2 /dev/null;
	else
		mysqladmin -h $DB_SERVER -u $DB_USER -p$DB_PASSWD drop $DB_NAME --force >2 /dev/null;
		mysqladmin -h $DB_SERVER -u $DB_USER -p$DB_PASSWD create $DB_NAME --force >2 /dev/null;
	fi

	php /var/www/html/install-dev/index_cli.php --domain=$(hostname -i) --db_server=$DB_SERVER --db_name="$DB_NAME" --db_user=$DB_USER \
		--db_password=$DB_PASSWD --firstname="John" --lastname="Doe" \
		--password=$ADMIN_PASSWD --email="$ADMIN_MAIL" --newsletter=0 --send_email=0
fi

if [ ! -z "$dev_mode" ]; then
	#echo "Set DEV MODE > true";
	sed -ie "s/define('_PS_MODE_DEV_', false);/define('_PS_MODE_DEV_',\ true);/g" /var/www/html/config/defines.inc.php
fi

if [ ! -z "$host_mode" ]; then
	#echo "Set HOST MODE > true";
	echo "define('_PS_HOST_MODE_', true);" >> /var/www/html/config/defines.inc.php
fi

/usr/sbin/apache2ctl -D FOREGROUND
