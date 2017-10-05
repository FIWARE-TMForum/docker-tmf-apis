# Business Ecosystem APIs Docker Image

Starting on version 5.4.0, you are able to run the Business API Ecosystem with Docker. In this context, the current
repository contains the  Docker image with the Business Ecosystem APIs offered by the TMForum. As you may
know, the different Business Ecosystem APIs require a MySQL database to store some information. For this reason, you must create an
additional container to run the database. You can do it automatically with `docker-compose` or manually by following
the given steps.

The current Docker image contains the whole set of TMForum APIs which are required by the Business API Ecosystem GE of FIWARE
in order to work. In particular the following APIs are included:

* Catalog API ([GitHub repo](https://github.com/FIWARE-TMForum/DSPRODUCTCATALOG2))
    * /DSProductCatalog
    
* Ordering API ([GitHub repo](https://github.com/FIWARE-TMForum/DSPRODUCTORDERING))
    * /DSProductOrdering
    
* Inventory API ([GitHub repo](https://github.com/FIWARE-TMForum/DSPRODUCTINVENTORY))
    * /DSProductInventory
    
* Billing API ([GitHub repo](https://github.com/FIWARE-TMForum/DSBILLINGMANAGEMENT))
    * /DSBillingManagement
    
* Party API ([GitHub repo](https://github.com/FIWARE-TMForum/DSPARTYMANAGEMENT))
    * /DSPartyManagement
    
* Customer API ([GitHub repo](https://github.com/FIWARE-TMForum/DSCUSTOMER))
    * /DSCustomerManagement
    
* Usage Management API ([GitHub repo](https://github.com/FIWARE-TMForum/DSUSAGEMANAGEMENT))
    * /DSUsageManagement

## Automatically

You can install the Business Ecosystem APIs automatically if you have `docker-compose` installed in your machine.
To do so, you must create a folder to place a new file file called `docker-compose.yml` that should include the following content:

```
version: '3'

apis_db:
    image: mysql:latest
    ports:
        - "3333:3306"
    volumes:
        - /var/lib/mysql
    environment:
        - MYSQL_ROOT_PASSWORD=my-secret-pw

apis:
    image: conwetlab/biz-ecosystem-apis
    ports:
        - "4848:4848"
        - "8080:8080"
    links:
        - apis_db
    depends_on:
        - apis_db
    environment:
        - MYSQL_ROOT_PASSWORD=my-secret-pw
        - MYSQL_HOST=apis_db

```

**Note**: The provided docker-compose file is using a port schema that can be easily changed modifying the file

Once you have created the file, run the following command for creating the containers:

```
docker-compose up
```

Then, the Business Ecosystem APIs should be up and running in `http://${YOUR_HOST}:${PORT}/${API_PATH}` replacing `YOUR_HOST`
by the host of your machine, `PORT` by the port selected in the previous step, and `API_PATH` by the path of the particular
API you are trying to access (As described in the previous section).

Once the different containers are running, you can stop them using:

```
docker-compose stop
```

And start them again using:

```
docker-compose start
```

Additionally, you can terminate the different containers by executing:

```
docker-compose down
```


## Manually

### 1) Creating a Container to host the Database

The first thing that you have to do is to create a docker container that will host the database used by the Business
Ecosystem APIs. To do so, you can execute the following command:

```
docker run --name apis_db -e MYSQL_ROOT_PASSWORD=my-secret-pw -p PORT:3306 -v /var/lib/mysql -d mysql
```

### 2) Deploying the Business Ecosystem APIs Image

Once that the database is configured, you can deploy the image by running the following command:

```
docker run -e MYSQL_ROOT_PASSWORD=my-secret-pw -e MYSQL_HOST=apis_db -p PORT:8080 --link apis_db conwetlab/biz-ecosystem-apis
```
**Note**: You can change the values of the MySQL connection (database password, and database host), but they must be
same as the used when running the MySQL container. 

Once that you have run these commands, be up and running in `http://${YOUR_HOST}:${PORT}/${API_PATH}` replacing `YOUR_HOST`
by the host of your machine, `PORT` by the port selected in the previous step, and `API_PATH` by the path of the particular
API you are trying to access (As described in the previous section). 
