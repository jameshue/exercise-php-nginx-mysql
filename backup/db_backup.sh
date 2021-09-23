#!/bin/bash

# Cronjob example.
# * * * * *    /bin/bash /path/to/db_backup.sh >> /var/log/db-cron.log
# * 1 * * *    /bin/bash /path/to/db_backup.sh >> /var/log/db-cron.log 		(Cron job every day at 1am is a commonly used cron schedule.)


# Get current date.
now=mysql-$(date +"%Y-%m-%d-%H")-all_db.sql.gz

# Backup database.
source ../.env.db
docker exec -i $(docker ps -qf name=webapp-db) bash -c 'mysqldump --default-character-set=utf8mb4 -u root -p${MYSQL_PASSWORD} --all-databases 2>/dev/null' |gzip -c > ./db/${now}
#docker exec -i $(docker ps -qf name=webapp-db) bash -c 'mysqldump --default-character-set=utf8mb4 -u${MYSQL_USER} -p${MYSQL_PASSWORD} ${MYSQL_DATABASE} --all-databases 2>/dev/null' |gzip -c > ./db/${now}
befor=mysql-$(date +"%Y-%m-%d-%H" --date="-11 day")-all_db.sql.gz
rm -fR ./db/$befor
