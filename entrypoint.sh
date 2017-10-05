#!/usr/bin/env bash

################################## ENVIRONMENT VARIABLES NEEDED ############################
if [[ -z $MYSQL_ROOT_PASSWORD ]];
then
    echo MYSQL_ROOT_PASSWORD is not set
    exit 1
fi

if [[ -z $MYSQL_HOST ]];
then
    echo MYSQL_HOST is not set
    exit 1
fi

############################################################################################

function create_tables { 
    echo "Creating Database tables"
    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTCATALOG2;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTORDERING;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSPRODUCTINVENTORY;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSPARTYMANAGEMENT;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSBILLINGMANAGEMENT;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSCUSTOMER;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS DSUSAGEMANAGEMENT;"

    mysql -u root --password=$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST -e "CREATE DATABASE IF NOT EXISTS RSS;"
}


function glassfish_related {
    echo "Deploying APIs"
    python /apis-entrypoint.py
}

############################################################################################

export PATH=$PATH:/glassfish4/glassfish/bin
asadmin start-domain



exec 8<>/dev/tcp/$MYSQL_HOST/3306
mysqlStatus=$?
doneTables=1

exec 9<>/dev/tcp/127.0.0.1/4848
glassfishStatus=$?
doneGlassfish=1

if [[ $mysqlStatus -eq 0 ]]; then
    create_tables
    doneTables=0
fi

if [[ $glassfishStatus -eq 0 && $mysqlStatus -eq 0 ]]; then
    glassfish_related
    doneGlassfish=0
fi

i=1

while [[ ($doneTables -ne 0 || $doneGlassfish -ne 0) && $i -lt 50 ]]; do
    echo "Checking deployment status: "
    echo "MySQL databases: $doneTables"
    echo "API deployment: $doneGlassfish"

    sleep 5
    i=$i+1

    if [[ $mysqlStatus -eq 0 && $doneTables -eq 1 ]]; then
        create_tables
        doneTables=0

    elif [[ $mysqlStatus -ne 0 ]]; then
        exec 8<>/dev/tcp/$MYSQL_HOST/3306
        mysqlStatus=$?

    fi

    if [[ $glassfishStatus -eq 0 && $doneGlassfish -eq 1 && $mysqlStatus -eq 0 && $doneTables -eq 0 ]]; then
        glassfish_related
        doneGlassfish=0

    elif [[ $glassfishStatus -ne 0 ]]; then
        exec 9<>/dev/tcp/127.0.0.1/4848
        glassfishStatus=$?
    fi
done

if [[ $i -eq 50 ]];
then
    echo "It has not been possible to start the Business API Ecosystem due to a timeout waiting for a required service"
    echo Conection to MySQL returned $mysqlStatus
    echo Conection to Glassfish returned $glassfishStatus
    exit 1
fi

echo "biz_apis finished successfully."
exec 8>&- # close output connection
exec 8<&- # close input connection

exec 9>&- # close output connection
exec 9<&- # close input connection

while :; do sleep 1000;  done
