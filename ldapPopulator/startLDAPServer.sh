#!/bin/bash

# Custom domain
DOMAIN=snykonprem.com

pip3 install -r requirements.txt

#Modify the script if needed additional number of users.
python3 ldap_populator.py --domain $DOMAIN


# DELETE EXISTING CONTAINERS WITH DATA
docker stop openldap
docker rm openldap
docker stop phpldapadmin-service
docker rm phpldapadmin-service

# Change if you want tochange password or organization name
docker run --name openldap -p 389:389 --env LDAP_ORGANISATION="Snyk" --env LDAP_DOMAIN=$DOMAIN --env LDAP_ADMIN_PASSWORD="sismasisma" --detach osixia/openldap:1.3.0
docker run --name phpldapadmin-service -p 9999:443 --hostname phpldapadmin-service --link openldap:ldap-host --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host  --detach osixia/phpldapadmin:0.7.1
sleep 15
docker cp users.ldif 5104d4032cec:/
docker exec openldap ldapadd -x -D "cn=admin,dc=snykonprem,dc=com" -w sismasisma -f /users.ldif
echo -e "Users are:"
cat users.ldif
echo "Connect to LDAP Admin page: https://<DOMAIN>:9999/ or https://localhost:9999"
