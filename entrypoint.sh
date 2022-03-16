#!/usr/bin/env bash

################################## ENVIRONMENT VARIABLES NEEDED ############################
if [[ -z ${MYSQL_ROOT_PASSWORD} ]];
then
    echo MYSQL_ROOT_PASSWORD is not set
    exit 1
fi

if [[ -z ${MYSQL_HOST} ]];
then
    echo MYSQL_HOST is not set
    exit 1
fi


if [[ -z ${MYSQL_PORT} ]];
then
    echo MYSQL_PORT is not set
    exit 1
fi

if [[ -z ${MYSQL_USER} ]];
then
    echo MYSQL_USER is not set
    exit 1
fi

############################################################################################

function create_tables { 
    echo "Creating Database tables"
    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTCATALOG2;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTORDERING;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTINVENTORY;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSPARTYMANAGEMENT;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSBILLINGMANAGEMENT;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSCUSTOMER;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS DSUSAGEMANAGEMENT;"

    mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "CREATE DATABASE IF NOT EXISTS RSS;"
}


function glassfish_related {
    echo "Deploying APIs"
    python /apis-entrypoint.py
    entrypointStatus=$?
    if [[ ${glassfishStatus} -ne 0 ]]; then
      echo "Was not able to deploy apis."
      exit 1
    fi
}

############################################################################################

export PATH=$PATH:/glassfish4/glassfish/bin
asadmin start-domain

# Test if MySQL is running
mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "SHOW DATABASES;"
mysqlStatus=$?
doneTables=1

# Test if the glassfish server is running
exec 9<>/dev/tcp/127.0.0.1/4848
glassfishStatus=$?
doneGlassfish=1

if [[ ${mysqlStatus} -eq 0 ]]; then
    create_tables
    doneTables=0
fi

if [[ ${glassfishStatus} -eq 0 && ${doneTables} -eq 0 ]]; then
    glassfish_related
    doneGlassfish=0
fi

i=1

while [[ (${doneTables} -ne 0 || ${doneGlassfish} -ne 0) && $i -lt 50 ]]; do
    echo "Checking deployment status: "
    echo "MySQL databases: $doneTables"
    echo "API deployment: $doneGlassfish"

    sleep 5
    i=${i}+1

    if [[ ${mysqlStatus} -eq 0 && ${doneTables} -eq 1 ]]; then
        # MySQL is up and running and tables are not yet created
        create_tables
        doneTables=0

    elif [[ ${mysqlStatus} -ne 0 ]]; then
        # Test if MySQL is now up and running
        mysql -u ${MYSQL_USER} --password=${MYSQL_ROOT_PASSWORD} -h ${MYSQL_HOST} --port ${MYSQL_PORT} -e "SHOW DATABASES;"
        mysqlStatus=$?

    fi

    if [[ ${glassfishStatus} -eq 0 && ${doneGlassfish} -eq 1 && ${mysqlStatus} -eq 0 && ${doneTables} -eq 0 ]]; then
        # MySQL is up, tables are created, glassfish is up and APIs are not deployed
        glassfish_related
        doneGlassfish=0

    elif [[ ${glassfishStatus} -ne 0 ]]; then
        # Test if glassfish is now deployed
        exec 9<>/dev/tcp/127.0.0.1/4848
        glassfishStatus=$?
    fi
done

if [[ $i -eq 50 ]];
then
    echo "It has not been possible to start the Business API Ecosystem due to a timeout waiting for a required service"
    echo Conection to MySQL returned ${mysqlStatus}
    echo Conection to Glassfish returned ${glassfishStatus}
    exit 1
fi

echo "biz_apis finished successfully."
exec 8>&- # close output connection
exec 8<&- # close input connection

exec 9>&- # close output connection
exec 9<&- # close input connection

while :; do sleep 1000;  done
