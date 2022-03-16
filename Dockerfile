FROM ubuntu:16.04 as build

ENV API_VERSION develop

RUN apt-get update; \
    apt-get install -y --fix-missing python2.7 net-tools python-pip git wget unzip maven mysql-client openjdk-8-jdk; \
    pip install sh; \
    wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz; \
    tar -xvf mysql-connector-java-5.1.39.tar.gz; \
    cp ./mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar glassfish4/glassfish/domains/domain1/lib; \
    mkdir /apis; \
    mkdir -p /etc/default/tmf/

WORKDIR /apis

RUN mkdir wars; \
git clone https://github.com/FIWARE-TMForum/DSPRODUCTCATALOG2.git

WORKDIR DSPRODUCTCATALOG2

RUN git checkout $API_VERSION; \
    sed -i 's/jdbc\/sample/jdbc\/pcatv2/g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
    grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
    mvn install; \
    mv ./target/DSProductCatalog.war ../wars/;

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPRODUCTORDERING.git

WORKDIR DSPRODUCTORDERING

RUN git checkout $API_VERSION; \
    sed -i 's/jdbc\/sample/jdbc\/podbv2/g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    if [ -f "./src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./src/main/java/org/tmf/dsmapi/settings.properties ./src/main/resources/settings.properties; fi; \
    grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
    mvn install; \
    mv ./target/DSProductOrdering.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPRODUCTINVENTORY.git

WORKDIR DSPRODUCTINVENTORY

RUN git checkout $API_VERSION; \
sed -i 's/jdbc\/sample/jdbc\/pidbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSProductInventory.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSPARTYMANAGEMENT.git

WORKDIR DSPARTYMANAGEMENT

RUN git checkout $API_VERSION; \
sed -i 's/jdbc\/sample/jdbc\/partydb/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSPartyManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSBILLINGMANAGEMENT.git

WORKDIR DSBILLINGMANAGEMENT

RUN git checkout $API_VERSION; \
sed -i 's/jdbc\/sample/jdbc\/bmdbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSBillingManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSCUSTOMER.git

WORKDIR DSCUSTOMER

RUN git checkout $API_VERSION; \
sed -i 's/jdbc\/sample/jdbc\/customerdbv2/g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
mvn install; \
mv ./target/DSCustomerManagement.war ../wars/

WORKDIR ../

# Next api Docker
RUN git clone https://github.com/FIWARE-TMForum/DSUSAGEMANAGEMENT.git

WORKDIR DSUSAGEMANAGEMENT

RUN git checkout $API_VERSION; \
    sed -i 's/jdbc\/sample/jdbc\/usagedbv2/g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<provider>org\.eclipse\.persistence\.jpa\.PersistenceProvider<\/provider>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.ddl-generation" value="drop-and-create-tables"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    sed -i 's/<property name="eclipselink\.logging\.level" value="FINE"\/>/ /g' ./src/main/resources/META-INF/persistence.xml; \
    if [ -f "./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties" ]; then mv ./DSPRODUCTORDERING/src/main/java/org/tmf/dsmapi/settings.properties ./DSPRODUCTORDERING/src/main/resources/settings.properties; fi; \
    grep -F "<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"/>" ./src/main/resources/META-INF/persistence.xml || sed -i 's/<\/properties>/\t<property name=\"javax.persistence.schema-generation.database.action\" value=\"create\"\/>\n\t\t<\/properties>/g' ./src/main/resources/META-INF/persistence.xml; \
    mvn install; \
    mv ./target/DSUsageManagement.war ../wars/

FROM glassfish:4.1-jdk8

ENV MYSQL_ROOT_PASSWORD=root
ENV MYSQL_USER=root
ENV MYSQL_HOST=172.17.0.2
ENV MYSQL_PORT=3306

COPY --from=build /apis/wars/ /apis/wars/
COPY ./entrypoint.sh /entrypoint.sh
COPY ./apis-entrypoint.py /apis-entrypoint.py

RUN apt-get update; \
    apt-get install -y --fix-missing mysql-client python-pip wget;
RUN pip install sh;
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz; \
    tar -xvf mysql-connector-java-5.1.39.tar.gz; \
    cp ./mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar /usr/local/glassfish4/glassfish/domains/domain1/lib;

# allow a user !=root to start glassfish
RUN chmod -R a+rw /usr/local/glassfish4

# never run as root
USER 1001

ENTRYPOINT ["/entrypoint.sh"]

