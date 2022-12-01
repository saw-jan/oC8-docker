#! /usr/bin/env bash
set -eo pipefail
[[ "${DEBUG}" == "true" ]] && set -x

sed -i "s/%database%/${MYSQL_DATABASE}/" /init.sql
sed -i "s/%user%/${MYSQL_USER}/" /init.sql
sed -i "s/%password%/${MYSQL_PASSWORD}/" /init.sql

/etc/init.d/mysql start --init-file /init.sql

printf "[INFO] waiting for mysql...\n"
while ! curl -o /dev/null -s localhost:3306; do sleep 1; done
printf "[INFO] mysql is ready\n"

php ./occ maintenance:install -vvv \
    --database=mysql \
    --database-name="${MYSQL_DATABASE}" \
    --database-table-prefix=oc_ \
    --admin-user=admin \
    --admin-pass=admin \
    --data-dir=/var/www/html/data \
    --database-host=127.0.0.1 \
    --database-user="${MYSQL_USER}" \
    --database-pass="${MYSQL_PASSWORD}"

printf "[INFO] waiting for owncloud...\n"

# fix permissions
chown -R www-data /var/www/html

apache2-foreground &

while ! curl -o /dev/null -s localhost:80; do sleep 1; done
printf "[INFO] owncloud server is ready\n"

rm /var/www/html/data/owncloud.log
tail -F /var/www/html/data/owncloud.log
