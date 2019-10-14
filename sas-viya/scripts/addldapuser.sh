#!/bin/bash

# add user to default openLDAP server
# execute this script from the ansible controller
# invoke to with:
# ./addtestusers.sh newuserid newuserpw adminpw

# to delete a user (change "newuserid" to the userid you want to delete):
# ssh stateful ldapdelete -W -D "cn=admin,dc=sasviya,dc=com" "uid=newuserid,ou=users,dc=sasviya,dc=com"

##### set parms
USER=${1:-testuser}
USERPW=${2:-testuserpw}
ADMINPW=${3:-adminadmin}

TOPUID=$(ssh -o StrictHostKeyChecking=no  services ldapsearch -x -h localhost -b "dc=sasviya,dc=com" | grep uidNumber | cut -f2 -d ' ' | sort -n | tail -n1)
let NEWUID=(TOPUID+1)

#
# add user/set pw
#
cat << EOF > /tmp/adduser.ldif
dn: uid=$USER,ou=users,dc=sasviya,dc=com
cn: $USER
givenName: New
sn: User
objectClass: top
objectClass: inetOrgPerson
objectClass: organizationalPerson
objectClass: posixAccount
loginShell: /bin/bash
uidNumber: $NEWUID
gidNumber: 100001
homeDirectory: /home/$USER
mail: $USER@services
displayName: $USER User
EOF

scp /tmp/adduser.ldif services:/tmp/adduser.ldif
ssh -o StrictHostKeyChecking=no  services ldapadd    -x -h localhost -D "cn=admin,dc=sasviya,dc=com" -w $ADMINPW -f /tmp/adduser.ldif

ssh -o StrictHostKeyChecking=no  services ldappasswd -s $USERPW -x -w $ADMINPW -D "cn=admin,dc=sasviya,dc=com" "uid=$USER,ou=users,dc=sasviya,dc=com"

#
# add user to sasusers group
#
cat << EOF > /tmp/addtogroup.ldif
dn: cn=sasusers,ou=groups,dc=sasviya,dc=com
changetype: modify
add: memberUid
memberUid: $USER
-
add: member
member: uid=$USER,ou=users,dc=sasviya,dc=com
EOF

scp /tmp/addtogroup.ldif services:/tmp/addtogroup.ldif
ssh -o StrictHostKeyChecking=no  services ldapadd -x -h localhost -D "cn=admin,dc=sasviya,dc=com" -w $ADMINPW -f /tmp/addtogroup.ldif


#
# add user home dir on programming  host
#
ssh -o StrictHostKeyChecking=no  services sudo mkdir -p /home/$USER
ssh -o StrictHostKeyChecking=no  services sudo chown $USER:sasusers /home/$USER

      