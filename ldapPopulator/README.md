# ldapPopulator
## A tool leveraging faker to generate a fake records to be imported in ldap
1. Copy the file to your ldap server
2. In your LDAP server run
```
ldapadd -x -D cn=admin,dc=example,dc=com -W -f users.ldif
```