#!/bin/sh -xv
#Script to import sql data into mysql container when running locally with docker-compose
#Not for use in kubernetes or production

#Wait 15 seconds for mysql container to come up
sleep 15

#Import sql into mysql container with defaults
echo "Importing database..."
mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE} < /tmp/database.sql

#Run flask app
python hardware.py
