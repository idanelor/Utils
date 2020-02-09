#!/bin/bash

usage() {
  echo "Usage: ./$0 -d <DOMAIN_NAME>, -o <Org Name> -p <LDAP Admin Password>"
  echo "Run this script with the appropriate level of permissions of docker."
  echo "For example: sudo ./$0 if docker is installed as root"
  echo "-d | --domain:  Domain such (example.com)"
  echo "-o | --organization-name:  Organization name  (Example)"
  echo "-p | --ldap-admin-password-domain:  LDAP Admin password  (s3cret)"
  echo "-n | --number-of-users: (Optional)  Number of random usrs to populate (10)"
  echo "-h | --help: print this message"
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --domain )
            shift
            DOMAIN="$1"
        ;;
        -o | --organization-name )
            shift
            ORG_NAME="$1"
        ;;
        -p | --ldap-admin-password-domain )
            shift
            LDAP_ADMIN_PASSWORD="$1"
        ;;
        -h | --help )
          shift
          LDAP_ADMIN_PASSWORD="$1"
        ;;
        -n | --number-of-users )
          shift
          NUMBER_OF_USERS="$1"
        ;;
        * )
        usage
        exit 1
    esac
    shift
done

if [[ -z $LDAP_ADMIN_PASSWORD || -z $ORG_NAME || -z $DOMAIN ]]; then
  echo "Missing arguments"
  usage
  exit 2
fi

if [ -z $NUMBER_OF_USERS ]; then
  NUMBER_OF_USERS = 10
fi
ADMIN_DN="cn=admin,dc=snykonprem,dc=com"
pip3 install -r requirements.txt

echo "Using domain name $DOMAIN"
echo "Using Org Name name $ORG_NAME"
echo""

# Populate filled users and groups template
echo "Populating demo .ldif with $NUMBER_OF_USERS users"
python3 ldap_populator.py --domain $DOMAIN --users-count $NUMBER_OF_USERS

# REMOVES EXISTING OPENLDAP ISTANCES(!!!)
echo "Stopping any existing openldap running container!!!!"
docker stop openldap
docker rm openldap
docker stop phpldapadmin-service
docker rm phpldapadmin-service

echo "Starting LDAP service and admin service"
docker run --name openldap -p 389:389 --env LDAP_ORGANISATION="$ORG_NAME" --env LDAP_DOMAIN=$DOMAIN --env LDAP_ADMIN_PASSWORD=$LDAP_ADMIN_PASSWORD --detach osixia/openldap:1.3.0
docker run --name phpldapadmin-service -p 9999:443 --hostname phpldapadmin-service --link openldap:ldap-host --env PHPLDAPADMIN_LDAP_HOSTS=ldap-host  --detach osixia/phpldapadmin:0.7.1
sleep 15
docker cp users.ldif openldap:/
docker exec openldap ldapadd -x -D $ADMIN_DN -w $LDAP_ADMIN_PASSWORD -f /users.ldif
echo -e "Users are: "
cat users.ldif
echo "Password is: <uid>ldappassword"
echo "Admin DN is: $ADMIN_DN"
